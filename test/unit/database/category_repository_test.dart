import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:wo_account/config/database/app_database.dart';
import 'package:wo_account/features/category/data/repositories/category_repository_impl.dart';
import 'package:wo_account/features/category/domain/repositories/category_repository.dart';

/// 注意：AppDatabase.onCreate 会自动插入 9 个默认分类，
/// 测试中应使用与默认分类不冲突的名称。

void main() {
  late AppDatabase db;
  late CategoryRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = CategoryRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('CategoryRepository', () {
    test('default categories are seeded on creation', () async {
      final all = await repo.getAll();
      expect(all.length, 9);
      expect(all[0].name, '餐饮');
      expect(all[1].name, '交通');
      expect(all.last.name, '其他');
    });

    test('insert adds user category', () async {
      await repo.insert(CategoriesCompanion.insert(
        name: '宠物',
        icon: const Value('🐱'),
        level: const Value(1),
        isSystem: const Value(false),
        sortOrder: const Value(10),
      ));

      final all = await repo.getAll();
      expect(all.length, 10);
      expect(all.last.name, '宠物');
    });

    test('getTopLevel returns only level 1 categories', () async {
      // 默认 9 个都是一级分类
      final topLevel = await repo.getTopLevel();
      expect(topLevel.length, 9);

      // 添加一个二级分类
      final foodId = (await repo.getByName('餐饮'))!.id;
      await repo.insert(CategoriesCompanion.insert(
        name: '火锅',
        level: const Value(2),
        parentId: Value(foodId),
        sortOrder: const Value(1),
      ));

      final topLevelAfter = await repo.getTopLevel();
      expect(topLevelAfter.length, 9); // 二级分类不会出现
    });

    test('getChildren returns child categories', () async {
      final foodId = (await repo.getByName('餐饮'))!.id;
      await repo.insert(CategoriesCompanion.insert(
        name: '火锅',
        level: const Value(2),
        parentId: Value(foodId),
        sortOrder: const Value(1),
      ));
      await repo.insert(CategoriesCompanion.insert(
        name: '外卖',
        level: const Value(2),
        parentId: Value(foodId),
        sortOrder: const Value(2),
      ));

      final children = await repo.getChildren(foodId);
      expect(children.length, 2);
      expect(children[0].name, '火锅');
      expect(children[1].name, '外卖');
    });

    test('getByName finds existing category', () async {
      final found = await repo.getByName('餐饮');
      expect(found, isNotNull);
      expect(found!.icon, '🍜');
    });

    test('getByName returns null for non-existing', () async {
      final notFound = await repo.getByName('不存在的分类');
      expect(notFound, isNull);
    });

    test('delete prevents system categories', () async {
      final food = await repo.getByName('餐饮');
      final result = await repo.delete(food!.id);
      expect(result, false);
      expect(await repo.getById(food.id), isNotNull);
    });

    test('delete allows user categories', () async {
      final id = await repo.insert(CategoriesCompanion.insert(
        name: '自定义分类',
        level: const Value(1),
        isSystem: const Value(false),
        sortOrder: const Value(10),
      ));

      final result = await repo.delete(id);
      expect(result, true);
      expect(await repo.getById(id), isNull);
    });
  });
}
