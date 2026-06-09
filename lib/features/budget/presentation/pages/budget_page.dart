import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/locale/locale_provider.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final repo = ref.read(budgetRepositoryProvider);
    final bookId = ref.read(currentBookProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(l10n.budgetTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/budget/setting'),
          ),
        ],
      ),
      body: FutureBuilder<List<BudgetProgress>>(
        future: repo.getBudgetProgress(bookId, now.year, now.month),
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
                  Icon(Icons.account_balance_wallet_outlined, size: 48, color: context.colors.textTertiary),
                  const SizedBox(height: 16),
                  Text(l10n.budgetEmpty, style: context.textStyles.callout.copyWith(color: context.colors.textSecondary)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => context.push('/budget/setting'),
                    child: Text(l10n.budgetSetButton),
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
                _buildTotalCard(context, totalBudget, totalSpent),

                // 超支警告
                if (categoryProgresses.any((p) => p.isOverBudget))
                  _buildOverBudgetWarning(context, categoryProgresses),

                const SizedBox(height: 16),

                // 分类预算列表
                ...categoryProgresses.map((p) => _buildCategoryItem(context, p)),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTotalCard(BuildContext context, double total, double spent) {
    final l10n = AppLocalizations.of(context)!;
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
            Text(l10n.budgetMonthlyTotal, style: context.textStyles.footnote.copyWith(color: const Color(0xFFE65100))),
            const SizedBox(height: 8),
            Text(
              context.localeProvider.currency.formatAmount(total, decimals: 0),
              style: context.textStyles.amountLarge.copyWith(color: const Color(0xFFE65100)),
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
                  percentage > 90 ? context.colors.error : context.colors.warning,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.budgetSpent(context.localeProvider.currency.formatAmount(spent, decimals: 0)), style: context.textStyles.caption),
                Text(l10n.budgetRemaining(context.localeProvider.currency.formatAmount(remaining, decimals: 0)), style: context.textStyles.caption),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverBudgetWarning(BuildContext context, List<BudgetProgress> progresses) {
    final l10n = AppLocalizations.of(context)!;
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
            Icon(Icons.warning_amber, size: 18, color: context.colors.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.budgetOverSpent(
                  overBudget.first.category?.name ?? l10n.budgetUnknownCategory,
                  context.localeProvider.currency.formatAmount(overBudget.first.spent - overBudget.first.budget.amount, decimals: 0),
                ),
                style: context.textStyles.caption.copyWith(color: context.colors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, BudgetProgress progress) {
    final cat = progress.category;
    final color = _parseColor(context, cat?.color);
    final percentage = progress.percentage;
    final barColor = percentage > 90
        ? context.colors.error
        : percentage > 70
            ? context.colors.warning
            : context.colors.success;

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
                          Text(cat?.name ?? AppLocalizations.of(context)!.budgetUncategorized, style: context.textStyles.body),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: context.textStyles.caption.copyWith(color: barColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (percentage / 100).clamp(0, 1),
                          minHeight: 6,
                          backgroundColor: context.colors.surfaceSecondary,
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
                      context.localeProvider.currency.formatAmount(progress.spent, decimals: 0),
                      style: context.textStyles.amountSmall.copyWith(
                        color: progress.isOverBudget ? context.colors.error : context.colors.textPrimary,
                      ),
                    ),
                    Text(
                      '/ ${context.localeProvider.currency.formatAmount(progress.budget.amount, decimals: 0)}',
                      style: context.textStyles.caption,
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

  Color _parseColor(BuildContext context, String? hex) {
    if (hex == null || hex.isEmpty) return context.colors.textTertiary;
    final clean = hex.replaceFirst('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }
}
