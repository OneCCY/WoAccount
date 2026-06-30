import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../config/di/providers.dart';
import '../../../../config/database/app_database.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 记忆管理页 — 按类型分组查看/编辑/删除语义记忆
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

  String _typeLabel(String type, AppLocalizations l10n) {
    switch (type) {
      case 'preference': return '偏好';
      case 'fact': return '事实';
      case 'relationship': return '社交关系';
      case 'instruction': return '习惯指令';
      default: return type;
    }
  }

  String _typeIcon(String type) {
    switch (type) {
      case 'preference': return '🏷️';
      case 'fact': return '📖';
      case 'relationship': return '💬';
      case 'instruction': return '⚙️';
      default: return '📌';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text('角色记忆管理')),
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
                    return _buildSection(entry.key, entry.value, l10n);
                  }).toList(),
                ),
    );
  }

  Widget _buildSection(String type, List<PersonaMemory> memories, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_typeIcon(type)} ${_typeLabel(type, l10n)} (${memories.length})',
            style: context.textStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          ...memories.map((m) => Card(
                margin: const EdgeInsets.only(top: 4),
                child: ListTile(
                  dense: true,
                  title: Text(m.content),
                  subtitle: Text('权重: ${m.score.toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: () => _delete(m.id),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}