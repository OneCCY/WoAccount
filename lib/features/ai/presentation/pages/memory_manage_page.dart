import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../config/di/providers.dart';
import '../../../../config/database/app_database.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 记忆管理页 — 按类型分组查看/编辑/新增/删除语义记忆
class MemoryManagePage extends ConsumerStatefulWidget {
  final String personaId;

  const MemoryManagePage({super.key, required this.personaId});

  @override
  ConsumerState<MemoryManagePage> createState() => _MemoryManagePageState();
}

class _MemoryManagePageState extends ConsumerState<MemoryManagePage> {
  Map<String, List<PersonaMemory>> _grouped = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = ref.read(appDatabaseProvider);
    final all = await (db.select(db.personaMemories)
      ..where((t) => t.personaId.equals(widget.personaId))
      ..orderBy([(t) => drift.OrderingTerm.desc(t.score)]))
      .get();

    final grouped = <String, List<PersonaMemory>>{};
    for (final m in all) {
      grouped.putIfAbsent(m.type, () => []).add(m);
    }

    if (mounted) {
      setState(() {
        _grouped = grouped;
        _loading = false;
      });
    }
  }

  Future<void> _delete(int id) async {
    final db = ref.read(appDatabaseProvider);
    await (db.delete(db.personaMemories)..where((t) => t.id.equals(id))).go();
    if (mounted) _load();
  }

  /// 新增记忆
  Future<void> _add() async {
    final result = await _showEditDialog(null);
    if (result != null && mounted) {
      final db = ref.read(appDatabaseProvider);
      await db.into(db.personaMemories).insert(PersonaMemoriesCompanion.insert(
        personaId: widget.personaId,
        type: result.type,
        content: result.content,
      ));
      _load();
    }
  }

  /// 编辑记忆
  Future<void> _edit(PersonaMemory memory) async {
    final result = await _showEditDialog(memory);
    if (result != null && mounted) {
      final db = ref.read(appDatabaseProvider);
      await (db.update(db.personaMemories)..where((t) => t.id.equals(memory.id)))
        .write(PersonaMemoriesCompanion(
          type: drift.Value(result.type),
          content: drift.Value(result.content),
          score: drift.Value(result.score),
          updatedAt: drift.Value(DateTime.now()),
        ));
      _load();
    }
  }

  Future<_MemoryFormData?> _showEditDialog(PersonaMemory? existing) async {
    final contentCtrl = TextEditingController(text: existing?.content ?? '');
    final scoreCtrl = TextEditingController(
      text: existing?.score.toStringAsFixed(2) ?? '0.8',
    );
    // 直接读取下拉框选中值，不用 StatefulBuilder

    final types = ['preference', 'fact', 'relationship', 'instruction'];
    final typeLabels = {'preference': '偏好', 'fact': '事实', 'relationship': '社交关系', 'instruction': '习惯指令'};
    String selectedType = existing?.type ?? 'fact';

    final result = await showDialog<_MemoryFormData>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? '新增记忆' : '编辑记忆'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                decoration: const InputDecoration(
                  labelText: '类型',
                  border: OutlineInputBorder(),
                ),
                items: types.map((t) => DropdownMenuItem(
                  value: t,
                  child: Text(typeLabels[t] ?? t),
                )).toList(),
                onChanged: (v) => selectedType = v ?? 'fact',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentCtrl,
                decoration: const InputDecoration(
                  labelText: '记忆内容',
                  hintText: '如：不吃辣、在字节跳动工作',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                autofocus: existing == null,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: scoreCtrl,
                decoration: const InputDecoration(
                  labelText: '权重 (0.0-1.0)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              if (contentCtrl.text.trim().isEmpty) return;
              final score = double.tryParse(scoreCtrl.text) ?? 0.8;
              Navigator.pop(ctx, _MemoryFormData(
                type: selectedType,
                content: contentCtrl.text.trim(),
                score: score.clamp(0.0, 1.0),
              ));
            },
            child: Text(existing == null ? '新增' : '保存'),
          ),
        ],
      ),
    );
    contentCtrl.dispose();
    scoreCtrl.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('角色记忆管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: '新增记忆',
            onPressed: _add,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _grouped.isEmpty
              ? Center(
                  child: Text(
                    '还没有记忆，AI 会在对话中自动学习',
                    style: context.textStyles.callout,
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: _grouped.entries.map((entry) {
                    return _buildSection(entry.key, entry.value);
                  }).toList(),
                ),
    );
  }

  Widget _buildSection(String type, List<PersonaMemory> memories) {
    final label = switch (type) {
      'preference' => '🏷️ 偏好',
      'fact' => '📖 事实',
      'relationship' => '💬 社交关系',
      'instruction' => '⚙️ 习惯指令',
      _ => '📌 $type',
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label (${memories.length})',
              style: context.textStyles.body.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          ...memories.map((m) => Card(
                margin: const EdgeInsets.only(top: 4),
                child: ListTile(
                  dense: true,
                  title: Text(m.content, style: const TextStyle(fontSize: 14)),
                  subtitle: Text('权重: ${m.score.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 11)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: () => _edit(m),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        onPressed: () => _delete(m.id),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _MemoryFormData {
  final String type;
  final String content;
  final double score;
  const _MemoryFormData({required this.type, required this.content, required this.score});
}