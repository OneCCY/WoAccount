import 'package:flutter/material.dart';
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
              Icon(Icons.bar_chart, size: 48, color: AppColors.textTertiary),
              const SizedBox(height: 8),
              Text('暂无数据', style: AppTextStyles.body.copyWith(color: AppColors.textTertiary)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: data.asMap().entries.map((entry) {
        final index = entry.key;
        final stat = entry.value;
        return _buildRankItem(index, stat);
      }).toList(),
    );
  }

  Widget _buildRankItem(int index, CategoryStat stat) {
    final color = _parseColor(stat.categoryColor, index);
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
                color: index < 3 ? AppColors.primary : AppColors.textTertiary,
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
                      '¥${_formatAmount(stat.amount)}',
                      style: AppTextStyles.amountSmall.copyWith(
                        color: isExpense ? AppColors.expense : AppColors.income,
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
                    backgroundColor: AppColors.surfaceSecondary,
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
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 10000) {
      return '${(amount / 10000).toStringAsFixed(1)}万';
    } else if (amount >= 1000) {
      return amount.toStringAsFixed(0);
    } else {
      return amount.toStringAsFixed(2);
    }
  }

  Color _parseColor(String? hex, int index) {
    if (hex != null && hex.isNotEmpty) {
      final clean = hex.replaceFirst('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    }
    final fallbackColors = [
      AppColors.categoryFood,
      AppColors.categoryTransport,
      AppColors.categoryShopping,
      AppColors.categoryHousing,
      AppColors.categoryEntertainment,
      AppColors.categoryEducation,
      AppColors.categoryMedical,
      AppColors.categorySocial,
      AppColors.categoryOther,
    ];
    return fallbackColors[index % fallbackColors.length];
  }
}
