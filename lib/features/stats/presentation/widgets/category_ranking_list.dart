import 'package:flutter/material.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../core/locale/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/repositories/report_repository.dart';

/// 分类排行榜列表
class CategoryRankingList extends StatelessWidget {
  final List<CategoryStat> data;
  final bool isExpense;

  const CategoryRankingList({
    super.key,
    required this.data,
    required this.isExpense,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bar_chart, size: 48, color: context.colors.textTertiary),
              const SizedBox(height: 8),
              Text(AppLocalizations.of(context)!.reportNoData, style: AppTextStyles.body.copyWith(color: context.colors.textTertiary)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: data.asMap().entries.map((entry) {
        final index = entry.key;
        final stat = entry.value;
        return _buildRankItem(context, index, stat);
      }).toList(),
    );
  }

  Widget _buildRankItem(BuildContext context, int index, CategoryStat stat) {
    final color = _parseColor(context, stat.categoryColor, index);
    final barWidth = stat.percentage / 100;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // 排名
          SizedBox(
            width: 24,
            child: Text(
              '${index + 1}',
              style: AppTextStyles.footnote.copyWith(
                color: index < 3 ? context.colors.primary : context.colors.textTertiary,
                fontWeight: index < 3 ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 10),
          // 图标
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(stat.categoryIcon ?? '📦', style: const TextStyle(fontSize: 18)),
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
                    Text(stat.categoryName, style: AppTextStyles.body),
                    Text(
                      context.localeProvider.currency.formatAbbreviated(stat.amount),
                      style: AppTextStyles.amountSmall.copyWith(
                        color: isExpense ? context.colors.expense : context.colors.income,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // 进度条
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: barWidth,
                    minHeight: 6,
                    backgroundColor: context.colors.surfaceSecondary,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // 百分比
          SizedBox(
            width: 42,
            child: Text(
              '${stat.percentage.toStringAsFixed(0)}%',
              style: AppTextStyles.caption.copyWith(color: context.colors.textSecondary),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(BuildContext context, String? hex, int index) {
    if (hex != null && hex.isNotEmpty) {
      final clean = hex.replaceFirst('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    }
    final fallbackColors = [
      context.colors.categoryFood,
      context.colors.categoryTransport,
      context.colors.categoryShopping,
      context.colors.categoryHousing,
      context.colors.categoryEntertainment,
      context.colors.categoryEducation,
      context.colors.categoryMedical,
      context.colors.categorySocial,
      context.colors.categoryOther,
    ];
    return fallbackColors[index % fallbackColors.length];
  }
}
