import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/locale/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../budget/domain/repositories/budget_repository.dart';

/// 预算提醒卡片（真实数据版本）
/// 查询本月预算进度，仅在超支时显示
class BudgetInsightCard extends ConsumerWidget {
  const BudgetInsightCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final repo = ref.read(budgetRepositoryProvider);
    final bookId = ref.watch(currentBookProvider);

    return FutureBuilder<List<BudgetProgress>>(
      future: repo.getBudgetProgress(bookId, now.year, now.month),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final progresses = snapshot.data!;
        final overBudget = progresses.where((p) => p.isOverBudget).toList();

        if (overBudget.isEmpty) {
          return const SizedBox.shrink();
        }

        // 找到超支最多的
        final worst = overBudget.reduce((a, b) =>
            (a.spent - a.budget.amount) > (b.spent - b.budget.amount) ? a : b);

        final l10n = AppLocalizations.of(context)!;
        final overAmount = worst.spent - worst.budget.amount;
        final catName = worst.category?.name ?? l10n.budgetUnknownCategory;

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.md,
            AppDimensions.sm,
            AppDimensions.md,
            0,
          ),
          child: Material(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            child: InkWell(
              onTap: () => context.push('/budget'),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.md,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber,
                      size: 20,
                      color: Color(0xFFE65100),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.budgetOverSpent(
                          catName,
                          context.localeProvider.currency.formatAmount(overAmount, decimals: 0),
                        ),
                        style: context.textStyles.footnote.copyWith(
                          color: const Color(0xFFE65100),
                        ),
                      ),
                    ),
                    Text(
                      l10n.homeBudgetDetails,
                      style: context.textStyles.footnote.copyWith(
                        color: context.colors.warning,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
