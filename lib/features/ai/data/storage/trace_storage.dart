import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ai_trace.dart';

/// Trace 存储层
///
/// 记录每次 AI 调用的 trace 数据。
/// SharedPreferences key: `llm_traces`
/// 保留最近 500 条记录。
class TraceStorage {
  static const _key = 'llm_traces';
  static const _maxRecords = 500;

  /// 加载所有 trace
  static Future<List<AiTrace>> loadAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_key);
      if (jsonStr == null || jsonStr.isEmpty) return [];
      final list = jsonDecode(jsonStr) as List;
      return list
          .map((e) => AiTrace.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// 记录一条 trace
  static Future<void> record(AiTrace trace) async {
    final all = await loadAll();
    all.add(trace);
    // 超过上限时移除最旧的记录
    if (all.length > _maxRecords) {
      all.removeRange(0, all.length - _maxRecords);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(all.map((t) => t.toJson()).toList()),
    );
  }

  /// 按 Agent ID 查询
  static Future<List<AiTrace>> getByAgent(String agentId) async {
    final all = await loadAll();
    return all.where((t) => t.agentId == agentId).toList();
  }

  /// 按时间范围查询
  static Future<List<AiTrace>> getByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final all = await loadAll();
    return all
        .where((t) => !t.timestamp.isBefore(start) && !t.timestamp.isAfter(end))
        .toList();
  }

  /// 清除所有 trace
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// 统计：按时间范围查询
  static Future<TraceStats> statsByDateRange(DateTime start, DateTime end) async {
    final traces = await getByDateRange(start, end);
    return TraceStats.fromTraces(traces);
  }

  /// 统计：本月
  static Future<TraceStats> monthlyStats() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return statsByDateRange(start, end);
  }
}

/// Trace 统计数据
class TraceStats {
  final int total;
  final int success;
  final int failed;
  final int fallbackUsed;
  final int totalInputTokens;
  final int totalOutputTokens;
  final int avgLatencyMs;

  const TraceStats({
    required this.total,
    required this.success,
    required this.failed,
    required this.fallbackUsed,
    required this.totalInputTokens,
    required this.totalOutputTokens,
    required this.avgLatencyMs,
  });

  factory TraceStats.fromTraces(List<AiTrace> traces) {
    if (traces.isEmpty) {
      return const TraceStats(
        total: 0, success: 0, failed: 0, fallbackUsed: 0,
        totalInputTokens: 0, totalOutputTokens: 0, avgLatencyMs: 0,
      );
    }
    final successCount = traces.where((t) => t.success).length;
    final fallbackCount = traces.where((t) => t.fallbackUsed).length;
    final inputTokens = traces.fold<int>(0, (s, t) => s + (t.inputTokens ?? 0));
    final outputTokens = traces.fold<int>(0, (s, t) => s + (t.outputTokens ?? 0));
    final totalLatency = traces.fold<int>(0, (s, t) => s + t.latencyMs);
    return TraceStats(
      total: traces.length,
      success: successCount,
      failed: traces.length - successCount,
      fallbackUsed: fallbackCount,
      totalInputTokens: inputTokens,
      totalOutputTokens: outputTokens,
      avgLatencyMs: traces.isNotEmpty ? (totalLatency / traces.length).round() : 0,
    );
  }
}
