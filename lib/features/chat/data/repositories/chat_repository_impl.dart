import 'package:drift/drift.dart';
import '../../../../config/database/app_database.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final AppDatabase _db;

  ChatRepositoryImpl(this._db);

  @override
  Future<List<ConversationMessage>> getMessages({
    required String conversationId,
    int limit = 20,
    DateTime? before,
  }) async {
    final query = _db.select(_db.conversationMessages)
      ..where((t) => t.conversationId.equals(conversationId))
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
    required String conversationId,
    int limit = 50,
  }) {
    final query = _db.select(_db.conversationMessages)
      ..where((t) => t.conversationId.equals(conversationId))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(limit);

    return query.watch().map((list) => list.reversed.toList());
  }

  @override
  Future<int> insertMessage(ConversationMessagesCompanion message) async {
    return await _db.into(_db.conversationMessages).insert(message);
  }

  @override
  Future<List<String>> getConversationIds() async {
    final query = _db.selectOnly(_db.conversationMessages)
      ..addColumns([_db.conversationMessages.conversationId])
      ..groupBy([_db.conversationMessages.conversationId])
      ..orderBy([OrderingTerm.desc(_db.conversationMessages.createdAt)]);

    final results = await query.get();
    return results
        .map((r) => r.read(_db.conversationMessages.conversationId)!)
        .toList();
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    await (_db.delete(_db.conversationMessages)
          ..where((t) => t.conversationId.equals(conversationId)))
        .go();
  }
}
