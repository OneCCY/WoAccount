import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/ai_provider.dart';
import '../models/agent_config.dart';
import '../models/llm_config.dart';
import '../storage/provider_storage.dart';
import '../storage/agent_config_storage.dart';

/// 从 v1 格式迁移到 v2 格式
///
/// v1: LlmProvider 含 models Map，存在 llm_providers key 中
/// v2: AiProvider（无 models）+ AgentConfig（独立存储）
class ConfigMigration {
  static const _configVersionKey = 'ai_config_version';
  static const _currentVersion = 2;

  /// 检查是否需要迁移
  static Future<bool> needsMigration() async {
    final prefs = await SharedPreferences.getInstance();
    final version = prefs.getInt(_configVersionKey) ?? 1;
    return version < _currentVersion;
  }

  /// 执行迁移
  static Future<int> migrate() async {
    // 版本守卫：已迁移则跳过
    if (!await needsMigration()) return 0;

    final prefs = await SharedPreferences.getInstance();
    final oldJson = prefs.getString('llm_providers');
    if (oldJson == null || oldJson.isEmpty) {
      await _setVersion();
      return 0;
    }

    List<dynamic> oldList;
    try {
      oldList = jsonDecode(oldJson) as List;
    } catch (_) {
      // JSON 损坏，标记迁移完成避免反复重试
      await _setVersion();
      return 0;
    }
    if (oldList.isEmpty) {
      await _setVersion();
      return 0;
    }

    int migratedCount = 0;

    // 1. 逐个解析旧 Provider（单个失败不阻塞其余）
    final oldProviders = <LlmProvider>[];
    for (final entry in oldList) {
      try {
        oldProviders.add(LlmProvider.fromJson(entry as Map<String, dynamic>));
      } catch (_) {
        // 跳过损坏的条目
      }
    }

    // 2. 提取 agent_configs
    for (final old in oldProviders) {
      for (final entry in old.models.entries) {
        try {
          final capability = entry.key;
          final modelConfig = entry.value;
          final agentId = _capabilityToAgentId(capability);

          if (agentId != null &&
              modelConfig.modelName.isNotEmpty &&
              modelConfig.providerId != null &&
              modelConfig.providerId!.isNotEmpty) {
            final targetProviderId = modelConfig.providerId!;
            final existing = await AgentConfigStorage.load(agentId);
            if (existing == null) {
              await AgentConfigStorage.save(AgentConfig(
                agentId: agentId,
                providerId: targetProviderId,
                modelName: modelConfig.modelName,
              ));
              migratedCount++;
            }
          }
        } catch (_) {
          // 单条迁移失败不阻塞
        }
      }
    }

    // 3. 保存不含 models 的 AiProvider（仅 v2 存储为空时写入）
    final existingV2 = await ProviderStorage.loadAll();
    if (existingV2.isEmpty) {
      final newProviders = oldProviders.map((old) => AiProvider(
        id: old.id,
        name: old.name,
        apiKey: old.apiKey,
        baseUrl: old.baseUrl,
        providerKey: old.providerKey == 'custom' ? null : old.providerKey,
        temperature: old.temperature,
        maxTokens: old.maxTokens,
        timeoutSeconds: old.timeoutSeconds,
      )).toList();
      await ProviderStorage.saveAll(newProviders);
    }

    // 4. 补充缺失的 agent_config（从旧 models 中提取）
    for (final old in oldProviders) {
      for (final entry in old.models.entries) {
        try {
          final capability = entry.key;
          final modelConfig = entry.value;
          final agentId = _capabilityToAgentId(capability);

          if (agentId != null && modelConfig.modelName.isNotEmpty) {
            final existing = await AgentConfigStorage.load(agentId);
            if (existing == null) {
              await AgentConfigStorage.save(AgentConfig(
                agentId: agentId,
                providerId: old.id,
                modelName: modelConfig.modelName,
              ));
              migratedCount++;
            }
          }
        } catch (_) {
          // 单条失败不阻塞
        }
      }
    }

    // 5. 标记迁移完成并清理旧数据
    await _setVersion();
    await prefs.remove('llm_providers');

    return migratedCount;
  }

  /// 能力 → Agent ID 映射
  static String? _capabilityToAgentId(String capability) {
    switch (capability) {
      case 'text':
        return 'transaction_parser';
      case 'vision':
        return 'receipt_ocr';
      case 'audio':
        return 'voice_transcribe';
      default:
        return null;
    }
  }

  static Future<void> _setVersion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_configVersionKey, _currentVersion);
  }
}
