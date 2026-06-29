import 'package:drift/drift.dart';
import '../../../../config/database/app_database.dart';

/// 角色聊天记录仓库
/// 管理角色对话历史的持久化、检索、自动清理
class ChatHistoryRepository {
  final AppDatabase _db;

  ChatHistoryRepository(this._db);

  /// 获取某角色的最近 N 条消息（按时间正序）
  Future<List<RoleChatMessage>> getRecentMessages({
    required String? personaId,
    int limit = 20,
  }) async {
    if (personaId == null) return [];
    return (_db.select(_db.chatMessages)
      ..where((t) => t.personaId.equals(personaId))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
      ..limit(limit))
      .get();
  }

  /// 批量保存消息
  Future<void> addMessages(List<ChatMessagesCompanion> msgs) async {
    await _db.batch((batch) {
      for (final msg in msgs) {
        batch.insert(_db.chatMessages, msg);
      }
    });
  }

  /// 按关键词模糊搜索（LIKE，后续可升级为 FTS）
  Future<List<RoleChatMessage>> searchByKeywords({
    required String? personaId,
    required String query,
    int limit = 3,
  }) async {
    if (personaId == null) return [];
    final kw = '%$query%';
    return (_db.select(_db.chatMessages)
      ..where((t) => t.personaId.equals(personaId) & t.searchKeywords.like(kw))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(limit))
      .get();
  }

  /// 更新消息的关键词字段
  Future<void> updateSearchKeywords(int messageId, String keywords) async {
    await _db.customUpdate(
      'UPDATE chat_messages SET search_keywords = ? WHERE id = ?',
      variables: [Variable(keywords), Variable(messageId)],
    );
  }

  /// 清理策略：保留最近 keepCount 条，删除更早的
  Future<void> trimHistory(String? personaId, {int keepCount = 50}) async {
    if (personaId == null) return;
    final rows = await (_db.select(_db.chatMessages)
      ..where((t) => t.personaId.equals(personaId)))
      .get();
    if (rows.length <= keepCount) return;

    final toDelete = rows.length - keepCount;
    rows.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final oldIds = rows.take(toDelete).map((r) => r.id).toList();

    await (_db.delete(_db.chatMessages)
      ..where((t) => t.id.isIn(oldIds)))
      .go();
  }

  /// 删除角色时联动清理历史
  Future<void> clearHistory(String? personaId) async {
    if (personaId == null) return;
    await (_db.delete(_db.chatMessages)
      ..where((t) => t.personaId.equals(personaId)))
      .go();
  }
}