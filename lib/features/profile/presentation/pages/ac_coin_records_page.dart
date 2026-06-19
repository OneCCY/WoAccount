import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      final acCoinRepo = ref.read(acCoinRepositoryProvider);
      final balance = await acCoinRepo.getBalance();
      final txns = await acCoinRepo.getAllTransactions();

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
        return _buildTransactionItem(txn, l10n);
      },
    );
  }

  Widget _buildTransactionItem(AcCoinTransaction txn, AppLocalizations l10n) {
    final isPositive = txn.amount > 0;
    final amountColor = isPositive ? context.colors.income : context.colors.expense;
    final amountText = isPositive ? '+${txn.amount}' : '${txn.amount}';
    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(txn.createdAt);
    final desc = _resolveDescription(txn, l10n);

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
                Text(desc, style: context.textStyles.body),
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

  /// Resolve transaction description via l10nKey, legacy text, or type-based mapping.
  String _resolveDescription(AcCoinTransaction txn, AppLocalizations l10n) {
    // 1) Map known l10nKeys AND legacy localized text to current locale
    final l10nMap = <String, String>{
      'acCoinInitialGiftDesc': l10n.acCoinInitialGiftDesc,
      '新用户注册赠送': l10n.acCoinInitialGiftDesc, // legacy zh data
      'initial_gift': l10n.acCoinInitialGiftDesc,
      'daily_checkin': l10n.checkinRewardDaily,
      'streak_7d': l10n.checkinReward7,
      'streak_30d': l10n.checkinReward30,
      'streak_180d': l10n.checkinReward180,
      'streak_365d': l10n.checkinReward365,
    };
    // Try description field first (may be l10nKey or legacy text)
    if (txn.description.isNotEmpty) {
      final resolved = l10nMap[txn.description];
      if (resolved != null) return resolved;
    }
    // Try type field
    final resolved = l10nMap[txn.type];
    if (resolved != null) return resolved;

    // 2) makeup_cost: needs date from relatedDate
    if (txn.type == 'makeup_cost' && txn.relatedDate != null) {
      final date = DateTime.fromMillisecondsSinceEpoch(txn.relatedDate!);
      return l10n.checkinMakeupCost(DateFormat(l10n.txnDayFormat).format(date));
    }

    // 3) Final fallback: use description as-is, or type
    return txn.description.isNotEmpty ? txn.description : txn.type;
  }
}
