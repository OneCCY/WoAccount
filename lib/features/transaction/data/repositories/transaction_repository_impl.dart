import 'package:drift/drift.dart';
import '../../../../config/database/app_database.dart';
import '../../domain/repositories/transaction_repository.dart';

/// 交易记录 Repository 实现（Data 层）
class TransactionRepositoryImpl implements TransactionRepository {
  final AppDatabase _db;

  TransactionRepositoryImpl(this._db);

  @override
  Future<List<Transaction>> getAll(int bookId) async {
    return (_db.select(_db.transactions)
          ..where((t) => t.isDeleted.equals(false) & t.accountBookId.equals(bookId))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .get();
  }

  @override
  Future<Transaction?> getById(int id) async {
    return (_db.select(_db.transactions)
          ..where((t) => t.id.equals(id) & t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  @override
  Future<List<Transaction>> getByDateRange(int bookId, DateTime start, DateTime end) async {
    return (_db.select(_db.transactions)
          ..where((t) =>
              t.accountBookId.equals(bookId) &
              t.transactionDate.isBetweenValues(start, end) &
              t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .get();
  }

  @override
  Future<List<Transaction>> getByCategoryId(int bookId, int categoryId) async {
    return (_db.select(_db.transactions)
          ..where((t) =>
              t.accountBookId.equals(bookId) &
              t.categoryId.equals(categoryId) & t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .get();
  }

  @override
  Future<List<Transaction>> getToday(int bookId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getByDateRange(bookId, startOfDay, endOfDay);
  }

  @override
  Future<List<Transaction>> getThisMonth(int bookId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);
    return getByDateRange(bookId, startOfMonth, endOfMonth);
  }

  @override
  Future<int> insert(TransactionsCompanion transaction) async {
    return _db.into(_db.transactions).insert(transaction);
  }

  @override
  Future<bool> update(TransactionsCompanion transaction) async {
    return _db.update(_db.transactions).replace(transaction);
  }

  @override
  Future<bool> delete(int id) async {
    final count = await (_db.update(_db.transactions)
          ..where((t) => t.id.equals(id)))
        .write(TransactionsCompanion(
      isDeleted: const Value(true),
      updatedAt: Value(DateTime.now()),
    ));
    return count > 0;
  }

  @override
  Stream<List<Transaction>> watchAll(int bookId) {
    return (_db.select(_db.transactions)
          ..where((t) => t.isDeleted.equals(false) & t.accountBookId.equals(bookId))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .watch();
  }

  @override
  Future<List<Transaction>> getPaged(int bookId, int limit, int offset) async {
    return (_db.select(_db.transactions)
          ..where((t) => t.isDeleted.equals(false) & t.accountBookId.equals(bookId))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)])
          ..limit(limit, offset: offset))
        .get();
  }

  @override
  Stream<List<Transaction>> watchToday(int bookId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (_db.select(_db.transactions)
          ..where((t) =>
              t.accountBookId.equals(bookId) &
              t.transactionDate.isBetweenValues(startOfDay, endOfDay) &
              t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .watch();
  }

  @override
  Future<TransactionStats> getStats(int bookId, DateTime start, DateTime end) async {
    // 通过 join Categories 区分收入/支出
    final query = _db.select(_db.transactions).join([
      innerJoin(
        _db.categories,
        _db.categories.id.equalsExp(_db.transactions.categoryId),
      ),
    ])
      ..where(
        _db.transactions.accountBookId.equals(bookId) &
            _db.transactions.transactionDate.isBetweenValues(start, end) &
            _db.transactions.isDeleted.equals(false),
      );

    final results = await query.get();

    double totalExpense = 0;
    double totalIncome = 0;

    for (final row in results) {
      final amount = row.readTable(_db.transactions).amount;
      final isExpense = row.readTable(_db.categories).isExpense;
      if (isExpense) {
        totalExpense += amount;
      } else {
        totalIncome += amount;
      }
    }

    return TransactionStats(
      totalExpense: totalExpense,
      totalIncome: totalIncome,
      balance: totalIncome - totalExpense,
      count: results.length,
    );
  }
}
