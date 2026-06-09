import 'dart:async';
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
// 模型 URL 智能构建 & 获取工具方法（供多个页面共用）
// ============================================================

const _knownCompatSuffixes = [
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

class _FetchedModel {
  final String id;
  final String? ownedBy;

  const _FetchedModel({required this.id, this.ownedBy});
}

Future<List<_FetchedModel>> fetchModelsFromApi(String baseUrl, String apiKey) async {
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

List<_FetchedModel> filterModelsByCapability(List<_FetchedModel> models, ModelCapability cap) {
  if (cap.filterKeywords.isEmpty) return models;
  return models.where((m) {
    final id = m.id.toLowerCase();
    return cap.filterKeywords.any((kw) => id.contains(kw.toLowerCase()));
  }).toList();
}

// ============================================================
// LLM 服务配置页 — 能力入口模式
// ============================================================

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

  LlmProvider? get _activeProvider {
    if (_activeId == null) return null;
    try {
      return _providers.firstWhere((p) => p.id == _activeId);
    } catch (_) {
      return null;
    }
  }

  void _openCapabilityConfig(ModelCapability cap) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _CapabilityConfigPage(capability: cap)),
    );
    _load(); // 返回时刷新状态
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

  Future<void> _deleteProvider(LlmProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除服务商'),
        content: Text('确定删除「${provider.name}」？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('删除', style: TextStyle(color: context.colors.error)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await LlmConfigManager.deleteProvider(provider.id);
      await _load();
    }
  }

  Future<void> _testProvider(LlmProvider provider) async {
    if (!provider.isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先完善配置（需要 API Key、地址和至少一个模型）'), behavior: SnackBarBehavior.floating),
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
          backgroundColor: success ? context.colors.success : context.colors.error,
        ),
      );
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
      backgroundColor: context.colors.background,
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
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. 能力配置卡片
                  ...ModelCapability.values.map((cap) => _buildCapabilityCard(cap)),
                  const SizedBox(height: 24),

                  // 2. 服务商管理
                  _sectionLabel('服务商管理'),
                  const SizedBox(height: 8),
                  _providers.isEmpty ? _buildEmptyProviderHint() : _buildProviderList(),
                  const SizedBox(height: 16),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: _addProvider,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('添加服务商'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.colors.primary,
                        side: BorderSide(color: context.colors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  // ============================================================
  // 能力配置卡片
  // ============================================================

  Widget _buildCapabilityCard(ModelCapability cap) {
    final active = _activeProvider;
    final modelName = active?.getModelForCapability(cap);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: InkWell(
        onTap: () => _openCapabilityConfig(cap),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.colors.primarySurface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Center(
                  child: Text(cap.emoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cap.label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    if (modelName != null && modelName.isNotEmpty)
                      Text(
                        '${active!.name} · $modelName',
                        style: AppTextStyles.caption.copyWith(color: context.colors.primary),
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Text(
                        '未配置',
                        style: AppTextStyles.caption.copyWith(color: context.colors.textTertiary),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (modelName != null && modelName.isNotEmpty)
                      ? context.colors.success.withValues(alpha: 0.1)
                      : context.colors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  (modelName != null && modelName.isNotEmpty) ? '已配置' : '未配置',
                  style: AppTextStyles.caption.copyWith(
                    color: (modelName != null && modelName.isNotEmpty) ? context.colors.success : context.colors.warning,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: context.colors.textTertiary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 服务商列表
  // ============================================================

  Widget _buildEmptyProviderHint() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.cloud_off_outlined, size: 40, color: context.colors.textTertiary),
            const SizedBox(height: 8),
            Text('尚未添加任何服务商', style: AppTextStyles.body.copyWith(color: context.colors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderList() {
    return Column(
      children: _providers.map((p) {
        final isActive = p.id == _activeId;
        final preset = getPresetByKey(p.providerKey);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: isActive ? Border.all(color: context.colors.primary, width: 1.5) : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(preset?.icon ?? '🤖', style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        p.name.isEmpty ? '未命名服务商' : p.name,
                        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.colors.primarySurface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('使用中', style: AppTextStyles.caption.copyWith(color: context.colors.primary, fontSize: 11)),
                      ),
                    if (!p.isComplete)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: context.colors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('未完成', style: AppTextStyles.caption.copyWith(color: context.colors.warning, fontSize: 11)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _providerActionButton(
                      icon: Icons.wifi_tethering,
                      label: '测试',
                      onTap: () => _testProvider(p),
                    ),
                    _providerActionButton(
                      icon: Icons.edit_outlined,
                      label: '编辑',
                      onTap: () => _editProvider(p),
                    ),
                    _providerActionButton(
                      icon: Icons.delete_outline,
                      label: '删除',
                      color: context.colors.error,
                      onTap: () => _deleteProvider(p),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _providerActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color ?? context.colors.textSecondary),
            const SizedBox(width: 3),
            Text(label, style: AppTextStyles.caption.copyWith(color: color ?? context.colors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text, style: AppTextStyles.footnote.copyWith(color: context.colors.textSecondary));
  }
}

// ============================================================
// 能力配置页 — 为某个能力选择服务商和模型
// ============================================================

/// 连接状态
enum ConnectionStatus {
  unknown,     // 未检测
  testing,     // 检测中
  connected,   // 已连接
  disconnected, // 连接失败
}

/// 自动检测频率选项
class _CheckIntervalOption {
  final String label;
  final Duration? duration; // null = 关闭
  const _CheckIntervalOption(this.label, this.duration);
}

const _checkIntervalOptions = [
  _CheckIntervalOption('关闭', null),
  _CheckIntervalOption('10秒', Duration(seconds: 10)),
  _CheckIntervalOption('30秒', Duration(seconds: 30)),
  _CheckIntervalOption('1分钟', Duration(minutes: 1)),
  _CheckIntervalOption('2分钟', Duration(minutes: 2)),
  _CheckIntervalOption('5分钟', Duration(minutes: 5)),
  _CheckIntervalOption('10分钟', Duration(minutes: 10)),
  _CheckIntervalOption('30分钟', Duration(minutes: 30)),
  _CheckIntervalOption('1小时', Duration(hours: 1)),
];

class _ProviderModelEntry {
  List<_FetchedModel> fetchedModels = [];
  String? selectedModel;
  bool isLoading = false;
  ConnectionStatus connectionStatus = ConnectionStatus.unknown;
  int? latencyMs;
  String? lastError;
}

class _CapabilityConfigPage extends StatefulWidget {
  final ModelCapability capability;
  const _CapabilityConfigPage({required this.capability});

  @override
  State<_CapabilityConfigPage> createState() => _CapabilityConfigPageState();
}

class _CapabilityConfigPageState extends State<_CapabilityConfigPage> {
  List<LlmProvider> _providers = [];
  String? _activeId;
  bool _isLoading = true;
  late final Map<String, _ProviderModelEntry> _entries;
  late final TextEditingController _customModelCtrl;

  // 自动检测
  Timer? _autoCheckTimer;
  int _intervalIndex = 0; // 默认：关闭

  @override
  void initState() {
    super.initState();
    _customModelCtrl = TextEditingController();
    _entries = {};
    _load();
  }

  @override
  void dispose() {
    _customModelCtrl.dispose();
    _autoCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final providers = await LlmConfigManager.loadProviders();
    final activeId = await LlmConfigManager.getActiveProviderId();
    if (!mounted) return;

    final entries = <String, _ProviderModelEntry>{};
    for (final p in providers) {
      final entry = _ProviderModelEntry();
      entry.selectedModel = p.getModelForCapability(widget.capability);
      // 加载预设默认模型
      final preset = getPresetByKey(p.providerKey);
      if (preset != null) {
        final defaults = preset.defaultModelsByCapability[widget.capability.name] ?? [];
        entry.fetchedModels = defaults.map((m) => _FetchedModel(id: m)).toList();
      }
      entries[p.id] = entry;
    }

    setState(() {
      _providers = providers;
      _activeId = activeId;
      _entries.clear();
      _entries.addAll(entries);
      _isLoading = false;
    });
  }

  Future<void> _fetchModelsForProvider(LlmProvider provider) async {
    final entry = _entries[provider.id];
    if (entry == null) return;

    if (provider.apiKey.isEmpty || provider.baseUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('该服务商未配置 API Key 或请求地址，请先编辑'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    setState(() => entry.isLoading = true);

    try {
      final allModels = await fetchModelsFromApi(provider.baseUrl, provider.apiKey);
      final filtered = filterModelsByCapability(allModels, widget.capability);

      if (mounted) {
        setState(() {
          entry.fetchedModels = filtered.isNotEmpty ? filtered : allModels;
          entry.isLoading = false;
        });
        final msg = filtered.isNotEmpty
            ? '获取到 ${filtered.length} 个${widget.capability.label}'
            : '获取到 ${allModels.length} 个模型（未筛选到专用模型，显示全部）';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => entry.isLoading = false);
        // 回退到预设
        final preset = getPresetByKey(provider.providerKey);
        final defaults = preset?.defaultModelsByCapability[widget.capability.name] ?? preset?.defaultModels ?? [];
        if (defaults.isNotEmpty) {
          setState(() {
            entry.fetchedModels = defaults.map((m) => _FetchedModel(id: m)).toList();
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

  Future<void> _selectModel(LlmProvider provider, String? model) async {
    if (model == null) return;

    final newModels = Map<String, ModelConfig>.from(provider.models);
    newModels[widget.capability.name] = ModelConfig(modelName: model);

    final updated = provider.copyWith(models: newModels);
    await LlmConfigManager.updateProvider(updated);
    // 设为当前使用中的服务商
    await LlmConfigManager.setActiveProviderId(provider.id);

    if (mounted) {
      setState(() {
        _entries[provider.id]!.selectedModel = model;
        _activeId = provider.id;
        // 更新本地 provider 列表
        final idx = _providers.indexWhere((p) => p.id == provider.id);
        if (idx != -1) _providers[idx] = updated;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已设置 ${widget.capability.label}：${provider.name} · $model'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  void _showCustomModelDialog(LlmProvider provider, _ProviderModelEntry entry) {
    _customModelCtrl.text = entry.selectedModel ?? '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('输入${widget.capability.label}名称'),
        content: TextField(
          controller: _customModelCtrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '如：${widget.capability == ModelCapability.audio ? "whisper-1" : "模型名称"}',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              final model = _customModelCtrl.text.trim();
              if (model.isNotEmpty) {
                if (!entry.fetchedModels.any((m) => m.id == model)) {
                  entry.fetchedModels.add(_FetchedModel(id: model));
                }
                _selectModel(provider, model);
              }
              Navigator.pop(ctx);
            },
            child: Text('确认', style: TextStyle(color: context.colors.primary)),
          ),
        ],
      ),
    );
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

  // ============================================================
  // 连接状态检测
  // ============================================================

  Future<void> _checkConnection(LlmProvider provider) async {
    final entry = _entries[provider.id];
    if (entry == null) return;
    if (provider.apiKey.isEmpty || provider.baseUrl.isEmpty) return;

    setState(() {
      entry.connectionStatus = ConnectionStatus.testing;
      entry.lastError = null;
    });

    final stopwatch = Stopwatch()..start();
    try {
      final repo = LlmRepositoryImpl(Dio());
      final success = await repo.testConnection(provider);
      stopwatch.stop();

      if (mounted) {
        setState(() {
          entry.connectionStatus = success ? ConnectionStatus.connected : ConnectionStatus.disconnected;
          entry.latencyMs = success ? stopwatch.elapsedMilliseconds : null;
          entry.lastError = success ? null : '连接失败';
        });
      }
    } catch (e) {
      stopwatch.stop();
      if (mounted) {
        setState(() {
          entry.connectionStatus = ConnectionStatus.disconnected;
          entry.latencyMs = null;
          entry.lastError = e.toString();
        });
      }
    }
  }

  void _checkAllConnections() {
    for (final p in _providers) {
      if (p.apiKey.isNotEmpty && p.baseUrl.isNotEmpty) {
        _checkConnection(p);
      }
    }
  }

  void _onIntervalTap() {
    setState(() {
      _intervalIndex = (_intervalIndex + 1) % _checkIntervalOptions.length;
    });
    _applyAutoCheckInterval();
  }

  void _onIntervalLongPress() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('自动检测间隔', style: AppTextStyles.h3.copyWith(fontSize: 16)),
            ),
            ...List.generate(_checkIntervalOptions.length, (i) {
              final opt = _checkIntervalOptions[i];
              final isSelected = i == _intervalIndex;
              return ListTile(
                title: Text(opt.label),
                trailing: isSelected ? Icon(Icons.check, color: context.colors.primary) : null,
                tileColor: isSelected ? context.colors.primarySurface : null,
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _intervalIndex = i);
                  _applyAutoCheckInterval();
                },
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _applyAutoCheckInterval() {
    _autoCheckTimer?.cancel();
    final duration = _checkIntervalOptions[_intervalIndex].duration;
    if (duration == null) return;

    _autoCheckTimer = Timer.periodic(duration, (_) {
      if (mounted) _checkAllConnections();
    });
    // 立即执行一次
    _checkAllConnections();
  }

  @override
  Widget build(BuildContext context) {
    final cap = widget.capability;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(title: Text('配置${cap.label}')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 当前使用中的服务商
                  if (_activeId != null) ...[
                    Text('当前使用', style: AppTextStyles.footnote.copyWith(color: context.colors.textSecondary)),
                    const SizedBox(height: 8),
                    _buildProviderCard(_providers.firstWhere((p) => p.id == _activeId), isActive: true),
                    const SizedBox(height: 20),
                  ],

                  // 其他服务商
                  ..._providers.where((p) => p.id != _activeId).map((p) => _buildProviderCard(p)),

                  if (_providers.where((p) => p.id != _activeId).isNotEmpty)
                    const SizedBox(height: 12),

                  // 添加服务商
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: _addProvider,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('添加服务商'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.colors.primary,
                        side: BorderSide(color: context.colors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildProviderCard(LlmProvider provider, {bool isActive = false}) {
    final preset = getPresetByKey(provider.providerKey);
    final entry = _entries[provider.id];
    final hasModels = entry != null && entry.fetchedModels.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: isActive ? Border.all(color: context.colors.primary, width: 1.5) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 服务商名称行 + 连接状态
            Row(
              children: [
                Text(preset?.icon ?? '🤖', style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    provider.name.isEmpty ? '未命名服务商' : provider.name,
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
                if (entry != null) _buildConnectionStatusIndicator(entry),
                if (isActive) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: context.colors.primarySurface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('使用中', style: AppTextStyles.caption.copyWith(color: context.colors.primary, fontSize: 11)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // 模型选择下拉 + 获取按钮
            if (entry != null) ...[
              Row(
                children: [
                  Expanded(child: _buildModelDropdown(provider, entry, hasModels)),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: entry.isLoading ? null : () => _fetchModelsForProvider(provider),
                      icon: entry.isLoading
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.sync, size: 16),
                      label: const Text('获取', style: TextStyle(fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // 检测连接 + 自动检测间隔
              _buildConnectionCheckRow(provider, entry),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 连接状态显示
  // ============================================================

  Widget _buildConnectionStatusIndicator(_ProviderModelEntry entry) {
    switch (entry.connectionStatus) {
      case ConnectionStatus.connected:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 14, color: context.colors.success),
            if (entry.latencyMs != null) ...[
              const SizedBox(width: 3),
              Text('${entry.latencyMs}ms', style: AppTextStyles.caption.copyWith(color: context.colors.success, fontSize: 11)),
            ],
          ],
        );
      case ConnectionStatus.disconnected:
        return Icon(Icons.error, size: 14, color: context.colors.error);
      case ConnectionStatus.testing:
        return const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2));
      case ConnectionStatus.unknown:
        return Icon(Icons.help_outline, size: 14, color: context.colors.textTertiary);
    }
  }

  Widget _buildConnectionCheckRow(LlmProvider provider, _ProviderModelEntry entry) {
    final canCheck = provider.apiKey.isNotEmpty && provider.baseUrl.isNotEmpty;
    final intervalLabel = _checkIntervalOptions[_intervalIndex].label;

    return Row(
      children: [
        // 检测连接按钮
        SizedBox(
          height: 32,
          child: TextButton.icon(
            onPressed: canCheck && entry.connectionStatus != ConnectionStatus.testing
                ? () => _checkConnection(provider)
                : null,
            icon: entry.connectionStatus == ConnectionStatus.testing
                ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5))
                : const Icon(Icons.wifi_tethering, size: 14),
            label: Text(
              entry.connectionStatus == ConnectionStatus.testing ? '检测中...' : '检测连接',
              style: const TextStyle(fontSize: 12),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),

        // 连接失败时显示错误信息
        if (entry.connectionStatus == ConnectionStatus.disconnected && entry.lastError != null)
          Expanded(
            child: Text(
              '失败',
              style: AppTextStyles.caption.copyWith(color: context.colors.error, fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          )
        else
          const Spacer(),

        // 自动检测间隔
        GestureDetector(
          onTap: _onIntervalTap,
          onLongPress: _onIntervalLongPress,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _intervalIndex > 0
                  ? context.colors.primarySurface
                  : context.colors.background,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _intervalIndex > 0 ? Icons.timer : Icons.timer_outlined,
                  size: 13,
                  color: _intervalIndex > 0 ? context.colors.primary : context.colors.textTertiary,
                ),
                const SizedBox(width: 3),
                Text(
                  intervalLabel,
                  style: AppTextStyles.caption.copyWith(
                    color: _intervalIndex > 0 ? context.colors.primary : context.colors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModelDropdown(LlmProvider provider, _ProviderModelEntry entry, bool hasModels) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: entry.selectedModel,
          isExpanded: true,
          hint: Text(
            '选择${widget.capability.label}',
            style: AppTextStyles.body.copyWith(color: context.colors.textHint, fontSize: 14),
          ),
          style: AppTextStyles.body.copyWith(fontSize: 14, color: context.colors.textPrimary),
          items: [
            ...entry.fetchedModels.map((m) => DropdownMenuItem(
              value: m.id,
              child: Text(m.id, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, color: context.colors.textPrimary)),
            )),
            if (hasModels) ...[
              const DropdownMenuItem(value: '__custom__', child: Divider(height: 1)),
              DropdownMenuItem(value: '__custom__', child: Text('✏️ 手动输入...', style: TextStyle(fontSize: 14, color: context.colors.textPrimary))),
            ],
          ],
          onChanged: (v) {
            if (v == '__custom__') {
              _showCustomModelDialog(provider, entry);
            } else if (v != null) {
              _selectModel(provider, v);
            }
          },
        ),
      ),
    );
  }
}

// ============================================================
// 服务商编辑页 — 仅配置服务商基础信息
// ============================================================

class _ProviderEditPage extends StatefulWidget {
  final LlmProvider? provider;
  const _ProviderEditPage({this.provider});

  @override
  State<_ProviderEditPage> createState() => _ProviderEditPageState();
}

class _ProviderEditPageState extends State<_ProviderEditPage> {
  late final TextEditingController _apiKeyCtrl;
  late final TextEditingController _baseUrlCtrl;

  String _selectedPresetKey = kCustomProviderKey;
  bool _obscureApiKey = true;

  double _temperature = 0.0;
  int _maxTokens = 1000;
  int _timeout = 30;
  bool _showAdvanced = false;

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
    }
  }

  @override
  void dispose() {
    _apiKeyCtrl.dispose();
    _baseUrlCtrl.dispose();
    super.dispose();
  }

  void _onPresetChanged(String key) {
    setState(() {
      _selectedPresetKey = key;
      if (key != kCustomProviderKey) {
        final preset = getPresetByKey(key)!;
        _baseUrlCtrl.text = preset.baseUrl;
      } else {
        _baseUrlCtrl.text = '';
      }
    });
  }

  void _save() {
    final apiKey = _apiKeyCtrl.text.trim();
    final baseUrl = _baseUrlCtrl.text.trim();

    if (apiKey.isEmpty || baseUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写 API Key 和请求地址'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    String name;
    if (_selectedPresetKey == kCustomProviderKey) {
      name = baseUrl.isNotEmpty ? Uri.tryParse(baseUrl)?.host ?? '自定义' : '自定义';
    } else {
      name = getPresetByKey(_selectedPresetKey)?.name ?? '自定义';
    }

    final cleanUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;

    // 保留已有的模型配置
    final models = widget.provider?.models ?? <String, ModelConfig>{};

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
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(_isEditing ? '编辑服务商' : '添加服务商'),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text('保存', style: AppTextStyles.body.copyWith(color: context.colors.primary)),
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
            const SizedBox(height: 12),

            // 提示信息
            if (!_isEditing)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.primarySurface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: context.colors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '保存后，请返回上一页通过能力卡片配置模型',
                        style: AppTextStyles.caption.copyWith(color: context.colors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // 4. 高级设置
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
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPresetKey,
          isExpanded: true,
          style: AppTextStyles.body.copyWith(color: context.colors.textPrimary),
          items: [
            ...aiProviderPresets.map((p) => DropdownMenuItem(
              value: p.key,
              child: Row(
                children: [
                  Text(p.icon, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(p.name, style: TextStyle(color: context.colors.textPrimary)),
                ],
              ),
            )),
            DropdownMenuItem(
              value: kCustomProviderKey,
              child: Row(
                children: [
                  const Text('✏️', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text('自定义', style: TextStyle(color: context.colors.textPrimary)),
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
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: TextField(
        controller: _apiKeyCtrl,
        obscureText: _obscureApiKey,
        style: AppTextStyles.body,
        decoration: InputDecoration(
          hintText: '输入 API Key',
          hintStyle: AppTextStyles.body.copyWith(color: context.colors.textHint),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureApiKey ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 20,
              color: context.colors.textTertiary,
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
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: TextField(
        controller: _baseUrlCtrl,
        style: AppTextStyles.body,
        decoration: InputDecoration(
          hintText: _isAnthropicFormat ? '如：https://api.anthropic.com' : '如：https://api.deepseek.com',
          hintStyle: AppTextStyles.body.copyWith(color: context.colors.textHint),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildAdvancedSection() {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
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
                Text(_temperature.toStringAsFixed(1), style: AppTextStyles.body.copyWith(color: context.colors.textSecondary)),
              ],
            ),
            Slider(
              value: _temperature,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              activeColor: context.colors.primary,
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
      child: Text(text, style: AppTextStyles.caption.copyWith(color: context.colors.textTertiary)),
    );
  }
}
