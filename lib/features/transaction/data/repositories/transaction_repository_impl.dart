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
  Future<bool> restore(int id) async {
    final count = await (_db.update(_db.transactions)
          ..where((t) => t.id.equals(id) & t.isDeleted.equals(true)))
        .write(TransactionsCompanion(
      isDeleted: const Value(false),
      updatedAt: Value(DateTime.now()),
    ));
    return count > 0;
  }

  @override
  Future<List<Transaction>> getDeleted(int bookId) async {
    return (_db.select(_db.transactions)
          ..where((t) => t.isDeleted.equals(true) & t.accountBookId.equals(bookId))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
  }

  @override
  Future<bool> permanentDelete(int id) async {
    final count = await (_db.delete(_db.transactions)
          ..where((t) => t.id.equals(id) & t.isDeleted.equals(true)))
        .go();
    return count > 0;
  }

  @override
  Future<int> restoreBatch(List<int> ids) async {
    if (ids.isEmpty) return 0;
    var count = 0;
    for (final id in ids) {
      if (await restore(id)) count++;
    }
    return count;
  }

  @override
  Future<int> permanentDeleteBatch(List<int> ids) async {
    if (ids.isEmpty) return 0;
    final deleted = await (_db.delete(_db.transactions)
          ..where((t) => t.id.isIn(ids) & t.isDeleted.equals(true)))
        .go();
    return deleted;
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
    // 使用 SQL 聚合替代内存计算
    final expenseQuery = _db.selectOnly(_db.transactions)
      ..addColumns([_db.transactions.amount.sum(), _db.transactions.id.count()])
      ..where(
        _db.transactions.accountBookId.equals(bookId) &
            _db.transactions.transactionDate.isBetweenValues(start, end) &
            _db.transactions.isDeleted.equals(false) &
            _db.transactions.type.equals('expense'),
      );

    final incomeQuery = _db.selectOnly(_db.transactions)
      ..addColumns([_db.transactions.amount.sum(), _db.transactions.id.count()])
      ..where(
        _db.transactions.accountBookId.equals(bookId) &
            _db.transactions.transactionDate.isBetweenValues(start, end) &
            _db.transactions.isDeleted.equals(false) &
            _db.transactions.type.equals('income'),
      );

    final expenseResult = await expenseQuery.getSingle();
    final incomeResult = await incomeQuery.getSingle();

    final totalExpense = expenseResult.read(_db.transactions.amount.sum()) ?? 0;
    final totalIncome = incomeResult.read(_db.transactions.amount.sum()) ?? 0;
    final expenseCount = expenseResult.read(_db.transactions.id.count()) ?? 0;
    final incomeCount = incomeResult.read(_db.transactions.id.count()) ?? 0;

    return TransactionStats(
      totalExpense: totalExpense,
      totalIncome: totalIncome,
      balance: totalIncome - totalExpense,
      count: expenseCount + incomeCount,
    );
  }

  @override
  Future<List<Transaction>> search(int bookId, SearchQuery query) async {
    final q = _db.select(_db.transactions)
      ..where((t) {
        final conditions = <Expression<bool>>[
          t.isDeleted.equals(false),
          t.accountBookId.equals(bookId),
        ];

        // 关键词模糊搜索（匹配 description / note / originalInput）
        if (query.keyword != null && query.keyword!.isNotEmpty) {
          // 限制总关键词数为 6 个（1 原始 + 最多 5 同义词），避免 LIKE 条件爆炸
          final allKeywords = [query.keyword!, ...query.keywordSynonyms.take(5)]
              .where((k) => k.isNotEmpty)
              .toList();
          if (allKeywords.isNotEmpty) {
            Expression<bool>? textCondition;
            for (final kw in allKeywords) {
              final likePattern = '%$kw%';
              final kwCondition = t.description.like(likePattern) |
                  t.note.like(likePattern) |
                  t.originalInput.like(likePattern);
              textCondition = textCondition == null
                  ? kwCondition
                  : textCondition | kwCondition;
            }
            if (textCondition != null) {
              conditions.add(textCondition);
            }
          }
        }

        // 类型筛选
        if (query.type != null) {
          conditions.add(t.type.equals(query.type!));
        }

        // 金额范围
        if (query.minAmount != null) {
          conditions.add(t.amount.isBiggerOrEqualValue(query.minAmount!));
        }
        if (query.maxAmount != null) {
          conditions.add(t.amount.isSmallerOrEqualValue(query.maxAmount!));
        }

        // 日期范围
        if (query.startDate != null) {
          conditions.add(t.transactionDate.isBiggerOrEqualValue(query.startDate!));
        }
        if (query.endDate != null) {
          conditions.add(t.transactionDate.isSmallerOrEqualValue(query.endDate!));
        }

        // 分类筛选
        if (query.parentCategoryId != null) {
          conditions.add(t.parentCategoryId.equals(query.parentCategoryId!));
        }
        if (query.categoryId != null) {
          conditions.add(t.categoryId.equals(query.categoryId!));
        }

        // 支付方式
        if (query.payMethod != null) {
          conditions.add(t.payMethod.equals(query.payMethod!));
        }

        // 组合所有条件为 AND
        return conditions.reduce((a, b) => a & b);
      });

    // 排序
    switch (query.sortBy) {
      case SearchSortBy.time:
        q.orderBy([(t) => OrderingTerm.desc(t.transactionDate)]);
      case SearchSortBy.amount:
        q.orderBy([(t) => OrderingTerm.desc(t.amount)]);
    }

    return q.get();
  }

  @override
  Future<SearchResultStats> searchWithStats(int bookId, SearchQuery query) async {
    final results = await search(bookId, query);
    return _computeStats(results);
  }

  @override
  Future<SearchResultWithResults> searchWithResults(int bookId, SearchQuery query) async {
    final results = await search(bookId, query);
    return SearchResultWithResults(results, _computeStats(results));
  }

  /// 从交易列表计算统计数据（单次遍历）
  SearchResultStats _computeStats(List<Transaction> results) {
    double totalExpense = 0;
    double totalIncome = 0;
    double? maxAmount;
    Transaction? maxTxn;

    for (final t in results) {
      if (t.type == 'expense') {
        totalExpense += t.amount;
      } else {
        totalIncome += t.amount;
      }
      if (maxAmount == null || t.amount > maxAmount) {
        maxAmount = t.amount;
        maxTxn = t;
      }
    }

    final totalAmount = totalExpense + totalIncome;

    return SearchResultStats(
      count: results.length,
      totalExpense: totalExpense,
      totalIncome: totalIncome,
      average: results.isNotEmpty ? totalAmount / results.length : null,
      maxAmount: maxAmount,
      maxTransaction: maxTxn,
    );
  }
}
