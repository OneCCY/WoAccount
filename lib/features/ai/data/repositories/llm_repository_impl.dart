import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/ai/prompt_templates.dart';
import '../../../../core/ai/rule_engine.dart';
import '../../../../core/config/ai_provider_presets.dart';
import '../../domain/repositories/llm_repository.dart';
import '../models/llm_config.dart';

/// LLM 服务实现（Data 层）
///
/// 支持两种 API 格式：
/// - OpenAI 兼容格式（/v1/chat/completions）
/// - Anthropic Messages API 格式（/messages）
class LlmRepositoryImpl implements LlmRepository {
  final Dio _dio;

  LlmRepositoryImpl(this._dio);

  @override
  Future<LlmProvider?> getActiveProvider() async {
    return await LlmConfigManager.getActiveProvider();
  }

  /// 获取指定能力的模型名称
  /// 优先使用 request.model → request.capability 对应的模型 → text 模型
  String _resolveModel(LlmProvider provider, LlmRequest request) {
    if (request.model != null && request.model!.isNotEmpty) return request.model!;
    final cap = request.capability ?? ModelCapability.text;
    final capModel = provider.getModelForCapability(cap);
    if (capModel != null) return capModel;
    throw const LlmException('未配置对应能力的模型', errorCode: 'llmErrorNoModelForCapability');
  }

  @override
  Future<LlmResponse> chat(LlmRequest request) async {
    final provider = await LlmConfigManager.getActiveProvider();

    if (provider == null || !provider.isComplete) {
      throw const LlmException('请先在设置中添加并配置 AI 服务商', errorCode: 'llmErrorNoProviderConfigured');
    }

    final model = _resolveModel(provider, request);

    // 判断 API 格式
    final preset = getPresetByKey(provider.providerKey);
    final isAnthropic = preset?.apiFormat == ApiFormat.anthropic;

    try {
      if (isAnthropic) {
        return await _chatAnthropic(provider, request, model);
      } else {
        return await _chatOpenAI(provider, request, model);
      }
    } on DioException catch (e) {
      throw LlmException(_parseDioError(e), errorCode: _parseDioErrorCode(e));
    }
  }

  /// OpenAI 兼容格式调用
  Future<LlmResponse> _chatOpenAI(LlmProvider provider, LlmRequest request, String model) async {
    final response = await _dio.post(
      '${provider.baseUrl}/chat/completions',
      options: Options(
        headers: {
          'Authorization': 'Bearer ${provider.apiKey}',
          'Content-Type': 'application/json',
        },
        sendTimeout: Duration(seconds: provider.timeoutSeconds),
        receiveTimeout: Duration(seconds: provider.timeoutSeconds),
      ),
      data: {
        'model': model,
        'messages': request.messages.map((m) => m.toJson()).toList(),
        'temperature': request.temperature ?? provider.temperature,
        'max_tokens': request.maxTokens ?? provider.maxTokens,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final usage = data['usage'] as Map<String, dynamic>? ?? {};
    final choices = data['choices'] as List<dynamic>;
    final messageContent =
        (choices[0] as Map<String, dynamic>)['message']['content'] as String;

    return LlmResponse(
      content: messageContent,
      model: data['model'] as String? ?? model,
      promptTokens: usage['prompt_tokens'] as int? ?? 0,
      completionTokens: usage['completion_tokens'] as int? ?? 0,
      totalTokens: usage['total_tokens'] as int? ?? 0,
    );
  }

  /// Anthropic Messages API 格式调用
  Future<LlmResponse> _chatAnthropic(LlmProvider provider, LlmRequest request, String model) async {
    // 分离 system 消息和 user/assistant 消息
    String? systemPrompt;
    final messages = <Map<String, String>>[];
    for (final msg in request.messages) {
      if (msg.role == 'system') {
        systemPrompt = msg.content;
      } else {
        messages.add({'role': msg.role, 'content': msg.content});
      }
    }

    // 如果没有 user/assistant 消息，添加一个空的 user 消息
    if (messages.isEmpty) {
      messages.add({'role': 'user', 'content': 'Hello'});
    }

    final requestBody = <String, dynamic>{
      'model': model,
      'messages': messages,
      'max_tokens': request.maxTokens ?? provider.maxTokens,
    };
    if (systemPrompt != null) {
      requestBody['system'] = systemPrompt;
    }
    if (request.temperature != null || provider.temperature > 0) {
      requestBody['temperature'] = request.temperature ?? provider.temperature;
    }

    final response = await _dio.post(
      '${provider.baseUrl}/messages',
      options: Options(
        headers: {
          'x-api-key': provider.apiKey,
          'anthropic-version': '2023-06-01',
          'Content-Type': 'application/json',
        },
        sendTimeout: Duration(seconds: provider.timeoutSeconds),
        receiveTimeout: Duration(seconds: provider.timeoutSeconds),
      ),
      data: requestBody,
    );

    final data = response.data as Map<String, dynamic>;
    final usage = data['usage'] as Map<String, dynamic>? ?? {};
    final content = data['content'] as List<dynamic>;
    final textContent = (content[0] as Map<String, dynamic>)['text'] as String;

    return LlmResponse(
      content: textContent,
      model: data['model'] as String? ?? model,
      promptTokens: usage['input_tokens'] as int? ?? 0,
      completionTokens: usage['output_tokens'] as int? ?? 0,
      totalTokens: (usage['input_tokens'] as int? ?? 0) + (usage['output_tokens'] as int? ?? 0),
    );
  }

  @override
  Future<List<TransactionParseResult>> parseTransaction(String input, {String? categoryTaxonomy}) async {
    // 降级策略：先尝试 LLM，失败后用规则引擎
    try {
      final provider = await LlmConfigManager.getActiveProvider();
      if (provider == null || !provider.isComplete) {
        // 未配置 LLM，直接用规则引擎
        final ruleResult = RuleEngine.parse(input);
        if (ruleResult != null) return [ruleResult];
        throw const LlmException('请先在设置中添加 AI 服务商，或输入更明确的描述（如"午饭拉面25"）', errorCode: 'llmErrorNoProviderOrInput');
      }

      // 构建系统提示词（使用动态分类或默认分类）
      final systemPrompt = categoryTaxonomy != null
          ? PromptTemplates.parseTransactionSystem(categoryTaxonomy)
          : PromptTemplates.parseTransactionSystem(_defaultCategoryTaxonomy);

      // 调用 LLM（使用文本能力）
      final response = await chat(LlmRequest(
        messages: [
          ChatMessage(role: 'system', content: systemPrompt),
          ChatMessage(role: 'user', content: PromptTemplates.parseTransactionUser(input)),
        ],
        temperature: 0.0,
        capability: ModelCapability.text,
      ));

      return _parseTransactionResponse(response.content);
    } on LlmException {
      // LLM 失败，降级到规则引擎
      final ruleResult = RuleEngine.parse(input);
      if (ruleResult != null) return [ruleResult];
      rethrow;
    }
  }

  /// 默认分类体系（当无法从数据库获取时的兜底）
  static const _defaultCategoryTaxonomy = '''
### 支出分类
- 餐饮（早餐、午餐、晚餐、外卖、零食、饮料、火锅、烧烤）
- 交通（公交地铁、打车、加油、停车、火车、飞机）
- 购物（日用品、衣服、电子产品、家居、美妆）
- 住房（房租、水电燃气、物业、维修）
- 娱乐（电影、游戏、旅游、运动、演出）
- 教育（课程、书籍、培训、考试）
- 医疗（挂号、药品、体检、牙科、眼科）
- 社交（礼物、聚餐、红包、份子钱）
- 其他支出（无法归类的支出）

### 收入分类
- 工资（月薪、日结、加班费）
- 奖金（年终奖、绩效奖、提成）
- 投资收益（股票、基金、利息）
- 退款（退货退款、保险理赔）
- 兼职（副业、freelance）
- 其他收入（无法归类的收入）''';

  @override
  Future<bool> testConnection(LlmProvider provider) async {
    try {
      final preset = getPresetByKey(provider.providerKey);
      final isAnthropic = preset?.apiFormat == ApiFormat.anthropic;

      if (isAnthropic) {
        return await _testConnectionAnthropic(provider);
      } else {
        return await _testConnectionOpenAI(provider);
      }
    } catch (_) {
      return false;
    }
  }

  /// 测试 OpenAI 兼容连接
  Future<bool> _testConnectionOpenAI(LlmProvider provider) async {
    final response = await _dio.post(
      '${provider.baseUrl}/chat/completions',
      options: Options(
        headers: {
          'Authorization': 'Bearer ${provider.apiKey}',
          'Content-Type': 'application/json',
        },
        sendTimeout: Duration(seconds: provider.timeoutSeconds),
        receiveTimeout: Duration(seconds: provider.timeoutSeconds),
      ),
      data: {
        'model': provider.getModelForCapability(ModelCapability.text) ?? '',
        'messages': [
          {'role': 'user', 'content': 'Hello'}
        ],
        'max_tokens': 10,
      },
    );
    return response.statusCode == 200;
  }

  /// 测试 Anthropic 连接
  Future<bool> _testConnectionAnthropic(LlmProvider provider) async {
    final response = await _dio.post(
      '${provider.baseUrl}/messages',
      options: Options(
        headers: {
          'x-api-key': provider.apiKey,
          'anthropic-version': '2023-06-01',
          'Content-Type': 'application/json',
        },
        sendTimeout: Duration(seconds: provider.timeoutSeconds),
        receiveTimeout: Duration(seconds: provider.timeoutSeconds),
      ),
      data: {
        'model': provider.getModelForCapability(ModelCapability.text) ?? '',
        'messages': [
          {'role': 'user', 'content': 'Hello'}
        ],
        'max_tokens': 10,
      },
    );
    return response.statusCode == 200;
  }

  /// 解析 LLM 返回的交易 JSON（支持单笔和多笔）
  List<TransactionParseResult> _parseTransactionResponse(String content) {
    try {
      // 提取 JSON（可能是对象或数组）
      final jsonMatch = RegExp(r'(\[[\s\S]*\]|\{[\s\S]*\})').firstMatch(content);
      if (jsonMatch == null) {
        throw const LlmException('无法解析 AI 响应', errorCode: 'llmErrorCannotParseResponse');
      }

      final raw = jsonDecode(jsonMatch.group(0)!);

      // 处理数组格式（多笔交易）
      if (raw is List) {
        return raw.map((item) => _parseSingleTransaction(item as Map<String, dynamic>)).toList();
      }

      // 处理单对象格式（兼容旧格式）
      if (raw is Map<String, dynamic>) {
        return [_parseSingleTransaction(raw)];
      }

      throw const LlmException('AI 响应格式不正确', errorCode: 'llmErrorInvalidResponseFormat');
    } catch (e) {
      if (e is LlmException) rethrow;
      throw LlmException('解析 AI 响应失败: $e', errorCode: 'llmErrorParseFailed');
    }
  }

  TransactionParseResult _parseSingleTransaction(Map<String, dynamic> json) {
    return TransactionParseResult(
      type: json['type'] as String? ?? 'expense',
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      subcategory: json['subcategory'] as String?,
      description: json['description'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.8,
      date: json['date'] as String?,
      note: json['note'] as String?,
      payMethod: json['payMethod'] as String?,
    );
  }

  /// 解析 Dio 错误
  String _parseDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return '请求超时，请检查网络连接';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) return 'API Key 无效，请检查设置';
        if (statusCode == 429) return '请求过于频繁，请稍后再试';
        if (statusCode == 403) return '访问被拒绝，请检查 API Key 权限';
        return '请求失败 ($statusCode)';
      case DioExceptionType.connectionError:
        return '网络连接失败，请检查网络';
      default:
        return '请求失败: ${e.message}';
    }
  }

  /// 解析 Dio 错误对应的 l10n errorCode
  String _parseDioErrorCode(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'llmErrorTimeout';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) return 'llmErrorInvalidApiKey';
        if (statusCode == 429) return 'llmErrorRateLimit';
        if (statusCode == 403) return 'llmErrorForbidden';
        return 'llmErrorRequestFailed';
      case DioExceptionType.connectionError:
        return 'llmErrorNetworkFailed';
      default:
        return 'llmErrorRequestFailedWithMessage';
    }
  }
}
