import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../config/database/app_database.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/locale/category_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/toast.dart';
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
        title: Text(_selectedParent != null ? l10n.catManageSubTitle(getCategoryDisplayName(_selectedParent!, l10n)) : l10n.catManageTitle),
        leading: _selectedParent != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _selectedParent = null),
              )
            : null,
      ),
      body: _selectedParent != null
          ? _buildSubCategoryList()
          : _buildCategoryView(),
    );
  }

  /// 分类视图（带类型切换）
  Widget _buildCategoryView() {
    return Column(
      children: [
        _buildTypeTabs(),
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
                onTap: () => setState(() => _selectedParent = cat),
                onLongPress: !cat.isSystem
                    ? () => _onEditCategory(cat)
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
                  onLongPress: !sub.isSystem
                      ? () => _onEditCategory(sub)
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddCategorySheet(
        isExpense: isExpense,
        isOther: isOther,
        onConfirm: (name, icon) async {
          try {
            if (!mounted) return false;
            final existing = await _catRepo.getByName(name);
            if (!mounted) return false;
            if (existing != null) {
              AppToast.show(context, AppLocalizations.of(context)!.catManageNameExists, duration: const Duration(milliseconds: 800));
              return false;
            }

            final allTopLevel = await _catRepo.getTopLevel();
            if (!mounted) return false;
            final maxSort = allTopLevel.isEmpty ? 0 : allTopLevel.map((c) => c.sortOrder).reduce((a, b) => a > b ? a : b);
            final randomColor = _colorOptions[DateTime.now().millisecondsSinceEpoch % _colorOptions.length];
            await _catRepo.insert(CategoriesCompanion.insert(
              name: name,
              icon: Value(icon),
              color: Value(randomColor),
              level: const Value(1),
              isSystem: const Value(false),
              isExpense: Value(isExpense && !isOther),
              sortOrder: Value(maxSort + 1),
            ));
            return true;
          } catch (_) {
            return false;
          }
        },
      ),
    );
  }

  void _onAddSubCategory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddSubCategorySheet(
        parentName: _selectedParent!.name,
        onConfirm: (name, icon) async {
          try {
            if (!mounted) return false;
            final existing = await _catRepo.getByName(name);
            if (!mounted) return false;
            if (existing != null) {
              AppToast.show(context, AppLocalizations.of(context)!.catManageSubNameExists, duration: const Duration(milliseconds: 800));
              return false;
            }

            final children = await _catRepo.getChildren(_selectedParent!.id);
            if (!mounted) return false;
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
            return true;
          } catch (_) {
            return false;
          }
        },
      ),
    );
  }

  void _onEditCategory(Category cat) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditCategorySheet(
        category: cat,
        onConfirm: (name, icon) async {
          try {
            final existing = await _catRepo.getByName(name);
            if (!mounted) return false;
            if (existing != null && existing.id != cat.id) {
              AppToast.show(context, l10n.catManageNameExists, duration: const Duration(milliseconds: 800));
              return false;
            }
            final success = await _catRepo.update(CategoriesCompanion(
              id: Value(cat.id),
              name: Value(name),
              icon: Value(icon),
              color: Value(cat.color),
              isExpense: Value(cat.isExpense),
              level: Value(cat.level),
              sortOrder: Value(cat.sortOrder),
              parentId: Value(cat.parentId),
            ));
            return success;
          } catch (_) {
            return false;
          }
        },
        onDelete: () async {
          try {
            final children = await _catRepo.getChildren(cat.id);
            if (!mounted) return false;
            final bool success;
            if (children.isNotEmpty) {
              success = await _catRepo.deleteWithChildren(cat.id);
            } else {
              success = await _catRepo.delete(cat.id);
            }
            if (!success && mounted) {
              AppToast.show(context, l10n.catManageDeleteBlocked, duration: const Duration(milliseconds: 800));
            }
            return success;
          } catch (_) {
            return false;
          }
        },
      ),
    );
  }
}

/// 分类网格项
class _CategoryGridItem extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _CategoryGridItem({
    required this.category,
    required this.onTap,
    this.onLongPress,
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
            ],
          ),
          const SizedBox(height: 4),
          Text(
            getCategoryDisplayName(category, AppLocalizations.of(context)!),
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
  final VoidCallback? onLongPress;

  const _SubCategoryListItem({
    required this.category,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
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
              child: Text(getCategoryDisplayName(category, AppLocalizations.of(context)!), style: context.textStyles.body),
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
          ],
        ),
      ),
    );
  }
}

// ==================== 添加分类底部弹窗 ====================

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

class _AddCategorySheet extends StatefulWidget {
  final bool isExpense;
  final bool isOther;
  final Future<bool> Function(String name, String icon) onConfirm;

  const _AddCategorySheet({
    required this.isExpense,
    required this.isOther,
    required this.onConfirm,
  });

  @override
  State<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<_AddCategorySheet> {
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
    final typeLabel = widget.isOther ? l10n.entryOther : (widget.isExpense ? l10n.entryExpense : l10n.entryIncome);

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppDimensions.md,
        8,
        AppDimensions.md,
        MediaQuery.viewInsetsOf(context).bottom + AppDimensions.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽指示条
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: context.colors.textTertiary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // 标题居中
          Text(
            l10n.catManageAddTitle(typeLabel),
            style: AppTextStyles.h3.copyWith(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // 名称输入
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.catManageNameLabel,
              hintText: l10n.catManageNameHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 图标选择标签
          Align(
            alignment: Alignment.centerLeft,
            child: Text(l10n.catManageSelectIcon, style: context.textStyles.footnote.copyWith(color: context.colors.textTertiary)),
          ),
          const SizedBox(height: 8),
          // 横向滚动图标选择
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _emojiOptions.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final emoji = _emojiOptions[index];
                final isSelected = _selectedIcon == emoji;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = emoji),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected ? context.colors.primarySurface : context.colors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected ? Border.all(color: context.colors.primary, width: 2) : null,
                    ),
                    child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          // 确认按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final name = _nameController.text.trim();
                if (name.isEmpty) {
                  AppToast.show(context, l10n.catManageNameHint, duration: const Duration(milliseconds: 500));
                  return;
                }
                final success = await widget.onConfirm(name, _selectedIcon);
                if (success && context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: context.colors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
              ),
              child: Text(l10n.commonConfirm, style: AppTextStyles.body.copyWith(
                color: context.colors.textOnPrimary,
                fontWeight: FontWeight.w600,
              )),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 添加子分类底部弹窗 ====================

class _AddSubCategorySheet extends StatefulWidget {
  final String parentName;
  final Future<bool> Function(String name, String icon) onConfirm;

  const _AddSubCategorySheet({
    required this.parentName,
    required this.onConfirm,
  });

  @override
  State<_AddSubCategorySheet> createState() => _AddSubCategorySheetState();
}

class _AddSubCategorySheetState extends State<_AddSubCategorySheet> {
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
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppDimensions.md,
        8,
        AppDimensions.md,
        MediaQuery.viewInsetsOf(context).bottom + AppDimensions.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽指示条
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: context.colors.textTertiary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // 标题居中
          Text(
            l10n.catManageAddSubTitle(widget.parentName),
            style: AppTextStyles.h3.copyWith(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // 名称输入
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.catManageSubNameLabel,
              hintText: l10n.catManageSubNameHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
            ),
            maxLength: 20,
          ),
          const SizedBox(height: 16),
          // 图标选择标签
          Align(
            alignment: Alignment.centerLeft,
            child: Text(l10n.catManageSelectIcon, style: context.textStyles.footnote.copyWith(color: context.colors.textTertiary)),
          ),
          const SizedBox(height: 8),
          // 横向滚动图标选择
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _emojiOptions.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final emoji = _emojiOptions[index];
                final isSelected = _selectedIcon == emoji;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = emoji),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected ? context.colors.primarySurface : context.colors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected ? Border.all(color: context.colors.primary, width: 2) : null,
                    ),
                    child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          // 确认按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final name = _nameController.text.trim();
                if (name.isEmpty) {
                  AppToast.show(context, l10n.catManageSubNameHint, duration: const Duration(milliseconds: 500));
                  return;
                }
                final success = await widget.onConfirm(name, _selectedIcon);
                if (success && context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: context.colors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
              ),
              child: Text(l10n.commonConfirm, style: AppTextStyles.body.copyWith(
                color: context.colors.textOnPrimary,
                fontWeight: FontWeight.w600,
              )),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 编辑分类底部弹窗 ====================

class _EditCategorySheet extends StatefulWidget {
  final Category category;
  final Future<bool> Function(String name, String icon) onConfirm;
  final Future<bool> Function() onDelete;

  const _EditCategorySheet({
    required this.category,
    required this.onConfirm,
    required this.onDelete,
  });

  @override
  State<_EditCategorySheet> createState() => _EditCategorySheetState();
}

class _EditCategorySheetState extends State<_EditCategorySheet> {
  late final TextEditingController _nameController;
  late String _selectedIcon;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _selectedIcon = widget.category.icon ?? '📦';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppDimensions.md,
        8,
        AppDimensions.md,
        MediaQuery.viewInsetsOf(context).bottom + AppDimensions.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽指示条
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: context.colors.textTertiary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // 标题居中
          Text(
            l10n.catManageEditTitle,
            style: AppTextStyles.h3.copyWith(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // 名称输入
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.catManageNameLabel,
              hintText: l10n.catManageNameHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 图标选择标签
          Align(
            alignment: Alignment.centerLeft,
            child: Text(l10n.catManageSelectIcon, style: context.textStyles.footnote.copyWith(color: context.colors.textTertiary)),
          ),
          const SizedBox(height: 8),
          // 横向滚动图标选择
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _emojiOptions.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final emoji = _emojiOptions[index];
                final isSelected = _selectedIcon == emoji;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = emoji),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected ? context.colors.primarySurface : context.colors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected ? Border.all(color: context.colors.primary, width: 2) : null,
                    ),
                    child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          // 删除 + 保存（左右布局）
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final success = await widget.onDelete();
                    if (success && context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: context.colors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    ),
                  ),
                  child: Text(l10n.commonDelete, style: AppTextStyles.body.copyWith(
                    color: context.colors.error,
                    fontWeight: FontWeight.w600,
                  )),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final name = _nameController.text.trim();
                    if (name.isEmpty) {
                      AppToast.show(context, l10n.catManageNameHint, duration: const Duration(milliseconds: 500));
                      return;
                    }
                    final success = await widget.onConfirm(name, _selectedIcon);
                    if (success && context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: context.colors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    ),
                  ),
                  child: Text(l10n.commonSave, style: AppTextStyles.body.copyWith(
                    color: context.colors.textOnPrimary,
                    fontWeight: FontWeight.w600,
                  )),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
