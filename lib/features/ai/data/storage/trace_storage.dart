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

  /// 统计：本月调用次数和成功次数
  static Future<({int total, int success, int fallbackUsed})> monthlyStats() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    final traces = await getByDateRange(start, end);
    return (
      total: traces.length,
      success: traces.where((t) => t.success).length,
      fallbackUsed: traces.where((t) => t.fallbackUsed).length,
    );
  }
}
