import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../config/database/app_database.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/locale/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/page_refresh_mixin.dart';
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

class _TransactionListPageState extends ConsumerState<TransactionListPage> with PageRefreshMixin {
  ViewType _currentView = ViewType.week;
  late DateTime _currentDate;
  DateTime? _selectedWeekDay;

  // 筛选和排序
  String? _filterType; // null=全部, 'expense', 'income'
  SortType _sortType = SortType.time;

  // 刷新key
  int _refreshKey = 0;

  @override
  String get routePath => '/transactions';

  @override
  void onRefresh() => _triggerRefresh();

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
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(transactionRepositoryProvider);
    final catRepo = ref.read(categoryRepositoryProvider);

    return Scaffold(
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity == null) return;
          if (details.primaryVelocity! > 300) {
            // 下滑 - 上一期
            _goPrevious();
          } else if (details.primaryVelocity! < -300) {
            // 上滑 - 下一期
            _goNext();
          }
        },
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top),
            _buildTopBar(),
            _buildSearchBar(l10n),
            _buildStatsBar(repo, l10n),
            Expanded(child: _buildContent(repo, catRepo, l10n)),
          ],
        ),
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
      color: context.colors.surface,
      child: Row(
        children: [
          ViewSwitcher(
            currentView: _currentView,
            onViewChanged: (view) => setState(() {
              _currentView = view;
              _selectedWeekDay = null;
              // 切到月视图时清空筛选，避免月视图显示已激活但无列表承载的状态
              if (view == ViewType.month) _filterType = null;
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
                style: context.textStyles.footnote.copyWith(
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
    if (!_canGoNext()) return;
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

  /// 是否可以往前导航（不超过当前日期）
  bool _canGoNext() {
    final now = DateTime.now();
    switch (_currentView) {
      case ViewType.day:
        return _currentDate.isBefore(DateTime(now.year, now.month, now.day));
      case ViewType.week:
        final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
        final thisWeekStart = DateTime(currentWeekStart.year, currentWeekStart.month, currentWeekStart.day);
        final viewWeekStart = _currentDate.subtract(Duration(days: _currentDate.weekday - 1));
        return viewWeekStart.isBefore(thisWeekStart);
      case ViewType.month:
        return _currentDate.isBefore(DateTime(now.year, now.month, 1));
    }
  }

  String _getPeriodLabel() {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    switch (_currentView) {
      case ViewType.day:
        return DateFormat('${l10n.txnDayFormat} EEEE', locale).format(_currentDate);
      case ViewType.week:
        final start = _currentDate.subtract(Duration(days: _currentDate.weekday - 1));
        final end = start.add(const Duration(days: 6));
        return '${DateFormat(l10n.txnDayFormat, locale).format(start)} - ${DateFormat(l10n.txnDayFormat, locale).format(end)}';
      case ViewType.month:
        return DateFormat(l10n.txnMonthFormat, locale).format(_currentDate);
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
        border: Border.all(color: context.colors.separator, width: 1),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Icon(icon, size: iconSize, color: context.colors.textSecondary),
        ),
      ),
    );
  }

  // ==================== 搜索栏 ====================

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.s(context, AppDimensions.md),
        vertical: Responsive.s(context, 8),
      ),
      color: context.colors.surface,
      child: Row(
        children: [
          // 左侧：回到今天按钮
          _buildTodayButton(l10n),
          SizedBox(width: Responsive.s(context, 8)),
          // 搜索框
          Expanded(
            child: GestureDetector(
              onTap: () {
                // TODO: 跳转搜索页或展开搜索
              },
              child: Container(
                height: Responsive.s(context, 36),
                padding: EdgeInsets.symmetric(horizontal: Responsive.s(context, 10)),
                decoration: BoxDecoration(
                  color: context.colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(Responsive.s(context, 10)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, size: 18, color: context.colors.textTertiary),
                    SizedBox(width: Responsive.s(context, 6)),
                    Expanded(
                      child: Text(
                        l10n.txnSearchHint,
                        style: context.textStyles.footnote.copyWith(color: context.colors.textTertiary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: Responsive.s(context, 8)),
          // 右侧：预算管理按钮
          GestureDetector(
            onTap: () => context.push('/budget'),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: Responsive.s(context, 10), vertical: Responsive.s(context, 8)),
              decoration: BoxDecoration(
                color: context.colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(Responsive.s(context, 8)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.account_balance_wallet_outlined, size: 17, color: context.colors.textSecondary),
                  SizedBox(width: Responsive.s(context, 4)),
                  Text(
                    l10n.txnBudget,
                    style: context.textStyles.footnote.copyWith(color: context.colors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayButton(AppLocalizations l10n) {
    return Material(
      color: context.colors.surfaceSecondary,
      borderRadius: BorderRadius.circular(Responsive.s(context, 8)),
      child: InkWell(
        onTap: _goToToday,
        borderRadius: BorderRadius.circular(Responsive.s(context, 8)),
        splashColor: context.colors.primary.withValues(alpha: 0.15),
        highlightColor: context.colors.primary.withValues(alpha: 0.08),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Responsive.s(context, 12), vertical: Responsive.s(context, 8)),
          child: Text(
            l10n.txnToday,
            style: context.textStyles.footnote.copyWith(
              color: context.colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      switch (_currentView) {
        case ViewType.day:
          _currentDate = DateTime(now.year, now.month, now.day);
        case ViewType.week:
          _currentDate = now;
          _selectedWeekDay = DateTime(now.year, now.month, now.day);
        case ViewType.month:
          _currentDate = DateTime(now.year, now.month, 1);
      }
      _filterType = null;
    });
  }

  // ==================== 统计栏 ====================

  Widget _buildStatsBar(TransactionRepository repo, AppLocalizations l10n) {
    return FutureBuilder<TransactionStats>(
      key: ValueKey(_refreshKey),
      future: _getCurrentPeriodStats(repo),
      builder: (context, snapshot) {
        final stats = snapshot.data;
        final expense = stats?.totalExpense ?? 0;
        final income = stats?.totalIncome ?? 0;
        final balance = stats?.balance ?? 0;

        final label = switch (_currentView) {
          ViewType.day => l10n.txnPeriodDay,
          ViewType.week => l10n.txnPeriodWeek,
          ViewType.month => l10n.txnPeriodMonth,
        };

        final isMonth = _currentView == ViewType.month;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.s(context, AppDimensions.md),
            vertical: Responsive.s(context, 4),
          ),
          child: Row(
            children: [
              _buildStatItem(
                l10n.txnExpense(label),
                context.localeProvider.currency.formatAmount(expense),
                context.colors.expense,
                isActive: !isMonth && _filterType == 'expense',
                onTap: isMonth ? null : () {
                  setState(() {
                    if (_filterType == 'expense') {
                      _filterType = null;
                    } else {
                      _filterType = 'expense';
                    }
                  });
                },
              ),
              _buildStatItem(
                l10n.txnIncome(label),
                context.localeProvider.currency.formatAmount(income),
                context.colors.income,
                isActive: !isMonth && _filterType == 'income',
                onTap: isMonth ? null : () {
                  setState(() {
                    if (_filterType == 'income') {
                      _filterType = null;
                    } else {
                      _filterType = 'income';
                    }
                  });
                },
              ),
              _buildStatItem(l10n.txnBalance, context.localeProvider.currency.formatAmount(balance), context.colors.textPrimary),
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
    return repo.getStats(ref.watch(currentBookProvider), start, end);
  }

  Widget _buildStatItem(String label, String value, Color valueColor, {bool isActive = false, VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: Responsive.s(context, 10)),
          margin: EdgeInsets.symmetric(horizontal: Responsive.s(context, 4)),
          decoration: BoxDecoration(
            color: isActive ? valueColor.withValues(alpha: 0.1) : context.colors.surfaceSecondary,
            borderRadius: BorderRadius.circular(Responsive.s(context, AppDimensions.radiusSm)),
            border: isActive ? Border.all(color: valueColor.withValues(alpha: 0.4), width: 1.5) : null,
          ),
          child: Column(
            children: [
              Text(label, style: context.textStyles.caption.copyWith(
                fontSize: Responsive.fs(context, 11),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? valueColor : context.colors.textSecondary,
              )),
              SizedBox(height: Responsive.s(context, 4)),
              Text(value,
                  style: context.textStyles.amountList.copyWith(
                    color: valueColor,
                    fontSize: Responsive.fs(context, 16),
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== 内容路由 ====================

  Widget _buildContent(TransactionRepository repo, CategoryRepository catRepo, AppLocalizations l10n) {
    switch (_currentView) {
      case ViewType.day:
        return _buildDayView(repo, catRepo, l10n);
      case ViewType.week:
        return _buildWeekView(repo, catRepo, l10n);
      case ViewType.month:
        return _buildMonthView(repo, catRepo, l10n);
    }
  }

  /// 应用筛选和排序
  List<Transaction> _applyFilterAndSort(List<Transaction> txns, Map<int, Category> catMap) {
    var filtered = txns;

    // 筛选
    if (_filterType != null) {
      filtered = txns.where((t) {
        if (_filterType == 'expense') return t.type == 'expense';
        if (_filterType == 'income') return t.type == 'income';
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

  Widget _buildDayView(TransactionRepository repo, CategoryRepository catRepo, AppLocalizations l10n) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! > 300) {
          // 右滑 - 上一天
          setState(() => _currentDate = _currentDate.subtract(const Duration(days: 1)));
        } else if (details.primaryVelocity! < -300) {
          // 左滑 - 下一天
          setState(() => _currentDate = _currentDate.add(const Duration(days: 1)));
        }
      },
      child: _buildDayContent(repo, catRepo, l10n),
    );
  }

  Widget _buildDayContent(TransactionRepository repo, CategoryRepository catRepo, AppLocalizations l10n) {
    final start = DateTime(_currentDate.year, _currentDate.month, _currentDate.day);
    final end = start.add(const Duration(days: 1));

    return RefreshIndicator(
      onRefresh: () async { _triggerRefresh(); },
      child: StreamBuilder<List<Transaction>>(
        key: ValueKey('day_$_refreshKey'),
        stream: repo.watchAll(ref.watch(currentBookProvider)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: context.colors.primary));
          }
          if (snapshot.hasError) {
            debugPrint('[TransactionList] stream error: ${snapshot.error}');
            return Center(child: Text(AppLocalizations.of(context)!.loadFailedPullToRefresh, style: context.textStyles.body.copyWith(color: context.colors.textTertiary)));
          }
          final allTxns = snapshot.data ?? [];
          final dayTxns = allTxns.where((t) =>
              !t.transactionDate.isBefore(start) && t.transactionDate.isBefore(end)).toList();

          return FutureBuilder<List<Category>>(
            future: catRepo.getAll(),
            builder: (context, catSnap) {
              final categoryMap = <int, Category>{for (final c in (catSnap.data ?? [])) c.id: c};
              final filtered = _applyFilterAndSort(dayTxns, categoryMap);

              if (filtered.isEmpty) return _buildEmptyState(l10n);

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
                    sortLabel: _sortType == SortType.time ? l10n.txnSortByTime : l10n.txnSortByAmount,
                    onSortToggle: () => setState(() {
                      _sortType = _sortType == SortType.time ? SortType.amount : SortType.time;
                    }),
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

  Widget _buildWeekView(TransactionRepository repo, CategoryRepository catRepo, AppLocalizations l10n) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! > 300) {
          // 右滑 - 上一周
          setState(() {
            _currentDate = _currentDate.subtract(const Duration(days: 7));
            _selectedWeekDay = null;
          });
        } else if (details.primaryVelocity! < -300) {
          // 左滑 - 下一周
          setState(() {
            _currentDate = _currentDate.add(const Duration(days: 7));
            _selectedWeekDay = null;
          });
        }
      },
      child: _buildWeekContent(repo, catRepo, l10n),
    );
  }

  Widget _buildWeekContent(TransactionRepository repo, CategoryRepository catRepo, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = _currentDate.subtract(Duration(days: _currentDate.weekday - 1));
    final weekStartDay = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final weekEnd = weekStartDay.add(const Duration(days: 7));
    final inCurrentWeek = !today.isBefore(weekStartDay) && today.isBefore(weekEnd);
    final selectedDay = _selectedWeekDay ?? (inCurrentWeek ? today : weekStartDay);

    return RefreshIndicator(
      onRefresh: () async { _triggerRefresh(); },
      child: StreamBuilder<List<Transaction>>(
        key: ValueKey('week_stats_$_refreshKey'),
        stream: repo.watchAll(ref.watch(currentBookProvider)),
        builder: (context, snapshot) {
          final allTxns = snapshot.data ?? [];
          return FutureBuilder<List<Category>>(
            future: catRepo.getAll(),
            builder: (context, catSnap) {
              // 计算本周每天的收支
              final dailyTotals = <int, ({double expense, double income})>{};
              for (final t in allTxns) {
                if (t.transactionDate.isBefore(weekStartDay) || !t.transactionDate.isBefore(weekEnd)) continue;
                final day = t.transactionDate.day;
                final isExpense = t.type == 'expense';
                final existing = dailyTotals[day];
                if (isExpense) {
                  dailyTotals[day] = (expense: (existing?.expense ?? 0) + t.amount, income: existing?.income ?? 0);
                } else {
                  dailyTotals[day] = (expense: existing?.expense ?? 0, income: (existing?.income ?? 0) + t.amount);
                }
              }
              return Column(
                children: [
                  _buildWeekDayCards(weekStart, selectedDay, dailyTotals, weekStartDay),
                  Expanded(child: _buildWeekTransactionList(repo, catRepo, selectedDay)),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildWeekDayCards(DateTime weekStart, DateTime selectedDay, Map<int, ({double expense, double income})> dailyTotals, DateTime weekStartDay) {
    final l10n = AppLocalizations.of(context)!;
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
          final weekday = [l10n.weekMon, l10n.weekTue, l10n.weekWed, l10n.weekThu, l10n.weekFri, l10n.weekSat, l10n.weekSun][i];
          final totals = dailyTotals[date.day];
          final hasExpense = totals != null && totals.expense > 0;
          final hasIncome = totals != null && totals.income > 0;
          final amountFontSize = Responsive.fs(context, 9);

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedWeekDay = date),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: Responsive.s(context, 2)),
                padding: EdgeInsets.symmetric(vertical: Responsive.s(context, 6)),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.colors.primarySurface
                      : (isToday ? context.colors.primarySurface.withValues(alpha: 0.5) : context.colors.surfaceSecondary),
                  borderRadius: BorderRadius.circular(Responsive.s(context, AppDimensions.radiusSm)),
                  border: isSelected
                      ? Border.all(color: context.colors.primary, width: 2)
                      : (isToday ? Border.all(color: context.colors.primary.withValues(alpha: 0.3), width: 1) : null),
                ),
                child: Column(
                  children: [
                    Text(weekday,
                        style: context.textStyles.caption.copyWith(
                          fontSize: Responsive.fs(context, 11),
                          color: isSelected ? context.colors.primary : context.colors.textTertiary,
                        )),
                    SizedBox(height: Responsive.s(context, 4)),
                    if (hasExpense)
                      Text(
                        '-${_formatCompact(totals.expense)}',
                        style: TextStyle(fontSize: amountFontSize, color: context.colors.expense, height: 1.1),
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (hasIncome)
                      Text(
                        '+${_formatCompact(totals.income)}',
                        style: TextStyle(fontSize: amountFontSize, color: context.colors.income, height: 1.1),
                        overflow: TextOverflow.ellipsis,
                      ),
                    // 始终保留两行高度，保持卡片高度一致
                    if (!hasExpense)
                      SizedBox(height: amountFontSize * 1.1),
                    if (!hasIncome)
                      SizedBox(height: amountFontSize * 1.1),
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
      stream: repo.watchAll(ref.watch(currentBookProvider)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: context.colors.primary));
        }
        final allTxns = snapshot.data ?? [];
        final dayTxns = allTxns.where((t) =>
            !t.transactionDate.isBefore(dayStart) && t.transactionDate.isBefore(dayEnd)).toList();

        return FutureBuilder<List<Category>>(
          future: catRepo.getAll(),
          builder: (context, catSnap) {
            final categoryMap = <int, Category>{for (final c in (catSnap.data ?? [])) c.id: c};
            final filtered = _applyFilterAndSort(dayTxns, categoryMap);

            if (filtered.isEmpty) return _buildEmptyState(AppLocalizations.of(context)!);

            final grouped = _groupByDate(filtered);
            final l10n = AppLocalizations.of(context)!;
            return ListView.builder(
              padding: EdgeInsets.only(bottom: Responsive.s(context, 16)),
              itemCount: grouped.length,
              itemBuilder: (context, index) {
                final entry = grouped.entries.elementAt(index);
                return TransactionGroup(
                  date: entry.key,
                  transactions: entry.value,
                  categoryMap: categoryMap,
                  sortLabel: _sortType == SortType.time ? l10n.txnSortByTime : l10n.txnSortByAmount,
                  onSortToggle: () => setState(() {
                    _sortType = _sortType == SortType.time ? SortType.amount : SortType.time;
                  }),
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

  // ==================== 月视图 ====================

  Widget _buildMonthView(TransactionRepository repo, CategoryRepository catRepo, AppLocalizations l10n) {
    return _buildMonthContent(repo, catRepo);
  }

  Widget _buildMonthContent(TransactionRepository repo, CategoryRepository catRepo) {
    final start = DateTime(_currentDate.year, _currentDate.month, 1);
    final end = DateTime(_currentDate.year, _currentDate.month + 1, 1);

    return RefreshIndicator(
      onRefresh: () async { _triggerRefresh(); },
      child: StreamBuilder<List<Transaction>>(
        key: ValueKey('month_$_refreshKey'),
        stream: repo.watchAll(ref.watch(currentBookProvider)),
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
    final l10n = AppLocalizations.of(context)!;
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
      color: context.colors.surface,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: Responsive.s(context, 8),
              horizontal: Responsive.s(context, AppDimensions.sm),
            ),
            child: Row(
              children: [l10n.weekSun, l10n.weekMon, l10n.weekTue, l10n.weekWed, l10n.weekThu, l10n.weekFri, l10n.weekSat]
                  .map<Widget>((d) => Expanded(
                        child: Center(
                          child: Text(d,
                              style: context.textStyles.caption.copyWith(
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
                      color: isToday ? context.colors.primarySurface : null,
                      borderRadius: BorderRadius.circular(Responsive.s(context, 4)),
                      border: isToday ? Border.all(color: context.colors.primary, width: 1) : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$day',
                          style: TextStyle(
                            fontSize: dayFontSize,
                            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                            color: isToday ? context.colors.primary : context.colors.textPrimary,
                          ),
                        ),
                        if (hasExpense)
                          Text(
                            '-${_formatAmount(totals.expense)}',
                            style: TextStyle(fontSize: amountFontSize, color: context.colors.expense, height: 1.2),
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (hasIncome)
                          Text(
                            '+${_formatAmount(totals.income)}',
                            style: TextStyle(fontSize: amountFontSize, color: context.colors.income, height: 1.2),
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
      return '${(amount / 10000).toStringAsFixed(1)}w';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}k';
    } else if (amount == amount.roundToDouble()) {
      return '${amount.toInt()}';
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  /// 周视图紧凑金额格式（省略小数，超千用k）
  String _formatCompact(double amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}k';
    } else if (amount == amount.roundToDouble()) {
      return '${amount.toInt()}';
    } else {
      return amount.toStringAsFixed(0);
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

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: Responsive.s(context, 48), color: context.colors.textTertiary),
          SizedBox(height: Responsive.s(context, AppDimensions.md)),
          Text(l10n.txnEmpty,
              style: context.textStyles.callout.copyWith(
                color: context.colors.textSecondary,
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
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final repo = ref.read(transactionRepositoryProvider);
    final catRepo = ref.read(categoryRepositoryProvider);
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(DateFormat(l10n.txnDayFormat, locale).format(date)),
        backgroundColor: context.colors.surface,
      ),
      body: StreamBuilder<List<Transaction>>(
        stream: repo.watchAll(ref.watch(currentBookProvider)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: context.colors.primary));
          }
          if (snapshot.hasError) {
            debugPrint('[TransactionList] stream error: ${snapshot.error}');
            return Center(child: Text(AppLocalizations.of(context)!.loadFailedPullToRefresh, style: context.textStyles.body.copyWith(color: context.colors.textTertiary)));
          }
          final allTxns = snapshot.data ?? [];
          final dayTxns = allTxns.where((t) =>
              !t.transactionDate.isBefore(start) && t.transactionDate.isBefore(end)).toList();

          if (dayTxns.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 48, color: context.colors.textTertiary),
                  const SizedBox(height: 16),
                  Text(l10n.txnDayDetailEmpty, style: context.textStyles.callout.copyWith(color: context.colors.textSecondary)),
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
