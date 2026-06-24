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
import '../../../../core/ai/llm_error_resolver.dart';
import '../../../../core/widgets/toast.dart';
import 'package:wo_account/l10n/app_localizations.dart';

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

  throw const LlmException('无法获取模型列表', errorCode: 'llmSettingsGetModelListError');
}

List<_FetchedModel> filterModelsByCapability(List<_FetchedModel> models, ModelCapability cap) {
  if (cap.filterKeywords.isEmpty) return models;
  return models.where((m) {
    final id = m.id.toLowerCase();
    return cap.filterKeywords.any((kw) => id.contains(kw.toLowerCase()));
  }).toList();
}

// ============================================================
// LLM 服务配置页 — 模型管理入口
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

  void _openModelManagement() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _ModelManagementPage()),
    );
    _load();
  }

  void _openSupplierManagement() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _SupplierManagementPage()),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(title: Text(l10n.llmSettingsTitle)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. 模型管理入口（多行展示各能力配置）
                  _buildModelEntryCard(l10n),
                  const SizedBox(height: 12),

                  // 2. 服务商管理入口
                  _buildSupplierEntryCard(l10n),
                ],
              ),
            ),
    );
  }

  /// 模型管理入口卡片 — 图标+名称在左，各能力配置在右
  Widget _buildModelEntryCard(AppLocalizations l10n) {
    final active = _activeProvider;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: InkWell(
        onTap: _openModelManagement,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 左侧：图标 + 名称（垂直布局）
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: context.colors.primarySurface,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                      ),
                      child: Center(child: Icon(Icons.smart_toy_outlined, size: 22, color: context.colors.primary)),
                    ),
                    const SizedBox(height: 6),
                    Text(l10n.llmModelManagement,
                      style: AppTextStyles.caption.copyWith(
                        color: context.colors.textSecondary, fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // 右侧：各能力配置状态
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: ModelCapability.values.map((cap) {
                      final model = active?.getModelForCapability(cap);
                      final hasModel = model != null && model.isNotEmpty;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Row(
                          children: [
                            Text(cap.emoji, style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            Text('${cap.getLocalizedLabel(l10n)}：',
                              style: AppTextStyles.caption.copyWith(color: context.colors.textTertiary)),
                            Expanded(
                              child: Text(
                                hasModel ? model : l10n.llmNotConfigured,
                                style: AppTextStyles.caption.copyWith(
                                  color: hasModel ? context.colors.textSecondary : context.colors.textHint,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Icon(Icons.chevron_right, color: context.colors.textTertiary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 服务商管理入口卡片 — 图标+名称在左，状态信息在右
  Widget _buildSupplierEntryCard(AppLocalizations l10n) {
    final count = _providers.length;
    final activeName = _activeProvider?.name;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: InkWell(
        onTap: _openSupplierManagement,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: context.colors.primarySurface,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    ),
                    child: Center(child: Icon(Icons.cloud_outlined, size: 22, color: context.colors.primary)),
                  ),
                  const SizedBox(height: 6),
                  Text(l10n.llmSupplierManagement,
                    style: AppTextStyles.caption.copyWith(
                      color: context.colors.textSecondary, fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: count > 0
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$count ${l10n.llmConfigured}',
                            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
                          if (activeName != null) ...[
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.check_circle, size: 12, color: context.colors.primary),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text('${l10n.llmInUse}：$activeName',
                                    style: AppTextStyles.caption.copyWith(color: context.colors.primary),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      )
                    : Text(l10n.llmNoProviders,
                        style: AppTextStyles.caption.copyWith(color: context.colors.textTertiary)),
              ),
              Icon(Icons.chevron_right, color: context.colors.textTertiary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 模型管理页 — 按能力选择服务商和模型
// ============================================================

class _ModelManagementPage extends StatefulWidget {
  const _ModelManagementPage();

  @override
  State<_ModelManagementPage> createState() => _ModelManagementPageState();
}

class _ModelManagementPageState extends State<_ModelManagementPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Trigger initial build after frame; cards use FutureBuilder internally
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  void _openCapabilityConfig(ModelCapability cap) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _CapabilityConfigPage(capability: cap)),
    );
    // Force rebuild so FutureBuilder re-resolves each capability
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(title: Text(l10n.llmModelManagement)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...ModelCapability.values.map((cap) => _buildCapabilityCard(cap, l10n)),
                ],
              ),
            ),
    );
  }

  Widget _buildCapabilityCard(ModelCapability cap, AppLocalizations l10n) {
    return FutureBuilder<(LlmProvider?, String?)>(
      future: LlmConfigManager.resolveCapabilityConfig(cap),
      builder: (context, snapshot) {
        final (provider, modelName) = snapshot.data ?? (null, null);
        final providerName = provider?.name ?? '';
        final hasConfig = modelName != null && modelName.isNotEmpty;

        String subtitle;
        if (hasConfig && providerName.isNotEmpty) {
          subtitle = '$providerName · $modelName';
        } else if (hasConfig) {
          subtitle = modelName;
        } else {
          subtitle = l10n.llmNotConfigured;
        }

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
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: context.colors.primarySurface,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    ),
                    child: Center(child: Text(cap.emoji, style: const TextStyle(fontSize: 22))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cap.getLocalizedLabel(l10n), style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(subtitle,
                          style: AppTextStyles.caption.copyWith(
                            color: hasConfig ? context.colors.primary : context.colors.textTertiary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: hasConfig
                          ? context.colors.success.withValues(alpha: 0.1)
                          : context.colors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      hasConfig ? l10n.llmConfigured : l10n.llmNotConfigured,
                      style: AppTextStyles.caption.copyWith(
                        color: hasConfig ? context.colors.success : context.colors.warning,
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
      },
    );
  }
}

// ============================================================
// 服务商管理页 — 独立页面，管理所有服务商
// ============================================================

class _SupplierManagementPage extends StatefulWidget {
  const _SupplierManagementPage();

  @override
  State<_SupplierManagementPage> createState() => _SupplierManagementPageState();
}

class _SupplierManagementPageState extends State<_SupplierManagementPage> {
  List<LlmProvider> _providers = [];
  bool _isLoading = true;

  // Connection status per provider
  final Map<String, ConnectionStatus> _connectionStatuses = {};
  final Map<String, int?> _latencies = {};

  @override
  void initState() {
    super.initState();
    _load().then((_) => _checkAllConnections());
  }

  Future<void> _load() async {
    final providers = await LlmConfigManager.loadProviders();
    if (mounted) {
      setState(() {
        _providers = providers;
        _isLoading = false;
      });
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

  Future<void> _deleteProvider(LlmProvider provider) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.llmDeleteProvider),
        content: Text(l10n.llmDeleteProviderConfirm(provider.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonDelete, style: TextStyle(color: context.colors.error)),
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
    if (provider.apiKey.isEmpty || provider.baseUrl.isEmpty) {
      AppToast.show(context, AppLocalizations.of(context)!.llmConfigIncomplete);
      return;
    }
    await _checkConnection(provider);
    if (mounted) {
      final status = _connectionStatuses[provider.id];
      if (status == ConnectionStatus.connected) {
        AppToast.show(context, AppLocalizations.of(context)!.llmConnectSuccess);
      } else {
        AppToast.show(context, AppLocalizations.of(context)!.llmConnectFail);
      }
    }
  }

  Future<void> _checkAllConnections() async {
    for (final p in _providers) {
      if (p.apiKey.isNotEmpty && p.baseUrl.isNotEmpty) await _checkConnection(p);
    }
  }

  Future<void> _checkConnection(LlmProvider provider) async {
    if (!mounted) return;
    setState(() {
      _connectionStatuses[provider.id] = ConnectionStatus.testing;
    });

    final stopwatch = Stopwatch()..start();
    try {
      final repo = LlmRepositoryImpl(Dio());
      final success = await repo.testConnection(provider);
      stopwatch.stop();
      if (mounted) {
        setState(() {
          _connectionStatuses[provider.id] = success ? ConnectionStatus.connected : ConnectionStatus.disconnected;
          _latencies[provider.id] = success ? stopwatch.elapsedMilliseconds : null;
        });
      }
    } catch (_) {
      stopwatch.stop();
      if (mounted) {
        setState(() {
          _connectionStatuses[provider.id] = ConnectionStatus.disconnected;
          _latencies[provider.id] = null;
        });
      }
    }
  }

  Future<void> _exportConfig() async {
    final json = await LlmConfigManager.exportConfig();
    await Clipboard.setData(ClipboardData(text: json));
    if (mounted) {
      AppToast.show(context, AppLocalizations.of(context)!.llmConfigCopied);
    }
  }

  Future<void> _importConfig() async {
    final data = await Clipboard.getData('text/plain');
    final text = data?.text;
    if (text == null || text.isEmpty) {
      if (mounted) {
        AppToast.show(context, AppLocalizations.of(context)!.llmClipboardEmpty);
      }
      return;
    }

    final count = await LlmConfigManager.importConfig(text);
    if (mounted) {
      if (count > 0) {
        AppToast.show(context, AppLocalizations.of(context)!.llmImported(count.toString()));
        await _load();
      } else {
        AppToast.show(context, AppLocalizations.of(context)!.llmImportFailed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(l10n.llmSupplierManagement),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (v) {
              if (v == 'export') _exportConfig();
              if (v == 'import') _importConfig();
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'export', child: Text(l10n.llmExportConfig)),
              PopupMenuItem(value: 'import', child: Text(l10n.llmImportConfig)),
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
                  _providers.isEmpty ? _buildEmptyHint(l10n) : _buildProviderList(l10n),
                  const SizedBox(height: 16),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: _addProvider,
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(l10n.llmAddProvider),
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

  Widget _buildEmptyHint(AppLocalizations l10n) {
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
            Text(l10n.llmNoProviders, style: AppTextStyles.body.copyWith(color: context.colors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderList(AppLocalizations l10n) {
    return Column(
      children: _providers.map((p) {
        final status = _connectionStatuses[p.id] ?? ConnectionStatus.unknown;
        final latency = _latencies[p.id];
        final preset = getPresetByKey(p.providerKey);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
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
                        p.name.isEmpty ? l10n.llmUnnamedProvider : p.name,
                        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    // Connection status indicator
                    _buildStatusChip(status, latency, l10n),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _actionButton(
                      icon: Icons.wifi_tethering, label: l10n.llmTest,
                      onTap: () => _testProvider(p),
                    ),
                    _actionButton(
                      icon: Icons.edit_outlined, label: l10n.commonEdit,
                      onTap: () => _editProvider(p),
                    ),
                    _actionButton(
                      icon: Icons.delete_outline, label: l10n.commonDelete,
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

  Widget _buildStatusChip(ConnectionStatus status, int? latency, AppLocalizations l10n) {
    final isConnected = status == ConnectionStatus.connected;
    final isTesting = status == ConnectionStatus.testing;
    final color = isConnected ? context.colors.success : context.colors.textTertiary;
    final label = isTesting
        ? '...'
        : isConnected
            ? '${latency ?? '?'}ms'
            : l10n.llmConnectFail;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (isConnected ? context.colors.success : context.colors.textTertiary).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isTesting)
            SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 1.5, color: color))
          else
            Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.caption.copyWith(color: color, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _actionButton({
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

List<_CheckIntervalOption> _buildCheckIntervalOptions(AppLocalizations l10n) => [
  _CheckIntervalOption(l10n.llmIntervalOff, null),
  _CheckIntervalOption(l10n.llmInterval10s, const Duration(seconds: 10)),
  _CheckIntervalOption(l10n.llmInterval30s, const Duration(seconds: 30)),
  _CheckIntervalOption(l10n.llmInterval1m, const Duration(minutes: 1)),
  _CheckIntervalOption(l10n.llmInterval2m, const Duration(minutes: 2)),
  _CheckIntervalOption(l10n.llmInterval5m, const Duration(minutes: 5)),
  _CheckIntervalOption(l10n.llmInterval10m, const Duration(minutes: 10)),
  _CheckIntervalOption(l10n.llmInterval30m, const Duration(minutes: 30)),
  _CheckIntervalOption(l10n.llmInterval1h, const Duration(hours: 1)),
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
  String? _selectedProviderId;  // 当前选中的供应商
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
    _load().then((_) => _checkAllConnections());
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

    // Determine which provider currently owns this capability
    String? selectedId;
    for (final p in providers) {
      final model = p.models[widget.capability.name];
      if (model != null && model.providerId != null && model.modelName.isNotEmpty) {
        selectedId = model.providerId;
        break;
      }
    }

    final entries = <String, _ProviderModelEntry>{};
    for (final p in providers) {
      final entry = _ProviderModelEntry();
      entry.selectedModel = p.getModelForCapability(widget.capability);

      // 1. 优先加载已缓存的模型列表
      final cached = await LlmConfigManager.loadFetchedModels(
          p.id, widget.capability.name);

      if (cached.isNotEmpty) {
        entry.fetchedModels = cached.map((m) => _FetchedModel(id: m)).toList();
      } else {
        // 2. 回退到预设默认模型
        final preset = getPresetByKey(p.providerKey);
        if (preset != null) {
          final defaults = preset.defaultModelsByCapability[widget.capability.name] ?? [];
          entry.fetchedModels = defaults.map((m) => _FetchedModel(id: m)).toList();
        }
      }

      // 3. 确保当前选中的模型在列表中（防止 DropdownButton 断言错误）
      if (entry.selectedModel != null &&
          !entry.fetchedModels.any((m) => m.id == entry.selectedModel)) {
        entry.fetchedModels.insert(0, _FetchedModel(id: entry.selectedModel!));
      }

      entries[p.id] = entry;
    }

    setState(() {
      _providers = providers;
      _activeId = activeId;
      _selectedProviderId = selectedId ?? activeId;
      _entries.clear();
      _entries.addAll(entries);
      _isLoading = false;
    });
  }

  Future<void> _fetchModelsForProvider(LlmProvider provider) async {
    final entry = _entries[provider.id];
    if (entry == null) return;

    if (provider.apiKey.isEmpty || provider.baseUrl.isEmpty) {
      AppToast.show(context, AppLocalizations.of(context)!.llmProviderNotConfigured);
      return;
    }

    setState(() => entry.isLoading = true);

    try {
      final allModels = await fetchModelsFromApi(provider.baseUrl, provider.apiKey);
      final filtered = filterModelsByCapability(allModels, widget.capability);

      if (mounted) {
        final models = filtered.isNotEmpty ? filtered : allModels;
        setState(() {
          entry.fetchedModels = models;
          entry.isLoading = false;
        });
        // 缓存获取到的模型列表
        await LlmConfigManager.saveFetchedModels(
            provider.id, widget.capability.name, models.map((m) => m.id).toList());
        final msg = filtered.isNotEmpty
            ? AppLocalizations.of(context)!.llmModelsFetched(filtered.length.toString(), widget.capability.getLocalizedLabel(AppLocalizations.of(context)!))
            : AppLocalizations.of(context)!.llmModelsFetchedAll(allModels.length.toString());
        AppToast.show(context, msg);
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
          AppToast.show(context, AppLocalizations.of(context)!.llmFetchFailed);
        } else {
          AppToast.show(context, AppLocalizations.of(context)!.llmFetchError(resolveLlmError(e, AppLocalizations.of(context)!)));
        }
      }
    }
  }

  Future<void> _selectModel(LlmProvider provider, String? model) async {
    if (model == null) return;

    // 1. Save model config with providerId
    final newModels = Map<String, ModelConfig>.from(provider.models);
    newModels[widget.capability.name] = ModelConfig(
      modelName: model,
      providerId: provider.id,
    );

    final updated = provider.copyWith(models: newModels);
    await LlmConfigManager.updateProvider(updated);

    // 2. Clean up old providers' capability config
    for (final p in _providers) {
      if (p.id == provider.id) continue;
      if (p.models.containsKey(widget.capability.name)) {
        final cleaned = Map<String, ModelConfig>.from(p.models);
        cleaned.remove(widget.capability.name);
        await LlmConfigManager.updateProvider(p.copyWith(models: cleaned));
      }
    }

    if (mounted) {
      setState(() {
        _entries[provider.id]!.selectedModel = model;
        // 更新本地 provider 列表
        final idx = _providers.indexWhere((p) => p.id == provider.id);
        if (idx != -1) _providers[idx] = updated;
        // Remove capability from other providers in local state
        for (var i = 0; i < _providers.length; i++) {
          if (_providers[i].id != provider.id &&
              _providers[i].models.containsKey(widget.capability.name)) {
            final cleaned = Map<String, ModelConfig>.from(_providers[i].models);
            cleaned.remove(widget.capability.name);
            _providers[i] = _providers[i].copyWith(models: cleaned);
          }
        }
      });
      AppToast.show(context, AppLocalizations.of(context)!.llmModelSet(widget.capability.getLocalizedLabel(AppLocalizations.of(context)!), provider.name, model));
    }
  }

  Future<void> _deselectModel(LlmProvider provider) async {
    // Remove capability from this provider
    final newModels = Map<String, ModelConfig>.from(provider.models);
    newModels.remove(widget.capability.name);
    final updated = provider.copyWith(models: newModels);
    await LlmConfigManager.updateProvider(updated);

    if (mounted) {
      setState(() {
        final idx = _providers.indexWhere((p) => p.id == provider.id);
        if (idx != -1) _providers[idx] = updated;
        final entry = _entries[provider.id];
        if (entry != null) entry.selectedModel = null;
      });
    }
  }

  void _showCustomModelDialog(LlmProvider provider, _ProviderModelEntry entry) {
    _customModelCtrl.text = entry.selectedModel ?? '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.llmInputModelName(widget.capability.label)),
        content: TextField(
          controller: _customModelCtrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: widget.capability == ModelCapability.audio ? 'whisper-1' : widget.capability.label,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(context)!.commonCancel)),
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
            child: Text(AppLocalizations.of(context)!.commonConfirm, style: TextStyle(color: context.colors.primary)),
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
    final l10n = AppLocalizations.of(context)!;

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
          entry.lastError = success ? null : l10n.llmConnectFailed;
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
    final l10n = AppLocalizations.of(context)!;
    final options = _buildCheckIntervalOptions(l10n);
    setState(() {
      _intervalIndex = (_intervalIndex + 1) % options.length;
    });
    _applyAutoCheckInterval();
  }

  void _onIntervalLongPress() {
    final l10n = AppLocalizations.of(context)!;
    final options = _buildCheckIntervalOptions(l10n);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.llmAutoDetectInterval, style: AppTextStyles.h3.copyWith(fontSize: 16)),
            ),
            ...List.generate(options.length, (i) {
              final opt = options[i];
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
    final l10n = AppLocalizations.of(context)!;
    final options = _buildCheckIntervalOptions(l10n);
    final duration = options[_intervalIndex].duration;
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
    final l10n = AppLocalizations.of(context)!;
    final selectedProvider = _selectedProviderId != null
        ? _providers.where((p) => p.id == _selectedProviderId).firstOrNull
        : null;
    final selectedEntry = selectedProvider != null ? _entries[selectedProvider.id] : null;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(title: Text(l10n.llmConfigureCap(cap.getLocalizedLabel(l10n)))),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step 1: 选择供应商
                  Text('1. ${l10n.llmSelectProvider}', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ..._providers.map((p) => _buildProviderRadio(p, l10n)),
                  const SizedBox(height: 8),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: _addProvider,
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(l10n.llmAddProvider),
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

                  // Step 2: 选择模型（仅选中供应商后显示）
                  if (selectedProvider != null && selectedEntry != null) ...[
                    const SizedBox(height: 24),
                    Text('2. ${l10n.llmSelectModel}', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _buildModelSection(selectedProvider, selectedEntry, l10n),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildProviderRadio(LlmProvider provider, AppLocalizations l10n) {
    final preset = getPresetByKey(provider.providerKey);
    final isSelected = provider.id == _selectedProviderId;
    final hasConfig = provider.apiKey.isNotEmpty && provider.baseUrl.isNotEmpty;
    final entry = _entries[provider.id];
    final isConnected = entry?.connectionStatus == ConnectionStatus.connected;
    final isTesting = entry?.connectionStatus == ConnectionStatus.testing;
    final canSelect = hasConfig && isConnected;

    return GestureDetector(
      onTap: canSelect
          ? () => setState(() => _selectedProviderId = provider.id)
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.primarySurface : context.colors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: isSelected
              ? Border.all(color: context.colors.primary, width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              size: 20,
              color: canSelect
                  ? (isSelected ? context.colors.primary : context.colors.textTertiary)
                  : context.colors.textHint.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 10),
            Text(preset?.icon ?? '🤖', style: TextStyle(fontSize: 18, color: canSelect ? null : context.colors.textHint)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.name.isEmpty ? l10n.llmUnnamedProvider : provider.name,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: canSelect ? null : context.colors.textHint,
                    ),
                  ),
                  if (!hasConfig)
                    Text(l10n.llmProviderIncomplete, style: AppTextStyles.caption.copyWith(color: context.colors.textTertiary)),
                  if (hasConfig && !isConnected && !isTesting)
                    Text(l10n.llmConnectFail, style: AppTextStyles.caption.copyWith(color: context.colors.error, fontSize: 11)),
                  if (isTesting)
                    Text('...', style: AppTextStyles.caption.copyWith(color: context.colors.textTertiary)),
                ],
              ),
            ),
            // Connection status dot
            if (hasConfig) _buildStatusDot(entry),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDot(_ProviderModelEntry? entry) {
    if (entry == null) return const SizedBox.shrink();
    final isConnected = entry.connectionStatus == ConnectionStatus.connected;
    final isTesting = entry.connectionStatus == ConnectionStatus.testing;
    final color = isConnected ? context.colors.success : context.colors.textTertiary;

    if (isTesting) {
      return SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.textTertiary));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        if (isConnected && entry.latencyMs != null) ...[
          const SizedBox(width: 4),
          Text('${entry.latencyMs}ms', style: AppTextStyles.caption.copyWith(color: context.colors.success, fontSize: 10)),
        ],
      ],
    );
  }

  Widget _buildModelSection(LlmProvider provider, _ProviderModelEntry entry, AppLocalizations l10n) {
    final hasModels = entry.fetchedModels.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 模型下拉 + 获取按钮
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
                  label: Text(l10n.llmFetch, style: const TextStyle(fontSize: 13)),
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
          // 连接检测
          _buildConnectionCheckRow(provider, entry),
        ],
      ),
    );
  }

  Widget _buildConnectionCheckRow(LlmProvider provider, _ProviderModelEntry entry) {
    final l10n = AppLocalizations.of(context)!;
    final canCheck = provider.apiKey.isNotEmpty && provider.baseUrl.isNotEmpty;
    final options = _buildCheckIntervalOptions(l10n);
    final intervalLabel = options[_intervalIndex].label;

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
              entry.connectionStatus == ConnectionStatus.testing ? l10n.llmTesting : l10n.llmTestConnection,
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
              l10n.llmFailed,
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
            AppLocalizations.of(context)!.llmSelectCap(widget.capability.label),
            style: AppTextStyles.body.copyWith(color: context.colors.textHint, fontSize: 14),
          ),
          style: AppTextStyles.body.copyWith(fontSize: 14, color: context.colors.textPrimary),
          items: [
            // None option — allow deselecting
            DropdownMenuItem<String>(
              value: null,
              child: Text(AppLocalizations.of(context)!.llmNone, style: TextStyle(fontSize: 14, color: context.colors.textHint)),
            ),
            ...entry.fetchedModels.map((m) => DropdownMenuItem(
              value: m.id,
              child: Text(m.id, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, color: context.colors.textPrimary)),
            )),
            if (hasModels) ...[
              const DropdownMenuItem(value: '__custom__', child: Divider(height: 1)),
              DropdownMenuItem(value: '__custom__', child: Text(AppLocalizations.of(context)!.llmManualInput, style: TextStyle(fontSize: 14, color: context.colors.textPrimary))),
            ],
          ],
          onChanged: (v) {
            if (v == '__custom__') {
              _showCustomModelDialog(provider, entry);
            } else if (v != null) {
              _selectModel(provider, v);
            } else {
              // Deselect — remove capability from this provider
              _deselectModel(provider);
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
    final l10n = AppLocalizations.of(context)!;
    final apiKey = _apiKeyCtrl.text.trim();
    final baseUrl = _baseUrlCtrl.text.trim();

    if (apiKey.isEmpty || baseUrl.isEmpty) {
      AppToast.show(context, l10n.llmFillApiKey);
      return;
    }

    String name;
    if (_selectedPresetKey == kCustomProviderKey) {
      name = baseUrl.isNotEmpty ? Uri.tryParse(baseUrl)?.host ?? l10n.llmCustom : l10n.llmCustom;
    } else {
      name = getPresetByKey(_selectedPresetKey)?.getLocalizedName(l10n) ?? l10n.llmCustom;
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(_isEditing ? l10n.llmEditProvider : l10n.llmAddProvider),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(l10n.commonSave, style: AppTextStyles.body.copyWith(color: context.colors.primary)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 服务商名称
            _label(l10n.llmProviderName),
            _buildPresetDropdown(),
            const SizedBox(height: 16),

            // 2. API Key
            _label('API Key'),
            _buildApiKeyField(),
            const SizedBox(height: 16),

            // 3. 请求地址
            _label(l10n.llmApiUrl),
            _buildBaseUrlField(),
            const SizedBox(height: 4),
            _hint(_isAnthropicFormat
                ? l10n.llmApiUrlHintAnthropic
                : l10n.llmApiUrlHelper),
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
                        l10n.llmSaveHint,
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
                  Text(p.getLocalizedName(AppLocalizations.of(context)!), style: TextStyle(color: context.colors.textPrimary)),
                ],
              ),
            )),
            DropdownMenuItem(
              value: kCustomProviderKey,
              child: Row(
                children: [
                  const Text('✏️', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.llmCustom, style: TextStyle(color: context.colors.textPrimary)),
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
          hintText: AppLocalizations.of(context)!.llmInputApiKey,
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
          hintText: AppLocalizations.of(context)!.llmApiUrlExample,
          hintStyle: AppTextStyles.body.copyWith(color: context.colors.textHint),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildAdvancedSection() {
    final l10n = AppLocalizations.of(context)!;
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
          title: Text(l10n.llmAdvancedSettings, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
          children: [
            // 回答风格标题 + 提示
            Text(l10n.llmTemperature, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(l10n.llmTemperatureHint, style: AppTextStyles.caption.copyWith(color: context.colors.textTertiary)),
            const SizedBox(height: 8),
            // 滑块 + 两端标签
            Row(
              children: [
                Text(l10n.llmTemperaturePrecise, style: AppTextStyles.caption.copyWith(color: context.colors.textTertiary)),
                Expanded(
                  child: Slider(
                    value: _temperature,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    activeColor: context.colors.primary,
                    onChanged: (v) => setState(() => _temperature = v),
                  ),
                ),
                Text(l10n.llmTemperatureCreative, style: AppTextStyles.caption.copyWith(color: context.colors.textTertiary)),
              ],
            ),
            Center(
              child: Text(
                _temperature.toStringAsFixed(1),
                style: AppTextStyles.caption.copyWith(color: context.colors.textSecondary),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(l10n.llmMaxToken, style: AppTextStyles.body),
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
                Text(l10n.llmTimeout, style: AppTextStyles.body),
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
