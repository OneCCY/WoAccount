import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 用户自定义的 LLM 服务商配置
class LlmProvider {
  final String id; // 唯一标识
  final String name; // 服务商名称（如 "DeepSeek"、"通义千问"）
  final String apiKey; // API Key
  final String baseUrl; // 请求地址（如 https://api.deepseek.com/v1）
  final String model; // 模型名称（如 deepseek-chat）
  final double temperature; // 温度参数 0.0-1.0
  final int maxTokens; // 最大 token 数
  final int timeoutSeconds; // 超时时间（秒）
  final String providerKey; // 预设 key（如 'deepseek'）或 'custom'

  const LlmProvider({
    required this.id,
    required this.name,
    required this.apiKey,
    required this.baseUrl,
    required this.model,
    this.temperature = 0.0,
    this.maxTokens = 1000,
    this.timeoutSeconds = 30,
    this.providerKey = 'custom',
  });

  /// 是否配置完整（名称、API Key、地址、模型都非空）
  bool get isComplete =>
      name.isNotEmpty &&
      apiKey.isNotEmpty &&
      baseUrl.isNotEmpty &&
      model.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'apiKey': apiKey,
        'baseUrl': baseUrl,
        'model': model,
        'temperature': temperature,
        'maxTokens': maxTokens,
        'timeoutSeconds': timeoutSeconds,
        'providerKey': providerKey,
      };

  factory LlmProvider.fromJson(Map<String, dynamic> json) => LlmProvider(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        apiKey: json['apiKey'] as String? ?? '',
        baseUrl: json['baseUrl'] as String? ?? '',
        model: json['model'] as String? ?? '',
        temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
        maxTokens: json['maxTokens'] as int? ?? 1000,
        timeoutSeconds: json['timeoutSeconds'] as int? ?? 30,
        providerKey: json['providerKey'] as String? ?? 'custom',
      );

  LlmProvider copyWith({
    String? name,
    String? apiKey,
    String? baseUrl,
    String? model,
    double? temperature,
    int? maxTokens,
    int? timeoutSeconds,
    String? providerKey,
  }) {
    return LlmProvider(
      id: id,
      name: name ?? this.name,
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      model: model ?? this.model,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
      providerKey: providerKey ?? this.providerKey,
    );
  }
}

/// LLM 服务配置管理（本地存储）
class LlmConfigManager {
  static const _keyProviders = 'llm_providers';
  static const _keyActiveId = 'llm_active_provider_id';

  /// 加载所有用户配置的服务商
  static Future<List<LlmProvider>> loadProviders() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyProviders);
    if (jsonStr == null || jsonStr.isEmpty) return [];

    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list
          .map((e) => LlmProvider.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// 保存所有服务商配置
  static Future<void> saveProviders(List<LlmProvider> providers) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(providers.map((p) => p.toJson()).toList());
    await prefs.setString(_keyProviders, jsonStr);
  }

  /// 获取当前激活的服务商 ID
  static Future<String?> getActiveProviderId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyActiveId);
  }

  /// 设置当前激活的服务商
  static Future<void> setActiveProviderId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyActiveId, id);
  }

  /// 获取当前激活的服务商配置
  static Future<LlmProvider?> getActiveProvider() async {
    final providers = await loadProviders();
    if (providers.isEmpty) return null;

    final activeId = await getActiveProviderId();
    if (activeId != null) {
      final match = providers.where((p) => p.id == activeId);
      if (match.isNotEmpty) return match.first;
    }

    // 返回第一个配置完整的服务商
    return providers.where((p) => p.isComplete).firstOrNull ?? providers.first;
  }

  /// 添加服务商
  static Future<void> addProvider(LlmProvider provider) async {
    final providers = await loadProviders();
    providers.add(provider);
    await saveProviders(providers);

    // 如果是第一个，自动设为激活
    if (providers.length == 1) {
      await setActiveProviderId(provider.id);
    }
  }

  /// 更新服务商
  static Future<void> updateProvider(LlmProvider provider) async {
    final providers = await loadProviders();
    final index = providers.indexWhere((p) => p.id == provider.id);
    if (index != -1) {
      providers[index] = provider;
      await saveProviders(providers);
    }
  }

  /// 删除服务商
  static Future<void> deleteProvider(String id) async {
    final providers = await loadProviders();
    providers.removeWhere((p) => p.id == id);
    await saveProviders(providers);

    // 如果删除的是当前激活的，切换到第一个
    final activeId = await getActiveProviderId();
    if (activeId == id && providers.isNotEmpty) {
      await setActiveProviderId(providers.first.id);
    }
  }

  /// 导出所有配置为 JSON 字符串（用于数据备份/分享）
  static Future<String> exportConfig() async {
    final providers = await loadProviders();
    final activeId = await getActiveProviderId();
    final exportData = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'providers': providers.map((p) => p.toJson()).toList(),
      'activeProviderId': activeId,
    };
    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  /// 从 JSON 字符串导入配置
  /// 返回导入的服务商数量，失败返回 -1
  static Future<int> importConfig(String jsonStr) async {
    try {
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final list = data['providers'] as List<dynamic>;
      final providers = list
          .map((e) => LlmProvider.fromJson(e as Map<String, dynamic>))
          .toList();

      await saveProviders(providers);

      final activeId = data['activeProviderId'] as String?;
      if (activeId != null) {
        await setActiveProviderId(activeId);
      }

      return providers.length;
    } catch (_) {
      return -1;
    }
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
