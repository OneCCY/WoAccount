import 'dart:convert';
import 'package:flutter/services.dart';

/// AI 角色系统配置加载器
/// 从 assets/config/ 读取 JSON 配置文件，运行时热加载
class PersonaConfigLoader {
  static Map<String, dynamic>? _triggers;
  static Map<String, dynamic>? _extraction;
  static Map<String, dynamic>? _prompt;

  /// 加载触发词配置
  static Future<List<String>> loadRecallTriggers() async {
    if (_triggers != null) {
      return List<String>.from(_triggers!['recall_triggers'] ?? []);
    }
    try {
      final jsonStr = await rootBundle.loadString('assets/config/persona_triggers.json');
      _triggers = jsonDecode(jsonStr) as Map<String, dynamic>;
      return List<String>.from(_triggers!['recall_triggers'] ?? _defaultTriggers);
    } catch (_) {
      return _defaultTriggers;
    }
  }

  static Future<List<String>> loadAutoTriggerPatterns() async {
    if (_triggers != null) {
      return List<String>.from(_triggers!['auto_trigger_patterns'] ?? []);
    }
    try {
      final jsonStr = await rootBundle.loadString('assets/config/persona_triggers.json');
      _triggers = jsonDecode(jsonStr) as Map<String, dynamic>;
      return List<String>.from(_triggers!['auto_trigger_patterns'] ?? []);
    } catch (_) {
      return [];
    }
  }

  /// 加载记忆提取 Prompt
  static Future<String> loadExtractionPrompt() async {
    if (_extraction != null) {
      return _extraction!['user_prompt'] as String? ?? '';
    }
    try {
      final jsonStr = await rootBundle.loadString('assets/config/memory_extraction.json');
      _extraction = jsonDecode(jsonStr) as Map<String, dynamic>;
      return _extraction!['user_prompt'] as String? ?? '';
    } catch (_) {
      return '';
    }
  }

  /// 加载角色 Prompt 配置
  static Future<Map<String, dynamic>> loadPromptConfig() async {
    if (_prompt != null) return _prompt!;
    try {
      final jsonStr = await rootBundle.loadString('assets/config/persona_prompt.json');
      _prompt = jsonDecode(jsonStr) as Map<String, dynamic>;
      return _prompt!;
    } catch (_) {
      return {};
    }
  }

  /// 获取配置中的 token 预算
  static Future<int> loadConversationMaxTokens() async {
    final config = await loadPromptConfig();
    return (config['conversation_budget_max_tokens'] as num?)?.toInt() ?? 100000;
  }

  /// 获取配置中的最大条数
  static Future<int> loadConversationMaxCount() async {
    final config = await loadPromptConfig();
    return (config['conversation_budget_max_count'] as num?)?.toInt() ?? 500;
  }

  static const _defaultTriggers = [
    '之前', '上次', '那个', '还记得', '以前',
    '昨天', '上周', '上个月', '刚才', '你说过',
    'last', 'before', 'again', 'remember',
    '我叫', '名字', '年龄', '几岁', '哪里',
    '喜欢', '不爱', '习惯', '生日', '家住',
  ];
}