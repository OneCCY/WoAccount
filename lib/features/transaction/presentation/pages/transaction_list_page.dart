import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../config/database/app_database.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
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

    return Scaffold(
      body: Column(
        children: [
          // 安全区留白
          SizedBox(height: MediaQuery.of(context).padding.top),

          // 顶部切换器
          _buildTopBar(),

          // 搜索栏
          _buildSearchBar(),

          // 统计栏
          _buildStatsBar(repo),

          // 交易列表
          Expanded(
            child: _buildTransactionList(repo),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: 8,
      ),
      color: AppColors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 日/周/月 切换器
          ViewSwitcher(
            currentView: _currentView,
            onViewChanged: (view) {
              setState(() => _currentView = view);
            },
          ),
          // 周期导航
          _buildPeriodNav(),
        ],
      ),
    );
  }

  Widget _buildPeriodNav() {
    return Row(
      children: [
        _buildArrowButton(Icons.chevron_left, () {
          setState(() {
            _currentDate = _currentDate.subtract(const Duration(days: 7));
          });
        }),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            _getPeriodLabel(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        _buildArrowButton(Icons.chevron_right, () {
          setState(() {
            _currentDate = _currentDate.add(const Duration(days: 7));
          });
        }),
      ],
    );
  }

  Widget _buildArrowButton(IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: 28,
      height: 28,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.separator, width: 1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 14, color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  String _getPeriodLabel() {
    switch (_currentView) {
      case ViewType.day:
        return DateFormat('M月d日 EEEE', 'zh_CN').format(_currentDate);
      case ViewType.week:
        final startOfWeek = _currentDate.subtract(
          Duration(days: _currentDate.weekday - 1),
        );
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return '${DateFormat('M月d日').format(startOfWeek)} - ${DateFormat('M月d日').format(endOfWeek)}';
      case ViewType.month:
        return DateFormat('yyyy年M月').format(_currentDate);
    }
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: const [
                  Icon(Icons.search, size: 16, color: AppColors.textTertiary),
                  SizedBox(width: 8),
                  Text(
                    '搜索账单...',
                    style: TextStyle(fontSize: 14, color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 预算入口
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('💰', style: TextStyle(fontSize: 20)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar(TransactionRepository repo) {
    return StreamBuilder<List<Transaction>>(
      stream: repo.watchAll(),
      builder: (context, snapshot) {
        final transactions = snapshot.data ?? [];
        double totalExpense = 0;
        for (final t in transactions) {
          totalExpense += t.amount;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              _buildStatItem('本日支出', '¥${totalExpense.toStringAsFixed(0)}', AppColors.error),
              _buildStatItem('本日收入', '¥0', AppColors.success),
              _buildStatItem('结余', '¥${(-totalExpense).toStringAsFixed(0)}', AppColors.textPrimary),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(TransactionRepository repo) {
    return StreamBuilder<List<Transaction>>(
      stream: repo.watchAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final transactions = snapshot.data ?? [];
        if (transactions.isEmpty) {
          return _buildEmptyState();
        }

        // 按日期分组
        final grouped = _groupByDate(transactions);

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: grouped.length,
          itemBuilder: (context, index) {
            final entry = grouped.entries.elementAt(index);
            return TransactionGroup(
              date: entry.key,
              transactions: entry.value,
              onDelete: (id) => repo.delete(id),
            );
          },
        );
      },
    );
  }

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
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: AppColors.textTertiary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppDimensions.md),
          const Text(
            '暂无账单记录',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
