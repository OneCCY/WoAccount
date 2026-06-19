import '../../../../config/database/app_database.dart';

/// 预算 Repository 接口（Domain 层）
abstract class BudgetRepository {
  /// 获取账本内所有预算
  Future<List<Budget>> getAll(int bookId);

  /// 获取账本内指定月份的预算
  Future<List<Budget>> getByMonth(int bookId, int year, int month);

  /// 获取账本内指定分类的预算
  Future<Budget?> getByCategoryId(int bookId, int categoryId, int year, int month);

  /// 根据 ID 获取预算
  Future<Budget?> getById(int id);

  /// 插入预算
  Future<int> insert(BudgetsCompanion budget);

  /// 更新预算
  Future<bool> update(BudgetsCompanion budget);

  /// 删除预算
  Future<bool> delete(int id);

  /// 监听账本内指定月份的预算变化
  Stream<List<Budget>> watchByMonth(int bookId, int year, int month);

  /// 获取账本内预算进度（含实际消费）
  Future<List<BudgetProgress>> getBudgetProgress(int bookId, int year, int month);
}

/// 预算进度数据
class BudgetProgress {
  final Budget budget;
  final Category? category;
  final double spent;
  final double percentage;

  const BudgetProgress({
    required this.budget,
    this.category,
    required this.spent,
    required this.percentage,
  });

  double get remaining => budget.amount - spent;
  bool get isOverBudget => spent > budget.amount;
}

