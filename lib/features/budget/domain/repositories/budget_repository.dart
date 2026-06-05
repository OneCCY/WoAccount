import '../../../../config/database/app_database.dart';

/// 预算 Repository 接口（Domain 层）
abstract class BudgetRepository {
  /// 获取所有预算
  Future<List<Budget>> getAll();

  /// 获取指定月份的预算
  Future<List<Budget>> getByMonth(int year, int month);

  /// 获取指定分类的预算
  Future<Budget?> getByCategoryId(int categoryId, int year, int month);

  /// 插入预算
  Future<int> insert(BudgetsCompanion budget);

  /// 更新预算
  Future<bool> update(BudgetsCompanion budget);

  /// 删除预算
  Future<bool> delete(int id);

  /// 监听指定月份的预算变化
  Stream<List<Budget>> watchByMonth(int year, int month);

  /// 获取预算进度（含实际消费）
  Future<List<BudgetProgress>> getBudgetProgress(int year, int month);
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

