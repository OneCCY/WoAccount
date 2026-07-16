import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import 'package:dio/dio.dart';

import '../../data/models/ai_provider.dart';
import '../../data/storage/provider_storage.dart';
import 'provider_edit_page_v2.dart';

/// 供应商管理页（v2.0）
///
/// 纯连接配置管理，不含模型选择。
class SupplierManagementPageV2 extends ConsumerStatefulWidget {
  const SupplierManagementPageV2({super.key});

  @override
  ConsumerState<SupplierManagementPageV2> createState() => _SupplierManagementPageV2State();
}

enum _ConnectionStatus { unknown, testing, connected, disconnected }

class _SupplierManagementPageV2State extends ConsumerState<SupplierManagementPageV2> {
  List<AiProvider> _providers = [];
  Map<String, _ConnectionStatus> _statuses = {};
  Map<String, int?> _latencies = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final providers = await ProviderStorage.loadAll();
    if (mounted) {
      setState(() {
        _providers = providers;
        _isLoading = false;
      });
      _checkAllConnections();
    }
  }

  Future<void> _checkAllConnections() async {
    for (final p in _providers) {
      await _checkConnection(p);
    }
  }

  Future<void> _checkConnection(AiProvider provider) async {
    setState(() {
      _statuses[provider.id] = _ConnectionStatus.testing;
    });

    final stopwatch = Stopwatch()..start();
    try {
      // 根据预设判断 API 格式
      final isAnthropic = provider.providerKey == 'claude';
      final baseUrl = provider.baseUrl.replaceAll(RegExp(r'/+$'), '');
      final candidates = [
        '$baseUrl/v1/models',
        '$baseUrl/models',
      ];

      final headers = isAnthropic
          ? {'x-api-key': provider.apiKey, 'anthropic-version': '2023-06-01'}
          : {'Authorization': 'Bearer ${provider.apiKey}'};

      final dio = Dio();
      bool connected = false;
      for (final url in candidates) {
        try {
          final response = await dio.get(
            url,
            options: Options(
              headers: headers,
              receiveTimeout: const Duration(seconds: 10),
            ),
          );
          if (response.statusCode == 200) {
            connected = true;
            break;
          }
        } on DioException catch (e) {
          // 401/403 表示 API Key 无效，连接失败
          if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
            connected = false;
            break;
          }
          if (e.response?.statusCode == 404) continue;
          rethrow;
        }
      }

      stopwatch.stop();
      if (mounted) {
        setState(() {
          _statuses[provider.id] = connected
              ? _ConnectionStatus.connected
              : _ConnectionStatus.disconnected;
          _latencies[provider.id] = connected ? stopwatch.elapsedMilliseconds : null;
        });
      }
    } catch (_) {
      stopwatch.stop();
      if (mounted) {
        setState(() {
          _statuses[provider.id] = _ConnectionStatus.disconnected;
          _latencies[provider.id] = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aiSettingsSuppliers),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addProvider,
            tooltip: l10n.aiSettingsAddSupplier,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _providers.isEmpty
              ? Center(child: Text(l10n.aiSettingsNoAgents))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _providers.length,
                  itemBuilder: (ctx, i) => _buildProviderCard(_providers[i], l10n),
                ),
    );
  }

  Widget _buildProviderCard(AiProvider provider, AppLocalizations l10n) {
    final status = _statuses[provider.id] ?? _ConnectionStatus.unknown;
    final latency = _latencies[provider.id];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatusIcon(status),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(provider.name, style: Theme.of(context).textTheme.titleSmall),
                      Text(
                        Uri.tryParse(provider.baseUrl)?.host ?? provider.baseUrl,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (status == _ConnectionStatus.connected && latency != null)
                  Chip(
                    label: Text('${latency}ms', style: const TextStyle(fontSize: 11)),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _checkConnection(provider),
                  icon: const Icon(Icons.wifi_tethering, size: 16),
                  label: Text(l10n.aiSettingsTestConnection),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _editProvider(provider),
                  icon: const Icon(Icons.edit, size: 16),
                  label: Text(l10n.agentEditSave),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _deleteProvider(provider, l10n),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: Text(l10n.cancel),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(_ConnectionStatus status) {
    return switch (status) {
      _ConnectionStatus.connected => const Icon(Icons.check_circle, color: Colors.green, size: 20),
      _ConnectionStatus.disconnected => const Icon(Icons.error_outline, color: Colors.red, size: 20),
      _ConnectionStatus.testing => const SizedBox(
          width: 20, height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      _ConnectionStatus.unknown => const Icon(Icons.help_outline, color: Colors.grey, size: 20),
    };
  }

  Future<void> _addProvider() async {
    final result = await Navigator.push<AiProvider>(
      context,
      MaterialPageRoute(builder: (_) => const ProviderEditPageV2()),
    );
    if (result != null) {
      await ProviderStorage.add(result);
      _load();
    }
  }

  Future<void> _editProvider(AiProvider provider) async {
    final result = await Navigator.push<AiProvider>(
      context,
      MaterialPageRoute(builder: (_) => ProviderEditPageV2(provider: provider)),
    );
    if (result != null) {
      await ProviderStorage.update(result);
      _load();
    }
  }

  Future<void> _deleteProvider(AiProvider provider, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.cancel),
        content: Text('确定删除 ${provider.name}？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.confirm)),
        ],
      ),
    );
    if (confirmed == true) {
      await ProviderStorage.delete(provider.id);
      _load();
    }
  }
}
