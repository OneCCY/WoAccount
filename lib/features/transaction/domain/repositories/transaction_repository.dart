import '../../../../config/database/app_database.dart';

/// 交易记录 Repository 接口（Domain 层）
abstract class TransactionRepository {
  /// 获取账本内所有交易（排除软删除）
  Future<List<Transaction>> getAll(int bookId);

  /// 根据 ID 获取
  Future<Transaction?> getById(int id);

  /// 根据日期范围获取
  Future<List<Transaction>> getByDateRange(int bookId, DateTime start, DateTime end);

  /// 根据分类获取
  Future<List<Transaction>> getByCategoryId(int bookId, int categoryId);

  /// 获取今日交易
  Future<List<Transaction>> getToday(int bookId);

  /// 获取本月交易
  Future<List<Transaction>> getThisMonth(int bookId);

  /// 插入交易
  Future<int> insert(TransactionsCompanion transaction);

  /// 更新交易
  Future<bool> update(TransactionsCompanion transaction);

  /// 软删除交易
  Future<bool> delete(int id);

  /// 监听账本内所有交易变化（响应式）
  Stream<List<Transaction>> watchAll(int bookId);

  /// 监听账本内今日交易变化
  Stream<List<Transaction>> watchToday(int bookId);

  /// 获取日期范围内的统计
  Future<TransactionStats> getStats(int bookId, DateTime start, DateTime end);
}

/// 交易统计数据
class TransactionStats {
  final double totalExpense;
  final double totalIncome;
  final double balance;
  final int count;

  const TransactionStats({
    required this.totalExpense,
    required this.totalIncome,
    required this.balance,
    required this.count,
  });
}
