/// AiAgent — Agent 预置定义（不可变）
///
/// 定义 Agent 的能力、推荐配置、测试用例。
/// 存储在代码中，不存 SharedPreferences。
enum ModelProfile {
  /// 快速低价（如 DeepSeek Chat）
  cheap,

  /// 均衡（如 GPT-4o-mini）
  balanced,

  /// 高质量（如 GPT-4o, Claude Opus）
  premium,
}

/// Agent 测试用例
class AgentTestCase {
  final String input;
  final Map<String, dynamic> expectedOutput;
  final List<String> mustIncludeFields;

  const AgentTestCase({
    required this.input,
    required this.expectedOutput,
    required this.mustIncludeFields,
  });
}

/// Agent 预置定义
class AiAgent {
  final String id;
  final String nameKey;
  final String descriptionKey;
  final String icon;
  final String systemPrompt;
  final List<String> builtinToolIds;
  final Map<String, dynamic>? outputSchema;
  final ModelProfile recommendedProfile;
  final List<AgentTestCase> testCases;
  final int defaultTimeout;

  const AiAgent({
    required this.id,
    required this.nameKey,
    required this.descriptionKey,
    required this.icon,
    this.systemPrompt = '',
    this.builtinToolIds = const [],
    this.outputSchema,
    this.recommendedProfile = ModelProfile.balanced,
    this.testCases = const [],
    this.defaultTimeout = 15,
  });
}
