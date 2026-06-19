import 'package:drift/drift.dart';
import '../../../../config/database/app_database.dart';
import '../../domain/repositories/tag_repository.dart';

/// 标签 Repository 实现（Data 层）
class TagRepositoryImpl implements TagRepository {
  final AppDatabase _db;

  TagRepositoryImpl(this._db);

  @override
  Future<List<Tag>> getAll(int bookId) async {
    return (_db.select(_db.tags)
          ..where((t) => t.accountBookId.equals(bookId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  @override
  Future<Tag?> getById(int id) async {
    return (_db.select(_db.tags)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Future<int> create(TagsCompanion tag) async {
    return _db.into(_db.tags).insert(tag);
  }

  @override
  Future<bool> update(TagsCompanion tag) async {
    return _db.update(_db.tags).replace(tag);
  }

  @override
  Future<bool> delete(int id) async {
    // 先删除所有关联关系
    await (_db.delete(_db.transactionTags)
          ..where((tt) => tt.tagId.equals(id)))
        .go();
    // 再删除标签本身
    final count = await (_db.delete(_db.tags)
          ..where((t) => t.id.equals(id)))
        .go();
    return count > 0;
  }

  @override
  Future<void> addTagToTransaction(int transactionId, int tagId) async {
    // 检查是否已存在
    final existing = await (_db.select(_db.transactionTags)
          ..where((tt) =>
              tt.transactionId.equals(transactionId) &
              tt.tagId.equals(tagId)))
        .getSingleOrNull();
    if (existing != null) return;

    await _db.into(_db.transactionTags).insert(
      TransactionTagsCompanion.insert(
        transactionId: transactionId,
        tagId: tagId,
      ),
    );
  }

  @override
  Future<void> removeTagFromTransaction(int transactionId, int tagId) async {
    await (_db.delete(_db.transactionTags)
          ..where((tt) =>
              tt.transactionId.equals(transactionId) &
              tt.tagId.equals(tagId)))
        .go();
  }

  @override
  Future<List<Tag>> getTagsForTransaction(int transactionId) async {
    final query = _db.select(_db.tags).join([
      innerJoin(
        _db.transactionTags,
        _db.transactionTags.tagId.equalsExp(_db.tags.id),
      ),
    ])
      ..where(_db.transactionTags.transactionId.equals(transactionId));

    final results = await query.get();
    return results.map((row) => row.readTable(_db.tags)).toList();
  }

  @override
  Future<List<int>> getTransactionIdsForTag(int tagId) async {
    final results = await (_db.select(_db.transactionTags)
          ..where((tt) => tt.tagId.equals(tagId)))
        .get();
    return results.map((tt) => tt.transactionId).toList();
  }

  @override
  Future<void> setTransactionTags(int transactionId, List<int> tagIds) async {
    // 删除旧的关联
    await (_db.delete(_db.transactionTags)
          ..where((tt) => tt.transactionId.equals(transactionId)))
        .go();
    // 插入新的关联
    for (final tagId in tagIds) {
      await _db.into(_db.transactionTags).insert(
        TransactionTagsCompanion.insert(
          transactionId: transactionId,
          tagId: tagId,
        ),
      );
    }
  }
}
