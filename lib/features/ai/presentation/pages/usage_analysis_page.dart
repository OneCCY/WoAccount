import 'package:flutter/material.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../data/models/ai_trace.dart';
import '../../data/storage/trace_storage.dart';

/// 用量分析页
///
/// 支持按年/月/周/日筛选，展示用量列表和统计。
class UsageAnalysisPage extends StatefulWidget {
  const UsageAnalysisPage({super.key});

  @override
  State<UsageAnalysisPage> createState() => _UsageAnalysisPageState();
}

enum _TimeRange { day, week, month, year }

class _UsageAnalysisPageState extends State<UsageAnalysisPage> {
  _TimeRange _range = _TimeRange.month;
  List<AiTrace> _traces = [];
  TraceStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final now = DateTime.now();
    DateTime start;
    DateTime end = now;

    switch (_range) {
      case _TimeRange.day:
        start = DateTime(now.year, now.month, now.day);
      case _TimeRange.week:
        start = now.subtract(Duration(days: now.weekday - 1));
        start = DateTime(start.year, start.month, start.day);
      case _TimeRange.month:
        start = DateTime(now.year, now.month, 1);
      case _TimeRange.year:
        start = DateTime(now.year, 1, 1);
    }

    final traces = await TraceStorage.getByDateRange(start, end);
    final stats = await TraceStorage.statsByDateRange(start, end);
    if (mounted) {
      setState(() {
        _traces = traces.reversed.toList();
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aiSettingsUsage)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 时间范围选择
                _buildRangeSelector(),
                // 统计概览
                if (_stats != null) _buildStatsOverview(),
                // 用量列表
                Expanded(child: _buildTraceList()),
              ],
            ),
    );
  }

  Widget _buildRangeSelector() {
    final labels = {
      _TimeRange.day: '日',
      _TimeRange.week: '周',
      _TimeRange.month: '月',
      _TimeRange.year: '年',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SegmentedButton<_TimeRange>(
        segments: labels.entries.map((e) =>
          ButtonSegment(value: e.key, label: Text(e.value))
        ).toList(),
        selected: {_range},
        onSelectionChanged: (v) {
          setState(() {
            _range = v.first;
            _isLoading = true;
          });
          _load();
        },
      ),
    );
  }

  Widget _buildStatsOverview() {
    final stats = _stats!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _statItem('${stats.total}', '总调用', Colors.blue),
              _statItem('${stats.success}', '成功', Colors.green),
              _statItem('${stats.failed}', '失败', Colors.red),
              _statItem('${stats.fallbackUsed}', '降级', Colors.orange),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statItem('${stats.totalInputTokens}', '输入Token', Colors.teal),
              _statItem('${stats.totalOutputTokens}', '输出Token', Colors.purple),
              _statItem('${stats.avgLatencyMs}ms', '平均延迟', Colors.grey),
              _statItem(
                stats.total > 0 ? '${(stats.success / stats.total * 100).toStringAsFixed(0)}%' : '-',
                '成功率',
                Colors.indigo,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildTraceList() {
    if (_traces.isEmpty) {
      return Center(
        child: Text('暂无数据', style: Theme.of(context).textTheme.bodySmall),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _traces.length,
      itemBuilder: (ctx, i) => _buildTraceItem(_traces[i]),
    );
  }

  Widget _buildTraceItem(AiTrace trace) {
    final time = TimeOfDay.fromDateTime(trace.timestamp);
    final dateStr = '${trace.timestamp.month}/${trace.timestamp.day}';

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        leading: Icon(
          trace.success ? Icons.check_circle : Icons.error,
          color: trace.success ? Colors.green : Colors.red,
          size: 20,
        ),
        title: Text(
          _agentName(trace.agentId),
          style: const TextStyle(fontSize: 13),
        ),
        subtitle: Text(
          '${trace.modelName}  ${trace.latencyMs}ms'
          '${trace.fallbackUsed ? "  (降级)" : ""}'
          '${trace.inputTokens != null ? "  in:${trace.inputTokens} out:${trace.outputTokens}" : ""}',
          style: const TextStyle(fontSize: 11),
        ),
        trailing: Text(
          '$dateStr ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }

  String _agentName(String agentId) {
    return switch (agentId) {
      'transaction_parser' => '💰 记账解析',
      'receipt_ocr' => '🧾 小票识别',
      'voice_transcribe' => '🎤 语音转写',
      'finance_search' => '🔍 财务搜索',
      'rule_engine' => '⚙️ 离线规则',
      _ => agentId,
    };
  }
}
