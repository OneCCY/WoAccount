import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../config/database/app_database.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 分类选择 BottomSheet
class CategoryPickerSheet extends ConsumerStatefulWidget {
  final bool initialIsExpense;
  final int? selectedCategoryId;

  const CategoryPickerSheet({
    super.key,
    required this.initialIsExpense,
    this.selectedCategoryId,
  });

  /// 显示分类选择 Sheet，返回选中的 Category，取消返回 null
  static Future<Category?> show(BuildContext context, {
    required bool initialIsExpense,
    int? selectedCategoryId,
  }) {
    return showModalBottomSheet<Category>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CategoryPickerSheet(
        initialIsExpense: initialIsExpense,
        selectedCategoryId: selectedCategoryId,
      ),
    );
  }

  @override
  ConsumerState<CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends ConsumerState<CategoryPickerSheet> {
  late bool _isExpense;
  int? _selectedId;
  int? _expandedParentId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _isExpense = widget.initialIsExpense;
    _selectedId = widget.selectedCategoryId;
  }

  List<Category> _filterTopLevel(List<Category> allCategories) {
    // BUG-6 修复：统一使用 c.level == 1 过滤顶层分类（与 repository 一致）
    var cats = allCategories.where((c) => c.level == 1).toList();
    if (_isExpense) {
      cats = cats.where((c) => c.isExpense).toList();
    } else {
      cats = cats.where((c) => !c.isExpense).toList();
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
                        allCategories.firstWhere((c) => c.id == _expandedParentId, orElse: () => _filterTopLevel(allCategories).first).name,
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
          _toggleBtn(l10n.entryExpense, _isExpense, () => setState(() {
            _isExpense = true;
            _expandedParentId = null;
          })),
          _toggleBtn(l10n.entryIncome, !_isExpense, () => setState(() {
            _isExpense = false;
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
    if (cats.isEmpty) {
      return Center(child: Text(l10n.txnCategoryEmpty, style: context.textStyles.footnote.copyWith(color: context.colors.textTertiary)));
    }
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: cats.length,
      itemBuilder: (context, index) {
        final cat = cats[index];
        final children = _childrenOf(allCategories, cat.id);
        final isSelected = _selectedId == cat.id;
        final hasChildren = children.isNotEmpty;
        return _CategoryTile(
          icon: cat.icon ?? '📦',
          name: cat.name,
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
    if (children.isEmpty) {
      return Center(child: Text(l10n.chatPageNoSubcategory, style: context.textStyles.footnote.copyWith(color: context.colors.textTertiary)));
    }
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) {
        final cat = children[index];
        final isSelected = _selectedId == cat.id;
        return _CategoryTile(
          icon: cat.icon ?? '📦',
          name: cat.name,
          color: _parseColor(cat.color),
          isSelected: isSelected,
          onTap: () => Navigator.of(context).pop(cat),
        );
      },
    );
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
