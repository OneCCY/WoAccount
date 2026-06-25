/// AgentConfig — 用户对每个 Agent 的个性化配置
///
/// 独立存储，与 Provider 解耦。
/// key 为 agentId，存储在 SharedPreferences 的 `llm_agent_configs` 中。
class AgentConfig {
  final String agentId;
  final String providerId;
  final String modelName;
  final String? fallbackProviderId;
  final String? fallbackModelName;
  final double? temperature;
  final int? maxTokens;
  final int? timeout;
  final bool enabled;

  const AgentConfig({
    required this.agentId,
    required this.providerId,
    required this.modelName,
    this.fallbackProviderId,
    this.fallbackModelName,
    this.temperature,
    this.maxTokens,
    this.timeout,
    this.enabled = true,
  });

  bool get hasFallback =>
      fallbackProviderId != null &&
      fallbackProviderId!.isNotEmpty &&
      fallbackModelName != null &&
      fallbackModelName!.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'agentId': agentId,
    'providerId': providerId,
    'modelName': modelName,
    if (fallbackProviderId != null) 'fallbackProviderId': fallbackProviderId,
    if (fallbackModelName != null) 'fallbackModelName': fallbackModelName,
    if (temperature != null) 'temperature': temperature,
    if (maxTokens != null) 'maxTokens': maxTokens,
    if (timeout != null) 'timeout': timeout,
    'enabled': enabled,
  };

  factory AgentConfig.fromJson(Map<String, dynamic> json) => AgentConfig(
    agentId: json['agentId'] as String? ?? '',
    providerId: json['providerId'] as String? ?? '',
    modelName: json['modelName'] as String? ?? '',
    fallbackProviderId: json['fallbackProviderId'] as String?,
    fallbackModelName: json['fallbackModelName'] as String?,
    temperature: (json['temperature'] as num?)?.toDouble(),
    maxTokens: json['maxTokens'] as int?,
    timeout: json['timeout'] as int?,
    enabled: json['enabled'] as bool? ?? true,
  );

  AgentConfig copyWith({
    String? agentId,
    String? providerId,
    String? modelName,
    String? fallbackProviderId,
    String? fallbackModelName,
    double? temperature,
    int? maxTokens,
    int? timeout,
    bool? enabled,
  }) => AgentConfig(
    agentId: agentId ?? this.agentId,
    providerId: providerId ?? this.providerId,
    modelName: modelName ?? this.modelName,
    fallbackProviderId: fallbackProviderId ?? this.fallbackProviderId,
    fallbackModelName: fallbackModelName ?? this.fallbackModelName,
    temperature: temperature ?? this.temperature,
    maxTokens: maxTokens ?? this.maxTokens,
    timeout: timeout ?? this.timeout,
    enabled: enabled ?? this.enabled,
  );
}
