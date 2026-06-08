import '../../../../config/database/app_database.dart';

/// 对话记录 Repository 接口
abstract class ChatRepository {
  /// 获取账本内对话列表（分页，倒序）
  /// [before] 传入最后一条消息的 createdAt，加载更早的记录
  Future<List<ConversationMessage>> getMessages({
    required int bookId,
    required String conversationId,
    int limit = 20,
    DateTime? before,
  });

  /// 监听账本内对话变化（实时更新）
  Stream<List<ConversationMessage>> watchMessages({
    required int bookId,
    required String conversationId,
    int limit = 50,
  });

  /// 插入一条消息
  Future<int> insertMessage(ConversationMessagesCompanion message);

  /// 获取账本内所有对话 ID（去重）
  Future<List<String>> getConversationIds(int bookId);

  /// 删除账本内某个对话的所有消息
  Future<void> deleteConversation(int bookId, String conversationId);
}
