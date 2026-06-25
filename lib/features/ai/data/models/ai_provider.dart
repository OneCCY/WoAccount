/// AiProvider — 供应商数据模型（v2.0 纯连接配置）
///
/// 不包含模型信息，只负责连接和认证。
/// 模型配置由 AgentConfig 独立管理。
class AiProvider {
  final String id;
  final String name;
  final String apiKey;
  final String baseUrl;
  final String? providerKey;
  final double temperature;
  final int maxTokens;
  final int timeoutSeconds;

  const AiProvider({
    required this.id,
    required this.name,
    required this.apiKey,
    required this.baseUrl,
    this.providerKey,
    this.temperature = 0.0,
    this.maxTokens = 1000,
    this.timeoutSeconds = 30,
  });

  /// 连通性判断：只需 name + apiKey + baseUrl 非空
  bool get isReady => name.isNotEmpty && apiKey.isNotEmpty && baseUrl.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'apiKey': apiKey,
    'baseUrl': baseUrl,
    if (providerKey != null) 'providerKey': providerKey,
    'temperature': temperature,
    'maxTokens': maxTokens,
    'timeoutSeconds': timeoutSeconds,
  };

  factory AiProvider.fromJson(Map<String, dynamic> json) => AiProvider(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    apiKey: json['apiKey'] as String? ?? '',
    baseUrl: json['baseUrl'] as String? ?? '',
    providerKey: json['providerKey'] as String?,
    temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
    maxTokens: json['maxTokens'] as int? ?? 1000,
    timeoutSeconds: json['timeoutSeconds'] as int? ?? 30,
  );

  AiProvider copyWith({
    String? id,
    String? name,
    String? apiKey,
    String? baseUrl,
    String? providerKey,
    double? temperature,
    int? maxTokens,
    int? timeoutSeconds,
  }) => AiProvider(
    id: id ?? this.id,
    name: name ?? this.name,
    apiKey: apiKey ?? this.apiKey,
    baseUrl: baseUrl ?? this.baseUrl,
    providerKey: providerKey ?? this.providerKey,
    temperature: temperature ?? this.temperature,
    maxTokens: maxTokens ?? this.maxTokens,
    timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
  );
}
