import 'package:drift/drift.dart';
import '../../../../config/database/app_database.dart';
import '../../domain/repositories/budget_repository.dart';

/// 预算 Repository 实现（Data 层）
class BudgetRepositoryImpl implements BudgetRepository {
  final AppDatabase _db;

  BudgetRepositoryImpl(this._db);

  @override
  Future<List<Budget>> getAll(int bookId) async {
    return (_db.select(_db.budgets)
          ..where((b) => b.accountBookId.equals(bookId))
          ..orderBy([(b) => OrderingTerm.desc(b.year), (b) => OrderingTerm.desc(b.month)]))
        .get();
  }

  @override
  Future<List<Budget>> getByMonth(int bookId, int year, int month) async {
    return (_db.select(_db.budgets)
          ..where((b) => b.accountBookId.equals(bookId) & b.year.equals(year) & b.month.equals(month)))
        .get();
  }

  @override
  Future<Budget?> getByCategoryId(int bookId, int categoryId, int year, int month) async {
    return (_db.select(_db.budgets)
          ..where((b) =>
              b.accountBookId.equals(bookId) &
              b.categoryId.equals(categoryId) &
              b.year.equals(year) &
              b.month.equals(month)))
        .getSingleOrNull();
  }

  @override
  Future<Budget?> getById(int id) async {
    return (_db.select(_db.budgets)
          ..where((b) => b.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Future<int> insert(BudgetsCompanion budget) async {
    return _db.into(_db.budgets).insert(budget);
  }

  @override
  Future<bool> update(BudgetsCompanion budget) async {
    return _db.update(_db.budgets).replace(budget);
  }

  @override
  Future<bool> delete(int id) async {
    final count = await (_db.delete(_db.budgets)..where((b) => b.id.equals(id))).go();
    return count > 0;
  }

  @override
  Stream<List<Budget>> watchByMonth(int bookId, int year, int month) {
    return (_db.select(_db.budgets)
          ..where((b) => b.accountBookId.equals(bookId) & b.year.equals(year) & b.month.equals(month)))
        .watch();
  }

  @override
  Future<List<BudgetProgress>> getBudgetProgress(int bookId, int year, int month) async {
    final budgets = await getByMonth(bookId, year, month);
    final results = <BudgetProgress>[];

    for (final budget in budgets) {
      double spent = 0;
      Category? category;

      if (budget.categoryId != null) {
        // 查询该分类本月的实际消费
        category = await (_db.select(_db.categories)
              ..where((c) => c.id.equals(budget.categoryId!)))
            .getSingleOrNull();

        final start = DateTime(year, month, 1);
        final end = DateTime(year, month + 1, 1);

        final query = _db.selectOnly(_db.transactions)
          ..addColumns([_db.transactions.amount.sum()])
          ..where(
            _db.transactions.accountBookId.equals(bookId) &
                _db.transactions.categoryId.equals(budget.categoryId!) &
                _db.transactions.transactionDate.isBetweenValues(start, end) &
                _db.transactions.isDeleted.equals(false),
          );

        final result = await query.getSingle();
        spent = result.read(_db.transactions.amount.sum()) ?? 0;
      } else {
        // 总预算：SQL 聚合查询所有支出（join categories 过滤 isExpense）
        final start = DateTime(year, month, 1);
        final end = DateTime(year, month + 1, 1);

        final query = _db.selectOnly(_db.transactions).join([
          innerJoin(_db.categories, _db.categories.id.equalsExp(_db.transactions.categoryId)),
        ])
          ..addColumns([_db.transactions.amount.sum()])
          ..where(
            _db.transactions.accountBookId.equals(bookId) &
                _db.transactions.transactionDate.isBetweenValues(start, end) &
                _db.transactions.isDeleted.equals(false) &
                _db.categories.isExpense.equals(true),
          );

        final result = await query.getSingle();
        spent = result.read(_db.transactions.amount.sum()) ?? 0;
      }

      final percentage = budget.amount > 0 ? (spent / budget.amount * 100) : 0.0;

      results.add(BudgetProgress(
        budget: budget,
        category: category,
        spent: spent,
        percentage: percentage,
      ));
    }

    return results;
  }
}
