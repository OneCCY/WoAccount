import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:intl/intl.dart';
import '../../../../config/database/app_database.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

/// AC币记录页
class AcCoinRecordsPage extends ConsumerStatefulWidget {
  const AcCoinRecordsPage({super.key});

  @override
  ConsumerState<AcCoinRecordsPage> createState() => _AcCoinRecordsPageState();
}

class _AcCoinRecordsPageState extends ConsumerState<AcCoinRecordsPage> {
  int _balance = 0;
  List<AcCoinTransaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final db = ref.read(appDatabaseProvider);

      final balances = await db.select(db.acCoinBalances).get();
      final balance = balances.isNotEmpty ? balances.first.balance : 0;

      final txns = await (db.select(db.acCoinTransactions)
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();

      if (mounted) {
        setState(() {
          _balance = balance;
          _transactions = txns;
        });
      }
    } catch (e) {
      debugPrint('加载AC币记录失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AC币记录'),
        backgroundColor: AppColors.surface,
      ),
      body: Column(
        children: [
          // 余额卡片
          _buildBalanceCard(),
          // 记录列表
          Expanded(child: _buildTransactionList()),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.md),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        children: [
          const Text('🪙', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('当前余额', style: AppTextStyles.caption.copyWith(color: Colors.white70)),
              const SizedBox(height: 4),
              Text('$_balance', style: AppTextStyles.h1.copyWith(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    if (_transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.monetization_on_outlined, size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text('暂无AC币记录', style: AppTextStyles.callout.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final txn = _transactions[index];
        return _buildTransactionItem(txn);
      },
    );
  }

  Widget _buildTransactionItem(AcCoinTransaction txn) {
    final isPositive = txn.amount > 0;
    final amountColor = isPositive ? AppColors.income : AppColors.expense;
    final amountText = isPositive ? '+${txn.amount}' : '${txn.amount}';
    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(txn.createdAt);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.separatorOpaque, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(txn.description.isNotEmpty ? txn.description : txn.type,
                    style: AppTextStyles.body),
                const SizedBox(height: 4),
                Text(dateStr, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
              ],
            ),
          ),
          Text(amountText, style: AppTextStyles.amountList.copyWith(color: amountColor, fontSize: 16)),
        ],
      ),
    );
  }
}
