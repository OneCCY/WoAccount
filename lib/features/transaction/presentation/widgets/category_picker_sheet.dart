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

/// 分类选择 BottomSheet
class CategoryPickerSheet extends ConsumerStatefulWidget {
  final bool initialIsExpense;
  final int initialCategoryType; // 0=expense, 1=income, 2=other; -1 = use initialIsExpense
  final int? selectedCategoryId;

  const CategoryPickerSheet({
    super.key,
    required this.initialIsExpense,
    this.initialCategoryType = -1,
    this.selectedCategoryId,
  });

  /// 显示分类选择 Sheet，返回选中的 Category，取消返回 null
  static Future<Category?> show(BuildContext context, {
    required bool initialIsExpense,
    int? selectedCategoryId,
    int initialCategoryType = -1,
  }) {
    return showModalBottomSheet<Category>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CategoryPickerSheet(
        initialIsExpense: initialIsExpense,
        initialCategoryType: initialCategoryType,
        selectedCategoryId: selectedCategoryId,
      ),
    );
  }

  @override
  ConsumerState<CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends ConsumerState<CategoryPickerSheet> {
  late int _categoryType; // 0=expense, 1=income, 2=other
  int? _selectedId;
  int? _expandedParentId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _categoryType = widget.initialCategoryType >= 0
        ? widget.initialCategoryType
        : (widget.initialIsExpense ? 0 : 1);
    _selectedId = widget.selectedCategoryId;
  }

  List<Category> _filterTopLevel(List<Category> allCategories) {
    var cats = allCategories.where((c) => c.level == 1).toList();
    if (_categoryType == 0) {
      // Expense
      cats = cats.where((c) => c.isExpense).toList();
    } else if (_categoryType == 2) {
      // Other — isExpense=false + l10nKey in otherKeys
      const otherKeys = {'catOtherTransfer', 'catOtherRepayment', 'catOtherSocial'};
      cats = cats.where((c) => !c.isExpense && c.l10nKey != null && otherKeys.contains(c.l10nKey)).toList();
    } else {
      // Income — isExpense=false + NOT other
      const otherKeys = {'catOtherTransfer', 'catOtherRepayment', 'catOtherSocial'};
      cats = cats.where((c) => !c.isExpense && (c.l10nKey == null || !otherKeys.contains(c.l10nKey!))).toList();
    }
    if (_searchQuery.isNotEmpty) {
      cats = cats.where((c) => c.name.contains(_searchQuery)).toList();
    }
    cats.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return cats;
  }

  List<Category> _childrenOf(List<Category> allCategories, int parentId) {
    return allCategories.where((c) => c.parentId == parentId).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return context.colors.textTertiary;
    final clean = hex.replaceFirst('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final catRepo = ref.read(categoryRepositoryProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    // BUG-12 修复：使用 StreamBuilder + watchAll() 实时同步
    return StreamBuilder<List<Category>>(
      stream: catRepo.watchAll(),
      builder: (context, snapshot) {
        final allCategories = snapshot.data ?? [];

        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
          child: Column(
            children: [
              // 拖拽把手
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 12),
                decoration: BoxDecoration(
                  color: context.colors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 标题 + 收支切换
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Text(l10n.commonEditCategory, style: context.textStyles.h3),
                    const Spacer(),
                    _buildTypeToggle(l10n),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // 搜索框
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: context.colors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: context.textStyles.footnote,
                    decoration: InputDecoration(
                      hintText: l10n.txnCategorySearch,
                      hintStyle: context.textStyles.footnote.copyWith(color: context.colors.textHint),
                      prefixIcon: Icon(Icons.search, size: 18, color: context.colors.textTertiary),
                      prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // 子分类返回
              if (_expandedParentId != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _expandedParentId = null),
                        child: Row(
                          children: [
                            Icon(Icons.arrow_back, size: 18, color: context.colors.primary),
                            const SizedBox(width: 4),
                            Text(l10n.commonBack, style: context.textStyles.footnote.copyWith(color: context.colors.primary)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        getCategoryDisplayName(allCategories.firstWhere((c) => c.id == _expandedParentId, orElse: () => _filterTopLevel(allCategories).first), AppLocalizations.of(context)!),
                        style: context.textStyles.footnote.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              if (_expandedParentId != null) const SizedBox(height: 8),
              // 分类网格
              Expanded(
                child: _expandedParentId != null
                    ? _buildChildGrid(allCategories, _expandedParentId!, l10n)
                    : _buildTopGrid(allCategories, l10n),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypeToggle(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleBtn(l10n.entryExpense, _categoryType == 0, () => setState(() {
            _categoryType = 0;
            _expandedParentId = null;
          })),
          _toggleBtn(l10n.entryIncome, _categoryType == 1, () => setState(() {
            _categoryType = 1;
            _expandedParentId = null;
          })),
          _toggleBtn(l10n.entryOther, _categoryType == 2, () => setState(() {
            _categoryType = 2;
            _expandedParentId = null;
          })),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? context.colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        child: Text(
          label,
          style: context.textStyles.caption.copyWith(
            color: active ? Colors.white : context.colors.textSecondary,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildTopGrid(List<Category> allCategories, AppLocalizations l10n) {
    final cats = _filterTopLevel(allCategories);
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: cats.length + 1, // +1 for the add button
      itemBuilder: (context, index) {
        if (index == cats.length) {
          return _CategoryTile(
            icon: '➕',
            name: AppLocalizations.of(context)!.commonAdd,
            color: context.colors.textTertiary,
            isSelected: false,
            onTap: () => _showAddCategoryDialog(null),
          );
        }
        final cat = cats[index];
        final children = _childrenOf(allCategories, cat.id);
        final isSelected = _selectedId == cat.id;
        final hasChildren = children.isNotEmpty;
        return _CategoryTile(
          icon: cat.icon ?? '📦',
          name: getCategoryDisplayName(cat, AppLocalizations.of(context)!),
          color: _parseColor(cat.color),
          isSelected: isSelected,
          hasChildren: hasChildren,
          onTap: () {
            if (hasChildren) {
              setState(() => _expandedParentId = cat.id);
            } else {
              Navigator.of(context).pop(cat);
            }
          },
        );
      },
    );
  }

  Widget _buildChildGrid(List<Category> allCategories, int parentId, AppLocalizations l10n) {
    final children = _childrenOf(allCategories, parentId);
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: children.length + 1, // +1 for the add button
      itemBuilder: (context, index) {
        if (index == children.length) {
          return _CategoryTile(
            icon: '➕',
            name: AppLocalizations.of(context)!.commonAdd,
            color: context.colors.textTertiary,
            isSelected: false,
            onTap: () => _showAddCategoryDialog(parentId),
          );
        }
        final cat = children[index];
        final isSelected = _selectedId == cat.id;
        return _CategoryTile(
          icon: cat.icon ?? '📦',
          name: getCategoryDisplayName(cat, AppLocalizations.of(context)!),
          color: _parseColor(cat.color),
          isSelected: isSelected,
          onTap: () => Navigator.of(context).pop(cat),
        );
      },
    );
  }

  /// 添加分类弹窗（一级或二级）
  Future<void> _showAddCategoryDialog(int? parentId) async {
    final l10n = AppLocalizations.of(context)!;
    final catRepo = ref.read(categoryRepositoryProvider);
    final isSub = parentId != null;

    // 获取父分类名称（用于子分类标题）
    String parentName = '';
    if (isSub) {
      final parentCat = await catRepo.getById(parentId);
      parentName = parentCat != null ? getCategoryDisplayName(parentCat, l10n) : '';
    }

    final nameController = TextEditingController();
    String selectedIcon = '📦';
    String selectedColor = '#607D8B';

    const emojiOptions = [
      '🍔', '🍜', '🛒', '🚗', '🚌', '🏠', '💊', '📚', '🎮', '👗',
      '💼', '💰', '🎁', '✈️', '🐾', '👶', '📱', '💡', '🏥', '🎓',
      '🎉', '💼', '🔧', '📦', '💳', '🏦', '🎯', '⭐', '❤️', '🔥',
    ];
    const colorOptions = [
      '#F44336', '#E91E63', '#9C27B0', '#673AB7', '#3F51B5',
      '#2196F3', '#00BCD4', '#009688', '#4CAF50', '#8BC34A',
      '#FF9800', '#FF5722', '#795548', '#607D8B', '#9E9E9E',
    ];

    final result = await showDialog<(String, String, String)>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isSub ? l10n.catManageAddSubTitle(parentName) : l10n.catManageAddTitle(l10n.catManageCustom)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  maxLength: 20,
                  decoration: InputDecoration(
                    hintText: isSub ? l10n.catManageSubNameHint : l10n.catManageNameHint,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSm)),
                  ),
                ),
                const SizedBox(height: 12),
                Text(l10n.catManageSelectIcon, style: context.textStyles.caption.copyWith(color: context.colors.textTertiary)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: emojiOptions.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 6),
                    itemBuilder: (_, i) {
                      final emoji = emojiOptions[i];
                      final isSelected = selectedIcon == emoji;
                      return GestureDetector(
                        onTap: () => setDialogState(() => selectedIcon = emoji),
                        child: Container(
                          width: 40, height: 40,
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
                const SizedBox(height: 12),
                Text(l10n.catManageSelectColor, style: context.textStyles.caption.copyWith(color: context.colors.textTertiary)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: colorOptions.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 6),
                    itemBuilder: (_, i) {
                      final hex = colorOptions[i];
                      final color = Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16));
                      final isSelected = selectedColor == hex;
                      return GestureDetector(
                        onTap: () => setDialogState(() => selectedColor = hex),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected ? Border.all(color: color, width: 2) : null,
                          ),
                          child: Center(
                            child: Container(
                              width: 16, height: 16,
                              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.commonCancel)),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(ctx, (name, selectedIcon, selectedColor));
              },
              child: Text(l10n.commonAdd),
            ),
          ],
        ),
      ),
    );

    if (result == null || !mounted) return;

    // 检查名称是否重复
    final existingCats = await catRepo.getAll();
    final duplicate = existingCats.any((c) => c.name == result.$1 && (isSub ? c.parentId == parentId : c.parentId == null));
    if (duplicate) {
      if (mounted) AppToast.show(context, isSub ? l10n.catManageSubNameExists : l10n.catManageNameExists);
      return;
    }

    // 确定 sortOrder 和 level
    final level = isSub ? 2 : 1;
    final siblings = existingCats.where((c) => isSub ? c.parentId == parentId : c.parentId == null).toList();
    final maxOrder = siblings.isEmpty ? 0 : siblings.map((c) => c.sortOrder).reduce((a, b) => a > b ? a : b);
    if (!mounted) return;

    await catRepo.insert(CategoriesCompanion.insert(
      name: result.$1,
      icon: Value(result.$2),
      color: Value(result.$3),
      isExpense: Value(_categoryType == 0),
      level: Value(level),
      sortOrder: Value(maxOrder + 1),
      parentId: Value(parentId),
    ));

    if (mounted) AppToast.show(context, l10n.catManageAddTitle(l10n.catManageCustom));
  }
}

class _CategoryTile extends StatelessWidget {
  final String icon;
  final String name;
  final Color color;
  final bool isSelected;
  final bool hasChildren;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.icon,
    required this.name,
    required this.color,
    required this.isSelected,
    this.hasChildren = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                  border: isSelected ? Border.all(color: context.colors.primary, width: 2) : null,
                ),
                child: Center(child: Text(icon, style: const TextStyle(fontSize: 22))),
              ),
              if (hasChildren)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: context.colors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.arrow_forward_ios, size: 8, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: context.textStyles.caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
