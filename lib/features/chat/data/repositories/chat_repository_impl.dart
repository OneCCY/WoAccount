import 'package:drift/drift.dart';
import '../../../../config/database/app_database.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final AppDatabase _db;

  ChatRepositoryImpl(this._db);

  @override
  Future<List<ConversationMessage>> getMessages({
    required int bookId,
    required String conversationId,
    int limit = 20,
    DateTime? before,
  }) async {
    final query = _db.select(_db.conversationMessages)
      ..where((t) => t.accountBookId.equals(bookId) & t.conversationId.equals(conversationId))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(limit);

    if (before != null) {
      query.where((t) => t.createdAt.isSmallerThanValue(before));
    }

    final results = await query.get();
    return results.reversed.toList(); // 反转为正序（旧→新）
  }

  @override
  Stream<List<ConversationMessage>> watchMessages({
    required int bookId,
    required String conversationId,
    int limit = 50,
  }) {
    final query = _db.select(_db.conversationMessages)
      ..where((t) => t.accountBookId.equals(bookId) & t.conversationId.equals(conversationId))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(limit);

    return query.watch().map((list) => list.reversed.toList());
  }

  @override
  Future<int> insertMessage(ConversationMessagesCompanion message) async {
    return await _db.into(_db.conversationMessages).insert(message);
  }

  @override
  Future<List<String>> getConversationIds(int bookId) async {
    final query = _db.selectOnly(_db.conversationMessages)
      ..addColumns([_db.conversationMessages.conversationId])
      ..where(_db.conversationMessages.accountBookId.equals(bookId))
      ..groupBy([_db.conversationMessages.conversationId])
      ..orderBy([OrderingTerm.desc(_db.conversationMessages.createdAt)]);

    final results = await query.get();
    return results
        .map((r) => r.read(_db.conversationMessages.conversationId) ?? '')
        .where((id) => id.isNotEmpty)
        .toList();
  }

  @override
  Future<void> deleteConversation(int bookId, String conversationId) async {
    await (_db.delete(_db.conversationMessages)
          ..where((t) => t.accountBookId.equals(bookId) & t.conversationId.equals(conversationId)))
        .go();
  }
}
