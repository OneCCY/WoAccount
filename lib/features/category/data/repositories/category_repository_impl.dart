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
