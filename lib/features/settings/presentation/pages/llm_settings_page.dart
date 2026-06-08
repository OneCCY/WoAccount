import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import '../../../../core/config/ai_provider_presets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../ai/data/models/llm_config.dart';
import '../../../ai/data/repositories/llm_repository_impl.dart';

// ============================================================
// 获取到的模型信息（带供应商分组）
// ============================================================

class _FetchedModel {
  final String id;
  final String? ownedBy;

  const _FetchedModel({required this.id, this.ownedBy});
}

/// LLM 服务配置页
class LlmSettingsPage extends StatefulWidget {
  const LlmSettingsPage({super.key});

  @override
  State<LlmSettingsPage> createState() => _LlmSettingsPageState();
}

class _LlmSettingsPageState extends State<LlmSettingsPage> {
  List<LlmProvider> _providers = [];
  String? _activeId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final providers = await LlmConfigManager.loadProviders();
    final activeId = await LlmConfigManager.getActiveProviderId();
    if (mounted) {
      setState(() {
        _providers = providers;
        _activeId = activeId;
        _isLoading = false;
      });
    }
  }

  Future<void> _setActive(String id) async {
    await LlmConfigManager.setActiveProviderId(id);
    setState(() => _activeId = id);
  }

  Future<void> _delete(LlmProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除服务商'),
        content: Text('确定删除「${provider.name}」？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('删除', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await LlmConfigManager.deleteProvider(provider.id);
      await _load();
    }
  }

  void _addProvider() async {
    final result = await Navigator.push<LlmProvider>(
      context,
      MaterialPageRoute(builder: (_) => const _ProviderEditPage()),
    );
    if (result != null) {
      await LlmConfigManager.addProvider(result);
      await _load();
    }
  }

  void _editProvider(LlmProvider provider) async {
    final result = await Navigator.push<LlmProvider>(
      context,
      MaterialPageRoute(builder: (_) => _ProviderEditPage(provider: provider)),
    );
    if (result != null) {
      await LlmConfigManager.updateProvider(result);
      await _load();
    }
  }

  Future<void> _exportConfig() async {
    final json = await LlmConfigManager.exportConfig();
    await Clipboard.setData(ClipboardData(text: json));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('配置已复制到剪贴板'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _importConfig() async {
    final data = await Clipboard.getData('text/plain');
    final text = data?.text;
    if (text == null || text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('剪贴板为空'), behavior: SnackBarBehavior.floating),
        );
      }
      return;
    }

    final count = await LlmConfigManager.importConfig(text);
    if (mounted) {
      if (count > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已导入 $count 个服务商配置'), behavior: SnackBarBehavior.floating),
        );
        await _load();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('导入失败，请检查 JSON 格式'), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI 服务配置'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (v) {
              if (v == 'export') _exportConfig();
              if (v == 'import') _importConfig();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'export', child: Text('导出配置')),
              const PopupMenuItem(value: 'import', child: Text('导入配置')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addProvider,
            tooltip: '添加服务商',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _providers.isEmpty
              ? _buildEmptyState()
              : _buildProviderList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text('尚未配置 AI 服务', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              '添加一个 AI 服务商即可使用智能记账功能\n支持文本、视觉、语音多种能力',
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addProvider,
              icon: const Icon(Icons.add),
              label: const Text('添加服务商'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.md),
      itemCount: _providers.length,
      itemBuilder: (context, index) {
        final p = _providers[index];
        final isActive = p.id == _activeId;
        final preset = getPresetByKey(p.providerKey);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: isActive ? Border.all(color: AppColors.primary, width: 2) : null,
          ),
          child: InkWell(
            onTap: () => _setActive(p.id),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(preset?.icon ?? '🤖', style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          p.name.isEmpty ? '未命名服务商' : p.name,
                          style: AppTextStyles.h3.copyWith(fontSize: 16),
                        ),
                      ),
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('使用中', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                        ),
                      if (!p.isComplete)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('未完成', style: AppTextStyles.caption.copyWith(color: AppColors.warning)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (p.baseUrl.isNotEmpty) _infoRow('地址', p.baseUrl),
                  // 显示已配置的能力标签
                  _buildCapabilityTags(p),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _actionButton(icon: Icons.wifi_tethering, label: '测试', onTap: () => _testProvider(p)),
                      const SizedBox(width: 8),
                      _actionButton(icon: Icons.edit_outlined, label: '编辑', onTap: () => _editProvider(p)),
                      const SizedBox(width: 8),
                      _actionButton(icon: Icons.delete_outline, label: '删除', color: AppColors.error, onTap: () => _delete(p)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCapabilityTags(LlmProvider p) {
    final caps = p.configuredCapabilities;
    if (caps.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text('模型', style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
          ),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: caps.map((cap) {
                final modelName = p.getModelForCapability(cap) ?? '';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${cap.emoji} $modelName',
                    style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary))),
          Expanded(child: Text(value, style: AppTextStyles.footnote, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _actionButton({required IconData icon, required String label, required VoidCallback onTap, Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color ?? AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(label, style: AppTextStyles.caption.copyWith(color: color ?? AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Future<void> _testProvider(LlmProvider provider) async {
    if (!provider.isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先完善配置'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

    final repo = LlmRepositoryImpl(Dio());
    final success = await repo.testConnection(provider);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '✅ 连接成功' : '❌ 连接失败，请检查地址、Key 和模型名称'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }
}

// ============================================================
// 服务商编辑页 — 分能力配置模型
// ============================================================

class _ProviderEditPage extends StatefulWidget {
  final LlmProvider? provider;
  const _ProviderEditPage({this.provider});

  @override
  State<_ProviderEditPage> createState() => _ProviderEditPageState();
}

/// 每个能力的编辑状态
class _CapabilityState {
  String? selectedModel;
  List<_FetchedModel> fetchedModels = [];
  bool isLoading = false;
}

class _ProviderEditPageState extends State<_ProviderEditPage> {
  late final TextEditingController _apiKeyCtrl;
  late final TextEditingController _baseUrlCtrl;
  late final TextEditingController _customModelCtrl;

  String _selectedPresetKey = kCustomProviderKey;
  bool _obscureApiKey = true;

  double _temperature = 0.0;
  int _maxTokens = 1000;
  int _timeout = 30;
  bool _showAdvanced = false;

  /// 每个能力独立的编辑状态
  late final Map<ModelCapability, _CapabilityState> _capStates;

  bool get _isEditing => widget.provider != null;

  AiProviderPreset? get _currentPreset =>
      _selectedPresetKey == kCustomProviderKey ? null : getPresetByKey(_selectedPresetKey);

  bool get _isAnthropicFormat =>
      _currentPreset?.apiFormat == ApiFormat.anthropic;

  @override
  void initState() {
    super.initState();
    final p = widget.provider;
    _apiKeyCtrl = TextEditingController(text: p?.apiKey ?? '');
    _baseUrlCtrl = TextEditingController(text: p?.baseUrl ?? '');
    _customModelCtrl = TextEditingController();

    // 初始化每个能力的状态
    _capStates = {for (final cap in ModelCapability.values) cap: _CapabilityState()};

    if (p != null) {
      _temperature = p.temperature;
      _maxTokens = p.maxTokens;
      _timeout = p.timeoutSeconds;
      _showAdvanced = true;

      // 匹配预设
      final preset = getPresetByKey(p.providerKey);
      if (preset != null) {
        _selectedPresetKey = preset.key;
      } else {
        final match = aiProviderPresets.where((pr) => pr.name == p.name);
        if (match.isNotEmpty) _selectedPresetKey = match.first.key;
      }

      // 从已有配置恢复每个能力的模型
      for (final cap in ModelCapability.values) {
        final modelName = p.getModelForCapability(cap);
        if (modelName != null && modelName.isNotEmpty) {
          _capStates[cap]!.selectedModel = modelName;
        }
        // 加载预设默认模型
        final effectivePreset = getPresetByKey(_selectedPresetKey);
        if (effectivePreset != null) {
          final defaults = effectivePreset.defaultModelsByCapability[cap.name] ?? [];
          _capStates[cap]!.fetchedModels = defaults.map((m) => _FetchedModel(id: m)).toList();
        }
      }
    }
  }

  @override
  void dispose() {
    _apiKeyCtrl.dispose();
    _baseUrlCtrl.dispose();
    _customModelCtrl.dispose();
    super.dispose();
  }

  /// 选择预设后自动填充 baseUrl 和各能力的默认模型
  void _onPresetChanged(String key) {
    setState(() {
      _selectedPresetKey = key;
      if (key == kCustomProviderKey) {
        _baseUrlCtrl.text = '';
        for (final cap in ModelCapability.values) {
          _capStates[cap] = _CapabilityState();
        }
      } else {
        final preset = getPresetByKey(key)!;
        _baseUrlCtrl.text = preset.baseUrl;
        for (final cap in ModelCapability.values) {
          final defaults = preset.defaultModelsByCapability[cap.name] ?? [];
          final state = _CapabilityState();
          state.fetchedModels = defaults.map((m) => _FetchedModel(id: m)).toList();
          _capStates[cap] = state;
        }
      }
    });
  }

  // ============================================================
  // 智能模型获取
  // ============================================================

  static const _knownCompatSuffixes = [
    '/api/claudecode', '/api/anthropic', '/apps/anthropic', '/api/coding',
    '/claudecode', '/anthropic', '/step_plan', '/coding', '/claude',
  ];

  bool _endsWithVersionSegment(String url) {
    final lastSegment = url.split('/').last;
    if (!lastSegment.startsWith('v')) return false;
    final digits = lastSegment.substring(1);
    if (digits.isEmpty) return false;
    return RegExp(r'^\d+$').hasMatch(digits);
  }

  String? _stripCompatSuffix(String url) {
    for (final suffix in _knownCompatSuffixes) {
      if (url.endsWith(suffix)) {
        return url.substring(0, url.length - suffix.length);
      }
    }
    return null;
  }

  List<String> _buildModelUrlCandidates(String baseUrl) {
    final trimmed = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    if (trimmed.isEmpty) return [];

    final candidates = <String>[];
    if (_endsWithVersionSegment(trimmed)) {
      candidates.add('$trimmed/models');
      if (!trimmed.endsWith('/v1')) candidates.add('$trimmed/v1/models');
    } else {
      candidates.add('$trimmed/v1/models');
    }

    final stripped = _stripCompatSuffix(trimmed);
    if (stripped != null && stripped.isNotEmpty && stripped.contains('://')) {
      candidates.add('$stripped/v1/models');
      candidates.add('$stripped/models');
    }

    final seen = <String>{};
    return candidates.where((u) => seen.add(u)).toList();
  }

  /// 获取模型列表（按能力筛选）
  Future<void> _fetchModelsForCapability(ModelCapability cap) async {
    final baseUrl = _baseUrlCtrl.text.trim();
    final apiKey = _apiKeyCtrl.text.trim();

    if (baseUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先填写请求地址'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先填写 API Key'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    setState(() => _capStates[cap]!.isLoading = true);

    try {
      final allModels = await _requestModels(baseUrl, apiKey);
      // 按能力关键词筛选
      final filtered = _filterByCapability(allModels, cap);

      if (mounted) {
        setState(() {
          _capStates[cap]!.fetchedModels = filtered.isNotEmpty ? filtered : allModels;
          _capStates[cap]!.isLoading = false;
        });
        final msg = filtered.isNotEmpty
            ? '获取到 ${filtered.length} 个${cap.label}'
            : '获取到 ${allModels.length} 个模型（未筛选到专用模型，显示全部）';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _capStates[cap]!.isLoading = false);
        // 回退到预设
        final preset = getPresetByKey(_selectedPresetKey);
        final defaults = preset?.defaultModelsByCapability[cap.name] ?? preset?.defaultModels ?? [];
        if (defaults.isNotEmpty) {
          setState(() {
            _capStates[cap]!.fetchedModels = defaults.map((m) => _FetchedModel(id: m)).toList();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('获取失败，已加载预设模型列表'), behavior: SnackBarBehavior.floating),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('获取模型失败: $e'), behavior: SnackBarBehavior.floating),
          );
        }
      }
    }
  }

  /// 按能力关键词筛选模型
  List<_FetchedModel> _filterByCapability(List<_FetchedModel> models, ModelCapability cap) {
    if (cap.filterKeywords.isEmpty) return models; // 文本能力不筛选
    return models.where((m) {
      final id = m.id.toLowerCase();
      return cap.filterKeywords.any((kw) => id.contains(kw.toLowerCase()));
    }).toList();
  }

  Future<List<_FetchedModel>> _requestModels(String baseUrl, String apiKey) async {
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);

    final candidates = _buildModelUrlCandidates(baseUrl);

    for (final modelsUrl in candidates) {
      try {
        final resp = await dio.get(
          modelsUrl,
          options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
        );

        final data = resp.data;
        List<_FetchedModel> models = [];

        if (data is Map && data['data'] is List) {
          models = (data['data'] as List)
              .map((m) {
                final id = m['id']?.toString() ?? '';
                final ownedBy = m['owned_by']?.toString();
                if (id.isEmpty) return null;
                return _FetchedModel(id: id, ownedBy: ownedBy);
              })
              .whereType<_FetchedModel>()
              .toList();
        }

        if (models.isNotEmpty) {
          models.sort((a, b) {
            final vc = (a.ownedBy ?? '').compareTo(b.ownedBy ?? '');
            if (vc != 0) return vc;
            return a.id.compareTo(b.id);
          });
          return models;
        }
      } on DioException catch (_) {
        continue;
      }
    }

    throw Exception('无法获取模型列表');
  }

  void _save() {
    final apiKey = _apiKeyCtrl.text.trim();
    final baseUrl = _baseUrlCtrl.text.trim();

    String name;
    if (_selectedPresetKey == kCustomProviderKey) {
      name = baseUrl.isNotEmpty ? Uri.tryParse(baseUrl)?.host ?? '自定义' : '自定义';
    } else {
      name = getPresetByKey(_selectedPresetKey)?.name ?? '自定义';
    }

    // 至少需要配置一个模型
    final models = <String, ModelConfig>{};
    for (final cap in ModelCapability.values) {
      final m = _capStates[cap]!.selectedModel;
      if (m != null && m.isNotEmpty) {
        models[cap.name] = ModelConfig(modelName: m);
      }
    }

    if (apiKey.isEmpty || baseUrl.isEmpty || models.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写 API Key、请求地址，并至少配置一个模型'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final cleanUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;

    final provider = LlmProvider(
      id: widget.provider?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      apiKey: apiKey,
      baseUrl: cleanUrl,
      temperature: _temperature,
      maxTokens: _maxTokens,
      timeoutSeconds: _timeout,
      providerKey: _selectedPresetKey,
      models: models,
    );

    Navigator.pop(context, provider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? '编辑服务商' : '添加服务商'),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text('保存', style: AppTextStyles.body.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 服务商名称
            _label('服务商名称'),
            _buildPresetDropdown(),
            const SizedBox(height: 16),

            // 2. API Key
            _label('API Key'),
            _buildApiKeyField(),
            const SizedBox(height: 16),

            // 3. 请求地址
            _label('请求地址'),
            _buildBaseUrlField(),
            const SizedBox(height: 4),
            _hint(_isAnthropicFormat
                ? 'Anthropic API 地址，如 https://api.anthropic.com'
                : '填入 API 的 base_url，不需要手动拼接 /chat/completions'),
            const SizedBox(height: 24),

            // 4. 模型配置（按能力分组）
            _buildCapabilitySection(),
            const SizedBox(height: 24),

            // 5. 高级设置
            _buildAdvancedSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPresetKey,
          isExpanded: true,
          style: AppTextStyles.body,
          items: [
            ...aiProviderPresets.map((p) => DropdownMenuItem(
              value: p.key,
              child: Row(
                children: [
                  Text(p.icon, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(p.name),
                ],
              ),
            )),
            const DropdownMenuItem(
              value: kCustomProviderKey,
              child: Row(
                children: [
                  Text('✏️', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text('自定义'),
                ],
              ),
            ),
          ],
          onChanged: (v) {
            if (v != null) _onPresetChanged(v);
          },
        ),
      ),
    );
  }

  Widget _buildApiKeyField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: TextField(
        controller: _apiKeyCtrl,
        obscureText: _obscureApiKey,
        style: AppTextStyles.body,
        decoration: InputDecoration(
          hintText: '输入 API Key',
          hintStyle: AppTextStyles.body.copyWith(color: AppColors.textHint),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureApiKey ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 20,
              color: AppColors.textTertiary,
            ),
            onPressed: () => setState(() => _obscureApiKey = !_obscureApiKey),
          ),
        ),
      ),
    );
  }

  Widget _buildBaseUrlField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: TextField(
        controller: _baseUrlCtrl,
        style: AppTextStyles.body,
        decoration: InputDecoration(
          hintText: _isAnthropicFormat ? '如：https://api.anthropic.com' : '如：https://api.deepseek.com',
          hintStyle: AppTextStyles.body.copyWith(color: AppColors.textHint),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // ============================================================
  // 按能力分组的模型配置区域
  // ============================================================

  Widget _buildCapabilitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('模型配置'),
        ...ModelCapability.values.map((cap) => _buildCapabilityCard(cap)),
      ],
    );
  }

  Widget _buildCapabilityCard(ModelCapability cap) {
    final state = _capStates[cap]!;
    final hasModels = state.fetchedModels.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 能力标题行
            Row(
              children: [
                Icon(cap.icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(cap.label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(cap.description, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // 模型下拉 + 获取按钮
            Row(
              children: [
                Expanded(child: _buildCapabilityModelDropdown(cap, state, hasModels)),
                const SizedBox(width: 8),
                SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: state.isLoading ? null : () => _fetchModelsForCapability(cap),
                    icon: state.isLoading
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.sync, size: 16),
                    label: const Text('获取', style: TextStyle(fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapabilityModelDropdown(ModelCapability cap, _CapabilityState state, bool hasModels) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: state.selectedModel,
          isExpanded: true,
          hint: Text('选择${cap.label}', style: AppTextStyles.body.copyWith(color: AppColors.textHint, fontSize: 14)),
          style: AppTextStyles.body.copyWith(fontSize: 14),
          items: [
            ...state.fetchedModels.map((m) => DropdownMenuItem(
              value: m.id,
              child: Text(m.id, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
            )),
            if (hasModels) ...[
              const DropdownMenuItem(value: '__custom__', child: Divider(height: 1)),
              const DropdownMenuItem(value: '__custom__', child: Text('✏️ 手动输入...', style: TextStyle(fontSize: 14))),
            ],
          ],
          onChanged: (v) {
            if (v == '__custom__') {
              _showCustomModelDialog(cap, state);
            } else if (v != null) {
              setState(() => state.selectedModel = v);
            }
          },
        ),
      ),
    );
  }

  void _showCustomModelDialog(ModelCapability cap, _CapabilityState state) {
    _customModelCtrl.text = state.selectedModel ?? '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('输入${cap.label}名称'),
        content: TextField(
          controller: _customModelCtrl,
          autofocus: true,
          decoration: InputDecoration(hintText: '如：${cap == ModelCapability.audio ? "whisper-1" : "模型名称"}'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              final model = _customModelCtrl.text.trim();
              if (model.isNotEmpty) {
                setState(() {
                  state.selectedModel = model;
                  if (!state.fetchedModels.any((m) => m.id == model)) {
                    state.fetchedModels.add(_FetchedModel(id: model));
                  }
                });
              }
              Navigator.pop(ctx);
            },
            child: Text('确认', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          initiallyExpanded: _showAdvanced,
          title: Text('高级设置', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
          children: [
            Row(
              children: [
                Text('温度参数', style: AppTextStyles.body),
                const Spacer(),
                Text(_temperature.toStringAsFixed(1), style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
              ],
            ),
            Slider(
              value: _temperature,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _temperature = v),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('最大 Token', style: AppTextStyles.body),
                const Spacer(),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: TextEditingController(text: _maxTokens.toString()),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.body,
                    decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                    onChanged: (v) => _maxTokens = int.tryParse(v) ?? 1000,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            Row(
              children: [
                Text('超时（秒）', style: AppTextStyles.body),
                const Spacer(),
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: TextEditingController(text: _timeout.toString()),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.body,
                    decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                    onChanged: (v) => _timeout = int.tryParse(v) ?? 30,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: AppTextStyles.footnote),
    );
  }

  Widget _hint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(text, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
    );
  }
}
