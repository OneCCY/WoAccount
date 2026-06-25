/// ToolRegistry — 内置工具注册表
///
/// 管理 Agent 可调用的内置工具。
/// 工具在 AgentRunner 执行前注入到 LLM 请求中。
class ToolRegistry {
  ToolRegistry._();

  static final Map<String, BuiltinTool> _tools = {};

  /// 注册工具
  static void register(BuiltinTool tool) {
    _tools[tool.id] = tool;
  }

  /// 获取工具
  static BuiltinTool? get(String toolId) => _tools[toolId];

  /// 按 ID 列表获取工具
  static List<BuiltinTool> getToolsByIds(List<String> toolIds) {
    return toolIds
        .map((id) => _tools[id])
        .whereType<BuiltinTool>()
        .toList();
  }

  /// 所有已注册工具
  static List<BuiltinTool> get all => _tools.values.toList();
}

/// 内置工具抽象基类
abstract class BuiltinTool {
  /// 工具 ID（如 'get_categories'）
  String get id;

  /// 工具名称（给 LLM 看的）
  String get name;

  /// 工具描述（给 LLM 看的）
  String get description;

  /// JSON Schema 参数定义
  Map<String, dynamic> get schema;

  /// 执行工具
  Future<dynamic> execute(Map<String, dynamic> params);
}
