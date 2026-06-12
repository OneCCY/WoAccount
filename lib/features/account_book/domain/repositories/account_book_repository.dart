import '../../../../config/database/app_database.dart';

/// 账本 Repository 接口（Domain 层）
abstract class AccountBookRepository {
  /// 获取所有账本（排除软删除）
  Future<List<AccountBook>> getAll();

  /// 根据 ID 获取
  Future<AccountBook?> getById(int id);

  /// 获取默认账本
  Future<AccountBook?> getDefault();

  /// 插入账本
  Future<int> insert(AccountBooksCompanion book);

  /// 更新账本
  Future<bool> update(AccountBooksCompanion book);

  /// 软删除账本（当前账本不可删除）
  Future<bool> delete(int id);

  /// 恢复已删除的账本
  Future<bool> restore(int id);

  /// 清空账本下的所有交易和对话数据
  Future<void> clearData(int bookId);

  /// 获取所有已删除的账本（回收站）
  Future<List<AccountBook>> getDeletedAll();

  /// 设为默认账本
  Future<bool> setDefault(int id);

  /// 监听所有账本变化
  Stream<List<AccountBook>> watchAll();

  /// 获取账本月度统计（收支、笔数）
  Future<AccountBookStats> getStats(int bookId, int year, int month);
}

/// 账本统计数据
class AccountBookStats {
  final double totalExpense;
  final double totalIncome;
  final int count;

  const AccountBookStats({
    required this.totalExpense,
    required this.totalIncome,
    required this.count,
  });

  double get balance => totalIncome - totalExpense;
}
