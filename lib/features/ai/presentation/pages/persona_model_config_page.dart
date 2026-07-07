import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wo_account/l10n/app_localizations.dart';

import '../../data/models/ai_provider.dart';
import '../../data/models/agent_config.dart';
import '../../data/storage/agent_config_storage.dart';
import '../../data/storage/provider_storage.dart';
import '../../data/storage/model_fetcher.dart';

/// AI 角色统一模型配置页
///
/// 所有角色共用同一套模型配置（主模型 + 备选模型）
class PersonaModelConfigPage extends ConsumerStatefulWidget {
  const PersonaModelConfigPage({super.key});

  @override
  ConsumerState<PersonaModelConfigPage> createState() => _PersonaModelConfigPageState();
}

class _PersonaModelConfigPageState extends ConsumerState<PersonaModelConfigPage> {
  static const _configKey = 'persona_chat';

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
    final config = await AgentConfigStorage.load(_configKey);
    final providers = await ProviderStorage.loadAll();

    setState(() {
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

    if (models.isEmpty) {
      models = await ProviderStorage.loadFetchedModels(providerId);
    }

    if (mounted) {
      setState(() {
        if (isFallback) {
          _fallbackModels = models;
          _isLoadingFallbackModels = false;
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
      agentId: _configKey,
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

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('AI 角色模型配置')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 AI 角色模型配置'),
        actions: [
          TextButton(onPressed: _save, child: Text(l10n.agentEditSave)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '为所有 AI 角色统一配置对话用的模型供应商。当用户发送非记账内容时，AI 会以所选角色身份调用此模型进行回复。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
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
}