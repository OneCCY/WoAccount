import 'package:drift/drift.dart';
import '../../../../config/database/app_database.dart';
import '../../domain/repositories/account_book_repository.dart';

/// 账本 Repository 实现（Data 层）
class AccountBookRepositoryImpl implements AccountBookRepository {
  final AppDatabase _db;

  AccountBookRepositoryImpl(this._db);

  @override
  Future<List<AccountBook>> getAll() async {
    return (_db.select(_db.accountBooks)
          ..where((b) => b.isDeleted.equals(false))
          ..orderBy([(b) => OrderingTerm.desc(b.isDefault), (b) => OrderingTerm.desc(b.createdAt)]))
        .get();
  }

  @override
  Future<AccountBook?> getById(int id) async {
    return (_db.select(_db.accountBooks)
          ..where((b) => b.id.equals(id) & b.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  @override
  Future<AccountBook?> getDefault() async {
    return (_db.select(_db.accountBooks)
          ..where((b) => b.isDefault.equals(true) & b.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  @override
  Future<int> insert(AccountBooksCompanion book) async {
    return _db.into(_db.accountBooks).insert(book);
  }

  @override
  Future<bool> update(AccountBooksCompanion book) async {
    return _db.update(_db.accountBooks).replace(book);
  }

  @override
  Future<bool> delete(int id) async {
    // 当前账本不可删除（由 UI 层判断）
    final result = await (_db.select(_db.accountBooks)
          ..where((b) => b.id.equals(id) & b.isDeleted.equals(false)))
        .getSingleOrNull();
    if (result == null) return false;

    final count = await (_db.update(_db.accountBooks)
          ..where((b) => b.id.equals(id)))
        .write(AccountBooksCompanion(
      isDeleted: const Value(true),
      updatedAt: Value(DateTime.now()),
    ));
    return count > 0;
  }

  @override
  Future<bool> restore(int id) async {
    final count = await (_db.update(_db.accountBooks)
          ..where((b) => b.id.equals(id) & b.isDeleted.equals(true)))
        .write(AccountBooksCompanion(
      isDeleted: const Value(false),
      updatedAt: Value(DateTime.now()),
    ));
    return count > 0;
  }

  @override
  Future<void> clearData(int bookId) async {
    await _db.transaction(() async {
      // 软删除该账本下的所有交易
      await (_db.update(_db.transactions)
            ..where((t) => t.accountBookId.equals(bookId)))
          .write(TransactionsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ));

      // 删除该账本下的所有对话记录
      await (_db.delete(_db.conversationMessages)
            ..where((m) => m.accountBookId.equals(bookId)))
          .go();

      // 删除该账本下的 AI 训练数据
      await (_db.delete(_db.aiTrainingRecords)
            ..where((r) => r.accountBookId.equals(bookId)))
          .go();

      // 删除该账本下的预算
      await (_db.delete(_db.budgets)
            ..where((b) => b.accountBookId.equals(bookId)))
          .go();
    });
  }

  @override
  Future<List<AccountBook>> getDeletedAll() async {
    return (_db.select(_db.accountBooks)
          ..where((b) => b.isDeleted.equals(true))
          ..orderBy([(b) => OrderingTerm.desc(b.updatedAt)]))
        .get();
  }

  @override
  Future<bool> setDefault(int id) async {
    return _db.transaction(() async {
      // 取消旧默认账本
      await (_db.update(_db.accountBooks)
            ..where((b) => b.isDefault.equals(true) & b.isDeleted.equals(false)))
          .write(AccountBooksCompanion(
        isDefault: const Value(false),
        updatedAt: Value(DateTime.now()),
      ));

      // 设置新默认账本
      final count = await (_db.update(_db.accountBooks)
            ..where((b) => b.id.equals(id) & b.isDeleted.equals(false)))
          .write(AccountBooksCompanion(
        isDefault: const Value(true),
        updatedAt: Value(DateTime.now()),
      ));
      return count > 0;
    });
  }

  @override
  Stream<List<AccountBook>> watchAll() {
    return (_db.select(_db.accountBooks)
          ..where((b) => b.isDeleted.equals(false))
          ..orderBy([(b) => OrderingTerm.desc(b.isDefault), (b) => OrderingTerm.desc(b.createdAt)]))
        .watch();
  }

  @override
  Future<AccountBookStats> getStats(int bookId, int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);

    // join Transactions + Categories 获取收支统计
    final query = _db.select(_db.transactions).join([
      innerJoin(_db.categories, _db.categories.id.equalsExp(_db.transactions.categoryId)),
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

    return AccountBookStats(
      totalExpense: totalExpense,
      totalIncome: totalIncome,
      count: results.length,
    );
  }
}
