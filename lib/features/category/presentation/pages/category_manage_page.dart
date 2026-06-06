import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
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
    final isExpense = _type == CategoryManageType.expense;
    final isOther = _type == CategoryManageType.other;
    showDialog(
      context: context,
      builder: (ctx) => _AddCategoryDialog(
        isExpense: isExpense,
        isOther: isOther,
        onConfirm: (name, icon, color) async {
          final categories = await _catRepo.getTopLevel();
          final maxSort = categories.isEmpty ? 0 : categories.map((c) => c.sortOrder).reduce((a, b) => a > b ? a : b);
          await _catRepo.insert(CategoriesCompanion.insert(
            name: name,
            icon: Value(icon),
            color: Value(color),
            level: const Value(1),
            isSystem: const Value(false),
            isExpense: Value(isExpense && !isOther),
            sortOrder: Value(maxSort + 1),
          ));
          setState(() {});
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
          setState(() {});
        },
      ),
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

// ==================== 添加分类对话框 ====================

const _emojiOptions = [
  '🍜', '🚗', '🛒', '🏠', '🎮', '📚', '💊', '👤', '🐾', '💰',
  '💼', '🎁', '📈', '↩️', '💻', '🔄', '💳', '🤝', '🍔', '☕',
  '🎬', '✈️', '🏋️', '🎵', '📱', '👕', '💄', '🔧', '📦', '🌟',
];

const _colorOptions = [
  '#FF9800', '#2196F3', '#E91E63', '#9C27B0', '#4CAF50',
  '#00BCD4', '#F44336', '#FF5722', '#795548', '#607D8B',
  '#3F51B5', '#009688', '#FFC107', '#795548', '#9E9E9E',
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
    final typeLabel = widget.isOther ? '其他' : (widget.isExpense ? '支出' : '收入');

    return AlertDialog(
      title: Text('添加$typeLabel分类'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 名称输入
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '分类名称',
                hintText: '请输入分类名称',
              ),
              maxLength: 20,
            ),
            const SizedBox(height: 16),
            // 图标选择
            Text('选择图标', style: AppTextStyles.footnote.copyWith(color: AppColors.textTertiary)),
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
                      color: isSelected ? AppColors.primarySurface : AppColors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
                    ),
                    child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // 颜色选择
            Text('选择颜色', style: AppTextStyles.footnote.copyWith(color: AppColors.textTertiary)),
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
                          ? Border.all(color: AppColors.textPrimary, width: 3)
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
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('请输入分类名称'), duration: Duration(milliseconds: 500)),
              );
              return;
            }
            Navigator.of(context).pop();
            widget.onConfirm(name, _selectedIcon, _selectedColor);
          },
          child: const Text('确定'),
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
    return AlertDialog(
      title: Text('添加子分类 - ${widget.parentName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '子分类名称',
                hintText: '请输入子分类名称',
              ),
              maxLength: 20,
            ),
            const SizedBox(height: 16),
            Text('选择图标', style: AppTextStyles.footnote.copyWith(color: AppColors.textTertiary)),
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
                      color: isSelected ? AppColors.primarySurface : AppColors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
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
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('请输入子分类名称'), duration: Duration(milliseconds: 500)),
              );
              return;
            }
            Navigator.of(context).pop();
            widget.onConfirm(name, _selectedIcon);
          },
          child: const Text('确定'),
        ),
      ],
    );
  }
}
