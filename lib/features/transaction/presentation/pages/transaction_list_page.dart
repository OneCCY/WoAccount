import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../config/database/app_database.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../category/domain/repositories/category_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../widgets/view_switcher.dart';
import '../widgets/transaction_group.dart';

/// 账单列表页（左Tab）
/// 顶部切换器（日/周/月）+ 搜索栏 + 统计栏 + 按日分组列表
class TransactionListPage extends ConsumerStatefulWidget {
  const TransactionListPage({super.key});

  @override
  ConsumerState<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends ConsumerState<TransactionListPage> {
  ViewType _currentView = ViewType.week;
  late DateTime _currentDate;

  /// 周视图中选中的日期（null 表示显示整周）
  DateTime? _selectedWeekDay;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(transactionRepositoryProvider);
    final catRepo = ref.read(categoryRepositoryProvider);

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          _buildTopBar(),
          _buildSearchBar(),
          _buildStatsBar(repo),
          Expanded(child: _buildContent(repo, catRepo)),
        ],
      ),
    );
  }

  // ==================== 顶部栏 ====================

  /// 顶部栏：切换器 + 周期导航（修复溢出）
  Widget _buildTopBar() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.s(context, AppDimensions.md),
        vertical: Responsive.s(context, 8),
      ),
      color: AppColors.surface,
      child: Row(
        children: [
          ViewSwitcher(
            currentView: _currentView,
            onViewChanged: (view) => setState(() {
              _currentView = view;
              _selectedWeekDay = null; // 切换视图时重置选中日期
            }),
          ),
          const Spacer(),
          _buildPeriodNav(),
        ],
      ),
    );
  }

  /// 周期导航：左右箭头 + 日期标签（响应式，防溢出）
  Widget _buildPeriodNav() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildArrowButton(Icons.chevron_left, _goPrevious),
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: Responsive.s(context, 60),
              maxWidth: Responsive.s(context, 140),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.s(context, 4)),
              child: Text(
                _getPeriodLabel(),
                style: AppTextStyles.footnote.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: Responsive.fs(context, 13),
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
          ),
        ),
        _buildArrowButton(Icons.chevron_right, _goNext),
      ],
    );
  }

  void _goPrevious() {
    setState(() {
      switch (_currentView) {
        case ViewType.day:
          _currentDate = _currentDate.subtract(const Duration(days: 1));
        case ViewType.week:
          _currentDate = _currentDate.subtract(const Duration(days: 7));
          _selectedWeekDay = null;
        case ViewType.month:
          _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
      }
    });
  }

  void _goNext() {
    setState(() {
      switch (_currentView) {
        case ViewType.day:
          _currentDate = _currentDate.add(const Duration(days: 1));
        case ViewType.week:
          _currentDate = _currentDate.add(const Duration(days: 7));
          _selectedWeekDay = null;
        case ViewType.month:
          _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
      }
    });
  }

  String _getPeriodLabel() {
    switch (_currentView) {
      case ViewType.day:
        return DateFormat('M月d日 EEEE', 'zh_CN').format(_currentDate);
      case ViewType.week:
        final start = _currentDate.subtract(Duration(days: _currentDate.weekday - 1));
        final end = start.add(const Duration(days: 6));
        return '${DateFormat('M月d日').format(start)} - ${DateFormat('M月d日').format(end)}';
      case ViewType.month:
        return DateFormat('yyyy年M月').format(_currentDate);
    }
  }

  Widget _buildArrowButton(IconData icon, VoidCallback onPressed) {
    final size = Responsive.s(context, 28);
    final iconSize = Responsive.s(context, 14);
    final borderRadius = Responsive.s(context, 6);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.separator, width: 1),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Icon(icon, size: iconSize, color: AppColors.textSecondary),
        ),
      ),
    );
  }

  // ==================== 搜索栏 ====================

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Responsive.s(context, AppDimensions.md),
        Responsive.s(context, 8),
        Responsive.s(context, AppDimensions.md),
        Responsive.s(context, 8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.s(context, 14),
                vertical: Responsive.s(context, 10),
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(Responsive.s(context, AppDimensions.radiusMd)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, size: Responsive.s(context, 16), color: AppColors.textHint),
                  SizedBox(width: Responsive.s(context, 8)),
                  Text('搜索账单...',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textHint,
                        fontSize: Responsive.fs(context, 14),
                      )),
                ],
              ),
            ),
          ),
          SizedBox(width: Responsive.s(context, 8)),
          GestureDetector(
            onTap: () => context.push('/budget'),
            child: Container(
              width: Responsive.s(context, 40),
              height: Responsive.s(context, 40),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(Responsive.s(context, AppDimensions.radiusMd)),
              ),
              child: Center(
                child: Icon(Icons.account_balance_wallet_outlined,
                    size: Responsive.s(context, 20), color: AppColors.warning),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 统计栏 ====================

  Widget _buildStatsBar(TransactionRepository repo) {
    return FutureBuilder<TransactionStats>(
      future: _getCurrentPeriodStats(repo),
      builder: (context, snapshot) {
        final stats = snapshot.data;
        final expense = stats?.totalExpense ?? 0;
        final income = stats?.totalIncome ?? 0;
        final balance = stats?.balance ?? 0;

        final label = switch (_currentView) {
          ViewType.day => '本日',
          ViewType.week => '本周',
          ViewType.month => '本月',
        };

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.s(context, AppDimensions.md),
            vertical: Responsive.s(context, 4),
          ),
          child: Row(
            children: [
              _buildStatItem('$label支出', '¥${expense.toStringAsFixed(0)}', AppColors.expense),
              _buildStatItem('$label收入', '¥${income.toStringAsFixed(0)}', AppColors.income),
              _buildStatItem('结余', '¥${balance.toStringAsFixed(0)}', AppColors.textPrimary),
            ],
          ),
        );
      },
    );
  }

  Future<TransactionStats> _getCurrentPeriodStats(TransactionRepository repo) {
    final now = _currentDate;
    DateTime start, end;
    switch (_currentView) {
      case ViewType.day:
        start = DateTime(now.year, now.month, now.day);
        end = start.add(const Duration(days: 1));
      case ViewType.week:
        start = now.subtract(Duration(days: now.weekday - 1));
        start = DateTime(start.year, start.month, start.day);
        end = start.add(const Duration(days: 7));
      case ViewType.month:
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 1);
    }
    return repo.getStats(start, end);
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: Responsive.s(context, 10)),
        margin: EdgeInsets.symmetric(horizontal: Responsive.s(context, 4)),
        decoration: BoxDecoration(
          color: AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(Responsive.s(context, AppDimensions.radiusSm)),
        ),
        child: Column(
          children: [
            Text(label, style: AppTextStyles.caption.copyWith(fontSize: Responsive.fs(context, 11))),
            SizedBox(height: Responsive.s(context, 4)),
            Text(value,
                style: AppTextStyles.amountList.copyWith(
                  color: valueColor,
                  fontSize: Responsive.fs(context, 16),
                )),
          ],
        ),
      ),
    );
  }

  // ==================== 内容路由 ====================

  Widget _buildContent(TransactionRepository repo, CategoryRepository catRepo) {
    switch (_currentView) {
      case ViewType.day:
        return _buildDayView(repo, catRepo);
      case ViewType.week:
        return _buildWeekView(repo, catRepo);
      case ViewType.month:
        return _buildMonthView(repo, catRepo);
    }
  }

  // ==================== 日视图 ====================

  Widget _buildDayView(TransactionRepository repo, CategoryRepository catRepo) {
    final start = DateTime(_currentDate.year, _currentDate.month, _currentDate.day);
    final end = start.add(const Duration(days: 1));

    return StreamBuilder<List<Transaction>>(
      stream: repo.watchAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        final allTxns = snapshot.data ?? [];
        final dayTxns = allTxns.where((t) =>
            t.transactionDate.isAfter(start) && t.transactionDate.isBefore(end)).toList();

        if (dayTxns.isEmpty) return _buildEmptyState();

        return FutureBuilder<List<Category>>(
          future: catRepo.getAll(),
          builder: (context, catSnap) {
            final categoryMap = <int, Category>{for (final c in (catSnap.data ?? [])) c.id: c};
            final grouped = _groupByDate(dayTxns);
            return ListView.builder(
              padding: EdgeInsets.only(bottom: Responsive.s(context, 16)),
              itemCount: grouped.length,
              itemBuilder: (context, index) {
                final entry = grouped.entries.elementAt(index);
                return TransactionGroup(
                  date: entry.key,
                  transactions: entry.value,
                  categoryMap: categoryMap,
                  onDelete: (id) => repo.delete(id),
                  onTap: (t) => context.push('/transactions/${t.id}'),
                );
              },
            );
          },
        );
      },
    );
  }

  // ==================== 周视图 ====================

  Widget _buildWeekView(TransactionRepository repo, CategoryRepository catRepo) {
    final weekStart = _currentDate.subtract(Duration(days: _currentDate.weekday - 1));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 默认选中今天（如果在本周范围内）
    final selectedDay = _selectedWeekDay ?? today;

    return Column(
      children: [
        // 7天日期卡片
        _buildWeekDayCards(weekStart, selectedDay),
        // 选中日期的交易列表
        Expanded(child: _buildWeekTransactionList(repo, catRepo, selectedDay)),
      ],
    );
  }

  /// 7天日期卡片（点击选中，不跳转视图）
  Widget _buildWeekDayCards(DateTime weekStart, DateTime selectedDay) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.s(context, AppDimensions.md),
        vertical: Responsive.s(context, 8),
      ),
      child: Row(
        children: List.generate(7, (i) {
          final date = weekStart.add(Duration(days: i));
          final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
          final isSelected = date.year == selectedDay.year &&
              date.month == selectedDay.month &&
              date.day == selectedDay.day;
          final weekday = ['一', '二', '三', '四', '五', '六', '日'][i];

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedWeekDay = date;
                });
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: Responsive.s(context, 2)),
                padding: EdgeInsets.symmetric(vertical: Responsive.s(context, 8)),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primarySurface
                      : (isToday ? AppColors.primarySurface.withValues(alpha: 0.5) : AppColors.surfaceSecondary),
                  borderRadius: BorderRadius.circular(Responsive.s(context, AppDimensions.radiusSm)),
                  border: isSelected
                      ? Border.all(color: AppColors.primary, width: 2)
                      : (isToday ? Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1) : null),
                ),
                child: Column(
                  children: [
                    Text(weekday,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: Responsive.fs(context, 11),
                          color: isSelected ? AppColors.primary : AppColors.textTertiary,
                        )),
                    SizedBox(height: Responsive.s(context, 2)),
                    Text(
                      '${date.day}',
                      style: AppTextStyles.callout.copyWith(
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        fontSize: Responsive.fs(context, 16),
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// 周视图交易列表（显示选中日期的交易）
  Widget _buildWeekTransactionList(TransactionRepository repo, CategoryRepository catRepo, DateTime selectedDay) {
    final dayStart = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    return StreamBuilder<List<Transaction>>(
      stream: repo.watchAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        final allTxns = snapshot.data ?? [];
        final dayTxns = allTxns.where((t) =>
            t.transactionDate.isAfter(dayStart) && t.transactionDate.isBefore(dayEnd)).toList();

        if (dayTxns.isEmpty) return _buildEmptyState();

        return FutureBuilder<List<Category>>(
          future: catRepo.getAll(),
          builder: (context, catSnap) {
            final categoryMap = <int, Category>{for (final c in (catSnap.data ?? [])) c.id: c};
            final grouped = _groupByDate(dayTxns);
            return ListView.builder(
              padding: EdgeInsets.only(bottom: Responsive.s(context, 16)),
              itemCount: grouped.length,
              itemBuilder: (context, index) {
                final entry = grouped.entries.elementAt(index);
                return TransactionGroup(
                  date: entry.key,
                  transactions: entry.value,
                  categoryMap: categoryMap,
                  onDelete: (id) => repo.delete(id),
                  onTap: (t) => context.push('/transactions/${t.id}'),
                );
              },
            );
          },
        );
      },
    );
  }

  // ==================== 月视图 ====================

  /// 月视图：仅显示日历（含每日收支），不显示交易列表
  Widget _buildMonthView(TransactionRepository repo, CategoryRepository catRepo) {
    final start = DateTime(_currentDate.year, _currentDate.month, 1);
    final end = DateTime(_currentDate.year, _currentDate.month + 1, 1);

    return StreamBuilder<List<Transaction>>(
      stream: repo.watchAll(),
      builder: (context, snapshot) {
        final allTxns = snapshot.data ?? [];
        final monthTxns = allTxns.where((t) =>
            t.transactionDate.isAfter(start) && t.transactionDate.isBefore(end)).toList();

        // 计算每日收支汇总
        final dailyTotals = <int, ({double expense, double income})>{};
        for (final t in monthTxns) {
          final day = t.transactionDate.day;
          final existing = dailyTotals[day];
          // 需要通过 category 判断收支类型，这里简化处理：amount > 0 为支出
          // 实际应通过 category.isExpense 判断，但此处使用 amount 正负约定
          // 由于当前 amount 总是正数，需要查 category
          dailyTotals[day] = (
            expense: (existing?.expense ?? 0) + t.amount, // 暂时全算支出，下面用 category 修正
            income: existing?.income ?? 0,
          );
        }

        // 用 FutureBuilder 获取分类信息以区分收支
        return FutureBuilder<List<Category>>(
          future: catRepo.getAll(),
          builder: (context, catSnap) {
            final categories = catSnap.data ?? [];
            final categoryMap = <int, Category>{for (final c in categories) c.id: c};

            // 重新计算每日收支（使用 category.isExpense）
            final correctedTotals = <int, ({double expense, double income})>{};
            for (final t in monthTxns) {
              final day = t.transactionDate.day;
              final cat = categoryMap[t.categoryId];
              final isExpense = cat?.isExpense ?? true;
              final existing = correctedTotals[day];
              if (isExpense) {
                correctedTotals[day] = (
                  expense: (existing?.expense ?? 0) + t.amount,
                  income: existing?.income ?? 0,
                );
              } else {
                correctedTotals[day] = (
                  expense: existing?.expense ?? 0,
                  income: (existing?.income ?? 0) + t.amount,
                );
              }
            }

            return _buildCalendar(correctedTotals);
          },
        );
      },
    );
  }

  /// 月历（含每日收支金额，模仿原型）
  Widget _buildCalendar(Map<int, ({double expense, double income})> dailyTotals) {
    final year = _currentDate.year;
    final month = _currentDate.month;
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    final startWeekday = firstDay.weekday % 7; // 0=Sunday
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final dayFontSize = Responsive.fs(context, 13);
    final amountFontSize = Responsive.fs(context, 9);

    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          // 星期标题
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: Responsive.s(context, 8),
              horizontal: Responsive.s(context, AppDimensions.sm),
            ),
            child: Row(
              children: ['日', '一', '二', '三', '四', '五', '六']
                  .map((d) => Expanded(
                        child: Center(
                          child: Text(d,
                              style: AppTextStyles.caption.copyWith(
                                fontSize: Responsive.fs(context, 12),
                                fontWeight: FontWeight.w500,
                              )),
                        ),
                      ))
                  .toList(),
            ),
          ),
          // 日期网格
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: Responsive.s(context, AppDimensions.sm)),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 0.78, // 稍高以容纳金额文字
              ),
              itemCount: startWeekday + lastDay.day,
              itemBuilder: (context, index) {
                if (index < startWeekday) return const SizedBox.shrink();
                final day = index - startWeekday + 1;
                final date = DateTime(year, month, day);
                final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
                final totals = dailyTotals[day];
                final hasExpense = totals != null && totals.expense > 0;
                final hasIncome = totals != null && totals.income > 0;

                return GestureDetector(
                  onTap: () {
                    // 点击日期切换到日视图
                    setState(() {
                      _currentDate = date;
                      _currentView = ViewType.day;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.all(Responsive.s(context, 1)),
                    decoration: BoxDecoration(
                      color: isToday ? AppColors.primarySurface : null,
                      borderRadius: BorderRadius.circular(Responsive.s(context, 4)),
                      border: isToday ? Border.all(color: AppColors.primary, width: 1) : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 日期数字
                        Text(
                          '$day',
                          style: TextStyle(
                            fontSize: dayFontSize,
                            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                            color: isToday ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                        // 支出金额
                        if (hasExpense)
                          Text(
                            _formatAmount(totals.expense),
                            style: TextStyle(
                              fontSize: amountFontSize,
                              color: AppColors.expense,
                              height: 1.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        // 收入金额
                        if (hasIncome)
                          Text(
                            '+${_formatAmount(totals.income)}',
                            style: TextStyle(
                              fontSize: amountFontSize,
                              color: AppColors.income,
                              height: 1.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        // 无数据时的占位
                        if (!hasExpense && !hasIncome)
                          SizedBox(height: amountFontSize * 1.2),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: Responsive.s(context, 8)),
        ],
      ),
    );
  }

  /// 格式化金额（简洁显示，如 156、1.2k）
  String _formatAmount(double amount) {
    if (amount >= 10000) {
      return '-${(amount / 10000).toStringAsFixed(1)}w';
    } else if (amount >= 1000) {
      return '-${(amount / 1000).toStringAsFixed(1)}k';
    } else if (amount == amount.roundToDouble()) {
      return '-${amount.toInt()}';
    } else {
      return '-${amount.toStringAsFixed(0)}';
    }
  }

  // ==================== 工具方法 ====================

  Map<DateTime, List<Transaction>> _groupByDate(List<Transaction> transactions) {
    final map = <DateTime, List<Transaction>>{};
    for (final t in transactions) {
      final dateKey = DateTime(t.transactionDate.year, t.transactionDate.month, t.transactionDate.day);
      map.putIfAbsent(dateKey, () => []).add(t);
    }
    return map;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: Responsive.s(context, 48), color: AppColors.textTertiary),
          SizedBox(height: Responsive.s(context, AppDimensions.md)),
          Text('暂无账单记录',
              style: AppTextStyles.callout.copyWith(
                color: AppColors.textSecondary,
                fontSize: Responsive.fs(context, 16),
              )),
        ],
      ),
    );
  }
}
