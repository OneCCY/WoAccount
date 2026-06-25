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
    final prefs = await SharedPreferences.getInstance();
    final oldJson = prefs.getString('llm_providers');
    if (oldJson == null || oldJson.isEmpty) {
      await _setVersion();
      return 0;
    }

    final oldList = jsonDecode(oldJson) as List;
    if (oldList.isEmpty) {
      await _setVersion();
      return 0;
    }

    int migratedCount = 0;

    // 1. 解析旧 Provider 列表
    final oldProviders = oldList
        .map((e) => LlmProvider.fromJson(e as Map<String, dynamic>))
        .toList();

    // 2. 提取 agent_configs
    for (final old in oldProviders) {
      for (final entry in old.models.entries) {
        final capability = entry.key;
        final modelConfig = entry.value;
        final agentId = _capabilityToAgentId(capability);

        if (agentId != null &&
            modelConfig.modelName.isNotEmpty &&
            modelConfig.providerId != null &&
            modelConfig.providerId!.isNotEmpty) {
          // 找到实际的 provider（可能是另一个 provider）
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
      }
    }

    // 3. 保存不含 models 的 AiProvider
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

    // 4. 对于没有 agent_config 的旧配置，尝试从旧 models 中提取默认配置
    for (final old in oldProviders) {
      for (final entry in old.models.entries) {
        final capability = entry.key;
        final modelConfig = entry.value;
        final agentId = _capabilityToAgentId(capability);

        if (agentId != null && modelConfig.modelName.isNotEmpty) {
          final existing = await AgentConfigStorage.load(agentId);
          if (existing == null) {
            // 模型配置在当前 provider 上，直接使用
            await AgentConfigStorage.save(AgentConfig(
              agentId: agentId,
              providerId: old.id,
              modelName: modelConfig.modelName,
            ));
            migratedCount++;
          }
        }
      }
    }

    // 5. 标记迁移完成
    await _setVersion();

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
