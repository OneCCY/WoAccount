import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wo_account/l10n/app_localizations.dart';

import '../../data/models/ai_agent.dart';
import '../../data/models/agent_config.dart';
import '../../data/models/ai_provider.dart';
import '../../data/storage/agent_config_storage.dart';
import '../../data/storage/provider_storage.dart';
import '../../domain/agent_registry.dart';
import '../../data/storage/model_fetcher.dart';

/// Agent 配置编辑页
///
/// 允许用户为每个 Agent 配置主模型和备选模型。
class AgentEditPage extends ConsumerStatefulWidget {
  final String agentId;
  const AgentEditPage({super.key, required this.agentId});

  @override
  ConsumerState<AgentEditPage> createState() => _AgentEditPageState();
}

class _AgentEditPageState extends ConsumerState<AgentEditPage> {
  AiAgent? _agent;
  AgentConfig? _config;
  List<AiProvider> _providers = [];
  List<String> _fetchedModels = [];
  bool _isLoading = true;
  bool _showFallback = false;

  // 主模型选择
  String? _selectedProviderId;
  String? _selectedModel;

  // 备选模型选择
  String? _fallbackProviderId;
  String? _fallbackModel;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final agent = AgentRegistry.get(widget.agentId);
    final config = await AgentConfigStorage.load(widget.agentId);
    final providers = await ProviderStorage.loadAll();

    setState(() {
      _agent = agent;
      _config = config;
      _providers = providers.where((p) => p.isReady).toList();
      _selectedProviderId = config?.providerId;
      _selectedModel = config?.modelName;
      _fallbackProviderId = config?.fallbackProviderId;
      _fallbackModel = config?.fallbackModelName;
      _showFallback = config?.hasFallback ?? false;
      _isLoading = false;
    });

    if (_selectedProviderId != null) {
      _fetchModels(_selectedProviderId!);
    }
  }

  Future<void> _fetchModels(String providerId) async {
    final provider = _providers.firstWhere(
      (p) => p.id == providerId,
      orElse: () => _providers.first,
    );
    final models = await ModelFetcher.fetchAndCache(
      providerId,
      provider.baseUrl,
      provider.apiKey,
    );
    if (mounted) {
      setState(() => _fetchedModels = models);
    }
  }

  Future<void> _save() async {
    if (_selectedProviderId == null || _selectedModel == null || _selectedModel!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.agentEditSelectModel)),
      );
      return;
    }

    final config = AgentConfig(
      agentId: widget.agentId,
      providerId: _selectedProviderId!,
      modelName: _selectedModel!,
      fallbackProviderId: _showFallback ? _fallbackProviderId : null,
      fallbackModelName: _showFallback ? _fallbackModel : null,
    );

    await AgentConfigStorage.save(config);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.agentEditSaved)),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final agent = _agent;

    if (_isLoading || agent == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.agentEditTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${agent.icon} ${_getAgentName(l10n, agent)}'),
        actions: [
          TextButton(onPressed: _save, child: Text(l10n.agentEditSave)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Agent 描述
          Text(
            _getAgentDesc(l10n, agent),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          _buildProfileChip(agent.recommendedProfile),
          const SizedBox(height: 24),

          // 主模型配置
          _buildSectionTitle(l10n.agentEditPrimaryModel),
          _buildProviderDropdown(
            value: _selectedProviderId,
            onChanged: (id) {
              setState(() {
                _selectedProviderId = id;
                _selectedModel = null;
                _fetchedModels = [];
              });
              if (id != null) _fetchModels(id);
            },
          ),
          const SizedBox(height: 8),
          _buildModelDropdown(
            value: _selectedModel,
            onChanged: (v) => setState(() => _selectedModel = v),
          ),
          const SizedBox(height: 24),

          // 备选模型配置
          _buildSectionTitle(l10n.agentEditFallbackModel),
          SwitchListTile(
            title: Text(l10n.agentEditEnableFallback),
            value: _showFallback,
            onChanged: (v) => setState(() => _showFallback = v),
            contentPadding: EdgeInsets.zero,
          ),
          if (_showFallback) ...[
            _buildProviderDropdown(
              value: _fallbackProviderId,
              onChanged: (id) => setState(() {
                _fallbackProviderId = id;
                _fallbackModel = null;
              }),
            ),
            const SizedBox(height: 8),
            _buildModelDropdown(
              value: _fallbackModel,
              onChanged: (v) => setState(() => _fallbackModel = v),
            ),
          ],
          const SizedBox(height: 24),

          // 测试用例
          if (agent.testCases.isNotEmpty) ...[
            _buildSectionTitle(l10n.agentEditTestCases),
            ...agent.testCases.asMap().entries.map((entry) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l10n.agentEditTestCase} ${entry.key + 1}',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '"${entry.value.input}"',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleSmall),
    );
  }

  Widget _buildProviderDropdown({
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: _providers.any((p) => p.id == value) ? value : null,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.agentEditProvider,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: _providers.map((p) => DropdownMenuItem(
        value: p.id,
        child: Text(p.name),
      )).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildModelDropdown({
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    final items = <DropdownMenuItem<String>>[];
    if (_fetchedModels.isNotEmpty) {
      items.addAll(_fetchedModels.map((m) => DropdownMenuItem(
        value: m,
        child: Text(m, overflow: TextOverflow.ellipsis),
      )));
    }
    // 手动输入选项
    return DropdownButtonFormField<String>(
      value: (value != null && (value.isEmpty || items.any((i) => i.value == value))) ? value : null,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.agentEditModel,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: items,
      onChanged: (v) {
        if (v == '__manual__') {
          _showManualInputDialog(onChanged);
        } else {
          onChanged(v);
        }
      },
    );
  }

  void _showManualInputDialog(ValueChanged<String?> onChanged) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.agentEditManualInput),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.agentEditModelNameHint,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              onChanged(controller.text.trim());
              Navigator.pop(ctx);
            },
            child: Text(AppLocalizations.of(context)!.confirm),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileChip(ModelProfile profile) {
    final (label, color) = switch (profile) {
      ModelProfile.cheap => ('cheap', Colors.green),
      ModelProfile.balanced => ('balanced', Colors.orange),
      ModelProfile.premium => ('premium', Colors.purple),
    };
    return Chip(
      label: Text(label, style: TextStyle(color: color, fontSize: 12)),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
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

  String _getAgentDesc(AppLocalizations l10n, AiAgent agent) {
    return switch (agent.id) {
      'transaction_parser' => l10n.agentTransactionParserDesc,
      'receipt_ocr' => l10n.agentReceiptOcrDesc,
      'voice_transcribe' => l10n.agentVoiceTranscribeDesc,
      'finance_search' => l10n.agentFinanceSearchDesc,
      _ => '',
    };
  }
}
