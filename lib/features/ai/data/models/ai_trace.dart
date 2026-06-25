/// AiTrace — AI 调用追踪记录
///
/// 每次 Agent 调用记录一条 trace，用于统计、模型推荐、预算控制。
class AiTrace {
  final String id;
  final String agentId;
  final String providerId;
  final String modelName;
  final DateTime timestamp;
  final int latencyMs;
  final int? inputTokens;
  final int? outputTokens;
  final bool success;
  final String? errorCode;
  final bool fallbackUsed;
  final String? fallbackProviderId;
  final String? fallbackModelName;

  const AiTrace({
    required this.id,
    required this.agentId,
    required this.providerId,
    required this.modelName,
    required this.timestamp,
    required this.latencyMs,
    this.inputTokens,
    this.outputTokens,
    required this.success,
    this.errorCode,
    this.fallbackUsed = false,
    this.fallbackProviderId,
    this.fallbackModelName,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'agentId': agentId,
    'providerId': providerId,
    'modelName': modelName,
    'timestamp': timestamp.toIso8601String(),
    'latencyMs': latencyMs,
    if (inputTokens != null) 'inputTokens': inputTokens,
    if (outputTokens != null) 'outputTokens': outputTokens,
    'success': success,
    if (errorCode != null) 'errorCode': errorCode,
    'fallbackUsed': fallbackUsed,
    if (fallbackProviderId != null) 'fallbackProviderId': fallbackProviderId,
    if (fallbackModelName != null) 'fallbackModelName': fallbackModelName,
  };

  factory AiTrace.fromJson(Map<String, dynamic> json) => AiTrace(
    id: json['id'] as String? ?? '',
    agentId: json['agentId'] as String? ?? '',
    providerId: json['providerId'] as String? ?? '',
    modelName: json['modelName'] as String? ?? '',
    timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
        DateTime.now(),
    latencyMs: json['latencyMs'] as int? ?? 0,
    inputTokens: json['inputTokens'] as int?,
    outputTokens: json['outputTokens'] as int?,
    success: json['success'] as bool? ?? false,
    errorCode: json['errorCode'] as String?,
    fallbackUsed: json['fallbackUsed'] as bool? ?? false,
    fallbackProviderId: json['fallbackProviderId'] as String?,
    fallbackModelName: json['fallbackModelName'] as String?,
  );
}
