import 'package:drift/drift.dart';
import '../../../../config/database/app_database.dart';

/// 角色聊天记录仓库
/// 管理角色对话历史的持久化、检索、自动清理
class ChatHistoryRepository {
  final AppDatabase _db;

  ChatHistoryRepository(this._db);

  /// 获取某角色、某会话的最近 N 条消息（按时间正序）
  Future<List<RoleChatMessage>> getRecentMessages({
    required String? personaId,
    String? conversationId,
    int limit = 20,
  }) async {
    if (personaId == null) return [];
    return (_db.select(_db.chatMessages)
      ..where((t) {
        var condition = t.personaId.equals(personaId);
        if (conversationId != null) {
          condition &= t.conversationId.equals(conversationId);
        }
        return condition;
      })
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

  /// 按关键词模糊搜索内容（跨会话共享）
  /// 同时搜索 searchKeywords 和原始 content
  Future<List<RoleChatMessage>> searchByKeywords({
    required String? personaId,
    required String query,
    int limit = 5,
  }) async {
    if (personaId == null) return [];
    final kw = '%$query%';
    return (_db.select(_db.chatMessages)
      ..where((t) =>
          t.personaId.equals(personaId) &
          (t.searchKeywords.like(kw) | t.content.like(kw)))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(limit))
      .get();
  }

  /// 按 token 估算加载最近消息，不超过 maxTokens
  /// 简单估算：中文 ≈ 2 token/字，英文 ≈ 1 token/词
  Future<List<RoleChatMessage>> getRecentMessagesByTokenBudget({
    required String? personaId,
    String? conversationId,
    int maxTokens = 1200,
    int maxCount = 20,
  }) async {
    if (personaId == null) return [];
    final all = (_db.select(_db.chatMessages)
      ..where((t) {
        var condition = t.personaId.equals(personaId);
        if (conversationId != null) {
          condition &= t.conversationId.equals(conversationId);
        }
        return condition;
      })
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(maxCount))
      .get();
    final rows = await all;
    rows.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    // 从最新的开始，累计 token 估算
    int totalTokens = 0;
    final result = <RoleChatMessage>[];
    for (int i = rows.length - 1; i >= 0; i--) {
      final tokens = _estimateTokens(rows[i].content);
      if (totalTokens + tokens > maxTokens) break;
      totalTokens += tokens;
      result.insert(0, rows[i]);
    }
    return result;
  }

  int _estimateTokens(String text) {
    // 中文 2 token/字，英文 1 token/词，取两者之和
    int chinese = 0;
    int english = 0;
    for (final c in text.runes) {
      if (c >= 0x4E00 && c <= 0x9FFF) {
        chinese++;
      } else if (c == 32) {
        english++; // 空格分隔英文词
      }
    }
    final words = text.split(RegExp(r'\s+')).length;
    return (chinese * 2) + english + words;
  }

  /// 更新消息的关键词字段
  Future<void> updateSearchKeywords(int messageId, String keywords) async {
    await _db.customUpdate(
      'UPDATE chat_messages SET search_keywords = ? WHERE id = ?',
      variables: [Variable(keywords), Variable(messageId)],
    );
  }

  /// 清理策略：保留某会话最近 keepCount 条
  Future<void> trimHistory(String? personaId, {String? conversationId, int keepCount = 50}) async {
    if (personaId == null) return;
    final rows = await (_db.select(_db.chatMessages)
      ..where((t) {
        var condition = t.personaId.equals(personaId);
        if (conversationId != null) condition &= t.conversationId.equals(conversationId);
        return condition;
      }))
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