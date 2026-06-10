import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/repositories/report_repository.dart';

/// 分类占比饼图
class CategoryPieChart extends StatefulWidget {
  final List<CategoryStat> data;
  final bool isExpense;

  const CategoryPieChart({
    super.key,
    required this.data,
    required this.isExpense,
  });

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (widget.data.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.pie_chart_outline, size: 48, color: context.colors.textTertiary),
              const SizedBox(height: 8),
              Text(l10n.reportNoData, style: TextStyle(color: context.colors.textTertiary)),
            ],
          ),
        ),
      );
    }

    // 最多显示 5 个分类，其余合并为"其他"
    final displayData = _getDisplayData();

    return SizedBox(
      height: 200,
      child: Row(
        children: [
          // 饼图
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        _touchedIndex = -1;
                        return;
                      }
                      _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: _buildSections(displayData),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 图例
          Expanded(
            flex: 2,
            child: _buildLegend(displayData),
          ),
        ],
      ),
    );
  }

  List<CategoryStat> _getDisplayData() {
    if (widget.data.length <= 5) return widget.data;

    final l10n = AppLocalizations.of(context)!;
    final top5 = widget.data.take(5).toList();
    final othersAmount = widget.data.skip(5).fold<double>(0, (s, c) => s + c.amount);
    final othersCount = widget.data.skip(5).fold<int>(0, (s, c) => s + c.count);
    final totalAmount = widget.data.fold<double>(0, (s, c) => s + c.amount);

    return [
      ...top5,
      CategoryStat(
        categoryId: -1,
        categoryName: l10n.txnGroupUncategorized,
        categoryIcon: '📦',
        amount: othersAmount,
        count: othersCount,
        percentage: totalAmount > 0 ? (othersAmount / totalAmount * 100) : 0,
      ),
    ];
  }

  List<PieChartSectionData> _buildSections(List<CategoryStat> data) {
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final stat = entry.value;
      final isTouched = index == _touchedIndex;
      final radius = isTouched ? 60.0 : 50.0;
      final color = _parseColor(stat.categoryColor, index);

      return PieChartSectionData(
        color: color,
        value: stat.amount,
        title: isTouched ? '${stat.percentage.toStringAsFixed(1)}%' : '',
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        radius: radius,
      );
    }).toList();
  }

  Widget _buildLegend(List<CategoryStat> data) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.asMap().entries.map((entry) {
        final index = entry.key;
        final stat = entry.value;
        final color = _parseColor(stat.categoryColor, index);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${stat.categoryIcon ?? ''} ${stat.categoryName}',
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${stat.percentage.toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 11, color: context.colors.textSecondary),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _parseColor(String? hex, int index) {
    if (hex != null && hex.isNotEmpty) {
      final clean = hex.replaceFirst('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    }
    // fallback 颜色
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
