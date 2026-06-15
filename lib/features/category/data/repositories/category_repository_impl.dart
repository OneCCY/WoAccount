import 'package:drift/drift.dart';
import '../../../../config/database/app_database.dart';
import '../../domain/repositories/category_repository.dart';

/// 分类 Repository 实现（Data 层）
class CategoryRepositoryImpl implements CategoryRepository {
  final AppDatabase _db;

  CategoryRepositoryImpl(this._db);

  @override
  Future<List<Category>> getAll() async {
    return (_db.select(_db.categories)
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .get();
  }

  @override
  Future<List<Category>> getTopLevel() async {
    return (_db.select(_db.categories)
          ..where((c) => c.level.equals(1))
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .get();
  }

  @override
  Future<List<Category>> getChildren(int parentId) async {
    return (_db.select(_db.categories)
          ..where((c) => c.parentId.equals(parentId))
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .get();
  }

  @override
  Future<Category?> getById(int id) async {
    return (_db.select(_db.categories)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Future<Category?> getByName(String name) async {
    return (_db.select(_db.categories)..where((c) => c.name.equals(name)))
        .getSingleOrNull();
  }

  @override
  Future<int> insert(CategoriesCompanion category) async {
    return _db.into(_db.categories).insert(category);
  }

  @override
  Future<bool> update(CategoriesCompanion category) async {
    return _db.update(_db.categories).replace(category);
  }

  @override
  Future<bool> delete(int id) async {
    // 不允许删除系统预设分类
    final category = await getById(id);
    if (category == null || category.isSystem) return false;

    // 检查是否有子分类
    final children = await getChildren(id);
    if (children.isNotEmpty) return false;

    // 检查是否有关联交易
    final txCount = await (_db.select(_db.transactions)
          ..where((t) => t.categoryId.equals(id) | t.parentCategoryId.equals(id))
          ..limit(1))
        .get();
    if (txCount.isNotEmpty) return false;

    // 检查是否有关联预算
    final budgetCount = await (_db.select(_db.budgets)
          ..where((b) => b.categoryId.equals(id))
          ..limit(1))
        .get();
    if (budgetCount.isNotEmpty) return false;

    final count = await (_db.delete(_db.categories)
          ..where((c) => c.id.equals(id)))
        .go();
    return count > 0;
  }

  @override
  Future<bool> deleteWithChildren(int id) async {
    // 不允许删除系统预设分类
    final category = await getById(id);
    if (category == null || category.isSystem) return false;

    // 检查子分类是否有关联数据
    final children = await getChildren(id);
    for (final child in children) {
      final txCount = await (_db.select(_db.transactions)
            ..where((t) => t.categoryId.equals(child.id) | t.parentCategoryId.equals(child.id))
            ..limit(1))
          .get();
      if (txCount.isNotEmpty) return false;

      final budgetCount = await (_db.select(_db.budgets)
            ..where((b) => b.categoryId.equals(child.id))
            ..limit(1))
          .get();
      if (budgetCount.isNotEmpty) return false;
    }

    // 检查父分类本身是否有关联数据
    final parentTxCount = await (_db.select(_db.transactions)
          ..where((t) => t.categoryId.equals(id) | t.parentCategoryId.equals(id))
          ..limit(1))
        .get();
    if (parentTxCount.isNotEmpty) return false;

    final parentBudgetCount = await (_db.select(_db.budgets)
          ..where((b) => b.categoryId.equals(id))
          ..limit(1))
        .get();
    if (parentBudgetCount.isNotEmpty) return false;

    // 先删除所有子分类
    for (final child in children) {
      await (_db.delete(_db.categories)
            ..where((c) => c.id.equals(child.id)))
          .go();
    }

    // 再删除父分类
    final count = await (_db.delete(_db.categories)
          ..where((c) => c.id.equals(id)))
        .go();
    return count > 0;
  }

  @override
  Stream<List<Category>> watchAll() {
    return (_db.select(_db.categories)
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .watch();
  }
}
