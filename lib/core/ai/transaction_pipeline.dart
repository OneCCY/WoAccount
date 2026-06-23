import 'package:drift/drift.dart';
import '../../config/database/app_database.dart';
import '../../features/ai/data/models/llm_config.dart';
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

  const PipelineResult({
    required this.normalizedText,
    required this.transactions,
    required this.source,
    this.mediaFilePath,
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

  TransactionPipeline({
    required LlmRepository llmRepo,
    required ImageRecognitionService imageService,
    required MediaStorageService mediaStorage,
    required AppDatabase db,
  })  : _llmRepo = llmRepo,
        _imageService = imageService,
        _mediaStorage = mediaStorage,
        _db = db;

  /// 处理文本输入
  Future<PipelineResult> processText(
    String text, {
    String? categoryTaxonomy,
    String locale = 'zh',
    int? bookId,
  }) async {
    // [Tool Use] 检测引用型输入，预取历史数据
    final resolvedText = await _resolveReference(text, bookId);

    // [RAG + Episodic Memory] 构建增强上下文
    final context = await _buildEnrichedContext(resolvedText, bookId);

    final results = await _llmRepo.parseTransaction(
      resolvedText,
      categoryTaxonomy: categoryTaxonomy,
      locale: locale,
      fewShotExamples: context.fewShotExamples,
      similarTransactions: context.similarTransactions,
    );
    return PipelineResult(
      normalizedText: text,  // 保留原始输入（不是解析后的）
      transactions: results,
      source: InputSource.text,
    );
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

    // 用文本走 AI 记账解析（带增强上下文）
    final results = await _llmRepo.parseTransaction(
      resolvedText,
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
  /// [provider] 当前 LLM 服务商配置
  Future<PipelineResult> processImage({
    required String imageTempPath,
    required LlmProvider provider,
    String? categoryTaxonomy,
    String locale = 'zh',
    int? bookId,
  }) async {
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

    // 3. 用识别文本走 AI 记账解析
    final results = await _llmRepo.parseTransaction(
      recognizedText,
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
          ? '${referenced!.description} ${referenced!.amount}元 ($catName)'
          : '${referenced!.description} ${referenced!.amount}元';
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
      similarTransactions: results[0] as String?,
      fewShotExamples: results[1] as String?,
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

/// 增强上下文
class _EnrichedContext {
  final String? similarTransactions;
  final String? fewShotExamples;
  const _EnrichedContext({this.similarTransactions, this.fewShotExamples});
}
