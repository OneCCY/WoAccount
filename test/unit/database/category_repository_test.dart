import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:wo_account/config/database/app_database.dart';
import 'package:wo_account/features/category/data/repositories/category_repository_impl.dart';
import 'package:wo_account/features/category/domain/repositories/category_repository.dart';

/// 注意：AppDatabase.onCreate 会自动插入 27 个默认一级分类
/// （16 支出 + 8 收入 + 3 其他），测试中应使用不冲突的名称。

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
      final all = await repo.getTopLevel();
      // 16 支出 + 8 收入 + 3 其他 = 27 个一级分类
      expect(all.length, 27);
      expect(all.first.name, '餐饮美食');
      // 验证部分收入分类
      final incomeNames = all.where((c) => !c.isExpense).map((c) => c.name).toList();
      expect(incomeNames, contains('工资薪酬'));
    });

    test('insert adds user category', () async {
      final beforeCount = (await repo.getTopLevel()).length;

      await repo.insert(CategoriesCompanion.insert(
        name: '自定义测试分类',
        icon: const Value('🐱'),
        level: const Value(1),
        isSystem: const Value(false),
        sortOrder: const Value(100),
      ));

      final all = await repo.getTopLevel();
      expect(all.length, beforeCount + 1);
      expect(all.last.name, '自定义测试分类');
    });

    test('getTopLevel returns only level 1 categories', () async {
      final topLevel = await repo.getTopLevel();
      expect(topLevel.length, 27);
      expect(topLevel.every((c) => c.level == 1), isTrue);

      // 添加一个二级分类
      final foodId = (await repo.getByName('餐饮美食'))!.id;
      await repo.insert(CategoriesCompanion.insert(
        name: '火锅',
        level: const Value(2),
        parentId: Value(foodId),
        sortOrder: const Value(1),
      ));

      final topLevelAfter = await repo.getTopLevel();
      expect(topLevelAfter.length, 27); // 二级分类不会出现
    });

    test('getChildren returns child categories', () async {
      final foodId = (await repo.getByName('餐饮美食'))!.id;
      // 餐饮美食已有种子数据的子分类
      final existingChildren = await repo.getChildren(foodId);
      expect(existingChildren.isNotEmpty, isTrue);

      // 再添加一个
      await repo.insert(CategoriesCompanion.insert(
        name: '测试火锅',
        level: const Value(2),
        parentId: Value(foodId),
        sortOrder: const Value(99),
      ));

      final children = await repo.getChildren(foodId);
      expect(children.length, existingChildren.length + 1);
      expect(children.any((c) => c.name == '测试火锅'), isTrue);
    });

    test('getByName finds existing category', () async {
      final found = await repo.getByName('餐饮美食');
      expect(found, isNotNull);
      expect(found!.icon, '🍜');
    });

    test('getByName returns null for non-existing', () async {
      final notFound = await repo.getByName('不存在的分类');
      expect(notFound, isNull);
    });

    test('delete prevents system categories', () async {
      final food = await repo.getByName('餐饮美食');
      final result = await repo.delete(food!.id);
      expect(result, false);
      expect(await repo.getById(food.id), isNotNull);
    });

    test('delete allows user categories without references', () async {
      final id = await repo.insert(CategoriesCompanion.insert(
        name: '自定义分类',
        level: const Value(1),
        isSystem: const Value(false),
        sortOrder: const Value(100),
      ));

      final result = await repo.delete(id);
      expect(result, true);
      expect(await repo.getById(id), isNull);
    });

    test('deleteWithChildren removes parent and all children', () async {
      // 创建父分类
      final parentId = await repo.insert(CategoriesCompanion.insert(
        name: '父分类测试',
        level: const Value(1),
        isSystem: const Value(false),
        sortOrder: const Value(100),
      ));

      // 创建子分类
      await repo.insert(CategoriesCompanion.insert(
        name: '子分类A',
        level: const Value(2),
        parentId: Value(parentId),
        isSystem: const Value(false),
        sortOrder: const Value(1),
      ));
      await repo.insert(CategoriesCompanion.insert(
        name: '子分类B',
        level: const Value(2),
        parentId: Value(parentId),
        isSystem: const Value(false),
        sortOrder: const Value(2),
      ));

      // 确认子分类存在
      final childrenBefore = await repo.getChildren(parentId);
      expect(childrenBefore.length, 2);

      // 级联删除
      final result = await repo.deleteWithChildren(parentId);
      expect(result, true);

      // 验证父分类和子分类都被删除
      expect(await repo.getById(parentId), isNull);
      final childrenAfter = await repo.getChildren(parentId);
      expect(childrenAfter.length, 0);
    });

    test('deleteWithChildren prevents system categories', () async {
      final food = await repo.getByName('餐饮美食');
      final result = await repo.deleteWithChildren(food!.id);
      expect(result, false);
      expect(await repo.getById(food.id), isNotNull);
    });

    test('delete rejects category with child categories', () async {
      // 创建父分类
      final parentId = await repo.insert(CategoriesCompanion.insert(
        name: '有子分类的父分类',
        level: const Value(1),
        isSystem: const Value(false),
        sortOrder: const Value(100),
      ));

      // 添加子分类
      await repo.insert(CategoriesCompanion.insert(
        name: '它的子分类',
        level: const Value(2),
        parentId: Value(parentId),
        isSystem: const Value(false),
        sortOrder: const Value(1),
      ));

      // 尝试直接删除父分类（应失败，因为有子分类）
      final result = await repo.delete(parentId);
      expect(result, false);

      // 验证父分类仍存在
      expect(await repo.getById(parentId), isNotNull);
    });
  });
}
