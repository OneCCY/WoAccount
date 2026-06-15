import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wo_account/config/database/app_database.dart';
import 'package:wo_account/config/di/providers.dart';
import 'package:wo_account/features/transaction/presentation/pages/transaction_list_page.dart';
import 'package:wo_account/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:wo_account/features/category/domain/repositories/category_repository.dart';

/// 简单的内存测试仓储，绕过 drift stream 的测试限制
class FakeTransactionRepository implements TransactionRepository {
  final List<Transaction> _data;
  final List<Category> _categories;
  FakeTransactionRepository(this._data, this._categories);

  @override
  Stream<List<Transaction>> watchAll(int bookId) => Stream.value(_data);

  @override
  Stream<List<Transaction>> watchToday(int bookId) => Stream.value(_data);

  @override
  Future<TransactionStats> getStats(int bookId, DateTime start, DateTime end) async {
    double totalExpense = 0;
    double totalIncome = 0;
    int count = 0;
    for (final t in _data) {
      if (t.transactionDate.isBefore(start) || !t.transactionDate.isBefore(end)) continue;
      count++;
      final cat = _categories.where((c) => c.id == t.categoryId).firstOrNull;
      if (cat?.isExpense ?? true) {
        totalExpense += t.amount;
      } else {
        totalIncome += t.amount;
      }
    }
    return TransactionStats(
      totalExpense: totalExpense,
      totalIncome: totalIncome,
      balance: totalIncome - totalExpense,
      count: count,
    );
  }

  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class FakeCategoryRepository implements CategoryRepository {
  final List<Category> _data;
  FakeCategoryRepository(this._data);

  @override
  Future<List<Category>> getAll() async => _data;

  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('zh_CN');
  });

  Transaction makeTxn({
    required int id,
    required double amount,
    required String description,
    required int categoryId,
    required DateTime transactionDate,
  }) {
    return Transaction(
      id: id,
      amount: amount,
      type: 'expense',
      description: description,
      note: null,
      categoryId: categoryId,
      parentCategoryId: null,
      transactionDate: transactionDate,
      payMethod: null,
      originalInput: null,
      aiConfidence: null,
      aiSource: 'manual',
      userConfirmed: false,
      isDeleted: false,
      accountBookId: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Category makeCat({
    required int id,
    required String name,
    required bool isExpense,
  }) {
    return Category(
      id: id,
      name: name,
      icon: '🍜',
      color: '#FF9800',
      parentId: null,
      level: 1,
      isSystem: false,
      isExpense: isExpense,
      sortOrder: 0,
      createdAt: DateTime.now(),
    );
  }

  /// 多次 pump 让 StreamBuilder + FutureBuilder 都完成
  Future<void> settle(WidgetTester tester) async {
    // StreamBuilder + FutureBuilder each need one frame to resolve
    // Multiple pumps ensure both async layers complete
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets('点击本日收入后仅展示当前日收入记录', (WidgetTester tester) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final expense = makeTxn(id: 1, amount: 28, description: '今日支出', categoryId: 1, transactionDate: today.add(const Duration(hours: 9)));
    final income = makeTxn(id: 2, amount: 500, description: '今日收入', categoryId: 2, transactionDate: today.add(const Duration(hours: 10)));
    final yesterdayIncome = makeTxn(id: 3, amount: 88, description: '昨日收入', categoryId: 2, transactionDate: yesterday.add(const Duration(hours: 10)));

    final cats = [
      makeCat(id: 1, name: '测试支出', isExpense: true),
      makeCat(id: 2, name: '测试收入', isExpense: false),
    ];
    final txnRepo = FakeTransactionRepository([expense, income, yesterdayIncome], cats);
    final catRepo = FakeCategoryRepository(cats);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionRepositoryProvider.overrideWith((_) => txnRepo),
          categoryRepositoryProvider.overrideWith((_) => catRepo),
        ],
        child: const MaterialApp(home: TransactionListPage()),
      ),
    );
    await settle(tester);

    // 切到日视图
    await tester.tap(find.text('日').first);
    await settle(tester);

    // 日视图下：今日的支出和收入都可见，昨日不可见
    expect(find.text('今日支出'), findsOneWidget);
    expect(find.text('今日收入'), findsOneWidget);
    expect(find.text('昨日收入'), findsNothing);

    // 点击本日收入 -> 仅显示今日收入
    await tester.tap(find.text('本日收入'));
    await settle(tester);

    expect(find.text('今日收入'), findsOneWidget);
    expect(find.text('今日支出'), findsNothing);

    // 再次点击本日收入 -> 取消筛选，回到全部
    await tester.tap(find.text('本日收入'));
    await settle(tester);

    expect(find.text('今日支出'), findsOneWidget);
    expect(find.text('今日收入'), findsOneWidget);
  });

  testWidgets('点击本日支出后仅展示当前日支出记录', (WidgetTester tester) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final expense = makeTxn(id: 1, amount: 28, description: '今日支出', categoryId: 1, transactionDate: today.add(const Duration(hours: 9)));
    final income = makeTxn(id: 2, amount: 500, description: '今日收入', categoryId: 2, transactionDate: today.add(const Duration(hours: 10)));

    final cats = [
      makeCat(id: 1, name: '测试支出', isExpense: true),
      makeCat(id: 2, name: '测试收入', isExpense: false),
    ];
    final txnRepo = FakeTransactionRepository([expense, income], cats);
    final catRepo = FakeCategoryRepository(cats);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionRepositoryProvider.overrideWith((_) => txnRepo),
          categoryRepositoryProvider.overrideWith((_) => catRepo),
        ],
        child: const MaterialApp(home: TransactionListPage()),
      ),
    );
    await settle(tester);

    await tester.tap(find.text('日').first);
    await settle(tester);

    await tester.tap(find.text('本日支出'));
    await settle(tester);

    expect(find.text('今日支出'), findsOneWidget);
    expect(find.text('今日收入'), findsNothing);
  });

  testWidgets('月视图点击本月收入切到日视图', (WidgetTester tester) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final income = makeTxn(id: 1, amount: 500, description: '今日收入', categoryId: 2, transactionDate: today.add(const Duration(hours: 10)));

    final cats = [
      makeCat(id: 2, name: '测试收入', isExpense: false),
    ];
    final txnRepo = FakeTransactionRepository([income], cats);
    final catRepo = FakeCategoryRepository(cats);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionRepositoryProvider.overrideWith((_) => txnRepo),
          categoryRepositoryProvider.overrideWith((_) => catRepo),
        ],
        child: const MaterialApp(home: TransactionListPage()),
      ),
    );
    await settle(tester);

    // 切到月视图
    await tester.tap(find.text('月'));
    await settle(tester);

    // 月视图统计应显示"本月..."
    expect(find.textContaining('本月'), findsWidgets);

    // 点击本月收入 -> 应切到日视图
    await tester.tap(find.text('本月收入'));
    await settle(tester);

    // 应切换到日视图并展示当前日收入
    expect(find.text('今日收入'), findsOneWidget);
  });
}
