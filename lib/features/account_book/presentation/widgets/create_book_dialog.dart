import 'package:flutter/material.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 新建账本对话框
class CreateBookDialog extends StatefulWidget {
  const CreateBookDialog({super.key});

  @override
  State<CreateBookDialog> createState() => _CreateBookDialogState();
}

class _CreateBookDialogState extends State<CreateBookDialog> {
  final _nameController = TextEditingController();
  String _selectedType = 'personal';
  String? _selectedIcon;
  final _descController = TextEditingController();
  final _nameFocusNode = FocusNode();

  // 可选图标列表
  static const _icons = ['📒', '📕', '📗', '📘', '📙', '💰', '🏦', '💳', '🏠', '✈️', '💼', '🎯', '🎮', '🐾', '🎓', '❤️'];

  List<_BookType> _getTypes(AppLocalizations l10n) => [
    _BookType('personal', '🧑', l10n.bookTypePersonal, l10n.bookDescPersonal),
    _BookType('family', '👨‍👩‍👧‍👦', l10n.bookTypeFamily, l10n.bookDescFamily),
    _BookType('travel', '✈️', l10n.bookTypeTravel, l10n.bookDescTravel),
    _BookType('business', '💼', l10n.bookTypeBusiness, l10n.bookDescBusiness),
    _BookType('other', '📁', l10n.bookTypeOther, l10n.bookDescOther),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final types = _getTypes(l10n);
    return AlertDialog(
      title: Text(l10n.bookCreate),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图标选择
            Text(l10n.catManageSelectIcon, style: context.textStyles.footnote.copyWith(color: context.colors.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _icons.map((icon) {
                final isSelected = _selectedIcon == icon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected ? context.colors.primary.withValues(alpha: 0.15) : context.colors.surface,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                      border: isSelected ? Border.all(color: context.colors.primary, width: 2) : null,
                    ),
                    child: Center(child: Text(icon, style: const TextStyle(fontSize: 20))),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // 名称输入
            TextField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              maxLength: 12,
              decoration: InputDecoration(
                labelText: l10n.bookNameLabel,
                hintText: l10n.bookNameHint,
                counterText: '',
              ),
            ),

            const SizedBox(height: 16),

            // 类型选择
            Text(l10n.bookTypeLabel, style: context.textStyles.footnote.copyWith(color: context.colors.textSecondary)),
            const SizedBox(height: 8),
            ...types.map((type) {
              final isSelected = _selectedType == type.value;
              return GestureDetector(
                onTap: () => setState(() => _selectedType = type.value),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? context.colors.primary.withValues(alpha: 0.08) : null,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    border: isSelected ? Border.all(color: context.colors.primary.withValues(alpha: 0.3)) : null,
                  ),
                  child: Row(
                    children: [
                      Text(type.icon, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(type.label, style: context.textStyles.body),
                            Text(type.desc, style: context.textStyles.caption.copyWith(color: context.colors.textTertiary)),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle, color: context.colors.primary, size: 20),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            // 备注
            TextField(
              controller: _descController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: l10n.bookDescLabel,
                hintText: l10n.bookDescHint,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        ElevatedButton(
          onPressed: _onCreate,
          child: Text(l10n.bookCreateButton),
        ),
      ],
    );
  }

  void _onCreate() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _nameFocusNode.requestFocus();
      return;
    }

    Navigator.pop(context, {
      'name': name,
      'type': _selectedType,
      'icon': _selectedIcon,
      'description': _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
    });
  }
}

class _BookType {
  final String value;
  final String icon;
  final String label;
  final String desc;

  const _BookType(this.value, this.icon, this.label, this.desc);
}
