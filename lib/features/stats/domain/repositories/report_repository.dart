/// 报表分析 Repository 接口（Domain 层）
abstract class ReportRepository {
  /// 获取指定日期范围的报表数据
  /// [isExpense]: true=支出分析, false=收入分析
  /// [groupBy]: 'day' | 'month' — 趋势图分组粒度
  Future<ReportSummary> getReport({
    required int bookId,
    required DateTime start,
    required DateTime end,
    required bool isExpense,
    String groupBy = 'day',
    String? uncategorizedLabel,
    String Function(int period, String groupBy)? trendLabelBuilder,
  });
}

/// 报表总览数据
class ReportSummary {
  final double totalAmount;
  final int transactionCount;
  final double? dailyAverage;
  final List<CategoryStat> categoryStats;
  final List<TrendPoint> trendPoints;

  const ReportSummary({
    required this.totalAmount,
    required this.transactionCount,
    this.dailyAverage,
    required this.categoryStats,
    required this.trendPoints,
  });
}

/// 分类统计数据（饼图 + 排行榜共用）
class CategoryStat {
  final int categoryId;
  final String categoryName;
  final String? categoryL10nKey;
  final String? categoryIcon;
  final String? categoryColor;
  final double amount;
  final int count;
  final double percentage;

  const CategoryStat({
    required this.categoryId,
    required this.categoryName,
    this.categoryL10nKey,
    this.categoryIcon,
    this.categoryColor,
    required this.amount,
    required this.count,
    required this.percentage,
  });
}

/// 趋势图数据点
class TrendPoint {
  final String label;
  final double amount;

  const TrendPoint({
    required this.label,
    required this.amount,
  });
}
