import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/storage/persona_storage.dart';
import '../../data/models/ai_persona.dart';

/// AI 角色列表页
class PersonaListPage extends StatefulWidget {
  const PersonaListPage({super.key});

  @override
  State<PersonaListPage> createState() => _PersonaListPageState();
}

class _PersonaListPageState extends State<PersonaListPage> {
  List<AiPersona> _personas = [];
  String? _activeId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final personas = await PersonaStorage.loadAll();
    final activeId = await PersonaStorage.getActiveId();
    if (mounted) {
      setState(() {
        _personas = personas;
        _activeId = activeId;
        _loading = false;
      });
    }
  }

  Future<void> _activate(String id) async {
    await PersonaStorage.setActiveId(id);
    if (mounted) setState(() => _activeId = id);
  }

  Future<void> _deactivate() async {
    await PersonaStorage.setActiveId(null);
    if (mounted) setState(() => _activeId = null);
  }

  Future<void> _delete(AiPersona persona) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${l10n.aiPersonaDeleteConfirm} "$persona.name"'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('删除')),
        ],
      ),
    );
    if (confirmed == true) {
      await PersonaStorage.delete(persona.id);
      if (mounted) _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aiPersonaManage),
        actions: [
          TextButton(
            onPressed: () => context.push('/ai/personas/edit'),
            child: const Text('+ 添加'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 不启用选项
                ListTile(
                  leading: const Icon(Icons.block),
                  title: Text(l10n.aiPersonaNone),
                  trailing: _activeId == null
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  onTap: _deactivate,
                ),
                const Divider(),
                // 角色列表
                if (_personas.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        l10n.aiPersonaEmpty,
                        style: context.textStyles.callout,
                      ),
                    ),
                  )
                else
                  ..._personas.map(_buildPersonaCard),
              ],
            ),
    );
  }

  Widget _buildPersonaCard(AiPersona persona) {
    final isActive = _activeId == persona.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isActive ? context.colors.primary : context.colors.surfaceSecondary,
          child: Text(persona.avatar, style: const TextStyle(fontSize: 20)),
        ),
        title: Text(persona.name),
        subtitle: Text(persona.description.isEmpty ? '暂无描述' : persona.description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive)
              const Icon(Icons.check_circle, color: Colors.green),
            IconButton(
              icon: const Icon(Icons.edit, size: 18),
              onPressed: () => context.push('/ai/personas/edit', extra: persona),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              onPressed: () => _delete(persona),
            ),
          ],
        ),
        onTap: () => _activate(persona.id),
      ),
    );
  }
}