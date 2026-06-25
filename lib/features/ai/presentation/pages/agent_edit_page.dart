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
class AgentEditPage extends ConsumerStatefulWidget {
  final String agentId;
  const AgentEditPage({super.key, required this.agentId});

  @override
  ConsumerState<AgentEditPage> createState() => _AgentEditPageState();
}

class _AgentEditPageState extends ConsumerState<AgentEditPage> {
  AiAgent? _agent;
  List<AiProvider> _providers = [];
  bool _isLoading = true;

  // 主模型
  String? _selectedProviderId;
  String? _selectedModel;
  List<String> _fetchedModels = [];
  bool _isLoadingModels = false;

  // 备选模型
  bool _showFallback = false;
  String? _fallbackProviderId;
  String? _fallbackModel;
  List<String> _fallbackModels = [];
  bool _isLoadingFallbackModels = false;

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
      _providers = providers.where((p) => p.isReady).toList();
      _selectedProviderId = config?.providerId;
      _selectedModel = config?.modelName;
      _fallbackProviderId = config?.fallbackProviderId;
      _fallbackModel = config?.fallbackModelName;
      _showFallback = config?.hasFallback ?? false;
      _isLoading = false;
    });

    if (_selectedProviderId != null) {
      _fetchModels(_selectedProviderId!, isFallback: false);
    }
    if (_showFallback && _fallbackProviderId != null) {
      _fetchModels(_fallbackProviderId!, isFallback: true);
    }
  }

  Future<void> _fetchModels(String providerId, {required bool isFallback}) async {
    final provider = _providers.where((p) => p.id == providerId).firstOrNull;
    if (provider == null) return;

    setState(() {
      if (isFallback) _isLoadingFallbackModels = true;
      else _isLoadingModels = true;
    });

    final isAnthropic = provider.providerKey == 'claude';

    List<String> models;
    try {
      models = await ModelFetcher.fetchAndCache(
        providerId, provider.baseUrl, provider.apiKey,
        isAnthropic: isAnthropic,
      );
    } catch (_) {
      models = [];
    }

    // API 失败时从缓存读取（缓存已按 providerId 隔离）
    if (models.isEmpty) {
      models = await ProviderStorage.loadFetchedModels(providerId);
    }

    if (mounted) {
      setState(() {
        if (isFallback) {
          _fallbackModels = models;
          _isLoadingFallbackModels = false;
          // 如果之前选的模型不在新列表中，清空选择
          if (_fallbackModel != null && !models.contains(_fallbackModel)) {
            _fallbackModel = null;
          }
        } else {
          _fetchedModels = models;
          _isLoadingModels = false;
          if (_selectedModel != null && !models.contains(_selectedModel)) {
            _selectedModel = null;
          }
        }
      });
    }
  }

  void _save() async {
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
          Text(
            _getAgentDesc(l10n, agent),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          _buildProfileChip(agent.recommendedProfile),
          const SizedBox(height: 24),

          // 主模型
          _buildSectionTitle(l10n.agentEditPrimaryModel),
          _buildProviderSelector(
            selectedId: _selectedProviderId,
            onChanged: (id) {
              setState(() {
                _selectedProviderId = id;
                _selectedModel = null;
                _fetchedModels = [];
              });
              if (id != null) _fetchModels(id, isFallback: false);
            },
          ),
          const SizedBox(height: 8),
          _buildModelSelector(
            selectedModel: _selectedModel,
            models: _fetchedModels,
            isLoading: _isLoadingModels,
            onChanged: (v) => setState(() => _selectedModel = v),
            onRefresh: _selectedProviderId != null
                ? () => _fetchModels(_selectedProviderId!, isFallback: false)
                : null,
          ),
          const SizedBox(height: 24),

          // 备选模型
          _buildSectionTitle(l10n.agentEditFallbackModel),
          SwitchListTile(
            title: Text(l10n.agentEditEnableFallback),
            value: _showFallback,
            onChanged: (v) => setState(() => _showFallback = v),
            contentPadding: EdgeInsets.zero,
          ),
          if (_showFallback) ...[
            _buildProviderSelector(
              selectedId: _fallbackProviderId,
              onChanged: (id) {
                setState(() {
                  _fallbackProviderId = id;
                  _fallbackModel = null;
                  _fallbackModels = [];
                });
                if (id != null) _fetchModels(id, isFallback: true);
              },
            ),
            const SizedBox(height: 8),
            _buildModelSelector(
              selectedModel: _fallbackModel,
              models: _fallbackModels,
              isLoading: _isLoadingFallbackModels,
              onChanged: (v) => setState(() => _fallbackModel = v),
              onRefresh: _fallbackProviderId != null
                  ? () => _fetchModels(_fallbackProviderId!, isFallback: true)
                  : null,
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
                      Text('${l10n.agentEditTestCase} ${entry.key + 1}',
                          style: Theme.of(context).textTheme.labelMedium),
                      const SizedBox(height: 4),
                      Text('"${entry.value.input}"',
                          style: Theme.of(context).textTheme.bodyMedium),
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

  Widget _buildProviderSelector({
    required String? selectedId,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: _providers.any((p) => p.id == selectedId) ? selectedId : null,
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

  Widget _buildModelSelector({
    required String? selectedModel,
    required List<String> models,
    required bool isLoading,
    required ValueChanged<String?> onChanged,
    VoidCallback? onRefresh,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: (selectedModel != null && models.contains(selectedModel))
                    ? selectedModel
                    : null,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.agentEditModel,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  suffixIcon: isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null,
                ),
                items: [
                  ...models.map((m) => DropdownMenuItem(
                    value: m,
                    child: Text(m, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                  )),
                  DropdownMenuItem(
                    value: '__manual__',
                    child: Text(
                      AppLocalizations.of(context)!.agentEditManualInput,
                      style: TextStyle(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ],
                onChanged: (v) {
                  if (v == '__manual__') {
                    _showManualInputDialog(onChanged);
                  } else {
                    onChanged(v);
                  }
                },
              ),
            ),
            if (onRefresh != null) ...[
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: isLoading ? null : onRefresh,
                icon: const Icon(Icons.refresh, size: 20),
                tooltip: AppLocalizations.of(context)!.aiSettingsTestConnection,
              ),
            ],
          ],
        ),
        // 如果当前选中的模型不在列表中，显示为文本
        if (selectedModel != null && selectedModel.isNotEmpty && !models.contains(selectedModel))
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '当前: $selectedModel',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
      ],
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
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) onChanged(name);
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
      backgroundColor: color.withValues(alpha: 0.1),
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
