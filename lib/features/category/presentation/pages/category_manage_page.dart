import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../config/database/app_database.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/repositories/category_repository.dart';

/// 分类管理类型
enum CategoryManageType { expense, income, other }

/// 分类管理页
/// 分类网格 + 子分类列表 + 编辑模式
class CategoryManagePage extends ConsumerStatefulWidget {
  const CategoryManagePage({super.key});

  @override
  ConsumerState<CategoryManagePage> createState() => _CategoryManagePageState();
}

class _CategoryManagePageState extends ConsumerState<CategoryManagePage> {
  CategoryManageType _type = CategoryManageType.expense;
  Category? _selectedParent;
  bool _isEditMode = false;
  late final CategoryRepository _catRepo;

  @override
  void initState() {
    super.initState();
    _catRepo = ref.read(categoryRepositoryProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(_selectedParent != null ? l10n.catManageSubTitle(_selectedParent!.name) : l10n.catManageTitle),
        leading: _selectedParent != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() {
                  _selectedParent = null;
                  _isEditMode = false; // BUG-9 修复：返回时退出编辑模式
                }),
              )
            : null,
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.check : Icons.edit_outlined),
            onPressed: () => setState(() => _isEditMode = !_isEditMode),
          ),
        ],
      ),
      body: _selectedParent != null
          ? _buildSubCategoryList()
          : _buildCategoryView(),
      bottomNavigationBar: _isEditMode
          ? Container(
              padding: const EdgeInsets.all(AppDimensions.md),
              color: context.colors.surface,
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: () => setState(() => _isEditMode = false),
                  child: Text(l10n.commonDone),
                ),
              ),
            )
          : null,
    );
  }

  /// 分类视图（带类型切换）
  Widget _buildCategoryView() {
    return Column(
      children: [
        // 类型切换
        if (!_isEditMode) _buildTypeTabs(),
        // 分类网格
        Expanded(child: _buildCategoryGrid()),
      ],
    );
  }

  Widget _buildTypeTabs() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: context.colors.surface,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      child: Row(
        children: CategoryManageType.values.map((type) {
          final isActive = _type == type;
          final label = switch (type) {
            CategoryManageType.expense => l10n.entryExpense,
            CategoryManageType.income => l10n.entryIncome,
            CategoryManageType.other => l10n.entryOther,
          };
          return GestureDetector(
            onTap: () => setState(() => _type = type),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                border: isActive
                    ? Border(bottom: BorderSide(color: context.colors.primary, width: 2))
                    : null,
              ),
              child: Text(
                label,
                style: context.textStyles.callout.copyWith(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? context.colors.primary : context.colors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // BUG-3 修复：使用 StreamBuilder + watchAll() 替代 FutureBuilder
  Widget _buildCategoryGrid() {
    return StreamBuilder<List<Category>>(
      stream: _catRepo.watchAll(),
      builder: (context, snapshot) {
        final allCategories = snapshot.data ?? [];
        // 仅取顶层分类
        final topLevel = allCategories.where((c) => c.level == 1).toList();
        final categories = _filterCategories(topLevel);

        return Padding(
          padding: const EdgeInsets.all(AppDimensions.md),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: categories.length + 1, // +1 for add button
            itemBuilder: (context, index) {
              if (index == categories.length) {
                return _buildAddButton();
              }
              final cat = categories[index];
              return _CategoryGridItem(
                category: cat,
                isEditMode: _isEditMode,
                onTap: () {
                  if (_isEditMode) return;
                  setState(() => _selectedParent = cat);
                },
                // BUG-8 修复：长按编辑用户自定义分类
                onLongPress: !cat.isSystem
                    ? () => _onEditCategory(cat)
                    : null,
                onDelete: _isEditMode && !cat.isSystem
                    ? () => _onDeleteCategory(cat)
                    : null,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _onAddCategory,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              border: Border.all(color: context.colors.textHint, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Center(
              child: Icon(Icons.add, size: 24, color: context.colors.textHint),
            ),
          ),
          const SizedBox(height: 4),
          Text(AppLocalizations.of(context)!.commonAdd, style: context.textStyles.caption),
        ],
      ),
    );
  }

  /// 子分类列表
  Widget _buildSubCategoryList() {
    return StreamBuilder<List<Category>>(
      stream: _catRepo.watchAll(),
      builder: (context, snapshot) {
        final allCategories = snapshot.data ?? [];
        // 仅取当前父分类的子分类
        final children = allCategories
            .where((c) => c.parentId == _selectedParent!.id)
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

        return ListView(
          padding: const EdgeInsets.all(AppDimensions.md),
          children: [
            ...children.map((sub) => _SubCategoryListItem(
                  category: sub,
                  isEditMode: _isEditMode,
                  onDelete: _isEditMode && !sub.isSystem
                      ? () => _onDeleteCategory(sub)
                      : null,
                )),
            // 添加子分类按钮
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: OutlinedButton.icon(
                onPressed: _onAddSubCategory,
                icon: const Icon(Icons.add, size: 18),
                label: Text(AppLocalizations.of(context)!.catManageAddSub),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: BorderSide(color: context.colors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // BUG-4 + BUG-10 修复：修正过滤逻辑，'人情' → '人情往来'
  List<Category> _filterCategories(List<Category> categories) {
    switch (_type) {
      case CategoryManageType.expense:
        return categories.where((c) => c.isExpense).toList();
      case CategoryManageType.income:
        return categories.where((c) => !c.isExpense && !_isOtherCategory(c)).toList();
      case CategoryManageType.other:
        return categories.where((c) => _isOtherCategory(c)).toList();
    }
  }

  /// 判断是否为"其他"分类（转账、还款、人情往来）
  /// 基于种子数据中的 l10nKey 匹配
  bool _isOtherCategory(Category cat) {
    const otherKeys = {'catOtherTransfer', 'catOtherRepayment', 'catOtherSocial'};
    final isOther = cat.l10nKey != null && otherKeys.contains(cat.l10nKey);
    return !cat.isExpense && isOther;
  }

  void _onAddCategory() {
    final isExpense = _type == CategoryManageType.expense;
    final isOther = _type == CategoryManageType.other;
    showDialog(
      context: context,
      builder: (ctx) => _AddCategoryDialog(
        isExpense: isExpense,
        isOther: isOther,
        onConfirm: (name, icon, color) async {
          // BUG-7 修复：重名校验
          final existing = await _catRepo.getByName(name);
          if (existing != null) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.catManageNameExists), duration: const Duration(milliseconds: 800)),
              );
            }
            return;
          }

          final allTopLevel = await _catRepo.getTopLevel();
          final maxSort = allTopLevel.isEmpty ? 0 : allTopLevel.map((c) => c.sortOrder).reduce((a, b) => a > b ? a : b);
          await _catRepo.insert(CategoriesCompanion.insert(
            name: name,
            icon: Value(icon),
            color: Value(color),
            level: const Value(1),
            isSystem: const Value(false),
            isExpense: Value(isExpense && !isOther),
            sortOrder: Value(maxSort + 1),
          ));
        },
      ),
    );
  }

  void _onAddSubCategory() {
    showDialog(
      context: context,
      builder: (ctx) => _AddSubCategoryDialog(
        parentName: _selectedParent!.name,
        onConfirm: (name, icon) async {
          // BUG-7 修复：重名校验
          final existing = await _catRepo.getByName(name);
          if (existing != null) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.catManageSubNameExists), duration: const Duration(milliseconds: 800)),
              );
            }
            return;
          }

          final children = await _catRepo.getChildren(_selectedParent!.id);
          final maxSort = children.isEmpty ? 0 : children.map((c) => c.sortOrder).reduce((a, b) => a > b ? a : b);
          await _catRepo.insert(CategoriesCompanion.insert(
            name: name,
            icon: Value(icon),
            color: Value(_selectedParent!.color),
            parentId: Value(_selectedParent!.id),
            level: const Value(2),
            isSystem: const Value(false),
            isExpense: Value(_selectedParent!.isExpense),
            sortOrder: Value(maxSort + 1),
          ));
        },
      ),
    );
  }

  // BUG-8 修复：编辑分类功能
  void _onEditCategory(Category cat) {
    showDialog(
      context: context,
      builder: (ctx) => _EditCategoryDialog(
        category: cat,
        onConfirm: (name, icon, color) async {
          // 检查重名（排除自身）
          final existing = await _catRepo.getByName(name);
          if (existing != null && existing.id != cat.id) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.catManageNameExists), duration: const Duration(milliseconds: 800)),
              );
            }
            return;
          }

          await _catRepo.update(cat.toCompanion(false).copyWith(
            name: Value(name),
            icon: Value(icon),
            color: Value(color),
          ));
        },
      ),
    );
  }

  void _onDeleteCategory(Category cat) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.catManageDeleteTitle),
        content: Text(cat.level == 1
            ? l10n.catManageDeleteWithChildren(cat.name)
            : l10n.catManageDeleteConfirm(cat.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              // BUG-2 修复：有子分类时使用级联删除
              final children = await _catRepo.getChildren(cat.id);
              final bool success;
              if (children.isNotEmpty) {
                success = await _catRepo.deleteWithChildren(cat.id);
              } else {
                success = await _catRepo.delete(cat.id);
              }
              if (!success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.catManageDeleteBlocked), duration: const Duration(milliseconds: 800)),
                );
              }
            },
            child: Text(l10n.commonDelete, style: TextStyle(color: context.colors.error)),
          ),
        ],
      ),
    );
  }
}

/// 分类网格项
class _CategoryGridItem extends StatelessWidget {
  final Category category;
  final bool isEditMode;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDelete;

  const _CategoryGridItem({
    required this.category,
    required this.isEditMode,
    required this.onTap,
    this.onLongPress,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(context, category.color);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Center(
                  child: Text(category.icon ?? '📦', style: const TextStyle(fontSize: 22)),
                ),
              ),
              // 自定义标记
              if (!category.isSystem)
                Positioned(
                  left: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                    decoration: BoxDecoration(
                      color: context.colors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(AppLocalizations.of(context)!.catManageCustomBadge, style: context.textStyles.caption.copyWith(
                      color: context.colors.textOnPrimary,
                      fontSize: 8,
                    )),
                  ),
                ),
              // 删除按钮
              if (isEditMode && onDelete != null)
                Positioned(
                  right: -4,
                  top: -4,
                  child: GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: context.colors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(Icons.close, size: 10, color: context.colors.textOnPrimary),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            category.name,
            style: context.textStyles.caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _parseColor(BuildContext context, String? hex) {
    if (hex == null || hex.isEmpty) return context.colors.textTertiary;
    final clean = hex.replaceFirst('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }
}

/// 子分类列表项
class _SubCategoryListItem extends StatelessWidget {
  final Category category;
  final bool isEditMode;
  final VoidCallback? onDelete;

  const _SubCategoryListItem({
    required this.category,
    required this.isEditMode,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(bottom: BorderSide(color: context.colors.separatorOpaque, width: 0.5)),
      ),
      child: Row(
        children: [
          Text(category.icon ?? '📦', style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(category.name, style: context.textStyles.body),
          ),
          if (!category.isSystem)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: context.colors.primarySurface,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(AppLocalizations.of(context)!.catManageCustom, style: context.textStyles.caption.copyWith(color: context.colors.primaryDark)),
            ),
          if (isEditMode && onDelete != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDelete,
              child: Icon(Icons.delete_outline, size: 20, color: context.colors.error),
            ),
          ],
        ],
      ),
    );
  }
}

// ==================== 添加分类对话框 ====================

const _emojiOptions = [
  '🍜', '🚗', '🛒', '🏠', '🎮', '📚', '💊', '👤', '🐾', '💰',
  '💼', '🎁', '📈', '↩️', '💻', '🔄', '💳', '🤝', '🍔', '☕',
  '🎬', '✈️', '🏋️', '🎵', '📱', '👕', '💄', '🔧', '📦', '🌟',
];

// BUG-5 修复：第二个 #795548 替换为 #FFEB3B（黄色）
const _colorOptions = [
  '#FF9800', '#2196F3', '#E91E63', '#9C27B0', '#4CAF50',
  '#00BCD4', '#F44336', '#FF5722', '#795548', '#607D8B',
  '#3F51B5', '#009688', '#FFC107', '#FFEB3B', '#9E9E9E',
];

class _AddCategoryDialog extends StatefulWidget {
  final bool isExpense;
  final bool isOther;
  final Function(String name, String icon, String color) onConfirm;

  const _AddCategoryDialog({
    required this.isExpense,
    required this.isOther,
    required this.onConfirm,
  });

  @override
  State<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<_AddCategoryDialog> {
  final _nameController = TextEditingController();
  String _selectedIcon = '📦';
  String _selectedColor = '#607D8B';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typeLabel = widget.isOther ? l10n.entryOther : (widget.isExpense ? l10n.entryExpense : l10n.entryIncome);

    return AlertDialog(
      title: Text(l10n.catManageAddTitle(typeLabel)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 名称输入
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.catManageNameLabel,
                hintText: l10n.catManageNameHint,
              ),
              maxLength: 20,
            ),
            const SizedBox(height: 16),
            // 图标选择
            Text(l10n.catManageSelectIcon, style: context.textStyles.footnote.copyWith(color: context.colors.textTertiary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _emojiOptions.map((emoji) {
                final isSelected = _selectedIcon == emoji;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = emoji),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected ? context.colors.primarySurface : context.colors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected ? Border.all(color: context.colors.primary, width: 2) : null,
                    ),
                    child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // 颜色选择
            Text(l10n.catManageSelectColor, style: context.textStyles.footnote.copyWith(color: context.colors.textTertiary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colorOptions.map((hex) {
                final color = Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16));
                final isSelected = _selectedColor == hex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = hex),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: context.colors.textPrimary, width: 3)
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.catManageNameHint), duration: const Duration(milliseconds: 500)),
              );
              return;
            }
            Navigator.of(context).pop();
            widget.onConfirm(name, _selectedIcon, _selectedColor);
          },
          child: Text(l10n.commonConfirm),
        ),
      ],
    );
  }
}

// ==================== 添加子分类对话框 ====================

class _AddSubCategoryDialog extends StatefulWidget {
  final String parentName;
  final Function(String name, String icon) onConfirm;

  const _AddSubCategoryDialog({
    required this.parentName,
    required this.onConfirm,
  });

  @override
  State<_AddSubCategoryDialog> createState() => _AddSubCategoryDialogState();
}

class _AddSubCategoryDialogState extends State<_AddSubCategoryDialog> {
  final _nameController = TextEditingController();
  String _selectedIcon = '📦';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.catManageAddSubTitle(widget.parentName)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.catManageSubNameLabel,
                hintText: l10n.catManageSubNameHint,
              ),
              maxLength: 20,
            ),
            const SizedBox(height: 16),
            Text(l10n.catManageSelectIcon, style: context.textStyles.footnote.copyWith(color: context.colors.textTertiary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _emojiOptions.map((emoji) {
                final isSelected = _selectedIcon == emoji;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = emoji),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected ? context.colors.primarySurface : context.colors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected ? Border.all(color: context.colors.primary, width: 2) : null,
                    ),
                    child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.catManageSubNameHint), duration: const Duration(milliseconds: 500)),
              );
              return;
            }
            Navigator.of(context).pop();
            widget.onConfirm(name, _selectedIcon);
          },
          child: Text(l10n.commonConfirm),
        ),
      ],
    );
  }
}

// ==================== 编辑分类对话框（BUG-8 新增） ====================

class _EditCategoryDialog extends StatefulWidget {
  final Category category;
  final Function(String name, String icon, String color) onConfirm;

  const _EditCategoryDialog({
    required this.category,
    required this.onConfirm,
  });

  @override
  State<_EditCategoryDialog> createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<_EditCategoryDialog> {
  late final TextEditingController _nameController;
  late String _selectedIcon;
  late String _selectedColor;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _selectedIcon = widget.category.icon ?? '📦';
    _selectedColor = widget.category.color;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.catManageEditTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.catManageNameLabel,
                hintText: l10n.catManageNameHint,
              ),
              maxLength: 20,
            ),
            const SizedBox(height: 16),
            Text(l10n.catManageSelectIcon, style: context.textStyles.footnote.copyWith(color: context.colors.textTertiary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _emojiOptions.map((emoji) {
                final isSelected = _selectedIcon == emoji;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = emoji),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected ? context.colors.primarySurface : context.colors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected ? Border.all(color: context.colors.primary, width: 2) : null,
                    ),
                    child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(l10n.catManageSelectColor, style: context.textStyles.footnote.copyWith(color: context.colors.textTertiary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colorOptions.map((hex) {
                final color = Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16));
                final isSelected = _selectedColor == hex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = hex),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: context.colors.textPrimary, width: 3)
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.catManageNameHint), duration: const Duration(milliseconds: 500)),
              );
              return;
            }
            Navigator.of(context).pop();
            widget.onConfirm(name, _selectedIcon, _selectedColor);
          },
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
