import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import '../../config/database/app_database.dart';
import '../../features/ai/data/models/llm_config.dart';
import '../../features/ai/data/storage/agent_config_storage.dart';
import '../../features/ai/data/storage/persona_storage.dart';
import '../../features/ai/data/storage/provider_storage.dart';
import '../../features/ai/data/repository/chat_history_repository.dart';
import '../../features/ai/data/repository/memory_repository.dart';
import '../../features/ai/data/repository/memory_extraction_queue.dart';
import '../../features/ai/data/models/ai_persona.dart';
import '../../features/ai/domain/agent_runner.dart';
import '../../features/vision_ai/data/services/image_recognition_service.dart';
import '../../features/ai/domain/repositories/llm_repository.dart';
import '../media/media_storage_service.dart';
import 'voice_transcription_orchestrator.dart';
import 'package:wo_account/l10n/app_localizations.dart';

/// 输入源类型
enum InputSource {
  text('文本', '📝'),
  voice('语音', '🎤'),
  image('图片', '📷');

  final String label;
  final String emoji;
  const InputSource(this.label, this.emoji);

  /// Returns the localized label for this input source.
  String getLocalizedLabel(AppLocalizations l10n) {
    switch (this) {
      case InputSource.text:
        return l10n.inputSourceText;
      case InputSource.voice:
        return l10n.inputSourceVoice;
      case InputSource.image:
        return l10n.inputSourceImage;
    }
  }
}

/// 统一记账管线结果
class PipelineResult {
  /// 归一化后的文本（语音转写文本 / 图片识别文本 / 原始文本）
  final String normalizedText;

  /// AI 解析出的交易列表
  final List<TransactionParseResult> transactions;

  /// 输入来源
  final InputSource source;

  /// 保存后的媒体文件路径（语音/图片输入时有值）
  final String? mediaFilePath;

  /// AI 对非记账输入的回复（如"你叫什么"时 AI 的友好回复）
  /// 当此字段非空时，transactions 为空，UI 应显示此文本作为 AI 回复
  final String? nonTransactionResponse;

  /// 是否为流式回复（角色对话场景下为 true，UI 应使用流式渲染）
  final bool isStreamed;

  const PipelineResult({
    required this.normalizedText,
    required this.transactions,
    required this.source,
    this.mediaFilePath,
    this.nonTransactionResponse,
    this.isStreamed = false,
  });
}

/// 统一记账管线
///
/// 所有输入（文本/语音/图片）都通过此管线处理：
/// 1. 语音 → 录制音频 → 语音模型转文字 → AI 记账解析
/// 2. 图片 → 拍照/选图 → 视觉模型识别 → AI 记账解析
/// 3. 文本 → 直接 AI 记账解析
///
/// 最终统一产出 PipelineResult（包含 TransactionParseResult 列表）。
///
/// 增强特性：
/// - RAG：检索相似历史交易注入 prompt
/// - Episodic Memory：注入用户修正过的分类记录
/// - Tool Use：检测引用型输入（"跟上次一样"）并预取历史数据
class TransactionPipeline {
  final LlmRepository _llmRepo;
  final ImageRecognitionService _imageService;
  final MediaStorageService _mediaStorage;
  final AppDatabase _db;
  final AgentRunner? _agentRunner;
  final ChatHistoryRepository? _chatHistoryRepo;
  final MemoryRepository? _memoryRepo;
  final MemoryExtractionQueue? _extractionQueue;

  /// 临时存储非记账回复（_parseAgentResult 设置，processText 读取后清空）
  String? _pendingNonTransactionResponse;

  TransactionPipeline({
    required LlmRepository llmRepo,
    required ImageRecognitionService imageService,
    required MediaStorageService mediaStorage,
    required AppDatabase db,
    AgentRunner? agentRunner,
    ChatHistoryRepository? chatHistoryRepo,
    MemoryRepository? memoryRepo,
    MemoryExtractionQueue? extractionQueue,
  })  : _llmRepo = llmRepo,
        _imageService = imageService,
        _mediaStorage = mediaStorage,
        _db = db,
        _agentRunner = agentRunner,
        _chatHistoryRepo = chatHistoryRepo,
        _memoryRepo = memoryRepo,
        _extractionQueue = extractionQueue;

  /// 流式事件：角色对话的文本片段
  /// UI 接收到 [PipelineStreamEvent.delta] 后追加显示，[PipelineStreamEvent.done] 时持久化
  Stream<PipelineStreamEvent> processTextStream(
    String text, {
    String? categoryTaxonomy,
    String locale = 'zh',
    int? bookId,
    String? conversationId,
  }) async* {
    // 先用 AgentRunner 解析是否为记账
    String? nonTxResponse;
    List<TransactionParseResult> parsed = [];
    try {
      if (_agentRunner != null) {
        final result = await _agentRunner.run(
          'transaction_parser',
          text,
          extraParams: {
            if (categoryTaxonomy != null) 'categoryTaxonomy': categoryTaxonomy,
            'locale': locale,
            if (bookId != null) 'bookId': bookId,
          },
        );
        parsed = _parseAgentResult(result.content);
        nonTxResponse = _pendingNonTransactionResponse;
        _pendingNonTransactionResponse = null;
      }
    } catch (e) {
      if (e is LlmException && e.errorCode == 'llmErrorNonTransaction') {
        nonTxResponse = e.data as String? ?? e.message;
      } else if (e is LlmException && e.errorCode == 'agentNotConfigured') {
        // 回退到旧路径
      } else {
        rethrow;
      }
    }

    // 记账输入：直接返回结果（非流式，UI 显示确认卡片）
    if (parsed.isNotEmpty) {
      yield PipelineStreamEvent.done(PipelineResult(
        normalizedText: text,
        transactions: parsed,
        source: InputSource.text,
      ));
      return;
    }

    // 非记账输入：先检查角色
    if (_chatHistoryRepo == null || _memoryRepo == null) {
      yield PipelineStreamEvent.done(PipelineResult(
        normalizedText: text,
        transactions: const [],
        source: InputSource.text,
        nonTransactionResponse: nonTxResponse,
      ));
      return;
    }

    final activePersona = await PersonaStorage.getActive();
    if (activePersona == null) {
      yield PipelineStreamEvent.done(PipelineResult(
        normalizedText: text,
        transactions: const [],
        source: InputSource.text,
        nonTransactionResponse: nonTxResponse,
      ));
      return;
    }

    // 有角色：流式调用 LLM
    try {
      final provider = await _resolvePersonaProvider();
      final historyEntities = await _chatHistoryRepo.getRecentMessages(
        personaId: activePersona.id,
        conversationId: conversationId,
        limit: 6,
      );
      final historyMessages = historyEntities.map((e) =>
        ChatMessage(role: e.role, content: e.content),
      ).toList();
      final enhancedPrompt = await _buildEnhancedPersonaPrompt(
        activePersona, historyMessages, text,
      );

      final fullBuffer = StringBuffer();
      await for (final chunk in _llmRepo.chatStream(
        LlmRequest(messages: [
          ChatMessage(role: 'system', content: enhancedPrompt),
          ...historyMessages,
          ChatMessage(role: 'user', content: text),
        ]),
        provider: provider,
      )) {
        fullBuffer.write(chunk);
        yield PipelineStreamEvent.delta(chunk);
      }

      final fullContent = fullBuffer.toString();

      // 持久化消息（带 conversationId 隔离）
      await _chatHistoryRepo.addMessages([
        ChatMessagesCompanion.insert(
          personaId: Value(activePersona.id),
          conversationId: Value(conversationId),
          role: 'user',
          content: text,
        ),
        ChatMessagesCompanion.insert(
          personaId: Value(activePersona.id),
          conversationId: Value(conversationId),
          role: 'assistant',
          content: fullContent,
        ),
      ]);

      // 异步入队记忆提取
      _extractionQueue?.enqueue(
        activePersona.id,
        text,
        fullContent,
      );

      yield PipelineStreamEvent.done(PipelineResult(
        normalizedText: text,
        transactions: const [],
        source: InputSource.text,
        nonTransactionResponse: fullContent,
        isStreamed: true,
      ));
    } catch (e) {
      // 流式失败，回退到原始响应
      yield PipelineStreamEvent.done(PipelineResult(
        normalizedText: text,
        transactions: const [],
        source: InputSource.text,
        nonTransactionResponse: nonTxResponse,
      ));
    }
  }

  /// 处理文本输入（非流式，兼容旧调用方）
  Future<PipelineResult> processText(
    String text, {
    String? categoryTaxonomy,
    String locale = 'zh',
    int? bookId,
    String? conversationId,
  }) async {
    // 优先使用 AgentRunner（v2.0）
    if (_agentRunner != null) {
      try {
        final agentRunner = _agentRunner;
        final result = await agentRunner.run(
          'transaction_parser',
          text,
          extraParams: {
            if (categoryTaxonomy != null) 'categoryTaxonomy': categoryTaxonomy,
            'locale': locale,
            if (bookId != null) 'bookId': bookId,
          },
        );
        var parsed = _parseAgentResult(result.content);
        var nonTxResponse = _pendingNonTransactionResponse;
        _pendingNonTransactionResponse = null;

        // [v1.2] 非记账 → 检查角色
        if (parsed.isEmpty) {
          final personaResult = await _handlePersonaResponse(text, nonTxResponse ?? '', conversationId: conversationId);
          if (personaResult != null) {
            parsed = personaResult.transactions;
            nonTxResponse = personaResult.nonTransactionResponse;
          } else if (nonTxResponse == null) {
            // 角色调用失败且无原始响应时，返回友好提示
            nonTxResponse = '嗯？有什么需要帮忙的吗？';
          }
        }

        return PipelineResult(
          normalizedText: text,
          transactions: parsed,
          source: InputSource.text,
          nonTransactionResponse: nonTxResponse,
        );
      } catch (e) {
        // AgentRunner 失败，回退到旧逻辑
        if (e is LlmException && e.errorCode == 'agentNotConfigured') {
          // Agent 未配置，使用旧路径
          assert(() { print('[Pipeline] AgentRunner: agentNotConfigured, falling back'); return true; }());
        } else {
          assert(() { print('[Pipeline] AgentRunner error: $e'); return true; }());
          rethrow;
        }
      }
    }

    // 旧路径（兼容 AgentRunner 不可用时）
    // [Tool Use] 检测引用型输入，预取历史数据
    final resolvedText = await _resolveReference(text, bookId);

    // [RAG + Episodic Memory] 构建增强上下文
    final context = await _buildEnrichedContext(resolvedText, bookId);

    // 解析 text 能力对应的 provider
    LlmProvider? provider = await LlmConfigManager.resolveProviderForCapability(
      ModelCapability.text,
    );

    // v2 回退：旧 LlmConfigManager 无数据时，从 ProviderStorage 获取
    if (provider == null || !provider.isComplete) {
      final agentConfig = await AgentConfigStorage.load('transaction_parser');
      if (agentConfig != null && agentConfig.providerId.isNotEmpty && agentConfig.modelName.isNotEmpty) {
        final aiProvider = await ProviderStorage.getById(agentConfig.providerId);
        if (aiProvider != null && aiProvider.isReady) {
          provider = LlmProvider(
            id: aiProvider.id,
            name: aiProvider.name,
            apiKey: aiProvider.apiKey,
            baseUrl: aiProvider.baseUrl,
            temperature: aiProvider.temperature,
            maxTokens: aiProvider.maxTokens,
            timeoutSeconds: aiProvider.timeoutSeconds,
            providerKey: aiProvider.providerKey ?? 'custom',
            models: {'text': ModelConfig(modelName: agentConfig.modelName)},
          );
        }
      }
    }

    // 仍然没有 provider，尝试用任意可用的 v2 provider
    if (provider == null || !provider.isComplete) {
      final v2Providers = await ProviderStorage.loadAll();
      final ready = v2Providers.where((p) => p.isReady).toList();
      if (ready.isNotEmpty) {
        final p = ready.first;
        provider = LlmProvider(
          id: p.id,
          name: p.name,
          apiKey: p.apiKey,
          baseUrl: p.baseUrl,
          temperature: p.temperature,
          maxTokens: p.maxTokens,
          timeoutSeconds: p.timeoutSeconds,
          providerKey: p.providerKey ?? 'custom',
          models: {},
        );
      }
    }

    try {
      final results = await _llmRepo.parseTransaction(
        resolvedText,
        provider: provider,
        categoryTaxonomy: categoryTaxonomy,
        locale: locale,
        fewShotExamples: context.fewShotExamples,
        similarTransactions: context.similarTransactions,
      );
      return PipelineResult(
        normalizedText: text,
        transactions: results,
        source: InputSource.text,
      );
    } on LlmException catch (e) {
      if (e.errorCode == 'llmErrorNonTransaction') {
        // [v1.2] 角色记忆：检查有角色时用角色回复覆盖原始响应
        final personaResult = await _handlePersonaResponse(text, e.data as String? ?? e.message, conversationId: conversationId);
        if (personaResult != null) return personaResult;

        // 无角色或失败，返回原始响应
        return PipelineResult(
          normalizedText: text,
          transactions: const [],
          source: InputSource.text,
          nonTransactionResponse: e.data as String? ?? e.message,
        );
      }
      rethrow;
    }
  }

  /// 处理双引擎语音转写结果
  ///
  /// 双引擎有差异时构建交叉校验 prompt，LLM 一次调用完成校验+解析。
  /// 单引擎或一致时直接用合并文本解析。
  Future<PipelineResult> processVoiceResult({
    required DualTranscriptionResult transcription,
    String? categoryTaxonomy,
    String locale = 'zh',
    int? bookId,
  }) async {
    // 构建输入文本
    String inputForLlm;

    if (transcription.engineCount >= 2 && !transcription.isIdentical) {
      // 双引擎有差异 → 交叉校验 prompt
      inputForLlm = _buildCrossValidationPrompt(
        transcription.platformText!,
        transcription.whisperText!,
      );
    } else {
      // 单引擎或双引擎一致 → 直接用合并文本
      inputForLlm = transcription.mergedText;
    }

    if (inputForLlm.trim().isEmpty) {
      throw const LlmException(
        '语音识别结果为空，请重新录制',
        errorCode: 'pipelineErrorEmptyVoiceResult',
      );
    }

    // [Tool Use] 引用检测 + [RAG + Episodic Memory] 上下文构建
    final resolvedText = await _resolveReference(inputForLlm, bookId);
    final context = await _buildEnrichedContext(resolvedText, bookId);

    // 解析 text 能力对应的 provider
    final provider = await LlmConfigManager.resolveProviderForCapability(
      ModelCapability.text,
    );

    // 用文本走 AI 记账解析（带增强上下文）
    final results = await _llmRepo.parseTransaction(
      resolvedText,
      provider: provider,
      categoryTaxonomy: categoryTaxonomy,
      locale: locale,
      fewShotExamples: context.fewShotExamples,
      similarTransactions: context.similarTransactions,
    );

    return PipelineResult(
      normalizedText: transcription.mergedText,
      transactions: results,
      source: InputSource.voice,
      mediaFilePath: transcription.audioPath,
    );
  }

  /// 构建双引擎交叉校验 prompt
  String _buildCrossValidationPrompt(String platformText, String whisperText) {
    return '## 语音识别交叉校验\n'
        '以下文字由两个不同的语音识别引擎转写，可能存在差异。'
        '请综合两段文本，判断用户的实际意图，然后解析为记账信息。\n\n'
        '引擎A（设备原生）：「$platformText」\n'
        '引擎B（云端Whisper）：「$whisperText」\n\n'
        '请先判断最可能的正确文本，再提取记账信息。';
  }

  /// 处理图片输入
  ///
  /// [imageTempPath] 图片临时文件路径
  Future<PipelineResult> processImage({
    required String imageTempPath,
    String? categoryTaxonomy,
    String locale = 'zh',
    int? bookId,
  }) async {
    // 解析 vision 能力对应的 provider
    final provider = await LlmConfigManager.resolveProviderForCapability(
      ModelCapability.vision,
    );
    if (provider == null || !provider.isComplete) {
      throw const LlmException('No vision provider configured', errorCode: 'llmErrorNoProviderOrInput');
    }

    // 1. 保存图片到永久存储
    final savedPath = await _mediaStorage.saveImageFile(imageTempPath);

    // 2. 视觉模型识别图片内容
    final recognizedText = await _imageService.recognize(
      provider,
      savedPath,
    );

    if (recognizedText.trim().isEmpty) {
      throw const LlmException('图片识别结果为空，请选择更清晰的图片', errorCode: 'pipelineErrorEmptyImageResult');
    }

    // 解析 text 能力对应的 provider（可能与 vision 不同）
    final textProvider = await LlmConfigManager.resolveProviderForCapability(
      ModelCapability.text,
    );

    // 3. 用识别文本走 AI 记账解析
    final results = await _llmRepo.parseTransaction(
      recognizedText,
      provider: textProvider,
      categoryTaxonomy: categoryTaxonomy,
      locale: locale,
    );

    return PipelineResult(
      normalizedText: recognizedText,
      transactions: results,
      source: InputSource.image,
      mediaFilePath: savedPath,
    );
  }

  // ==================== Tool Use：引用型输入检测与解析 ====================

  /// 检测并解析引用型输入（如"跟上次一样"、"和昨天一样"）
  ///
  /// 如果检测到引用，从数据库中查找最近一笔交易，将引用替换为具体描述。
  /// 如果未检测到引用，原样返回输入文本。
  Future<String> _resolveReference(String input, int? bookId) async {
    if (bookId == null) return input;

    // 检测引用关键词
    final referencePatterns = [
      _ReferencePattern('跟上次一样', _ReferenceType.lastTransaction),
      _ReferencePattern('跟上笔一样', _ReferenceType.lastTransaction),
      _ReferencePattern('和上次一样', _ReferenceType.lastTransaction),
      _ReferencePattern('同上次', _ReferenceType.lastTransaction),
      _ReferencePattern('同上', _ReferenceType.lastTransaction),
      _ReferencePattern('一样的', _ReferenceType.lastTransaction),
      _ReferencePattern('same as last', _ReferenceType.lastTransaction),
      _ReferencePattern('跟昨天一样', _ReferenceType.sameDayYesterday),
      _ReferencePattern('和昨天一样', _ReferenceType.sameDayYesterday),
      _ReferencePattern('like yesterday', _ReferenceType.sameDayYesterday),
    ];

    _ReferencePattern? matched;
    for (final p in referencePatterns) {
      if (input.contains(p.keyword)) {
        matched = p;
        break;
      }
    }
    if (matched == null) return input;

    try {
      Transaction? referenced;

      switch (matched.type) {
        case _ReferenceType.lastTransaction:
          // 获取最近一笔交易
          final recent = await (_db.select(_db.transactions)
                ..where((t) => t.accountBookId.equals(bookId) & t.isDeleted.equals(false))
                ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
                ..limit(1))
              .get();
          if (recent.isNotEmpty) referenced = recent.first;
          break;

        case _ReferenceType.sameDayYesterday:
          // 获取昨天的最后一笔交易
          final now = DateTime.now();
          final yesterday = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
          final dayEnd = yesterday.add(const Duration(days: 1));
          final recent = await (_db.select(_db.transactions)
                ..where((t) =>
                    t.accountBookId.equals(bookId) &
                    t.isDeleted.equals(false) &
                    t.transactionDate.isBetweenValues(yesterday, dayEnd))
                ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
                ..limit(1))
              .get();
          if (recent.isNotEmpty) referenced = recent.first;
          break;
      }

      if (referenced == null) return input;

      // 获取分类名称（用于更精确的描述）
      final cat = await (_db.select(_db.categories)
            ..where((t) => t.id.equals(referenced!.categoryId)))
          .getSingleOrNull();
      final catName = cat?.name ?? '';

      // 构建替换文本：将"跟上次一样"替换为具体描述
      final detail = catName.isNotEmpty
          ? '${referenced.description} ${referenced.amount}元 ($catName)'
          : '${referenced.description} ${referenced.amount}元';
      return input.replaceAll(matched.keyword, detail);
    } catch (_) {
      // 查找失败时原样返回，让 LLM 自行处理
      return input;
    }
  }

  // ==================== RAG + Episodic Memory：增强上下文构建 ====================

  /// 构建增强上下文（RAG 相似交易 + Episodic Memory 修正记录）
  Future<_EnrichedContext> _buildEnrichedContext(String input, int? bookId) async {
    if (bookId == null) return const _EnrichedContext();

    // 并行查询相似交易和修正记录
    final results = await Future.wait([
      _retrieveSimilarTransactions(input, bookId),
      _retrieveFewShotCorrections(bookId),
    ]);

    return _EnrichedContext(
      similarTransactions: results[0],
      fewShotExamples: results[1],
    );
  }

  /// RAG：检索相似历史交易
  ///
  /// 从输入文本中提取关键词，搜索历史交易中匹配的记录。
  /// 返回格式化的交易列表文本，用于注入 prompt。
  Future<String?> _retrieveSimilarTransactions(String input, int bookId) async {
    try {
      // 提取关键词：按空格/标点分割，过滤短词和纯数字
      final keywords = _extractKeywords(input);
      if (keywords.isEmpty) return null;

      // 用前 3 个关键词做 LIKE 搜索
      final searchKeywords = keywords.take(3).toList();
      Expression<bool>? condition;
      for (final kw in searchKeywords) {
        final kwCondition = _db.transactions.description.like('%$kw%') |
            _db.transactions.note.like('%$kw%') |
            _db.transactions.originalInput.like('%$kw%');
        condition = condition == null ? kwCondition : condition | kwCondition;
      }

      final recent = await (_db.select(_db.transactions)
            ..where((t) =>
                t.accountBookId.equals(bookId) &
                t.isDeleted.equals(false) &
                condition!)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(3))
          .get();

      if (recent.isEmpty) return null;

      // 批量获取分类名称（避免 N+1 查询）
      final categoryIds = recent.map((t) => t.categoryId).toSet();
      final allCats = await (_db.select(_db.categories)
            ..where((c) => c.id.isIn(categoryIds)))
          .get();
      final catMap = {for (final c in allCats) c.id: c};

      final buffer = StringBuffer();
      for (final t in recent) {
        final cat = catMap[t.categoryId];
        final dateStr = '${t.transactionDate.month}/${t.transactionDate.day}';
        buffer.writeln('- "${t.description}" ${t.amount}元 → ${cat?.name ?? '未分类'} ($dateStr)');
      }

      return buffer.toString().trim();
    } catch (_) {
      return null;
    }
  }

  /// Episodic Memory Phase 2：检索用户修正过的分类记录
  ///
  /// 从 AiTrainingRecords 中获取最近的修正记录，
  /// 格式化为 few-shot examples 注入 prompt。
  Future<String?> _retrieveFewShotCorrections(int bookId) async {
    try {
      final records = await (_db.select(_db.aiTrainingRecords)
            ..where((t) =>
                t.accountBookId.equals(bookId) &
                t.wasCorrect.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(3))
          .get();

      if (records.isEmpty) return null;

      // 批量获取分类名称（避免 N+1 查询）
      final catIds = <int>{};
      for (final r in records) {
        if (r.predictedCategoryId != null) catIds.add(r.predictedCategoryId!);
        if (r.actualCategoryId != null) catIds.add(r.actualCategoryId!);
      }
      final allCats = catIds.isNotEmpty
          ? await (_db.select(_db.categories)..where((c) => c.id.isIn(catIds))).get()
          : <Category>[];
      final catMap = {for (final c in allCats) c.id: c};

      final buffer = StringBuffer();
      for (final r in records) {
        final predictedName = r.predictedCategoryId != null
            ? (catMap[r.predictedCategoryId!]?.name ?? '未知')
            : '未知';
        final actualName = r.actualCategoryId != null
            ? (catMap[r.actualCategoryId!]?.name ?? '未知')
            : '未知';

        buffer.writeln('- "${r.inputText}" → 用户选择了 $actualName（而非 $predictedName）');
      }

      return buffer.toString().trim();
    } catch (_) {
      return null;
    }
  }

  /// 从输入文本中提取关键词
  List<String> _extractKeywords(String input) {
    // 移除数字和常见量词
    final cleaned = input
        .replaceAll(RegExp(r'\d+\.?\d*(元|块|万|千)?'), '')
        .replaceAll(RegExp(r'[，。！？、\s,\.!\?]+'), ' ')
        .trim();

    // 按空格分割，过滤太短的词
    return cleaned.split(RegExp(r'\s+'))
        .where((w) => w.length >= 2)
        .toList();
  }

  /// 解析 AgentRunner 返回的 JSON 为 TransactionParseResult 列表
  List<TransactionParseResult> _parseAgentResult(String content) {
    try {
      // 提取 JSON（可能被 markdown 代码块包裹）
      var jsonStr = content.trim();

      // 1. 尝试从 markdown 代码块中提取
      if (jsonStr.contains('```')) {
        final match = RegExp(r'```(?:json)?\s*([\s\S]*?)```').firstMatch(jsonStr);
        if (match != null) jsonStr = match.group(1)!.trim();
      }

      // 2. 找到第一个 [ 或 { 作为 JSON 起点
      final arrayStart = jsonStr.indexOf('[');
      final objectStart = jsonStr.indexOf('{');
      int jsonStart;
      if (arrayStart < 0 && objectStart < 0) {
        // 没有 JSON → LLM 的非记账回复，标记为 nonTransactionResponse
        _pendingNonTransactionResponse = content;
        return [];
      } else if (arrayStart < 0) {
        jsonStart = objectStart;
      } else if (objectStart < 0) {
        jsonStart = arrayStart;
      } else {
        jsonStart = arrayStart < objectStart ? arrayStart : objectStart;
      }
      jsonStr = jsonStr.substring(jsonStart);

      // 3. 找到匹配的闭合括号（处理 LLM 在 JSON 后附加文本的情况）
      final openChar = jsonStr[0];
      final closeChar = openChar == '[' ? ']' : '}';
      int depth = 0;
      int jsonEnd = -1;
      for (int i = 0; i < jsonStr.length; i++) {
        if (jsonStr[i] == openChar) depth++;
        if (jsonStr[i] == closeChar) {
          depth--;
          if (depth == 0) {
            jsonEnd = i + 1;
            break;
          }
        }
      }
      if (jsonEnd > 0) {
        jsonStr = jsonStr.substring(0, jsonEnd);
      }

      final decoded = jsonDecode(jsonStr);
      final List<dynamic> txList;
      if (decoded is Map<String, dynamic> && decoded.containsKey('transactions')) {
        txList = decoded['transactions'] as List<dynamic>;
      } else if (decoded is List) {
        txList = decoded;
      } else if (decoded is Map<String, dynamic>) {
        // 单个对象而非数组
        txList = [decoded];
      } else {
        return [];
      }

      // 空交易列表 → 非记账输入，标记为 nonTransactionResponse
      if (txList.isEmpty) {
        _pendingNonTransactionResponse = content;
        return [];
      }

      return txList.map((tx) {
        final m = tx as Map<String, dynamic>;
        return TransactionParseResult(
          type: m['type'] as String? ?? 'expense',
          amount: (m['amount'] as num?)?.toDouble() ?? 0,
          category: m['category'] as String? ?? '',
          subcategory: m['subcategory'] as String?,
          description: m['description'] as String? ?? '',
          confidence: (m['confidence'] as num?)?.toDouble() ?? 0.5,
          date: m['date'] as String?,
          note: m['note'] as String?,
          payMethod: m['payMethod'] as String?,
        );
      }).toList();
    } catch (e) {
      assert(() {
        print('[TransactionPipeline] _parseAgentResult failed: $e\n  content: ${content.substring(0, content.length.clamp(0, 200))}');
        return true;
      }());
      // 解析失败 → 将原始 LLM 回复作为非记账回复展示
      _pendingNonTransactionResponse = content;
      return [];
    }
  }

  /// [v1.2] 构建增强的角色 System Prompt（含语义记忆 + 情景记忆）
  Future<String> _buildEnhancedPersonaPrompt(
    AiPersona persona,
    List<ChatMessage> historyMessages,
    String userInput,
  ) async {
    final buffer = StringBuffer(persona.systemPrompt);

    // 📌 语义记忆：固定注入，按 score 降序取 Top-8
    final memories = await _memoryRepo!.getTopMemories(
      personaId: persona.id,
      limit: 8,
    );
    if (memories.isNotEmpty) {
      buffer.writeln('\n## 你对用户的长期了解');
      for (final m in memories) {
        buffer.writeln('- [${m.type}] ${m.content}');
      }
    }

    // 🔍 情景记忆：按需检索，仅在输入含潜在指代时触发
    if (_needsContextRecall(userInput)) {
      try {
        final relevant = await _chatHistoryRepo!.searchByKeywords(
          personaId: persona.id,
          query: userInput,
          limit: 3,
        );
        if (relevant.isNotEmpty) {
          buffer.writeln('\n## 相关历史回忆');
          for (final msg in relevant) {
            buffer.writeln('- ${msg.content}');
          }
        }
      } catch (_) {
        // FTS 检索失败不影响主流程
      }
    }

    // 📋 本轮对话历史（直接注入，确保 LLM 不会忽略）
    if (historyMessages.isNotEmpty) {
      buffer.writeln('\n## 本轮对话历史（请仔细阅读并记住用户说过的信息）');
      for (final msg in historyMessages) {
        final prefix = msg.role == 'user' ? '用户' : '你';
        buffer.writeln('$prefix: ${msg.content}');
      }
    }

    return buffer.toString();
  }

  /// 轻量判断是否需要触发情景记忆检索
  bool _needsContextRecall(String input) {
    if (input.length < 5) return false;
    const triggers = ['之前', '上次', '那个', '还记得', '以前', '昨天', '上周', 'last', 'before', 'again'];
    return triggers.any((t) => input.toLowerCase().contains(t));
  }

  /// [v1.2] 处理角色响应：用角色 prompt 重新调用 LLM，返回 PipelineResult 或 null
  Future<PipelineResult?> _handlePersonaResponse(
    String userInput,
    String fallbackResponse, {
    String? conversationId,
  }) async {
    if (_chatHistoryRepo == null || _memoryRepo == null) return null;

    final activePersona = await PersonaStorage.getActive();
    if (activePersona == null) return null;

    try {
      // 0. 解析角色专用 provider（来自 persona_chat 配置）
      final provider = await _resolvePersonaProvider();

      // 1. 加载持久化历史（按 persona + 会话隔离）
      final historyEntities = await _chatHistoryRepo.getRecentMessages(
        personaId: activePersona.id,
        conversationId: conversationId,
        limit: 6,
      );
      final historyMessages = historyEntities.map((e) =>
        ChatMessage(role: e.role, content: e.content),
      ).toList();

      // 2. 构建增强 System Prompt（含语义记忆 + 历史）
      final enhancedPrompt = await _buildEnhancedPersonaPrompt(
        activePersona,
        historyMessages,
        userInput,
      );

      // 3. 调用 LLM
      final response = await _llmRepo.chat(
        LlmRequest(messages: [
          ChatMessage(role: 'system', content: enhancedPrompt),
          ...historyMessages,
          ChatMessage(role: 'user', content: userInput),
        ]),
        provider: provider,
      );

      // 4. 持久化消息（带 conversationId 隔离）
      await _chatHistoryRepo.addMessages([
        ChatMessagesCompanion.insert(
          personaId: Value(activePersona.id),
          conversationId: Value(conversationId),
          role: 'user',
          content: userInput,
        ),
        ChatMessagesCompanion.insert(
          personaId: Value(activePersona.id),
          conversationId: Value(conversationId),
          role: 'assistant',
          content: response.content,
        ),
      ]);

      // 5. 异步入队记忆提取
      _extractionQueue?.enqueue(
        activePersona.id,
        userInput,
        response.content,
      );

      return PipelineResult(
        normalizedText: userInput,
        transactions: const [],
        source: InputSource.text,
        nonTransactionResponse: response.content,
      );
    } catch (e) {
      // 角色调用失败，静默回退
      return null;
    }
  }

  /// 解析角色对话专用的 LLM provider
  /// 优先级：persona_chat AgentConfig → 任意可用 v2 provider
  Future<LlmProvider?> _resolvePersonaProvider() async {
    // 1. 角色专用配置
    final personaConfig = await AgentConfigStorage.load('persona_chat');
    if (personaConfig != null &&
        personaConfig.providerId.isNotEmpty &&
        personaConfig.modelName.isNotEmpty) {
      final aiProvider = await ProviderStorage.getById(personaConfig.providerId);
      if (aiProvider != null && aiProvider.isReady) {
        return LlmProvider(
          id: aiProvider.id,
          name: aiProvider.name,
          apiKey: aiProvider.apiKey,
          baseUrl: aiProvider.baseUrl,
          temperature: aiProvider.temperature,
          maxTokens: aiProvider.maxTokens,
          timeoutSeconds: aiProvider.timeoutSeconds,
          providerKey: aiProvider.providerKey ?? 'custom',
          models: {'text': ModelConfig(modelName: personaConfig.modelName)},
        );
      }
    }

    // 2. 回退：任意可用 v2 provider（模型从 transaction_parser 配置获取）
    final v2Providers = await ProviderStorage.loadAll();
    final ready = v2Providers.where((p) => p.isReady).toList();
    if (ready.isNotEmpty) {
      final p = ready.first;
      String? textModel;
      final tpConfig = await AgentConfigStorage.load('transaction_parser');
      if (tpConfig != null && tpConfig.modelName.isNotEmpty) {
        textModel = tpConfig.modelName;
      }
      if (textModel == null || textModel.isEmpty) return null;
      return LlmProvider(
        id: p.id,
        name: p.name,
        apiKey: p.apiKey,
        baseUrl: p.baseUrl,
        temperature: p.temperature,
        maxTokens: p.maxTokens,
        timeoutSeconds: p.timeoutSeconds,
        providerKey: p.providerKey ?? 'custom',
        models: {'text': ModelConfig(modelName: textModel)},
      );
    }
    return null;
  }
}

/// 引用类型
enum _ReferenceType {
  lastTransaction,   // "跟上次一样"
  sameDayYesterday,  // "跟昨天一样"
}

/// 引用模式
class _ReferencePattern {
  final String keyword;
  final _ReferenceType type;
  const _ReferencePattern(this.keyword, this.type);
}

/// 流式事件
sealed class PipelineStreamEvent {
  const PipelineStreamEvent();

  /// 文本增量
  const factory PipelineStreamEvent.delta(String text) = PipelineStreamDeltaEvent;

  /// 流结束，携带最终结果
  const factory PipelineStreamEvent.done(PipelineResult result) = PipelineStreamDoneEvent;
}

class PipelineStreamDeltaEvent extends PipelineStreamEvent {
  final String text;
  const PipelineStreamDeltaEvent(this.text);
}

class PipelineStreamDoneEvent extends PipelineStreamEvent {
  final PipelineResult result;
  const PipelineStreamDoneEvent(this.result);
}

/// 增强上下文
class _EnrichedContext {
  final String? similarTransactions;
  final String? fewShotExamples;
  const _EnrichedContext({this.similarTransactions, this.fewShotExamples});
}
