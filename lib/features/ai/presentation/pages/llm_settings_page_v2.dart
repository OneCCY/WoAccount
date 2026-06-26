import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
/// 三个卡片：供应商管理、功能配置、用量情况
class LlmSettingsPageV2 extends ConsumerStatefulWidget {
  const LlmSettingsPageV2({super.key});

  @override
  ConsumerState<LlmSettingsPageV2> createState() => _LlmSettingsPageV2State();
}

class _LlmSettingsPageV2State extends ConsumerState<LlmSettingsPageV2> {
  List<AiProvider> _providers = [];
  Map<String, AgentConfig> _agentConfigs = {};
  TraceStats? _stats;
  bool _isLoading = true;

  // 用量时间范围
  DateTime _usageStart = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _usageEnd = DateTime.now();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final providers = await ProviderStorage.loadAll();
    final configs = await AgentConfigStorage.loadAll();
    final stats = await TraceStorage.statsByDateRange(_usageStart, _usageEnd);
    if (mounted) {
      setState(() {
        _providers = providers;
        _agentConfigs = configs;
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _usageStart, end: _usageEnd),
    );
    if (picked != null) {
      setState(() {
        _usageStart = picked.start;
        _usageEnd = picked.end;
      });
      _load();
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
                  _buildSupplierCard(l10n),
                  const SizedBox(height: 12),
                  _buildAgentCard(l10n),
                  const SizedBox(height: 12),
                  _buildUsageCard(l10n),
                ],
              ),
            ),
    );
  }

  // ==================== 卡片 1：供应商管理 ====================

  Widget _buildSupplierCard(AppLocalizations l10n) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SupplierManagementPageV2()),
          );
          _load();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.dns_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text(l10n.aiSettingsSuppliers,
                      style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  Text('${_providers.length}',
                      style: Theme.of(context).textTheme.bodySmall),
                  const Icon(Icons.chevron_right, size: 20),
                ],
              ),
              const SizedBox(height: 12),
              if (_providers.isEmpty)
                Text(l10n.aiSettingsNoAgents,
                    style: Theme.of(context).textTheme.bodySmall)
              else
                ..._providers.take(3).map((p) => _buildSupplierRow(p)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupplierRow(AiProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            provider.isReady ? Icons.check_circle : Icons.error_outline,
            size: 16,
            color: provider.isReady ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(provider.name, style: const TextStyle(fontSize: 13)),
          ),
          Text(
            Uri.tryParse(provider.baseUrl)?.host ?? '',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  // ==================== 卡片 2：功能配置 ====================

  Widget _buildAgentCard(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.smart_toy_outlined, size: 20),
                const SizedBox(width: 8),
                Text(l10n.aiSettingsAgents,
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            ...AgentRegistry.all.map((agent) => _buildAgentRow(agent, l10n)),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentRow(AiAgent agent, AppLocalizations l10n) {
    final config = _agentConfigs[agent.id];
    final isConfigured = config != null &&
        config.providerId.isNotEmpty &&
        config.modelName.isNotEmpty;

    final providerName = isConfigured
        ? _providers.where((p) => p.id == config!.providerId).firstOrNull?.name ?? config!.providerId
        : null;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Text(agent.icon, style: const TextStyle(fontSize: 22)),
      title: Text(_getAgentName(l10n, agent), style: const TextStyle(fontSize: 14)),
      subtitle: isConfigured
          ? Text('$providerName / ${config!.modelName}',
              style: const TextStyle(fontSize: 11))
          : Text(l10n.aiSettingsNoAgents,
              style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.error)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      dense: true,
      onTap: () async {
        final result = await Navigator.push(context,
          MaterialPageRoute(builder: (_) => AgentEditPage(agentId: agent.id)),
        );
        if (result == true) _load();
      },
    );
  }

  // ==================== 卡片 3：用量情况 ====================

  Widget _buildUsageCard(AppLocalizations l10n) {
    final stats = _stats;
    final dateFormat = DateFormat('MM/dd');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart_outlined, size: 20),
                const SizedBox(width: 8),
                Text(l10n.aiSettingsUsage,
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                // 时间范围选择
                InkWell(
                  onTap: _pickDateRange,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.date_range, size: 14, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          '${dateFormat.format(_usageStart)} - ${dateFormat.format(_usageEnd)}',
                          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (stats == null || stats.total == 0)
              Text('暂无数据', style: Theme.of(context).textTheme.bodySmall)
            else ...[
              // 统计数字
              Row(
                children: [
                  _buildStatItem('${stats.total}', '总调用', Colors.blue),
                  _buildStatItem('${stats.success}', '成功', Colors.green),
                  _buildStatItem('${stats.failed}', '失败', Colors.red),
                  _buildStatItem('${stats.fallbackUsed}', '降级', Colors.orange),
                ],
              ),
              const SizedBox(height: 12),
              // Token 和延迟
              Row(
                children: [
                  _buildStatItem('${stats.totalInputTokens}', '输入 Token', Colors.teal),
                  _buildStatItem('${stats.totalOutputTokens}', '输出 Token', Colors.purple),
                  _buildStatItem('${stats.avgLatencyMs}ms', '平均延迟', Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              // 成功率进度条
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: stats.total > 0 ? stats.success / stats.total : 0,
                  minHeight: 6,
                  backgroundColor: Colors.red.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '成功率 ${stats.total > 0 ? (stats.success / stats.total * 100).toStringAsFixed(1) : 0}%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
        ],
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
