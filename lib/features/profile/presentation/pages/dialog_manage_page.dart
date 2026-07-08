import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart';
import '../../../../config/di/providers.dart';
import '../../../../config/di/ai_providers.dart';
import '../../../chat/domain/repositories/chat_repository.dart';

/// 对话管理页 — 列出所有历史会话，支持按角色筛选
class DialogManagePage extends ConsumerStatefulWidget {
  const DialogManagePage({super.key});

  @override
  ConsumerState<DialogManagePage> createState() => _DialogManagePageState();
}

class _DialogManagePageState extends ConsumerState<DialogManagePage> {
  String? _filterPersonaId;
  Map<String, String> _personaNames = {};

  @override
  void initState() {
    super.initState();
    _loadPersonas();
  }

  Future<void> _loadPersonas() async {
    final db = ref.read(appDatabaseProvider);
    try {
      final personaRows = await db.customSelect(
        'SELECT DISTINCT persona_id FROM chat_messages WHERE persona_id IS NOT NULL AND persona_id != ?',
        variables: [Variable('')],
      ).get();
      final names = <String, String>{};
      for (final row in personaRows) {
        final pid = row.read<String>('persona_id') ?? '';
        if (pid.isNotEmpty) names[pid] = pid;
      }
      if (mounted) setState(() => _personaNames = names);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final chatRepo = ref.watch(chatRepositoryProvider);
    final bookId = ref.watch(currentBookProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('对话管理'),
        actions: [
          if (_personaNames.isNotEmpty)
            PopupMenuButton<String?>(
              icon: const Icon(Icons.filter_list),
              tooltip: '筛选角色',
              onSelected: (v) => setState(() => _filterPersonaId = v),
              itemBuilder: (_) => [
                const PopupMenuItem(value: null, child: Text('全部对话')),
                const PopupMenuDivider(),
                ..._personaNames.keys.map((pid) => PopupMenuItem(
                  value: pid,
                  child: Text('角色: ${pid.length > 8 ? "${pid.substring(0, 8)}..." : pid}'),
                )),
              ],
            ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadConversations(chatRepo, bookId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final convs = snapshot.data ?? [];
          final filtered = _filterPersonaId != null
              ? convs.where((c) => c['personaId'] == _filterPersonaId).toList()
              : convs;
          if (filtered.isEmpty) {
            return Center(
              child: Text(_filterPersonaId != null ? '该角色暂无对话' : '暂无对话记录'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final conv = filtered[index];
              final id = conv['id'] as String;
              final title = conv['title'] as String;
              final time = conv['time'] as DateTime;
              final personaId = conv['personaId'] as String?;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: personaId != null
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Text(personaId != null ? '🤖' : '💬', style: const TextStyle(fontSize: 18)),
                  ),
                  title: Text(
                    title.length > 40 ? '${title.substring(0, 40)}...' : title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${DateFormat('MM-dd HH:mm').format(time)}${personaId != null ? ' · 角色对话' : ''}',
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () {
                    ref.read(currentConversationIdProvider.notifier).state = id;
                    context.go('/');
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _loadConversations(ChatRepository chatRepo, int bookId) async {
    final ids = await chatRepo.getConversationIds(bookId);
    final db = ref.read(appDatabaseProvider);
    final results = <Map<String, dynamic>>[];

    for (final id in ids) {
      final msgs = await chatRepo.getMessages(
        bookId: bookId,
        conversationId: id,
        limit: 50,
      );
      if (msgs.isEmpty) continue;

      // 第一条用户消息作为标题
      final firstUserMsg = msgs.where((m) => m.role == 'user').firstOrNull;
      final lastMsg = msgs.last;
      var title = firstUserMsg?.content ?? lastMsg.content;
      title = title.replaceAll(RegExp(r'[\n\r]+'), ' ');
      if (title.length > 50) title = '${title.substring(0, 50)}...';

      // 检查是否是角色对话
      String? personaId;
      try {
        final rows = await db.customSelect(
          'SELECT persona_id FROM chat_messages WHERE conversation_id = ? AND persona_id IS NOT NULL AND persona_id != ? LIMIT 1',
          variables: [Variable(id), Variable('')],
        ).get();
        if (rows.isNotEmpty) {
          personaId = rows.first.read<String>('persona_id');
        }
      } catch (_) {}

      results.add({
        'id': id,
        'title': title,
        'time': lastMsg.createdAt,
        'personaId': personaId,
      });
    }
    // 按时间倒序
    results.sort((a, b) => (b['time'] as DateTime).compareTo(a['time'] as DateTime));
    return results;
  }
}