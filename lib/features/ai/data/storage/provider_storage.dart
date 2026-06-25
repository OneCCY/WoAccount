import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ai_provider.dart';

/// AiProvider 存储层（v2.0）
///
/// 独立于旧 LlmConfigManager，使用新的 SharedPreferences key。
class ProviderStorage {
  static const _keyProviders = 'ai_v2_providers';
  static const _keyFetchedModels = 'ai_v2_fetched_models';

  /// 加载所有供应商
  static Future<List<AiProvider>> loadAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_keyProviders);
      if (jsonStr == null || jsonStr.isEmpty) return [];
      final list = jsonDecode(jsonStr) as List;
      return list
          .map((e) => AiProvider.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// 保存所有供应商
  static Future<void> saveAll(List<AiProvider> providers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyProviders,
      jsonEncode(providers.map((p) => p.toJson()).toList()),
    );
  }

  /// 按 ID 查找
  static Future<AiProvider?> getById(String id) async {
    final all = await loadAll();
    for (final p in all) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// 添加供应商
  static Future<void> add(AiProvider provider) async {
    final all = await loadAll();
    all.add(provider);
    await saveAll(all);
  }

  /// 更新供应商
  static Future<void> update(AiProvider provider) async {
    final all = await loadAll();
    final idx = all.indexWhere((p) => p.id == provider.id);
    if (idx >= 0) {
      all[idx] = provider;
      await saveAll(all);
    }
  }

  /// 删除供应商
  static Future<void> delete(String id) async {
    final all = await loadAll();
    all.removeWhere((p) => p.id == id);
    await saveAll(all);
  }

  /// 缓存从 API 拉取的模型列表
  static Future<void> saveFetchedModels(
    String providerId,
    List<String> models,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> map;
    try {
      final raw = prefs.getString(_keyFetchedModels);
      map = raw != null ? Map<String, dynamic>.from(jsonDecode(raw)) : <String, dynamic>{};
    } catch (_) {
      map = <String, dynamic>{};
    }
    map[providerId] = models;
    await prefs.setString(_keyFetchedModels, jsonEncode(map));
  }

  /// 读取缓存的模型列表
  static Future<List<String>> loadFetchedModels(String providerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyFetchedModels);
      if (raw == null) return [];
      final map = Map<String, dynamic>.from(jsonDecode(raw));
      final list = map[providerId] as List?;
      return list?.cast<String>() ?? [];
    } catch (_) {
      return [];
    }
  }
}
