import 'package:flutter/material.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../core/locale/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 标签统计数据
class TagStat {
  final int tagId;
  final String tagName;
  final String tagColor;
  final double amount;
  final int count;
  final double percentage;

  const TagStat({
    required this.tagId,
    required this.tagName,
    required this.tagColor,
    required this.amount,
    required this.count,
    required this.percentage,
  });
}

/// 标签排行榜列表
class TagRankingList extends StatelessWidget {
  final List<TagStat> data;

  const TagRankingList({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.label_outline, size: 48, color: context.colors.textTertiary),
              const SizedBox(height: 8),
              Text(AppLocalizations.of(context)!.reportNoData,
                style: AppTextStyles.body.copyWith(color: context.colors.textTertiary)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: data.asMap().entries.map((entry) {
        final index = entry.key;
        final stat = entry.value;
        return _buildTagItem(context, index, stat);
      }).toList(),
    );
  }

  Widget _buildTagItem(BuildContext context, int index, TagStat stat) {
    final color = _parseColor(stat.tagColor);
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
          // 色块图标
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Container(
                width: 16, height: 16,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
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
                    Text(stat.tagName, style: AppTextStyles.body),
                    Text(
                      '${context.localeProvider.currency.formatAbbreviated(stat.amount)}  (${stat.count})',
                      style: AppTextStyles.amountSmall.copyWith(color: context.colors.expense),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
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
            width: 48,
            child: Text(
              '${stat.percentage.toStringAsFixed(1)}%',
              style: AppTextStyles.caption.copyWith(color: context.colors.textSecondary),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  static Color _parseColor(String hex) {
    try {
      final clean = hex.replaceFirst('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return const Color(0xFF607D8B);
    }
  }
}
