import 'package:flutter/material.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../core/config/ai_provider_presets.dart';
import '../../data/models/ai_provider.dart';

/// 供应商编辑页（v2.0）
///
/// 纯连接配置编辑，不含模型选择。
/// 保存后自动测试连通性。
class ProviderEditPageV2 extends StatefulWidget {
  final AiProvider? provider;
  const ProviderEditPageV2({super.key, this.provider});

  @override
  State<ProviderEditPageV2> createState() => _ProviderEditPageV2State();
}

class _ProviderEditPageV2State extends State<ProviderEditPageV2> {
  late TextEditingController _apiKeyCtrl;
  late TextEditingController _baseUrlCtrl;
  String _selectedPresetKey = kCustomProviderKey;
  bool _obscureApiKey = true;
  double _temperature = 0.0;
  int _maxTokens = 1000;
  int _timeout = 30;
  bool _showAdvanced = false;

  bool get _isEditing => widget.provider != null;

  @override
  void initState() {
    super.initState();
    final p = widget.provider;
    _apiKeyCtrl = TextEditingController(text: p?.apiKey ?? '');
    _baseUrlCtrl = TextEditingController(text: p?.baseUrl ?? '');
    _selectedPresetKey = p?.providerKey ?? kCustomProviderKey;
    _temperature = p?.temperature ?? 0.0;
    _maxTokens = p?.maxTokens ?? 1000;
    _timeout = p?.timeoutSeconds ?? 30;
  }

  @override
  void dispose() {
    _apiKeyCtrl.dispose();
    _baseUrlCtrl.dispose();
    super.dispose();
  }

  void _onPresetChanged(String key) {
    final preset = getPresetByKey(key);
    setState(() {
      _selectedPresetKey = key;
      if (preset != null && !_isEditing) {
        _baseUrlCtrl.text = preset.baseUrl;
      }
    });
  }

  void _save() {
    final apiKey = _apiKeyCtrl.text.trim();
    final baseUrl = _baseUrlCtrl.text.trim();
    final preset = getPresetByKey(_selectedPresetKey);

    if (apiKey.isEmpty || baseUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.agentEditSelectModel)),
      );
      return;
    }

    final provider = AiProvider(
      id: widget.provider?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: preset?.name ?? Uri.tryParse(baseUrl)?.host ?? 'Custom',
      apiKey: apiKey,
      baseUrl: baseUrl,
      providerKey: _selectedPresetKey == kCustomProviderKey ? null : _selectedPresetKey,
      temperature: _temperature,
      maxTokens: _maxTokens,
      timeoutSeconds: _timeout,
    );

    Navigator.pop(context, provider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.agentEditSave : l10n.aiSettingsAddSupplier),
        actions: [
          TextButton(onPressed: _save, child: Text(l10n.agentEditSave)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 预设模板
          Text(l10n.agentEditProvider, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: aiProviderPresets.any((p) => p.key == _selectedPresetKey)
                ? _selectedPresetKey
                : kCustomProviderKey,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: [
              ...aiProviderPresets.map((p) => DropdownMenuItem(
                value: p.key,
                child: Text('${p.icon} ${p.name}'),
              )),
              const DropdownMenuItem(
                value: kCustomProviderKey,
                child: Text('🔧 Custom'),
              ),
            ],
            onChanged: (v) => v != null ? _onPresetChanged(v) : null,
          ),
          const SizedBox(height: 16),

          // API Key
          Text('API Key', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          TextField(
            controller: _apiKeyCtrl,
            obscureText: _obscureApiKey,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              suffixIcon: IconButton(
                icon: Icon(_obscureApiKey ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscureApiKey = !_obscureApiKey),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Base URL
          Text(l10n.agentEditModel, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          TextField(
            controller: _baseUrlCtrl,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              hintText: 'https://api.example.com',
            ),
          ),
          const SizedBox(height: 16),

          // 高级设置
          ExpansionTile(
            title: Text(l10n.agentEditPrimaryModel),
            initiallyExpanded: _showAdvanced,
            onExpansionChanged: (v) => setState(() => _showAdvanced = v),
            children: [
              ListTile(
                title: const Text('Temperature'),
                subtitle: Slider(
                  value: _temperature,
                  min: 0,
                  max: 2,
                  divisions: 20,
                  label: _temperature.toStringAsFixed(1),
                  onChanged: (v) => setState(() => _temperature = v),
                ),
              ),
              ListTile(
                title: const Text('Max Tokens'),
                subtitle: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '$_maxTokens',
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (v) => _maxTokens = int.tryParse(v) ?? _maxTokens,
                ),
              ),
              ListTile(
                title: const Text('Timeout (s)'),
                subtitle: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '$_timeout',
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (v) => _timeout = int.tryParse(v) ?? _timeout,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
