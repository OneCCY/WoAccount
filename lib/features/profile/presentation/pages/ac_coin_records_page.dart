import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:intl/intl.dart';
import 'package:wo_account/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(l10n.acCoinTitle),
        backgroundColor: context.colors.surface,
      ),
      body: Column(
        children: [
          // 余额卡片
          _buildBalanceCard(l10n),
          // 记录列表
          Expanded(child: _buildTransactionList(l10n)),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.md),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        children: [
          const Text('🪙', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.acCoinCurrentBalance, style: context.textStyles.caption.copyWith(color: Colors.white70)),
              const SizedBox(height: 4),
              Text('$_balance', style: context.textStyles.h1.copyWith(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(AppLocalizations l10n) {
    if (_transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.monetization_on_outlined, size: 48, color: context.colors.textTertiary),
            const SizedBox(height: 16),
            Text(l10n.acCoinEmpty, style: context.textStyles.callout.copyWith(color: context.colors.textSecondary)),
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
    final amountColor = isPositive ? context.colors.income : context.colors.expense;
    final amountText = isPositive ? '+${txn.amount}' : '${txn.amount}';
    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(txn.createdAt);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.colors.separatorOpaque, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(txn.description.isNotEmpty ? txn.description : txn.type,
                    style: context.textStyles.body),
                const SizedBox(height: 4),
                Text(dateStr, style: context.textStyles.caption.copyWith(color: context.colors.textTertiary)),
              ],
            ),
          ),
          Text(amountText, style: context.textStyles.amountList.copyWith(color: amountColor, fontSize: 16)),
        ],
      ),
    );
  }
}
