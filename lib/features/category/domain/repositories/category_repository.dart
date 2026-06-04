import '../../../../config/database/app_database.dart';

/// 分类 Repository 接口（Domain 层）
abstract class CategoryRepository {
  /// 获取所有分类
  Future<List<Category>> getAll();

  /// 获取一级分类
  Future<List<Category>> getTopLevel();

  /// 根据父分类获取子分类
  Future<List<Category>> getChildren(int parentId);

  /// 根据 ID 获取
  Future<Category?> getById(int id);

  /// 根据名称查找
  Future<Category?> getByName(String name);

  /// 插入分类
  Future<int> insert(CategoriesCompanion category);

  /// 更新分类
  Future<bool> update(CategoriesCompanion category);

  /// 删除分类（仅非系统预设）
  Future<bool> delete(int id);

  /// 监听分类变化
  Stream<List<Category>> watchAll();
}
