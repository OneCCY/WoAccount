import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/ai_persona.dart';
import '../../data/storage/persona_storage.dart';

/// AI 角色编辑页
class PersonaEditPage extends StatefulWidget {
  final AiPersona? existingPersona;

  const PersonaEditPage({super.key, this.existingPersona});

  @override
  State<PersonaEditPage> createState() => _PersonaEditPageState();
}

class _PersonaEditPageState extends State<PersonaEditPage> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _greetingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedAvatar = '🤖';
  List<DialogueExample> _examples = [];

  // 常用头像选项
  static const _avatars = [
    '🤖', '🧚', '🎅', '🧛', '🐱', '🐶', '🦊', '🐰',
    '🐼', '🦄', '🐧', '🦋', '💃', '🕺', '🎪', '🎭',
    '🧙', '🧝', '🧞', '🧜', '😎', '🧐', '🤗', '😊',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingPersona != null) {
      final p = widget.existingPersona!;
      _nameController.text = p.name;
      _selectedAvatar = p.avatar;
      _descController.text = p.description;
      _greetingController.text = p.greeting;
      _examples = List.from(p.examples);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _greetingController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final persona = widget.existingPersona ??
        AiPersona.generate(
          name: _nameController.text.trim(),
          avatar: _selectedAvatar,
          description: _descController.text.trim(),
          greeting: _greetingController.text.trim(),
          examples: _examples,
        );

    await PersonaStorage.save(persona.copyWith(
      name: _nameController.text.trim(),
      avatar: _selectedAvatar,
      description: _descController.text.trim(),
      greeting: _greetingController.text.trim(),
      examples: _examples,
    ));

    if (mounted) {
      context.pop();
    }
  }

  void _addExample() {
    showDialog(
      context: context,
      builder: (_) {
        final userCtrl = TextEditingController();
        final aiCtrl = TextEditingController();
        return AlertDialog(
          title: const Text('添加对话示例'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: userCtrl, decoration: const InputDecoration(labelText: '用户'), autofocus: true),
              const SizedBox(height: 8),
              TextField(controller: aiCtrl, decoration: const InputDecoration(labelText: '角色')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
            TextButton(
              onPressed: () {
                if (userCtrl.text.trim().isNotEmpty && aiCtrl.text.trim().isNotEmpty) {
                  setState(() {
                    _examples.add(DialogueExample(
                      user: userCtrl.text.trim(),
                      assistant: aiCtrl.text.trim(),
                    ));
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('添加'),
            ),
          ],
        );
      },
    );
  }

  void _removeExample(int index) {
    setState(() => _examples.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isNew = widget.existingPersona == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? l10n.aiPersonaAdd : l10n.aiPersonaEdit),
        actions: [
          TextButton(onPressed: _save, child: const Text('保存')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 角色名称
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.aiPersonaName,
                hintText: 'e.g. 温柔知心',
                border: const OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? l10n.aiPersonaNameRequired : null,
            ),
            const SizedBox(height: 16),

            // 头像选择
            Text(l10n.aiPersonaAvatar, style: context.textStyles.body),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _avatars.map((a) {
                final isSelected = a == _selectedAvatar;
                return GestureDetector(
                  onTap: () => setState(() => _selectedAvatar = a),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? context.colors.primary : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: isSelected ? context.colors.primarySurface : null,
                    ),
                    child: Center(child: Text(a, style: const TextStyle(fontSize: 20))),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 性格描述
            TextFormField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: l10n.aiPersonaDescription,
                hintText: l10n.aiPersonaDescriptionHint,
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // 开场白
            TextFormField(
              controller: _greetingController,
              decoration: InputDecoration(
                labelText: l10n.aiPersonaGreeting,
                hintText: l10n.aiPersonaGreetingHint,
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // 对话示例
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.aiPersonaExamples, style: context.textStyles.body),
                TextButton.icon(
                  onPressed: _addExample,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('添加示例'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(l10n.aiPersonaExamplesHint, style: context.textStyles.caption),
            const SizedBox(height: 8),
            if (_examples.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '还没有添加示例，点击右上角 + 添加一组对话示例',
                  style: context.textStyles.caption,
                ),
              )
            else
              ..._examples.asMap().entries.map((entry) {
                final i = entry.key;
                final ex = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 4),
                  child: ListTile(
                    dense: true,
                    title: Text(ex.user, style: context.textStyles.caption),
                    subtitle: Text(ex.assistant, style: context.textStyles.caption),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      onPressed: () => _removeExample(i),
                    ),
                  ),
                );
              }),
            const SizedBox(height: 16),

            // 管理记忆
            if (widget.existingPersona != null)
              ListTile(
                leading: const Icon(Icons.memory, color: Colors.purple),
                title: const Text('管理记忆'),
                subtitle: const Text('查看和编辑 AI 从对话中学到的记忆'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/ai/personas/memories', extra: widget.existingPersona!.id),
              ),

            // 提示
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.primarySurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.aiPersonaTip,
                      style: context.textStyles.caption,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}