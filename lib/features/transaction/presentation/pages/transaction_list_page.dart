import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../config/database/app_database.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
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

  /// 顶部栏：切换器 + 周期导航
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 8),
      color: AppColors.surface,
      child: Row(
        children: [
          ViewSwitcher(
            currentView: _currentView,
            onViewChanged: (view) => setState(() => _currentView = view),
          ),
          const Spacer(),
          Flexible(child: _buildPeriodNav()),
        ],
      ),
    );
  }

  /// 周期导航：左右箭头 + 日期标签
  Widget _buildPeriodNav() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildArrowButton(Icons.chevron_left, _goPrevious),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              _getPeriodLabel(),
              style: AppTextStyles.footnote.copyWith(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
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
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.separator, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(6),
          child: Icon(icon, size: 14, color: AppColors.textSecondary),
        ),
      ),
    );
  }

  /// 搜索栏
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.md, 8, AppDimensions.md, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 16, color: AppColors.textHint),
                  const SizedBox(width: 8),
                  Text('搜索账单...', style: AppTextStyles.body.copyWith(color: AppColors.textHint)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => context.push('/budget'),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: const Center(
                child: Icon(Icons.account_balance_wallet_outlined, size: 20, color: AppColors.warning),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 统计栏
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
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 4),
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
        padding: const EdgeInsets.symmetric(vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        child: Column(
          children: [
            Text(label, style: AppTextStyles.caption),
            const SizedBox(height: 4),
            Text(value, style: AppTextStyles.amountList.copyWith(color: valueColor)),
          ],
        ),
      ),
    );
  }

  /// 根据当前视图显示不同内容
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
              padding: const EdgeInsets.only(bottom: 16),
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

    return Column(
      children: [
        // 7天日期卡片
        _buildWeekDayCards(weekStart),
        // 交易列表
        Expanded(child: _buildWeekTransactionList(repo, catRepo, weekStart)),
      ],
    );
  }

  /// 7天日期卡片（原型中的周视图核心组件）
  Widget _buildWeekDayCards(DateTime weekStart) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 8),
      child: Row(
        children: List.generate(7, (i) {
          final date = weekStart.add(Duration(days: i));
          final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
          final weekday = ['一', '二', '三', '四', '五', '六', '日'][i];

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _currentDate = date;
                  _currentView = ViewType.day;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isToday ? AppColors.primarySurface : AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  border: isToday ? Border.all(color: AppColors.primary, width: 2) : null,
                ),
                child: Column(
                  children: [
                    Text(weekday, style: AppTextStyles.caption),
                    const SizedBox(height: 2),
                    Text(
                      '${date.day}',
                      style: AppTextStyles.callout.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isToday ? AppColors.primary : AppColors.textPrimary,
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

  Widget _buildWeekTransactionList(TransactionRepository repo, CategoryRepository catRepo, DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 7));

    return StreamBuilder<List<Transaction>>(
      stream: repo.watchAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        final allTxns = snapshot.data ?? [];
        final weekTxns = allTxns.where((t) =>
            t.transactionDate.isAfter(weekStart) && t.transactionDate.isBefore(weekEnd)).toList();

        if (weekTxns.isEmpty) return _buildEmptyState();

        return FutureBuilder<List<Category>>(
          future: catRepo.getAll(),
          builder: (context, catSnap) {
            final categoryMap = <int, Category>{for (final c in (catSnap.data ?? [])) c.id: c};
            final grouped = _groupByDate(weekTxns);
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
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

  Widget _buildMonthView(TransactionRepository repo, CategoryRepository catRepo) {
    return Column(
      children: [
        _buildCalendar(),
        Expanded(child: _buildMonthTransactionList(repo, catRepo)),
      ],
    );
  }

  /// 月历（原型中的月视图核心组件）
  Widget _buildCalendar() {
    final year = _currentDate.year;
    final month = _currentDate.month;
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    final startWeekday = firstDay.weekday % 7; // 0=Sunday
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm),
      child: Column(
        children: [
          // 星期标题
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: ['日', '一', '二', '三', '四', '五', '六']
                  .map((d) => Expanded(
                        child: Center(child: Text(d, style: AppTextStyles.caption)),
                      ))
                  .toList(),
            ),
          ),
          // 日期网格
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
            ),
            itemCount: startWeekday + lastDay.day,
            itemBuilder: (context, index) {
              if (index < startWeekday) return const SizedBox.shrink();
              final day = index - startWeekday + 1;
              final date = DateTime(year, month, day);
              final isToday = date.year == today.year && date.month == today.month && date.day == today.day;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentDate = date;
                    _currentView = ViewType.day;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isToday ? AppColors.primarySurface : null,
                    borderRadius: BorderRadius.circular(4),
                    border: isToday ? Border.all(color: AppColors.primary, width: 1) : null,
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                        color: isToday ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildMonthTransactionList(TransactionRepository repo, CategoryRepository catRepo) {
    final start = DateTime(_currentDate.year, _currentDate.month, 1);
    final end = DateTime(_currentDate.year, _currentDate.month + 1, 1);

    return StreamBuilder<List<Transaction>>(
      stream: repo.watchAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        final allTxns = snapshot.data ?? [];
        final monthTxns = allTxns.where((t) =>
            t.transactionDate.isAfter(start) && t.transactionDate.isBefore(end)).toList();

        if (monthTxns.isEmpty) return _buildEmptyState();

        return FutureBuilder<List<Category>>(
          future: catRepo.getAll(),
          builder: (context, catSnap) {
            final categoryMap = <int, Category>{for (final c in (catSnap.data ?? [])) c.id: c};
            final grouped = _groupByDate(monthTxns);
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
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
          Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.textTertiary),
          const SizedBox(height: AppDimensions.md),
          Text('暂无账单记录', style: AppTextStyles.callout.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
