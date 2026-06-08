import 'package:flutter/material.dart';
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

  // 账本类型
  static const _types = [
    _BookType('personal', '🧑', '个人', '日常个人记账'),
    _BookType('family', '👨‍👩‍👧‍👦', '家庭', '家庭共同开支'),
    _BookType('travel', '✈️', '旅行', '旅行花费记录'),
    _BookType('business', '💼', '生意', '副业/小生意收支'),
    _BookType('other', '📁', '其他', '自定义用途'),
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
    return AlertDialog(
      title: const Text('新建账本'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图标选择
            Text('选择图标', style: AppTextStyles.footnote.copyWith(color: AppColors.textSecondary)),
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
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                      border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
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
              decoration: const InputDecoration(
                labelText: '账本名称',
                hintText: '例如：日常记账',
                counterText: '',
              ),
            ),

            const SizedBox(height: 16),

            // 类型选择
            Text('账本类型', style: AppTextStyles.footnote.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            ..._types.map((type) {
              final isSelected = _selectedType == type.value;
              return GestureDetector(
                onTap: () => setState(() => _selectedType = type.value),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : null,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    border: isSelected ? Border.all(color: AppColors.primary.withValues(alpha: 0.3)) : null,
                  ),
                  child: Row(
                    children: [
                      Text(type.icon, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(type.label, style: AppTextStyles.body),
                            Text(type.desc, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle, color: AppColors.primary, size: 20),
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
              decoration: const InputDecoration(
                labelText: '备注（可选）',
                hintText: '简单描述账本用途',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _onCreate,
          child: const Text('创建'),
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
