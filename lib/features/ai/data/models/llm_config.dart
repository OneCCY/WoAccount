/// LLM 配置模型
class LlmConfig {
  final String providerId;
  final String apiKey;
  final String baseUrl;
  final String model;
  final double temperature;
  final int maxTokens;
  final int timeoutSeconds;

  const LlmConfig({
    required this.providerId,
    required this.apiKey,
    required this.baseUrl,
    required this.model,
    this.temperature = 0.0,
    this.maxTokens = 1000,
    this.timeoutSeconds = 30,
  });

  /// 是否已配置（API Key 非空）
  bool get isConfigured => apiKey.isNotEmpty;

  /// 从 SharedPreferences 构建
  factory LlmConfig.fromSettings(Map<String, String> settings) {
    return LlmConfig(
      providerId: settings['llm_provider'] ?? 'deepseek',
      apiKey: settings['llm_api_key'] ?? '',
      baseUrl: settings['llm_base_url'] ?? '',
      model: settings['llm_model'] ?? '',
      temperature: double.tryParse(settings['llm_temperature'] ?? '0') ?? 0.0,
      maxTokens: int.tryParse(settings['llm_max_tokens'] ?? '1000') ?? 1000,
      timeoutSeconds: int.tryParse(settings['llm_timeout'] ?? '30') ?? 30,
    );
  }

  /// 转为 Map 用于存储
  Map<String, String> toSettings() {
    return {
      'llm_provider': providerId,
      'llm_api_key': apiKey,
      'llm_base_url': baseUrl,
      'llm_model': model,
      'llm_temperature': temperature.toString(),
      'llm_max_tokens': maxTokens.toString(),
      'llm_timeout': timeoutSeconds.toString(),
    };
  }

  LlmConfig copyWith({
    String? providerId,
    String? apiKey,
    String? baseUrl,
    String? model,
    double? temperature,
    int? maxTokens,
    int? timeoutSeconds,
  }) {
    return LlmConfig(
      providerId: providerId ?? this.providerId,
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      model: model ?? this.model,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
    );
  }
}

/// 预设 LLM 提供商
class LlmProvider {
  final String id;
  final String name;
  final String defaultBaseUrl;
  final String defaultModel;
  final List<String> availableModels;

  const LlmProvider({
    required this.id,
    required this.name,
    required this.defaultBaseUrl,
    required this.defaultModel,
    required this.availableModels,
  });
}

/// 预设提供商列表
class LlmProviders {
  static const qwen = LlmProvider(
    id: 'qwen',
    name: '通义千问',
    defaultBaseUrl: 'https://dashscope.aliyuncs.com/api/v1',
    defaultModel: 'qwen-turbo',
    availableModels: ['qwen-turbo', 'qwen-plus', 'qwen-max'],
  );

  static const deepseek = LlmProvider(
    id: 'deepseek',
    name: 'DeepSeek',
    defaultBaseUrl: 'https://api.deepseek.com/v1',
    defaultModel: 'deepseek-chat',
    availableModels: ['deepseek-chat', 'deepseek-coder'],
  );

  static const zhipu = LlmProvider(
    id: 'zhipu',
    name: '智谱AI',
    defaultBaseUrl: 'https://open.bigmodel.cn/api/paas/v4',
    defaultModel: 'glm-4-flash',
    availableModels: ['glm-4-flash', 'glm-4', 'glm-4v'],
  );

  static const moonshot = LlmProvider(
    id: 'moonshot',
    name: '月之暗面',
    defaultBaseUrl: 'https://api.moonshot.cn/v1',
    defaultModel: 'moonshot-v1-8k',
    availableModels: ['moonshot-v1-8k', 'moonshot-v1-32k', 'moonshot-v1-128k'],
  );

  static const xunfei = LlmProvider(
    id: 'xunfei',
    name: '讯飞星火',
    defaultBaseUrl: 'https://spark-api-open.xf-yun.com/v1',
    defaultModel: 'generalv3.5',
    availableModels: ['generalv3.5', 'generalv3', 'pro-128k'],
  );

  static const openai = LlmProvider(
    id: 'openai',
    name: 'OpenAI',
    defaultBaseUrl: 'https://api.openai.com/v1',
    defaultModel: 'gpt-4o-mini',
    availableModels: ['gpt-4o-mini', 'gpt-4o', 'gpt-3.5-turbo'],
  );

  static const custom = LlmProvider(
    id: 'custom',
    name: '自定义',
    defaultBaseUrl: '',
    defaultModel: '',
    availableModels: [],
  );

  /// 所有预设提供商
  static const List<LlmProvider> all = [
    deepseek,
    qwen,
    zhipu,
    moonshot,
    xunfei,
    openai,
    custom,
  ];

  /// 根据 ID 获取提供商
  static LlmProvider? getById(String id) {
    return all.where((p) => p.id == id).firstOrNull;
  }
}

/// 聊天消息
class ChatMessage {
  final String role; // system / user / assistant
  final String content;

  const ChatMessage({required this.role, required this.content});

  Map<String, String> toJson() => {'role': role, 'content': content};
}

/// LLM 请求
class LlmRequest {
  final List<ChatMessage> messages;
  final String? model;
  final double? temperature;
  final int? maxTokens;

  const LlmRequest({
    required this.messages,
    this.model,
    this.temperature,
    this.maxTokens,
  });
}

/// LLM 响应
class LlmResponse {
  final String content;
  final String model;
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  const LlmResponse({
    required this.content,
    required this.model,
    this.promptTokens = 0,
    this.completionTokens = 0,
    this.totalTokens = 0,
  });
}

/// 记账解析结果
class TransactionParseResult {
  final String type; // expense / income
  final double amount;
  final String category;
  final String? subcategory;
  final String description;
  final double confidence;
  final String? date;
  final String? note;

  const TransactionParseResult({
    required this.type,
    required this.amount,
    required this.category,
    this.subcategory,
    required this.description,
    required this.confidence,
    this.date,
    this.note,
  });
}

/// LLM 异常
class LlmException implements Exception {
  final String message;
  const LlmException(this.message);

  @override
  String toString() => 'LlmException: $message';
}
