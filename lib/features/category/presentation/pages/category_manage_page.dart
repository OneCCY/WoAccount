import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_selectedParent != null ? '${_selectedParent!.name} - 子分类' : '分类管理'),
        leading: _selectedParent != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _selectedParent = null),
              )
            : null,
        actions: [
          if (_selectedParent == null)
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
              color: AppColors.surface,
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: () => setState(() => _isEditMode = false),
                  child: const Text('完成'),
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
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      child: Row(
        children: CategoryManageType.values.map((type) {
          final isActive = _type == type;
          final label = switch (type) {
            CategoryManageType.expense => '支出',
            CategoryManageType.income => '收入',
            CategoryManageType.other => '其他',
          };
          return GestureDetector(
            onTap: () => setState(() => _type = type),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                border: isActive
                    ? const Border(bottom: BorderSide(color: AppColors.primary, width: 2))
                    : null,
              ),
              child: Text(
                label,
                style: AppTextStyles.callout.copyWith(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return FutureBuilder<List<Category>>(
      future: _catRepo.getTopLevel(),
      builder: (context, snapshot) {
        final allCategories = snapshot.data ?? [];
        final categories = _filterCategories(allCategories);

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
              border: Border.all(color: AppColors.textHint, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: const Center(
              child: Icon(Icons.add, size: 24, color: AppColors.textHint),
            ),
          ),
          const SizedBox(height: 4),
          Text('添加', style: AppTextStyles.caption),
        ],
      ),
    );
  }

  /// 子分类列表
  Widget _buildSubCategoryList() {
    return FutureBuilder<List<Category>>(
      future: _catRepo.getChildren(_selectedParent!.id),
      builder: (context, snapshot) {
        final children = snapshot.data ?? [];

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
                label: const Text('添加子分类'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: AppColors.primary),
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

  List<Category> _filterCategories(List<Category> categories) {
    switch (_type) {
      case CategoryManageType.expense:
        return categories.where((c) => c.isExpense).toList();
      case CategoryManageType.income:
        return categories.where((c) => !c.isExpense && !['转账', '还款', '人情'].contains(c.name)).toList();
      case CategoryManageType.other:
        return categories.where((c) => ['转账', '还款', '人情'].contains(c.name)).toList();
    }
  }

  void _onAddCategory() {
    // TODO: 添加分类对话框
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('添加分类功能开发中'), behavior: SnackBarBehavior.floating),
    );
  }

  void _onAddSubCategory() {
    // TODO: 添加子分类对话框
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('添加子分类功能开发中'), behavior: SnackBarBehavior.floating),
    );
  }

  void _onDeleteCategory(Category cat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除分类"${cat.name}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _catRepo.delete(cat.id);
              setState(() {});
            },
            child: Text('删除', style: TextStyle(color: AppColors.error)),
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
  final VoidCallback? onDelete;

  const _CategoryGridItem({
    required this.category,
    required this.isEditMode,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(category.color);

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
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('自', style: AppTextStyles.caption.copyWith(
                      color: AppColors.textOnPrimary,
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
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.close, size: 10, color: AppColors.textOnPrimary),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            category.name,
            style: AppTextStyles.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return AppColors.textTertiary;
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
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.separatorOpaque, width: 0.5)),
      ),
      child: Row(
        children: [
          Text(category.icon ?? '📦', style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(category.name, style: AppTextStyles.body),
          ),
          if (!category.isSystem)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('自定义', style: AppTextStyles.caption.copyWith(color: AppColors.primaryDark)),
            ),
          if (isEditMode && onDelete != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDelete,
              child: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
            ),
          ],
        ],
      ),
    );
  }
}
