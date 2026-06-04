import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:wo_account/config/database/app_database.dart';
import 'package:wo_account/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:wo_account/features/transaction/domain/repositories/transaction_repository.dart';

void main() {
  late AppDatabase db;
  late TransactionRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = TransactionRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('TransactionRepository', () {
    test('insert and getAll', () async {
      final categoryId = await db.into(db.categories).insert(
            CategoriesCompanion.insert(
              name: '餐饮',
              icon: const Value('🍜'),
              color: const Value('#FF9800'),
              level: const Value(1),
              isSystem: const Value(true),
              sortOrder: const Value(1),
            ),
          );

      await repo.insert(TransactionsCompanion.insert(
        amount: 25.0,
        description: '午饭拉面',
        categoryId: categoryId,
        transactionDate: DateTime(2026, 6, 5),
      ));

      final all = await repo.getAll();
      expect(all.length, 1);
      expect(all.first.amount, 25.0);
      expect(all.first.description, '午饭拉面');
    });

    test('getById returns correct transaction', () async {
      final categoryId = await db.into(db.categories).insert(
            CategoriesCompanion.insert(
              name: '交通',
              icon: const Value('🚗'),
              color: const Value('#2196F3'),
              level: const Value(1),
              isSystem: const Value(true),
              sortOrder: const Value(2),
            ),
          );

      final id = await repo.insert(TransactionsCompanion.insert(
        amount: 28.0,
        description: '打车去公司',
        categoryId: categoryId,
        transactionDate: DateTime(2026, 6, 5),
      ));

      final transaction = await repo.getById(id);
      expect(transaction, isNotNull);
      expect(transaction!.amount, 28.0);
    });

    test('getByDateRange filters correctly', () async {
      final categoryId = await db.into(db.categories).insert(
            CategoriesCompanion.insert(
              name: '餐饮',
              icon: const Value('🍜'),
              color: const Value('#FF9800'),
              level: const Value(1),
              isSystem: const Value(true),
              sortOrder: const Value(1),
            ),
          );

      await repo.insert(TransactionsCompanion.insert(
        amount: 10.0,
        description: '早餐',
        categoryId: categoryId,
        transactionDate: DateTime(2026, 6, 1),
      ));
      await repo.insert(TransactionsCompanion.insert(
        amount: 25.0,
        description: '午餐',
        categoryId: categoryId,
        transactionDate: DateTime(2026, 6, 5),
      ));
      await repo.insert(TransactionsCompanion.insert(
        amount: 30.0,
        description: '晚餐',
        categoryId: categoryId,
        transactionDate: DateTime(2026, 6, 10),
      ));

      final june = await repo.getByDateRange(
        DateTime(2026, 6, 1),
        DateTime(2026, 6, 30),
      );
      expect(june.length, 3);

      final earlyJune = await repo.getByDateRange(
        DateTime(2026, 6, 1),
        DateTime(2026, 6, 5),
      );
      expect(earlyJune.length, 2);
    });

    test('delete performs soft delete', () async {
      final categoryId = await db.into(db.categories).insert(
            CategoriesCompanion.insert(
              name: '餐饮',
              icon: const Value('🍜'),
              color: const Value('#FF9800'),
              level: const Value(1),
              isSystem: const Value(true),
              sortOrder: const Value(1),
            ),
          );

      final id = await repo.insert(TransactionsCompanion.insert(
        amount: 25.0,
        description: '午饭',
        categoryId: categoryId,
        transactionDate: DateTime(2026, 6, 5),
      ));

      expect(await repo.getById(id), isNotNull);
      final deleted = await repo.delete(id);
      expect(deleted, true);
      expect(await repo.getById(id), isNull);
      expect((await repo.getAll()).length, 0);
    });

    test('getStats calculates correctly', () async {
      final categoryId = await db.into(db.categories).insert(
            CategoriesCompanion.insert(
              name: '餐饮',
              icon: const Value('🍜'),
              color: const Value('#FF9800'),
              level: const Value(1),
              isSystem: const Value(true),
              sortOrder: const Value(1),
            ),
          );

      await repo.insert(TransactionsCompanion.insert(
        amount: 25.0,
        description: '午餐',
        categoryId: categoryId,
        transactionDate: DateTime(2026, 6, 5),
      ));
      await repo.insert(TransactionsCompanion.insert(
        amount: 35.0,
        description: '晚餐',
        categoryId: categoryId,
        transactionDate: DateTime(2026, 6, 5),
      ));

      final stats = await repo.getStats(
        DateTime(2026, 6, 1),
        DateTime(2026, 6, 30),
      );

      expect(stats.totalExpense, 60.0);
      expect(stats.count, 2);
    });
  });
}
