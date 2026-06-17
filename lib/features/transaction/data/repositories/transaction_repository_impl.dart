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
          final allKeywords = [query.keyword!, ...query.keywordSynonyms]
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
