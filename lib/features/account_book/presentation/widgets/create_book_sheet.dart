import 'package:flutter/material.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 新建账本底部弹窗
/// 从上到下：名称输入、图标横向滚动选择、类型横向滚动选择、备注输入
class CreateBookSheet extends StatefulWidget {
  const CreateBookSheet({super.key});

  /// 显示底部弹窗，返回创建数据或 null
  static Future<Map<String, dynamic>?> show(BuildContext context) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateBookSheet(),
    );
  }

  @override
  State<CreateBookSheet> createState() => _CreateBookSheetState();
}

class _CreateBookSheetState extends State<CreateBookSheet> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _nameFocusNode = FocusNode();
  String _selectedType = 'personal';
  String _selectedIcon = '📒';

  static const _icons = [
    '📒', '📕', '📗', '📘', '📙', '💰', '🏦', '💳',
    '🏠', '✈️', '💼', '🎯', '🎮', '🐾', '🎓', '❤️',
    '🍎', '🛒', '🎬', '🏋️', '🚗', '🎁', '📱', '☕',
  ];

  List<_BookType> _getTypes(AppLocalizations l10n) => [
    _BookType('personal', '🧑', l10n.bookTypePersonal),
    _BookType('family', '👨‍👩‍👧‍👦', l10n.bookTypeFamily),
    _BookType('travel', '✈️', l10n.bookTypeTravel),
    _BookType('business', '💼', l10n.bookTypeBusiness),
    _BookType('other', '📁', l10n.bookTypeOther),
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
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽指示条
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.textTertiary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // 标题栏
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(l10n.bookCreate, style: context.textStyles.h3),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.commonCancel),
                  ),
                ],
              ),
            ),

            // 可滚动内容
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        filled: true,
                        fillColor: context.colors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 图标选择（横向滚动）
                    Text(l10n.catManageSelectIcon, style: context.textStyles.footnote.copyWith(color: context.colors.textSecondary)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 48,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _icons.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final icon = _icons[index];
                          final isSelected = _selectedIcon == icon;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedIcon = icon),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isSelected ? context.colors.primary.withValues(alpha: 0.15) : context.colors.surface,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                                border: isSelected ? Border.all(color: context.colors.primary, width: 2) : null,
                              ),
                              child: Center(child: Text(icon, style: const TextStyle(fontSize: 22))),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 类型选择（横向滚动）
                    Text(l10n.bookTypeLabel, style: context.textStyles.footnote.copyWith(color: context.colors.textSecondary)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: types.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final type = types[index];
                          final isSelected = _selectedType == type.value;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedType = type.value),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: isSelected ? context.colors.primary.withValues(alpha: 0.12) : context.colors.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: isSelected ? Border.all(color: context.colors.primary.withValues(alpha: 0.5)) : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(type.icon, style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 6),
                                  Text(type.label, style: context.textStyles.caption.copyWith(
                                    color: isSelected ? context.colors.primary : context.colors.textPrimary,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  )),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 备注输入
                    TextField(
                      controller: _descController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: l10n.bookDescLabel,
                        hintText: l10n.bookDescHint,
                        filled: true,
                        fillColor: context.colors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 创建按钮
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _onCreate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                          ),
                        ),
                        child: Text(l10n.bookCreateButton, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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

  const _BookType(this.value, this.icon, this.label);
}
