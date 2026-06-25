import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/agent_config.dart';

/// AgentConfig 存储层
///
/// 存储用户对每个 Agent 的个性化配置。
/// SharedPreferences key: `llm_agent_configs`
class AgentConfigStorage {
  static const _key = 'llm_agent_configs';

  /// 加载所有 Agent 配置
  static Future<Map<String, AgentConfig>> loadAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_key);
      if (jsonStr == null || jsonStr.isEmpty) return {};
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return map.map(
        (k, v) => MapEntry(k, AgentConfig.fromJson(v as Map<String, dynamic>)),
      );
    } catch (_) {
      return {};
    }
  }

  /// 保存所有 Agent 配置
  static Future<void> saveAll(Map<String, AgentConfig> configs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(configs.map((k, v) => MapEntry(k, v.toJson()))),
    );
  }

  /// 加载单个 Agent 配置
  static Future<AgentConfig?> load(String agentId) async {
    final all = await loadAll();
    return all[agentId];
  }

  /// 保存单个 Agent 配置
  static Future<void> save(AgentConfig config) async {
    final all = await loadAll();
    all[config.agentId] = config;
    await saveAll(all);
  }

  /// 删除单个 Agent 配置
  static Future<void> delete(String agentId) async {
    final all = await loadAll();
    all.remove(agentId);
    await saveAll(all);
  }

  /// 检查指定 Agent 是否已配置
  static Future<bool> isConfigured(String agentId) async {
    final config = await load(agentId);
    return config != null && config.providerId.isNotEmpty && config.modelName.isNotEmpty;
  }
}
