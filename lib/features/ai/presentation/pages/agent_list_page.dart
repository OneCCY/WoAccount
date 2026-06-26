import 'package:flutter/material.dart';
import 'package:wo_account/l10n/app_localizations.dart';

import '../../data/models/ai_agent.dart';
import '../../data/models/ai_provider.dart';
import '../../data/models/agent_config.dart';
import '../../data/storage/agent_config_storage.dart';
import '../../data/storage/provider_storage.dart';
import '../../domain/agent_registry.dart';
import 'agent_edit_page.dart';

/// 功能配置列表页
class AgentListPage extends StatefulWidget {
  const AgentListPage({super.key});

  @override
  State<AgentListPage> createState() => _AgentListPageState();
}

class _AgentListPageState extends State<AgentListPage> {
  List<AiProvider> _providers = [];
  Map<String, AgentConfig> _agentConfigs = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final providers = await ProviderStorage.loadAll();
    final configs = await AgentConfigStorage.loadAll();
    if (mounted) {
      setState(() {
        _providers = providers;
        _agentConfigs = configs;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aiSettingsAgents)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: AgentRegistry.all.length,
              itemBuilder: (ctx, i) => _buildAgentCard(AgentRegistry.all[i], l10n),
            ),
    );
  }

  Widget _buildAgentCard(AiAgent agent, AppLocalizations l10n) {
    final config = _agentConfigs[agent.id];
    final isConfigured = config != null &&
        config.providerId.isNotEmpty &&
        config.modelName.isNotEmpty;

    final agentConfig = isConfigured ? config : null;
    final providerName = agentConfig != null
        ? _providers.where((p) => p.id == agentConfig.providerId).firstOrNull?.name ?? agentConfig.providerId
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(agent.icon, style: const TextStyle(fontSize: 28)),
        title: Text(_getAgentName(l10n, agent)),
        subtitle: isConfigured && agentConfig != null
            ? Text('$providerName / ${agentConfig.modelName}')
            : Text(l10n.aiSettingsNoAgents,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final result = await Navigator.push(context,
            MaterialPageRoute(builder: (_) => AgentEditPage(agentId: agent.id)),
          );
          if (result == true) _load();
        },
      ),
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
