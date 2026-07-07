import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../config/di/providers.dart';
import '../../../../config/di/ai_providers.dart';
import '../../../../config/database/app_database.dart';

/// 对话管理页 — 列出所有历史会话
class DialogManagePage extends ConsumerWidget {
  const DialogManagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRepo = ref.watch(chatRepositoryProvider);
    final bookId = ref.watch(currentBookProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('对话管理')),
      body: FutureBuilder<List<String>>(
        future: chatRepo.getConversationIds(bookId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final ids = snapshot.data ?? [];
          if (ids.isEmpty) {
            return const Center(child: Text('暂无对话记录'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ids.length,
            itemBuilder: (context, index) {
              final conv = ids[index];
              return FutureBuilder<List<ConversationMessage>>(
                future: chatRepo.getMessages(
                  bookId: bookId,
                  conversationId: conv,
                  limit: 1,
                ),
                builder: (ctx, snap) {
                  final msgs = snap.data ?? [];
                  final lastMsg = msgs.isNotEmpty ? msgs.last.content : '(空)';
                  final lastTime = msgs.isNotEmpty ? msgs.last.createdAt : DateTime.now();
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: const Text('💬', style: TextStyle(fontSize: 18)),
                      ),
                      title: Text(
                        lastMsg.length > 50 ? '${lastMsg.substring(0, 50)}...' : lastMsg,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(DateFormat('MM-dd HH:mm').format(lastTime)),
                      trailing: const Icon(Icons.chevron_right, size: 18),
                      onTap: () {
                        // 更新当前对话 ID 并跳转到记账页
                        ref.read(currentConversationIdProvider.notifier).state = conv;
                        context.go('/');
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}