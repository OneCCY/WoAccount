import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../config/database/app_database.dart';
import '../../../core/ai/prompt_templates.dart';
import '../../../core/ai/rule_engine.dart';
import '../data/models/ai_agent.dart';
import '../data/models/ai_provider.dart';
import '../data/models/ai_trace.dart';
import '../data/models/llm_config.dart';
import '../data/models/agent_config.dart';
import '../data/storage/agent_config_storage.dart';
import '../data/storage/provider_storage.dart';
import '../data/storage/trace_storage.dart';
import 'repositories/llm_repository.dart';
import 'agent_registry.dart';
import 'tool_registry.dart';

/// Agent 执行结果
class AgentResult {
  final String content;
  final AiTrace trace;
  final bool fallbackUsed;

  const AgentResult({
    required this.content,
    required this.trace,
    this.fallbackUsed = false,
  });
}

/// Agent 执行引擎
///
/// 职责：
/// 1. 加载 Agent 定义 + 用户配置 + Provider
/// 2. 预处理（RAG + Episodic Memory + Reference Resolution）
/// 3. 调用主模型 → 失败时降级到备选模型
/// 4. 记录 Trace
class AgentRunner {
  final LlmRepository _llmRepo;
  final AppDatabase _db;

  AgentRunner(this._llmRepo, this._db);

  /// 执行 Agent
  ///
  /// [agentId] Agent ID（如 'transaction_parser'）
  /// [input] 用户输入（文本、图片路径等）
  /// [extraParams] 额外参数（如 bookId, locale, categoryTaxonomy）
  Future<AgentResult> run(
    String agentId,
    dynamic input, {
    Map<String, dynamic>? extraParams,
  }) async {
    final agent = AgentRegistry.get(agentId);
    if (agent == null) {
      throw LlmException('未知的 Agent: $agentId', errorCode: 'agentNotFound');
    }

    final config = await AgentConfigStorage.load(agentId);
    if (config == null || !config.enabled) {
      throw LlmException(
        'Agent "$agentId" 未配置，请在 AI 设置中配置',
        errorCode: 'agentNotConfigured',
      );
    }

    final stopwatch = Stopwatch()..start();

    // 尝试主模型
    try {
      final result = await _executeWithProvider(
        agent, config, input, extraParams,
        providerId: config.providerId,
        modelName: config.modelName,
      );
      stopwatch.stop();

      final trace = AiTrace(
        id: const Uuid().v4(),
        agentId: agentId,
        providerId: config.providerId,
        modelName: config.modelName,
        timestamp: DateTime.now(),
        latencyMs: stopwatch.elapsedMilliseconds,
        inputTokens: result.promptTokens,
        outputTokens: result.completionTokens,
        success: true,
        fallbackUsed: false,
      );
      await TraceStorage.record(trace);

      return AgentResult(content: result.content, trace: trace, fallbackUsed: false);
    } catch (e) {
      // 主模型失败，检查是否可以降级
      if (!_shouldFallback(e)) {
        stopwatch.stop();
        final trace = AiTrace(
          id: const Uuid().v4(),
          agentId: agentId,
          providerId: config.providerId,
          modelName: config.modelName,
          timestamp: DateTime.now(),
          latencyMs: stopwatch.elapsedMilliseconds,
          success: false,
          errorCode: e is LlmException ? e.errorCode : e.toString(),
          fallbackUsed: false,
        );
        await TraceStorage.record(trace);
        rethrow;
      }

      // 尝试备选模型
      if (config.hasFallback) {
        try {
          final result = await _executeWithProvider(
            agent, config, input, extraParams,
            providerId: config.fallbackProviderId!,
            modelName: config.fallbackModelName!,
          );
          stopwatch.stop();

          final trace = AiTrace(
            id: const Uuid().v4(),
            agentId: agentId,
            providerId: config.fallbackProviderId!,
            modelName: config.fallbackModelName!,
            timestamp: DateTime.now(),
            latencyMs: stopwatch.elapsedMilliseconds,
            inputTokens: result.promptTokens,
            outputTokens: result.completionTokens,
            success: true,
            fallbackUsed: true,
            fallbackProviderId: config.providerId,
            fallbackModelName: config.modelName,
          );
          await TraceStorage.record(trace);

          return AgentResult(content: result.content, trace: trace, fallbackUsed: true);
        } catch (_) {
          // 备选也失败，继续到 RuleEngine 降级
        }
      }

      // 最终降级：transaction_parser 使用 RuleEngine
      if (agentId == 'transaction_parser' && input is String) {
        final ruleResult = RuleEngine.parse(input);
        if (ruleResult != null) {
          stopwatch.stop();
          final trace = AiTrace(
            id: const Uuid().v4(),
            agentId: agentId,
            providerId: 'rule_engine',
            modelName: 'offline',
            timestamp: DateTime.now(),
            latencyMs: stopwatch.elapsedMilliseconds,
            success: true,
            fallbackUsed: true,
          );
          await TraceStorage.record(trace);

          return AgentResult(
            content: jsonEncode({
              'transactions': [{
                'type': ruleResult.type,
                'amount': ruleResult.amount,
                'category': ruleResult.category,
                'description': ruleResult.description,
                'confidence': ruleResult.confidence,
                if (ruleResult.date != null) 'date': ruleResult.date,
              }],
            }),
            trace: trace,
            fallbackUsed: true,
          );
        }
      }

      // 所有降级都失败
      stopwatch.stop();
      final trace = AiTrace(
        id: const Uuid().v4(),
        agentId: agentId,
        providerId: config.providerId,
        modelName: config.modelName,
        timestamp: DateTime.now(),
        latencyMs: stopwatch.elapsedMilliseconds,
        success: false,
        errorCode: e is LlmException ? e.errorCode : e.toString(),
        fallbackUsed: true,
      );
      await TraceStorage.record(trace);
      rethrow;
    }
  }

  /// 使用指定 Provider 和模型执行
  Future<({String content, int? promptTokens, int? completionTokens})> _executeWithProvider(
    AiAgent agent,
    AgentConfig config,
    dynamic input,
    Map<String, dynamic>? extraParams, {
    required String providerId,
    required String modelName,
  }) async {
    final provider = await ProviderStorage.getById(providerId);
    if (provider == null || !provider.isReady) {
      throw LlmException(
        '供应商 "$providerId" 未配置或不可用',
        errorCode: 'providerNotAvailable',
      );
    }

    // 构建请求
    final messages = await _buildMessages(agent, input, extraParams);
    final temperature = config.temperature ?? provider.temperature;
    final maxTokens = config.maxTokens ?? provider.maxTokens;

    final request = LlmRequest(
      messages: messages,
      model: modelName,
      temperature: temperature,
      maxTokens: maxTokens,
      structuredOutput: agent.outputSchema != null,
      jsonSchema: agent.outputSchema,
    );

    // 使用 AgentConfig.timeout 覆盖 Provider 默认超时
    final effectiveProvider = _toLegacyProvider(provider, modelName);
    final timeoutProvider = config.timeout != null
        ? effectiveProvider.copyWith(timeoutSeconds: config.timeout)
        : effectiveProvider;

    final response = await _llmRepo.chat(request, provider: timeoutProvider);
    return (
      content: response.content,
      promptTokens: response.promptTokens > 0 ? response.promptTokens : null,
      completionTokens: response.completionTokens > 0 ? response.completionTokens : null,
    );
  }

  /// 构建 LLM 请求消息
  Future<List<ChatMessage>> _buildMessages(
    AiAgent agent,
    dynamic input,
    Map<String, dynamic>? extraParams,
  ) async {
    final messages = <ChatMessage>[];

    if (agent.id == 'transaction_parser') {
      await _buildTransactionParserMessages(messages, input.toString(), extraParams);
    } else if (agent.id == 'receipt_ocr') {
      _buildReceiptOcrMessages(messages, input.toString(), extraParams);
    } else if (agent.id == 'finance_search') {
      _buildFinanceSearchMessages(messages, input.toString(), extraParams);
    } else {
      // 通用 Agent：直接使用 systemPrompt + input
      if (agent.systemPrompt.isNotEmpty) {
        messages.add(ChatMessage(role: 'system', content: agent.systemPrompt));
      }
      messages.add(ChatMessage(role: 'user', content: input.toString()));
    }

    return messages;
  }

  /// 构建 transaction_parser 的消息（含 RAG + Episodic Memory）
  Future<void> _buildTransactionParserMessages(
    List<ChatMessage> messages,
    String input,
    Map<String, dynamic>? extraParams,
  ) async {
    final locale = extraParams?['locale'] as String? ?? 'zh';
    final bookId = extraParams?['bookId'] as int?;
    final categoryTaxonomy = extraParams?['categoryTaxonomy'] as String?;

    // 解析指代
    final resolvedInput = await _resolveReference(input, bookId);

    // RAG + Episodic Memory
    final (similarTransactions, fewShotExamples) = await _buildEnrichedContext(resolvedInput, bookId);

    // 构建系统 prompt
    final systemPrompt = PromptTemplates.parseTransactionSystem(
      categoryTaxonomy ?? '',
      locale: locale,
      fewShotExamples: fewShotExamples,
      similarTransactions: similarTransactions,
    );

    // 构建用户 prompt
    final userPrompt = PromptTemplates.parseTransactionUser(resolvedInput, locale: locale);

    messages.add(ChatMessage(role: 'system', content: systemPrompt));
    messages.add(ChatMessage(role: 'user', content: userPrompt));
  }

  /// 构建 receipt_ocr 的消息
  void _buildReceiptOcrMessages(
    List<ChatMessage> messages,
    String input,
    Map<String, dynamic>? extraParams,
  ) {
    final locale = extraParams?['locale'] as String? ?? 'zh';
    final categoryTaxonomy = extraParams?['categoryTaxonomy'] as String?;

    // OCR 结果作为用户输入，用 transaction parser 的 prompt 来解析
    final systemPrompt = PromptTemplates.parseTransactionSystem(
      categoryTaxonomy ?? '',
      locale: locale,
    );
    final userPrompt = PromptTemplates.parseTransactionUser(input, locale: locale);

    messages.add(ChatMessage(role: 'system', content: systemPrompt));
    messages.add(ChatMessage(role: 'user', content: userPrompt));
  }

  /// 构建 finance_search 的消息
  void _buildFinanceSearchMessages(
    List<ChatMessage> messages,
    String input,
    Map<String, dynamic>? extraParams,
  ) {
    final categoryTaxonomy = extraParams?['categoryTaxonomy'] as String?;

    final systemPrompt = PromptTemplates.searchQueryParseSystem(categoryTaxonomy ?? '');
    final userPrompt = PromptTemplates.searchQueryParseUser(input);

    messages.add(ChatMessage(role: 'system', content: systemPrompt));
    messages.add(ChatMessage(role: 'user', content: userPrompt));
  }

  /// 解析指代（从 TransactionPipeline._resolveReference 迁移）
  Future<String> _resolveReference(String input, int? bookId) async {
    final tool = ToolRegistry.get('resolve_reference');
    if (tool == null) return input;

    try {
      final result = await tool.execute({
        'input': input,
        if (bookId != null) 'bookId': bookId,
      });
      if (result is Map && result['resolved'] == true) {
        return result['resolvedInput'] as String;
      }
    } catch (e) {
      // 工具执行失败，记录日志并返回原始输入
      assert(() {
        print('[AgentRunner] resolve_reference failed: $e');
        return true;
      }());
    }
    return input;
  }

  /// 构建富上下文（RAG + Episodic Memory）
  Future<(String?, String?)> _buildEnrichedContext(String input, int? bookId) async {
    final similar = await _retrieveSimilarTransactions(input, bookId ?? 1);
    final fewShot = await _retrieveFewShotCorrections(bookId ?? 1);
    return (similar, fewShot);
  }

  /// RAG: 检索相似交易
  Future<String?> _retrieveSimilarTransactions(String input, int bookId) async {
    try {
      final keywords = _extractKeywords(input);
      if (keywords.isEmpty) return null;

      final topKeywords = keywords.take(3).toList();

      // 构建 LIKE 表达式（转义 LIKE 通配符）
      final tbl = _db.transactions;
      Expression<bool>? likeCondition;
      for (final kw in topKeywords) {
        // 转义 LIKE 通配符：用方括号包裹特殊字符（SQLite 兼容）
        final escaped = kw
            .replaceAll('%', '')
            .replaceAll('_', '')
            .replaceAll('[', '')
            .replaceAll(']', '');
        if (escaped.isEmpty) continue;
        final pattern = '%$escaped%';
        final expr = tbl.description.like(pattern) |
            tbl.note.like(pattern) |
            tbl.originalInput.like(pattern);
        likeCondition = likeCondition == null ? expr : likeCondition | expr;
      }

      // 合并所有 WHERE 条件为单次调用（避免 .where() 覆盖）
      final query = _db.select(_db.transactions)
        ..where((t) =>
            t.isDeleted.equals(false) &
            t.accountBookId.equals(bookId) &
            (likeCondition ?? t.id.isBiggerThanValue(-1)))
        ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)])
        ..limit(3);

      final results = await query.get();
      if (results.isEmpty) return null;

      // 批量获取分类名称
      final categoryIds = results.map((t) => t.categoryId).toSet();
      final categories = await (_db.select(_db.categories)
        ..where((c) => c.id.isIn(categoryIds))).get();
      final catMap = {for (final c in categories) c.id: c.name};

      return results.map((t) {
        final catName = catMap[t.categoryId] ?? '未知';
        final date = '${t.transactionDate.month}/${t.transactionDate.day}';
        return '- "${t.description}" ${t.amount}元 -> $catName ($date)';
      }).join('\n');
    } catch (_) {
      return null;
    }
  }

  /// Episodic Memory: 检索纠错记忆
  Future<String?> _retrieveFewShotCorrections(int bookId) async {
    try {
      final query = _db.select(_db.aiTrainingRecords)
        ..where((t) => t.wasCorrect.equals(false) & t.accountBookId.equals(bookId))
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
        ..limit(3);
      final records = await query.get();
      if (records.isEmpty) return null;

      final categoryIds = <int>{};
      for (final r in records) {
        if (r.predictedCategoryId != null) categoryIds.add(r.predictedCategoryId!);
        if (r.actualCategoryId != null) categoryIds.add(r.actualCategoryId!);
      }
      final categories = await (_db.select(_db.categories)
        ..where((c) => c.id.isIn(categoryIds))).get();
      final catMap = {for (final c in categories) c.id: c.name};

      return records.map((r) {
        final predicted = catMap[r.predictedCategoryId] ?? '未知';
        final actual = catMap[r.actualCategoryId] ?? '未知';
        return '- "${r.inputText}" -> 用户选择了 $actual（而非 $predicted）';
      }).join('\n');
    } catch (_) {
      return null;
    }
  }

  /// 提取关键词
  List<String> _extractKeywords(String input) {
    final cleaned = input
        .replaceAll(RegExp(r'\d+\.?\d*'), '')
        .replaceAll(RegExp(r'[元块块钱圆角分]'), '')
        .replaceAll(RegExp(r'[，。！？、；：""''（）\[\]【】\s]+'), ' ')
        .trim();
    return cleaned.split(' ').where((w) => w.length >= 2).toList();
  }

  /// 判断是否应该降级
  bool _shouldFallback(Object error) {
    if (error is LlmException) {
      // 401 认证失败不降级（密钥问题，换模型也没用）
      if (error.errorCode == 'llmErrorInvalidApiKey') return false;
      return true;
    }
    return true;
  }

  /// 将 AiProvider 转换为旧的 LlmProvider（兼容现有 LlmRepository）
  LlmProvider _toLegacyProvider(AiProvider provider, String modelName) {
    return LlmProvider(
      id: provider.id,
      name: provider.name,
      apiKey: provider.apiKey,
      baseUrl: provider.baseUrl,
      temperature: provider.temperature,
      maxTokens: provider.maxTokens,
      timeoutSeconds: provider.timeoutSeconds,
      providerKey: provider.providerKey ?? 'custom',
      models: {
        'text': ModelConfig(modelName: modelName),
      },
    );
  }
}
