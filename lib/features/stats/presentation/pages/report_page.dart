import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/repositories/report_repository.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/category_ranking_list.dart';

/// 时间维度
enum ReportPeriod { week, month, year }

/// 报表分析页
class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({super.key});

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> {
  ReportPeriod _period = ReportPeriod.month;
  bool _isExpense = true;
  late DateTime _currentDate;
  ReportSummary? _summary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final bookId = ref.read(currentBookProvider);
    final repo = ref.read(reportRepositoryProvider);
    final range = _getDateRange();

    final summary = await repo.getReport(
      bookId: bookId,
      start: range.$1,
      end: range.$2,
      isExpense: _isExpense,
      groupBy: _period == ReportPeriod.month ? 'day' : 'month',
    );

    setState(() {
      _summary = summary;
      _isLoading = false;
    });
  }

  (DateTime, DateTime) _getDateRange() {
    switch (_period) {
      case ReportPeriod.week:
        // 本周一到周日
        final weekday = _currentDate.weekday;
        final monday = DateTime(_currentDate.year, _currentDate.month, _currentDate.day - weekday + 1);
        final sunday = monday.add(const Duration(days: 7));
        return (monday, sunday);
      case ReportPeriod.month:
        final start = DateTime(_currentDate.year, _currentDate.month, 1);
        final end = DateTime(_currentDate.year, _currentDate.month + 1, 1);
        return (start, end);
      case ReportPeriod.year:
        final start = DateTime(_currentDate.year, 1, 1);
        final end = DateTime(_currentDate.year + 1, 1, 1);
        return (start, end);
    }
  }

  void _onPeriodChanged(ReportPeriod period) {
    setState(() => _period = period);
    _loadData();
  }

  void _onTypeChanged(bool isExpense) {
    setState(() => _isExpense = isExpense);
    _loadData();
  }

  void _onPrev() {
    setState(() {
      switch (_period) {
        case ReportPeriod.week:
          _currentDate = _currentDate.subtract(const Duration(days: 7));
          break;
        case ReportPeriod.month:
          _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
          break;
        case ReportPeriod.year:
          _currentDate = DateTime(_currentDate.year - 1, _currentDate.month, 1);
          break;
      }
    });
    _loadData();
  }

  void _onNext() {
    setState(() {
      switch (_period) {
        case ReportPeriod.week:
          _currentDate = _currentDate.add(const Duration(days: 7));
          break;
        case ReportPeriod.month:
          _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
          break;
        case ReportPeriod.year:
          _currentDate = DateTime(_currentDate.year + 1, _currentDate.month, 1);
          break;
      }
    });
    _loadData();
  }

  String _getPeriodLabel() {
    switch (_period) {
      case ReportPeriod.week:
        final weekday = _currentDate.weekday;
        final monday = _currentDate.subtract(Duration(days: weekday - 1));
        final sunday = monday.add(const Duration(days: 6));
        return '${monday.month}/${monday.day} - ${sunday.month}/${sunday.day}';
      case ReportPeriod.month:
        return '${_currentDate.year}年${_currentDate.month}月';
      case ReportPeriod.year:
        return '${_currentDate.year}年';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('报表分析'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // 时间维度切换
                    _buildPeriodSelector(),

                    // 时间导航
                    _buildTimeNav(),

                    const SizedBox(height: 8),

                    // 收支类型切换
                    _buildTypeSelector(),

                    const SizedBox(height: 16),

                    // 总览卡片
                    _buildSummaryCard(),

                    const SizedBox(height: 24),

                    // 分类占比标题 + 饼图
                    _buildSectionTitle('分类占比'),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
                      child: CategoryPieChart(
                        data: _summary?.categoryStats ?? [],
                        isExpense: _isExpense,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 分类排行榜
                    _buildSectionTitle('分类排行'),
                    const SizedBox(height: 8),
                    CategoryRankingList(
                      data: _summary?.categoryStats ?? [],
                      isExpense: _isExpense,
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
        ),
        child: Row(
          children: ReportPeriod.values.map((p) {
            final isSelected = _period == p;
            final label = switch (p) {
              ReportPeriod.week => '周',
              ReportPeriod.month => '月',
              ReportPeriod.year => '年',
            };
            return Expanded(
              child: GestureDetector(
                onTap: () => _onPeriodChanged(p),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.surface : null,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ] : null,
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTimeNav() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 28),
            onPressed: _onPrev,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 16),
          Text(
            _getPeriodLabel(),
            style: AppTextStyles.h3,
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 28),
            onPressed: _onNext,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      child: Row(
        children: [
          _buildTypeChip('支出', _isExpense, () => _onTypeChanged(true)),
          const SizedBox(width: 12),
          _buildTypeChip('收入', !_isExpense, () => _onTypeChanged(false)),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (_isExpense ? AppColors.expense : AppColors.income)
              : AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
        ),
        child: Text(
          label,
          style: AppTextStyles.footnote.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final summary = _summary;
    if (summary == null) return const SizedBox.shrink();

    final label = _isExpense ? '总支出' : '总收入';
    final color = _isExpense ? AppColors.expense : AppColors.income;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.footnote.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(
              '¥${_formatAmount(summary.totalAmount)}',
              style: AppTextStyles.amountLarge.copyWith(color: color),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildSummaryStat('笔数', '${summary.transactionCount}笔'),
                const SizedBox(width: 24),
                if (summary.dailyAverage != null)
                  _buildSummaryStat('日均', '¥${summary.dailyAverage!.toStringAsFixed(0)}'),
                const SizedBox(width: 24),
                _buildSummaryStat('分类', '${summary.categoryStats.length}个'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.footnote.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(title, style: AppTextStyles.h3),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 10000) {
      return '${(amount / 10000).toStringAsFixed(2)}万';
    } else if (amount >= 1000) {
      return amount.toStringAsFixed(0);
    } else {
      return amount.toStringAsFixed(2);
    }
  }
}
