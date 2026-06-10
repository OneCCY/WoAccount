import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wo_account/l10n/app_localizations.dart';

// ============================================================
// 模型能力枚举
// ============================================================

/// AI 模型能力类型
enum ModelCapability {
  /// 文本模型 — 用于记账解析、AI 对话
  text(
    '文本模型',
    '用于记账解析、AI 对话',
    Icons.text_fields,
    '📝',
    [], // 文本能力不做关键词筛选
  ),

  /// 视觉模型 — 用于拍照识别小票/发票
  vision(
    '视觉模型',
    '用于拍照识别小票/发票',
    Icons.image,
    '👁',
    ['vision', 'gpt-4o', 'gpt-4.1', 'claude-sonnet', 'claude-opus', 'qwen-vl', 'glm-4v', 'internvl', 'deepseek-vl'],
  ),

  /// 语音模型 — 用于语音转文字
  audio(
    '语音模型',
    '用于语音转文字',
    Icons.mic,
    '🎤',
    ['whisper', 'tts', 'audio', 'asr', 'sense-voice', 'paraformer'],
  );

  final String label;
  final String description;
  final IconData icon;
  final String emoji;
  final List<String> filterKeywords;

  const ModelCapability(this.label, this.description, this.icon, this.emoji, this.filterKeywords);

  /// Returns the localized label for this capability.
  String getLocalizedLabel(AppLocalizations l10n) {
    switch (this) {
      case ModelCapability.text:
        return l10n.llmCapTextLabel;
      case ModelCapability.vision:
        return l10n.llmCapVisionLabel;
      case ModelCapability.audio:
        return l10n.llmCapAudioLabel;
    }
  }

  /// Returns the localized description for this capability.
  String getLocalizedDesc(AppLocalizations l10n) {
    switch (this) {
      case ModelCapability.text:
        return l10n.llmCapTextDesc;
      case ModelCapability.vision:
        return l10n.llmCapVisionDesc;
      case ModelCapability.audio:
        return l10n.llmCapAudioDesc;
    }
  }
}

// ============================================================
// 单个模型配置
// ============================================================

class ModelConfig {
  final String modelName;

  const ModelConfig({required this.modelName});

  Map<String, dynamic> toJson() => {'modelName': modelName};

  factory ModelConfig.fromJson(Map<String, dynamic> json) =>
      ModelConfig(modelName: json['modelName'] as String? ?? '');
}

// ============================================================
// 用户自定义的 LLM 服务商配置
// ============================================================

class LlmProvider {
  final String id;
  final String name;
  final String apiKey;
  final String baseUrl;
  final double temperature;
  final int maxTokens;
  final int timeoutSeconds;
  final String providerKey;

  /// 按能力分组的模型配置
  final Map<String, ModelConfig> models;

  const LlmProvider({
    required this.id,
    required this.name,
    required this.apiKey,
    required this.baseUrl,
    this.temperature = 0.0,
    this.maxTokens = 1000,
    this.timeoutSeconds = 30,
    this.providerKey = 'custom',
    this.models = const {},
  });

  /// 是否配置完整（至少配置了一个模型）
  bool get isComplete =>
      name.isNotEmpty &&
      apiKey.isNotEmpty &&
      baseUrl.isNotEmpty &&
      models.values.any((m) => m.modelName.isNotEmpty);

  /// 获取指定能力的模型名称
  String? getModelForCapability(ModelCapability capability) {
    final config = models[capability.name];
    if (config != null && config.modelName.isNotEmpty) return config.modelName;
    return null;
  }

  /// 获取所有已配置的能力列表
  List<ModelCapability> get configuredCapabilities {
    return ModelCapability.values.where((cap) => getModelForCapability(cap) != null).toList();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'apiKey': apiKey,
        'baseUrl': baseUrl,
        'temperature': temperature,
        'maxTokens': maxTokens,
        'timeoutSeconds': timeoutSeconds,
        'providerKey': providerKey,
        'models': models.map((k, v) => MapEntry(k, v.toJson())),
      };

  factory LlmProvider.fromJson(Map<String, dynamic> json) {
    final modelsJson = json['models'] as Map<String, dynamic>? ?? {};
    final models = <String, ModelConfig>{};
    for (final entry in modelsJson.entries) {
      if (entry.value is Map<String, dynamic>) {
        models[entry.key] = ModelConfig.fromJson(entry.value as Map<String, dynamic>);
      }
    }

    return LlmProvider(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      apiKey: json['apiKey'] as String? ?? '',
      baseUrl: json['baseUrl'] as String? ?? '',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      maxTokens: json['maxTokens'] as int? ?? 1000,
      timeoutSeconds: json['timeoutSeconds'] as int? ?? 30,
      providerKey: json['providerKey'] as String? ?? 'custom',
      models: models,
    );
  }

  LlmProvider copyWith({
    String? name,
    String? apiKey,
    String? baseUrl,
    double? temperature,
    int? maxTokens,
    int? timeoutSeconds,
    String? providerKey,
    Map<String, ModelConfig>? models,
  }) {
    return LlmProvider(
      id: id,
      name: name ?? this.name,
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
      providerKey: providerKey ?? this.providerKey,
      models: models ?? this.models,
    );
  }
}

// ============================================================
// LLM 服务配置管理（本地存储）
// ============================================================

class LlmConfigManager {
  static const _keyProviders = 'llm_providers';
  static const _keyActiveId = 'llm_active_provider_id';

  static Future<List<LlmProvider>> loadProviders() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyProviders);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((e) => LlmProvider.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveProviders(List<LlmProvider> providers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProviders, jsonEncode(providers.map((p) => p.toJson()).toList()));
  }

  static Future<String?> getActiveProviderId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyActiveId);
  }

  static Future<void> setActiveProviderId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyActiveId, id);
  }

  static Future<LlmProvider?> getActiveProvider() async {
    final providers = await loadProviders();
    if (providers.isEmpty) return null;
    final activeId = await getActiveProviderId();
    if (activeId != null) {
      final match = providers.where((p) => p.id == activeId);
      if (match.isNotEmpty) return match.first;
    }
    return providers.where((p) => p.isComplete).firstOrNull ?? providers.first;
  }

  static Future<void> addProvider(LlmProvider provider) async {
    final providers = await loadProviders();
    providers.add(provider);
    await saveProviders(providers);
    if (providers.length == 1) await setActiveProviderId(provider.id);
  }

  static Future<void> updateProvider(LlmProvider provider) async {
    final providers = await loadProviders();
    final index = providers.indexWhere((p) => p.id == provider.id);
    if (index != -1) {
      providers[index] = provider;
      await saveProviders(providers);
    }
  }

  static Future<void> deleteProvider(String id) async {
    final providers = await loadProviders();
    providers.removeWhere((p) => p.id == id);
    await saveProviders(providers);
    final activeId = await getActiveProviderId();
    if (activeId == id && providers.isNotEmpty) {
      await setActiveProviderId(providers.first.id);
    }
  }

  static Future<String> exportConfig() async {
    final providers = await loadProviders();
    final activeId = await getActiveProviderId();
    return const JsonEncoder.withIndent('  ').convert({
      'version': 2,
      'exportedAt': DateTime.now().toIso8601String(),
      'providers': providers.map((p) => p.toJson()).toList(),
      'activeProviderId': activeId,
    });
  }

  static Future<int> importConfig(String jsonStr) async {
    try {
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final providers = (data['providers'] as List<dynamic>)
          .map((e) => LlmProvider.fromJson(e as Map<String, dynamic>))
          .toList();
      await saveProviders(providers);
      final activeId = data['activeProviderId'] as String?;
      if (activeId != null) await setActiveProviderId(activeId);
      return providers.length;
    } catch (_) {
      return -1;
    }
  }
}

// ============================================================
// 聊天消息 / 请求 / 响应
// ============================================================

class ChatMessage {
  final String role;
  final String content;

  const ChatMessage({required this.role, required this.content});

  Map<String, String> toJson() => {'role': role, 'content': content};
}

class LlmRequest {
  final List<ChatMessage> messages;
  final String? model;
  final double? temperature;
  final int? maxTokens;
  final ModelCapability? capability;

  const LlmRequest({
    required this.messages,
    this.model,
    this.temperature,
    this.maxTokens,
    this.capability,
  });
}

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

class TransactionParseResult {
  final String type;
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

class LlmException implements Exception {
  final String message;
  const LlmException(this.message);

  @override
  String toString() => 'LlmException: $message';
}
