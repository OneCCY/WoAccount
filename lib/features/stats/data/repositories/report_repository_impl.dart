import 'package:drift/drift.dart';
import '../../../../config/database/app_database.dart';
import '../../domain/repositories/report_repository.dart';

/// 报表分析 Repository 实现（Data 层）
/// 使用 Drift SQL 聚合查询（selectOnly + GROUP BY），避免全量加载到内存
class ReportRepositoryImpl implements ReportRepository {
  final AppDatabase _db;

  ReportRepositoryImpl(this._db);

  @override
  Future<ReportSummary> getReport({
    required int bookId,
    required DateTime start,
    required DateTime end,
    required bool isExpense,
    String groupBy = 'day',
  }) async {
    // 并行执行分类查询和趋势查询
    final categoryStats = await _getCategoryStats(bookId, start, end, isExpense);
    final trendPoints = await _getTrendPoints(bookId, start, end, isExpense, groupBy);

    // 计算总览
    final totalAmount = categoryStats.fold<double>(0, (sum, c) => sum + c.amount);
    final totalCount = categoryStats.fold<int>(0, (sum, c) => sum + c.count);

    // 日均（月/年维度有意义）
    final days = end.difference(start).inDays;
    final dailyAverage = days > 0 ? totalAmount / days : null;

    return ReportSummary(
      totalAmount: totalAmount,
      transactionCount: totalCount,
      dailyAverage: dailyAverage,
      categoryStats: categoryStats,
      trendPoints: trendPoints,
    );
  }

  /// 分类占比查询 — SQL GROUP BY categoryId
  Future<List<CategoryStat>> _getCategoryStats(
    int bookId,
    DateTime start,
    DateTime end,
    bool isExpense,
  ) async {
    final amountSum = _db.transactions.amount.sum();
    final amountCount = _db.transactions.amount.count();

    final query = _db.selectOnly(_db.transactions)
      ..addColumns([
        _db.transactions.categoryId,
        amountSum,
        amountCount,
      ])
      ..join([
        innerJoin(
          _db.categories,
          _db.categories.id.equalsExp(_db.transactions.categoryId),
        ),
      ])
      ..where(
        _db.transactions.accountBookId.equals(bookId) &
            _db.transactions.isDeleted.equals(false) &
            _db.transactions.transactionDate.isBetweenValues(start, end) &
            _db.categories.isExpense.equals(isExpense),
      )
      ..groupBy([_db.transactions.categoryId])
      ..orderBy([OrderingTerm.desc(amountSum)]);

    final rows = await query.get();

    // 计算总额用于百分比
    final totalAmount = rows.fold<double>(0, (sum, row) {
      return sum + (row.read(amountSum) ?? 0);
    });

    // 需要查询分类详情（name, icon, color）
    final results = <CategoryStat>[];
    for (final row in rows) {
      final catId = row.read(_db.transactions.categoryId)!;
      final amount = row.read(amountSum) ?? 0;
      final count = row.read(amountCount) ?? 0;

      // 查询分类信息
      final cat = await (_db.select(_db.categories)
            ..where((c) => c.id.equals(catId)))
          .getSingleOrNull();

      results.add(CategoryStat(
        categoryId: catId,
        categoryName: cat?.name ?? '未分类',
        categoryIcon: cat?.icon,
        categoryColor: cat?.color,
        amount: amount,
        count: count,
        percentage: totalAmount > 0 ? (amount / totalAmount * 100) : 0,
      ));
    }

    return results;
  }

  /// 趋势图查询 — SQL GROUP BY 时间维度
  Future<List<TrendPoint>> _getTrendPoints(
    int bookId,
    DateTime start,
    DateTime end,
    bool isExpense,
    String groupBy,
  ) async {
    final amountSum = _db.transactions.amount.sum();

    final query = _db.selectOnly(_db.transactions)
      ..join([
        innerJoin(
          _db.categories,
          _db.categories.id.equalsExp(_db.transactions.categoryId),
        ),
      ])
      ..where(
        _db.transactions.accountBookId.equals(bookId) &
            _db.transactions.isDeleted.equals(false) &
            _db.transactions.transactionDate.isBetweenValues(start, end) &
            _db.categories.isExpense.equals(isExpense),
      );

    // 根据 groupBy 选择分组列
    Expression<int> groupColumn;
    switch (groupBy) {
      case 'month':
        groupColumn = _db.transactions.transactionDate.month;
        query.addColumns([_db.transactions.transactionDate.month, amountSum]);
        query.groupBy([_db.transactions.transactionDate.month]);
        query.orderBy([OrderingTerm.asc(_db.transactions.transactionDate.month)]);
        break;
      case 'day':
      default:
        groupColumn = _db.transactions.transactionDate.day;
        query.addColumns([_db.transactions.transactionDate.day, amountSum]);
        query.groupBy([_db.transactions.transactionDate.day]);
        query.orderBy([OrderingTerm.asc(_db.transactions.transactionDate.day)]);
        break;
    }

    final rows = await query.get();

    return rows.map((row) {
      final period = row.read(groupColumn)!;
      final amount = row.read(amountSum) ?? 0;

      String label;
      switch (groupBy) {
        case 'month':
          label = '$period月';
          break;
        case 'day':
        default:
          label = '$period日';
          break;
      }

      return TrendPoint(label: label, amount: amount);
    }).toList();
  }
}
