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

/// 排序方式
enum SortType { time, amount }

/// 账单列表页
class TransactionListPage extends ConsumerStatefulWidget {
  const TransactionListPage({super.key});

  @override
  ConsumerState<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends ConsumerState<TransactionListPage> {
  ViewType _currentView = ViewType.week;
  late DateTime _currentDate;
  DateTime? _selectedWeekDay;

  // 筛选和排序
  String? _filterType; // null=全部, 'expense', 'income'
  SortType _sortType = SortType.time;

  // 刷新key
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
  }

  /// 触发刷新
  void _triggerRefresh() {
    setState(() {
      _refreshKey++;
      _filterType = null;
      _sortType = SortType.time;
    });
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
          _buildFilterSortBar(),
          _buildStatsBar(repo),
          Expanded(child: _buildContent(repo, catRepo)),
        ],
      ),
    );
  }

  // ==================== 顶部栏 ====================

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
              _selectedWeekDay = null;
            }),
          ),
          const Spacer(),
          _buildPeriodNav(),
        ],
      ),
    );
  }

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

  // ==================== 筛选排序栏 ====================

  Widget _buildFilterSortBar() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.s(context, AppDimensions.md),
        vertical: 6,
      ),
      color: AppColors.surface,
      child: Row(
        children: [
          // 筛选标签
          _buildFilterChip(null, '全部'),
          const SizedBox(width: 8),
          _buildFilterChip('expense', '支出'),
          const SizedBox(width: 8),
          _buildFilterChip('income', '收入'),
          const Spacer(),
          // 排序切换
          GestureDetector(
            onTap: () {
              setState(() {
                _sortType = _sortType == SortType.time ? SortType.amount : SortType.time;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _sortType == SortType.time ? Icons.access_time : Icons.sort,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  _sortType == SortType.time ? '按时间' : '按金额',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String? type, String label) {
    final isActive = _filterType == type;
    return GestureDetector(
      onTap: () => setState(() => _filterType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isActive ? AppColors.textOnPrimary : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  // ==================== 统计栏 ====================

  Widget _buildStatsBar(TransactionRepository repo) {
    return FutureBuilder<TransactionStats>(
      key: ValueKey(_refreshKey),
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

  /// 应用筛选和排序
  List<Transaction> _applyFilterAndSort(List<Transaction> txns, Map<int, Category> catMap) {
    var filtered = txns;

    // 筛选
    if (_filterType != null) {
      filtered = txns.where((t) {
        final cat = catMap[t.categoryId];
        if (_filterType == 'expense') return cat?.isExpense ?? true;
        if (_filterType == 'income') return !(cat?.isExpense ?? true);
        return true;
      }).toList();
    }

    // 排序
    if (_sortType == SortType.amount) {
      filtered.sort((a, b) => b.amount.compareTo(a.amount));
    }
    // time排序已在watchAll中按transactionDate desc处理，这里改为asc
    if (_sortType == SortType.time) {
      filtered.sort((a, b) => a.transactionDate.compareTo(b.transactionDate));
    }

    return filtered;
  }

  // ==================== 日视图 ====================

  Widget _buildDayView(TransactionRepository repo, CategoryRepository catRepo) {
    final start = DateTime(_currentDate.year, _currentDate.month, _currentDate.day);
    final end = start.add(const Duration(days: 1));

    return RefreshIndicator(
      onRefresh: () async { _triggerRefresh(); },
      child: StreamBuilder<List<Transaction>>(
        key: ValueKey('day_$_refreshKey'),
        stream: repo.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          final allTxns = snapshot.data ?? [];
          final dayTxns = allTxns.where((t) =>
              !t.transactionDate.isBefore(start) && t.transactionDate.isBefore(end)).toList();

          return FutureBuilder<List<Category>>(
            future: catRepo.getAll(),
            builder: (context, catSnap) {
              final categoryMap = <int, Category>{for (final c in (catSnap.data ?? [])) c.id: c};
              final filtered = _applyFilterAndSort(dayTxns, categoryMap);

              if (filtered.isEmpty) return _buildEmptyState();

              final grouped = _groupByDate(filtered);
              return ListView.builder(
                padding: EdgeInsets.only(bottom: Responsive.s(context, 16)),
                itemCount: grouped.length,
                itemBuilder: (context, index) {
                  final entry = grouped.entries.elementAt(index);
                  return TransactionGroup(
                    date: entry.key,
                    transactions: entry.value,
                    categoryMap: categoryMap,
                    onDelete: (id) async {
                      final result = await repo.delete(id);
                      setState(() {});
                      return result;
                    },
                    onTap: (t) => context.push('/transactions/${t.id}'),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // ==================== 周视图 ====================

  Widget _buildWeekView(TransactionRepository repo, CategoryRepository catRepo) {
    final weekStart = _currentDate.subtract(Duration(days: _currentDate.weekday - 1));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = _selectedWeekDay ?? today;

    return RefreshIndicator(
      onRefresh: () async { _triggerRefresh(); },
      child: Column(
        children: [
          _buildWeekDayCards(weekStart, selectedDay),
          Expanded(child: _buildWeekTransactionList(repo, catRepo, selectedDay)),
        ],
      ),
    );
  }

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
              onTap: () => setState(() => _selectedWeekDay = date),
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

  Widget _buildWeekTransactionList(TransactionRepository repo, CategoryRepository catRepo, DateTime selectedDay) {
    final dayStart = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    return StreamBuilder<List<Transaction>>(
      key: ValueKey('week_$_refreshKey'),
      stream: repo.watchAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        final allTxns = snapshot.data ?? [];
        final dayTxns = allTxns.where((t) =>
            !t.transactionDate.isBefore(dayStart) && t.transactionDate.isBefore(dayEnd)).toList();

        return FutureBuilder<List<Category>>(
          future: catRepo.getAll(),
          builder: (context, catSnap) {
            final categoryMap = <int, Category>{for (final c in (catSnap.data ?? [])) c.id: c};
            final filtered = _applyFilterAndSort(dayTxns, categoryMap);

            if (filtered.isEmpty) return _buildEmptyState();

            final grouped = _groupByDate(filtered);
            return ListView.builder(
              padding: EdgeInsets.only(bottom: Responsive.s(context, 16)),
              itemCount: grouped.length,
              itemBuilder: (context, index) {
                final entry = grouped.entries.elementAt(index);
                return TransactionGroup(
                  date: entry.key,
                  transactions: entry.value,
                  categoryMap: categoryMap,
                  onDelete: (id) async {
                    final result = await repo.delete(id);
                    setState(() {});
                    return result;
                  },
                  onTap: (t) => context.push('/transactions/${t.id}'),
                );
              },
            );
          },
        );
      },
    );
  }

  // ==================== 月视图（支持左右滑动切换月份） ====================

  Widget _buildMonthView(TransactionRepository repo, CategoryRepository catRepo) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! > 300) {
          // 右滑 - 上个月
          setState(() {
            _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
          });
        } else if (details.primaryVelocity! < -300) {
          // 左滑 - 下个月
          setState(() {
            _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
          });
        }
      },
      child: _buildMonthContent(repo, catRepo),
    );
  }

  Widget _buildMonthContent(TransactionRepository repo, CategoryRepository catRepo) {
    final start = DateTime(_currentDate.year, _currentDate.month, 1);
    final end = DateTime(_currentDate.year, _currentDate.month + 1, 1);

    return RefreshIndicator(
      onRefresh: () async { _triggerRefresh(); },
      child: StreamBuilder<List<Transaction>>(
        key: ValueKey('month_$_refreshKey'),
        stream: repo.watchAll(),
        builder: (context, snapshot) {
          final allTxns = snapshot.data ?? [];
          final monthTxns = allTxns.where((t) =>
              !t.transactionDate.isBefore(start) && t.transactionDate.isBefore(end)).toList();

          return FutureBuilder<List<Category>>(
            future: catRepo.getAll(),
            builder: (context, catSnap) {
              final categories = catSnap.data ?? [];
              final categoryMap = <int, Category>{for (final c in categories) c.id: c};

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
      ),
    );
  }

  Widget _buildCalendar(Map<int, ({double expense, double income})> dailyTotals) {
    final year = _currentDate.year;
    final month = _currentDate.month;
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    final startWeekday = firstDay.weekday % 7;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final dayFontSize = Responsive.fs(context, 13);
    final amountFontSize = Responsive.fs(context, 9);

    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
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
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: Responsive.s(context, AppDimensions.sm)),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 0.78,
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
                    // 点击日期跳转到日明细页
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => _DayDetailPage(
                          date: date,
                          categoryMap: const {},
                        ),
                      ),
                    );
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
                        Text(
                          '$day',
                          style: TextStyle(
                            fontSize: dayFontSize,
                            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                            color: isToday ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                        if (hasExpense)
                          Text(
                            _formatAmount(totals.expense),
                            style: TextStyle(fontSize: amountFontSize, color: AppColors.expense, height: 1.2),
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (hasIncome)
                          Text(
                            '+${_formatAmount(totals.income)}',
                            style: TextStyle(fontSize: amountFontSize, color: AppColors.income, height: 1.2),
                            overflow: TextOverflow.ellipsis,
                          ),
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
          Icon(Icons.receipt_long_outlined, size: Responsive.s(context, 48), color: AppColors.textTertiary),
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

/// 日明细页（从月视图点击某日进入）
class _DayDetailPage extends ConsumerWidget {
  final DateTime date;
  final Map<int, Category> categoryMap;

  const _DayDetailPage({required this.date, required this.categoryMap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(transactionRepositoryProvider);
    final catRepo = ref.read(categoryRepositoryProvider);
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(DateFormat('M月d日', 'zh_CN').format(date)),
        backgroundColor: AppColors.surface,
      ),
      body: StreamBuilder<List<Transaction>>(
        stream: repo.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          final allTxns = snapshot.data ?? [];
          final dayTxns = allTxns.where((t) =>
              !t.transactionDate.isBefore(start) && t.transactionDate.isBefore(end)).toList();

          if (dayTxns.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  Text('当日无账单记录', style: AppTextStyles.callout.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          return FutureBuilder<List<Category>>(
            future: catRepo.getAll(),
            builder: (context, catSnap) {
              final catMap = <int, Category>{for (final c in (catSnap.data ?? [])) c.id: c};
              final grouped = <DateTime, List<Transaction>>{};
              for (final t in dayTxns) {
                final dk = DateTime(t.transactionDate.year, t.transactionDate.month, t.transactionDate.day);
                grouped.putIfAbsent(dk, () => []).add(t);
              }
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: grouped.length,
                itemBuilder: (context, index) {
                  final entry = grouped.entries.elementAt(index);
                  return TransactionGroup(
                    date: entry.key,
                    transactions: entry.value,
                    categoryMap: catMap,
                    onDelete: (id) async {
                      return await repo.delete(id);
                    },
                    onTap: (t) => context.push('/transactions/${t.id}'),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
