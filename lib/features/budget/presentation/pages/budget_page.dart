import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
// ignore: unused_import
import '../../domain/repositories/budget_repository.dart';

/// 预算管理页
/// 总额卡片 + 分类预算列表
class BudgetPage extends ConsumerWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final repo = ref.read(budgetRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('预算管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/budget/setting'),
          ),
        ],
      ),
      body: FutureBuilder<List<BudgetProgress>>(
        future: repo.getBudgetProgress(now.year, now.month),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final progresses = snapshot.data ?? [];
          final totalBudget = progresses
              .where((p) => p.budget.categoryId == null)
              .fold<double>(0, (sum, p) => sum + p.budget.amount);
          final totalSpent = progresses
              .where((p) => p.budget.categoryId == null)
              .fold<double>(0, (sum, p) => sum + p.spent);
          final categoryProgresses =
              progresses.where((p) => p.budget.categoryId != null).toList();

          if (progresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.account_balance_wallet_outlined, size: 48, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  Text('暂未设置预算', style: AppTextStyles.callout.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => context.push('/budget/setting'),
                    child: const Text('设置预算'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),

                // 总预算卡片
                _buildTotalCard(totalBudget, totalSpent),

                // 超支警告
                if (categoryProgresses.any((p) => p.isOverBudget))
                  _buildOverBudgetWarning(categoryProgresses),

                const SizedBox(height: 16),

                // 分类预算列表
                ...categoryProgresses.map(_buildCategoryItem),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTotalCard(double total, double spent) {
    final percentage = total > 0 ? (spent / total * 100) : 0.0;
    final remaining = total - spent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF3E0), Color(0xFFFFECB3)],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('本月总预算', style: AppTextStyles.footnote.copyWith(color: const Color(0xFFE65100))),
            const SizedBox(height: 8),
            Text(
              '¥${total.toStringAsFixed(0)}',
              style: AppTextStyles.amountLarge.copyWith(color: const Color(0xFFE65100)),
            ),
            const SizedBox(height: 12),
            // 进度条
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (percentage / 100).clamp(0, 1),
                minHeight: 8,
                backgroundColor: const Color(0x33E65100),
                valueColor: AlwaysStoppedAnimation(
                  percentage > 90 ? AppColors.error : AppColors.warning,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('已消费 ¥${spent.toStringAsFixed(0)}', style: AppTextStyles.caption),
                Text('剩余 ¥${remaining.toStringAsFixed(0)}', style: AppTextStyles.caption),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverBudgetWarning(List<BudgetProgress> progresses) {
    final overBudget = progresses.where((p) => p.isOverBudget).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.md, 12, AppDimensions.md, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber, size: 18, color: AppColors.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${overBudget.first.category?.name ?? '某分类'}预算已超支 ¥${(overBudget.first.spent - overBudget.first.budget.amount).toStringAsFixed(0)}',
                style: AppTextStyles.caption.copyWith(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BudgetProgress progress) {
    final cat = progress.category;
    final color = _parseColor(cat?.color);
    final percentage = progress.percentage;
    final barColor = percentage > 90
        ? AppColors.error
        : percentage > 70
            ? AppColors.warning
            : AppColors.success;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: 4,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // 图标
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
                // 名称 + 进度条
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(cat?.name ?? '未分类', style: AppTextStyles.body),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: AppTextStyles.caption.copyWith(color: barColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (percentage / 100).clamp(0, 1),
                          minHeight: 6,
                          backgroundColor: AppColors.surfaceSecondary,
                          valueColor: AlwaysStoppedAnimation(barColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // 金额
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '¥${progress.spent.toStringAsFixed(0)}',
                      style: AppTextStyles.amountSmall.copyWith(
                        color: progress.isOverBudget ? AppColors.error : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '/ ¥${progress.budget.amount.toStringAsFixed(0)}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return AppColors.textTertiary;
    final clean = hex.replaceFirst('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }
}
