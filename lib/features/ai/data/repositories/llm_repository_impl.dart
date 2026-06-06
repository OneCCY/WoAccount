import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/ai/prompt_templates.dart';
import '../../../../core/ai/rule_engine.dart';
import '../../domain/repositories/llm_repository.dart';
import '../models/llm_config.dart';

/// LLM 服务实现（Data 层）
class LlmRepositoryImpl implements LlmRepository {
  final Dio _dio;
  LlmConfig? _cachedConfig;

  LlmRepositoryImpl(this._dio);

  @override
  Future<LlmConfig> getConfig() async {
    if (_cachedConfig != null) return _cachedConfig!;

    final prefs = await SharedPreferences.getInstance();
    final settings = <String, String>{};
    for (final key in [
      'llm_provider', 'llm_api_key', 'llm_base_url', 'llm_model',
      'llm_temperature', 'llm_max_tokens', 'llm_timeout',
    ]) {
      settings[key] = prefs.getString(key) ?? '';
    }

    _cachedConfig = LlmConfig.fromSettings(settings);
    return _cachedConfig!;
  }

  @override
  Future<void> updateConfig(LlmConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in config.toSettings().entries) {
      await prefs.setString(entry.key, entry.value);
    }
    _cachedConfig = config;
  }

  @override
  Future<LlmResponse> chat(LlmRequest request) async {
    final config = await getConfig();

    if (!config.isConfigured) {
      throw const LlmException('请先在设置中配置 AI 服务（API Key）');
    }

    try {
      final response = await _dio.post(
        '${config.baseUrl}/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${config.apiKey}',
            'Content-Type': 'application/json',
          },
          sendTimeout: Duration(seconds: config.timeoutSeconds),
          receiveTimeout: Duration(seconds: config.timeoutSeconds),
        ),
        data: {
          'model': request.model ?? config.model,
          'messages': request.messages.map((m) => m.toJson()).toList(),
          'temperature': request.temperature ?? config.temperature,
          'max_tokens': request.maxTokens ?? config.maxTokens,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final usage = data['usage'] as Map<String, dynamic>? ?? {};
      final choices = data['choices'] as List<dynamic>;
      final messageContent =
          (choices[0] as Map<String, dynamic>)['message']['content'] as String;

      return LlmResponse(
        content: messageContent,
        model: data['model'] as String? ?? config.model,
        promptTokens: usage['prompt_tokens'] as int? ?? 0,
        completionTokens: usage['completion_tokens'] as int? ?? 0,
        totalTokens: usage['total_tokens'] as int? ?? 0,
      );
    } on DioException catch (e) {
      throw LlmException(_parseDioError(e));
    }
  }

  @override
  Future<TransactionParseResult> parseTransaction(String input) async {
    // 降级策略：先尝试 LLM，失败后用规则引擎
    try {
      final config = await getConfig();
      if (!config.isConfigured) {
        // 未配置 LLM，直接用规则引擎
        final ruleResult = RuleEngine.parse(input);
        if (ruleResult != null) return ruleResult;
        throw const LlmException('请先在设置中配置 AI 服务，或输入更明确的描述（如"午饭拉面25"）');
      }

      // 调用 LLM
      final response = await chat(LlmRequest(
        messages: [
          ChatMessage(role: 'system', content: PromptTemplates.parseTransactionSystem),
          ChatMessage(role: 'user', content: PromptTemplates.parseTransactionUser(input)),
        ],
        temperature: 0.0,
      ));

      return _parseTransactionResponse(response.content);
    } on LlmException {
      // LLM 失败，降级到规则引擎
      final ruleResult = RuleEngine.parse(input);
      if (ruleResult != null) return ruleResult;
      rethrow;
    }
  }

  @override
  Future<bool> testConnection() async {
    try {
      final response = await chat(LlmRequest(
        messages: const [
          ChatMessage(role: 'user', content: 'Hello'),
        ],
        maxTokens: 10,
      ));
      return response.content.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// 解析 LLM 返回的交易 JSON
  TransactionParseResult _parseTransactionResponse(String content) {
    try {
      // 提取 JSON（可能被 markdown 代码块包裹）
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
      if (jsonMatch == null) {
        throw const LlmException('无法解析 AI 响应');
      }

      final json = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;

      return TransactionParseResult(
        type: json['type'] as String? ?? 'expense',
        amount: (json['amount'] as num).toDouble(),
        category: json['category'] as String,
        subcategory: json['subcategory'] as String?,
        description: json['description'] as String? ?? '',
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.8,
        date: json['date'] as String?,
        note: json['note'] as String?,
      );
    } catch (e) {
      if (e is LlmException) rethrow;
      throw LlmException('解析 AI 响应失败: $e');
    }
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
}
