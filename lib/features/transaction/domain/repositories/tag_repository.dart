import '../../../../config/database/app_database.dart';

/// 标签 Repository 接口（Domain 层）
abstract class TagRepository {
  /// 获取账本内所有标签
  Future<List<Tag>> getAll(int bookId);

  /// 根据 ID 获取标签
  Future<Tag?> getById(int id);

  /// 创建标签，返回新标签 ID
  Future<int> create(TagsCompanion tag);

  /// 更新标签
  Future<bool> update(TagsCompanion tag);

  /// 删除标签（同时移除所有关联关系）
  Future<bool> delete(int id);

  /// 为交易添加标签
  Future<void> addTagToTransaction(int transactionId, int tagId);

  /// 移除交易的标签
  Future<void> removeTagFromTransaction(int transactionId, int tagId);

  /// 获取交易的所有标签
  Future<List<Tag>> getTagsForTransaction(int transactionId);

  /// 获取标签关联的交易 ID 列表
  Future<List<int>> getTransactionIdsForTag(int tagId);

  /// 设置交易的标签（全量替换）
  Future<void> setTransactionTags(int transactionId, List<int> tagIds);
}
