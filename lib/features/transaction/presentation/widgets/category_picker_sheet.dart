import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  List<Category> _allCategories = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _isExpense = widget.initialIsExpense;
    _selectedId = widget.selectedCategoryId;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final catRepo = ref.read(categoryRepositoryProvider);
    final cats = await catRepo.getAll();
    if (mounted) setState(() => _allCategories = cats);
  }

  List<Category> get _topLevel {
    var cats = _allCategories.where((c) => c.parentId == null && c.level == 1).toList();
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

  List<Category> _childrenOf(int parentId) {
    return _allCategories.where((c) => c.parentId == parentId).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return AppColors.textTertiary;
    final clean = hex.replaceFirst('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.surface,
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
              color: AppColors.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 标题 + 收支切换
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Text('选择分类', style: AppTextStyles.h3),
                const Spacer(),
                _buildTypeToggle(),
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
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                style: AppTextStyles.footnote,
                decoration: InputDecoration(
                  hintText: '搜索分类...',
                  hintStyle: AppTextStyles.footnote.copyWith(color: AppColors.textHint),
                  prefixIcon: Icon(Icons.search, size: 18, color: AppColors.textTertiary),
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
                        Icon(Icons.arrow_back, size: 18, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text('返回', style: AppTextStyles.footnote.copyWith(color: AppColors.primary)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _allCategories.firstWhere((c) => c.id == _expandedParentId, orElse: () => _topLevel.first).name,
                    style: AppTextStyles.footnote.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          if (_expandedParentId != null) const SizedBox(height: 8),
          // 分类网格
          Expanded(
            child: _expandedParentId != null
                ? _buildChildGrid(_expandedParentId!)
                : _buildTopGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleBtn('支出', _isExpense, () => setState(() {
            _isExpense = true;
            _expandedParentId = null;
          })),
          _toggleBtn('收入', !_isExpense, () => setState(() {
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
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: active ? Colors.white : AppColors.textSecondary,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildTopGrid() {
    final cats = _topLevel;
    if (cats.isEmpty) {
      return Center(child: Text('暂无分类', style: AppTextStyles.footnote.copyWith(color: AppColors.textTertiary)));
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
        final children = _childrenOf(cat.id);
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

  Widget _buildChildGrid(int parentId) {
    final children = _childrenOf(parentId);
    if (children.isEmpty) {
      return Center(child: Text('暂无子分类', style: AppTextStyles.footnote.copyWith(color: AppColors.textTertiary)));
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
                  border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
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
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
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
            style: AppTextStyles.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
