import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wo_account/l10n/app_localizations.dart';

import '../../data/models/ai_agent.dart';
import '../../data/models/ai_provider.dart';
import '../../data/models/agent_config.dart';
import '../../data/storage/agent_config_storage.dart';
import '../../data/storage/provider_storage.dart';
import '../../data/storage/trace_storage.dart';
import '../../domain/agent_registry.dart';
import 'agent_edit_page.dart';
import 'supplier_management_page.dart';

/// AI 设置主入口页（v2.0）
///
/// 显示：供应商列表 + Agent 配置列表 + 用量概览
class LlmSettingsPageV2 extends ConsumerStatefulWidget {
  const LlmSettingsPageV2({super.key});

  @override
  ConsumerState<LlmSettingsPageV2> createState() => _LlmSettingsPageV2State();
}

class _LlmSettingsPageV2State extends ConsumerState<LlmSettingsPageV2> {
  List<AiProvider> _providers = [];
  Map<String, AgentConfig> _agentConfigs = {};
  ({int total, int success, int fallbackUsed})? _monthlyStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final providers = await ProviderStorage.loadAll();
    final configs = await AgentConfigStorage.loadAll();
    final stats = await TraceStorage.monthlyStats();
    if (mounted) {
      setState(() {
        _providers = providers;
        _agentConfigs = configs;
        _monthlyStats = stats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aiSettingsTitle)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 供应商概览
                  _buildSupplierSection(l10n),
                  const SizedBox(height: 16),

                  // Agent 配置列表
                  _buildAgentSection(l10n),
                  const SizedBox(height: 16),

                  // 用量概览
                  if (_monthlyStats != null) _buildUsageSection(l10n),
                ],
              ),
            ),
    );
  }

  Widget _buildSupplierSection(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.aiSettingsSuppliers,
                    style: Theme.of(context).textTheme.titleMedium),
                Text('${_providers.length}',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 8),
            if (_providers.isEmpty)
              Text(l10n.aiSettingsNoAgents,
                  style: Theme.of(context).textTheme.bodySmall)
            else
              ..._providers.take(3).map((p) => _buildSupplierTile(p)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SupplierManagementPageV2()),
                  );
                  _load();
                },
                icon: const Icon(Icons.settings, size: 18),
                label: Text(l10n.aiSettingsSuppliers),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplierTile(AiProvider provider) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: provider.isReady
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        child: Icon(
          provider.isReady ? Icons.check_circle : Icons.error_outline,
          size: 18,
          color: provider.isReady ? Colors.green : Colors.red,
        ),
      ),
      title: Text(provider.name, style: const TextStyle(fontSize: 14)),
      subtitle: Text(
        Uri.tryParse(provider.baseUrl)?.host ?? provider.baseUrl,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildAgentSection(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.aiSettingsAgents,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...AgentRegistry.all.map((agent) => _buildAgentTile(agent, l10n)),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentTile(AiAgent agent, AppLocalizations l10n) {
    final config = _agentConfigs[agent.id];
    final isConfigured = config != null &&
        config.providerId.isNotEmpty &&
        config.modelName.isNotEmpty;

    final providerName = isConfigured
        ? _providers.where((p) => p.id == config!.providerId).firstOrNull?.name ?? config!.providerId
        : null;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Text(agent.icon, style: const TextStyle(fontSize: 24)),
      title: Text(_getAgentName(l10n, agent)),
      subtitle: isConfigured
          ? Text('$providerName / ${config!.modelName}',
              style: const TextStyle(fontSize: 12))
          : Text(l10n.aiSettingsNoAgents,
              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.error)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final result = await Navigator.push(context,
          MaterialPageRoute(builder: (_) => AgentEditPage(agentId: agent.id)),
        );
        if (result == true) _load();
      },
    );
  }

  Widget _buildUsageSection(AppLocalizations l10n) {
    final stats = _monthlyStats!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.aiSettingsUsage,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildStatChip('${stats.total}', l10n.aiSettingsUsageCalls),
                const SizedBox(width: 12),
                _buildStatChip('${stats.success}', l10n.aiSettingsConnected),
                const SizedBox(width: 12),
                _buildStatChip('${stats.fallbackUsed}', l10n.aiSettingsUsageFallback),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String value, String label) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  String _getAgentName(AppLocalizations l10n, AiAgent agent) {
    return switch (agent.id) {
      'transaction_parser' => l10n.agentTransactionParser,
      'receipt_ocr' => l10n.agentReceiptOcr,
      'voice_transcribe' => l10n.agentVoiceTranscribe,
      'finance_search' => l10n.agentFinanceSearch,
      _ => agent.id,
    };
  }
}
