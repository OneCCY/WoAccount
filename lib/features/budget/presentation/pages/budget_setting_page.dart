import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
// ignore: unused_import
import '../../domain/repositories/budget_repository.dart';

/// 预算设置页
/// 总预算 + 分类预算列表 + 添加
class BudgetSettingPage extends ConsumerStatefulWidget {
  const BudgetSettingPage({super.key});

  @override
  ConsumerState<BudgetSettingPage> createState() => _BudgetSettingPageState();
}

class _BudgetSettingPageState extends ConsumerState<BudgetSettingPage> {
  late final BudgetRepository _budgetRepo;
  late final int _bookId;
  final now = DateTime.now();
  List<BudgetProgress> _progresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _budgetRepo = ref.read(budgetRepositoryProvider);
    _bookId = ref.read(currentBookProvider);
    _loadData();
  }

  Future<void> _loadData() async {
    final progresses = await _budgetRepo.getBudgetProgress(_bookId, now.year, now.month);
    setState(() {
      _progresses = progresses;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalBudget = _progresses
        .where((p) => p.budget.categoryId == null)
        .fold<double>(0, (sum, p) => sum + p.budget.amount);
    final totalSpent = _progresses
        .where((p) => p.budget.categoryId == null)
        .fold<double>(0, (sum, p) => sum + p.spent);
    final categoryProgresses =
        _progresses.where((p) => p.budget.categoryId != null).toList();

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(title: const Text('预算设置')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // 总预算显示
                  Text(
                    '¥${totalBudget.toStringAsFixed(0)}',
                    style: context.textStyles.amountLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '已设置 ${categoryProgresses.length} 个分类预算',
                    style: context.textStyles.caption,
                  ),

                  const SizedBox(height: 16),

                  // 使用进度
                  if (totalBudget > 0) _buildUsageBar(totalBudget, totalSpent),

                  const SizedBox(height: 24),

                  // 分类预算列表
                  ...categoryProgresses.map((p) => _buildCategoryBudgetItem(context, p)),

                  // 添加按钮
                  Padding(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    child: OutlinedButton.icon(
                      onPressed: _onAddCategoryBudget,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('添加分类预算'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        side: BorderSide(color: context.colors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildUsageBar(double total, double spent) {
    final percentage = total > 0 ? (spent / total * 100) : 0.0;
    final barColor = percentage > 90
        ? context.colors.error
        : percentage > 70
            ? context.colors.warning
            : context.colors.success;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (percentage / 100).clamp(0, 1),
                minHeight: 10,
                backgroundColor: context.colors.surfaceSecondary,
                valueColor: AlwaysStoppedAnimation(barColor),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('已使用 ${percentage.toStringAsFixed(1)}%', style: context.textStyles.caption),
                Text('剩余 ¥${(total - spent).toStringAsFixed(0)}', style: context.textStyles.caption),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBudgetItem(BuildContext context, BudgetProgress progress) {
    final cat = progress.category;
    final color = _parseColor(context, cat?.color);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: 4,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: Center(
                child: Text(cat?.icon ?? '📦', style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cat?.name ?? '未分类', style: context.textStyles.body),
                  const SizedBox(height: 4),
                  Text(
                    '已消费 ¥${progress.spent.toStringAsFixed(0)}',
                    style: context.textStyles.caption,
                  ),
                ],
              ),
            ),
            Text(
              '¥${progress.budget.amount.toStringAsFixed(0)}',
              style: context.textStyles.amountSmall,
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _onEditBudget(progress),
              child: Icon(Icons.edit_outlined, size: 18, color: context.colors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  void _onAddCategoryBudget() {
    // TODO: 显示分类选择 + 金额输入对话框
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('添加分类预算功能开发中'), behavior: SnackBarBehavior.floating, duration: Duration(milliseconds: 500)),
    );
  }

  void _onEditBudget(BudgetProgress progress) {
    // TODO: 编辑预算金额
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('编辑预算功能开发中'), behavior: SnackBarBehavior.floating, duration: Duration(milliseconds: 500)),
    );
  }

  Color _parseColor(BuildContext context, String? hex) {
    if (hex == null || hex.isEmpty) return context.colors.textTertiary;
    final clean = hex.replaceFirst('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }
}
