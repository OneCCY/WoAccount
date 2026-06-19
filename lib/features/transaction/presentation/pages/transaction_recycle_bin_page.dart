import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../config/database/app_database.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/locale/app_currency.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/toast.dart';
import '../../../../core/locale/locale_provider.dart';

/// 交易回收站
/// 显示已软删除的交易记录，支持恢复
class TransactionRecycleBinPage extends ConsumerStatefulWidget {
  const TransactionRecycleBinPage({super.key});

  @override
  ConsumerState<TransactionRecycleBinPage> createState() => _TransactionRecycleBinPageState();
}

class _TransactionRecycleBinPageState extends ConsumerState<TransactionRecycleBinPage> {
  List<Transaction> _deletedTxns = [];
  Map<int, Category?> _categories = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final txnRepo = ref.read(transactionRepositoryProvider);
    final catRepo = ref.read(categoryRepositoryProvider);
    final bookId = ref.read(currentBookProvider);

    final txns = await txnRepo.getDeleted(bookId);
    final cats = <int, Category?>{};
    for (final txn in txns) {
      if (!cats.containsKey(txn.categoryId)) {
        cats[txn.categoryId] = await catRepo.getById(txn.categoryId);
      }
    }

    if (mounted) {
      setState(() {
        _deletedTxns = txns;
        _categories = cats;
        _isLoading = false;
      });
    }
  }

  Future<void> _restore(int id) async {
    final txnRepo = ref.read(transactionRepositoryProvider);
    final success = await txnRepo.restore(id);
    if (success && mounted) {
      AppToast.show(context, AppLocalizations.of(context)!.txnRestored);
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = ref.read(localeProviderOverrideProvider);
    final currency = localeProvider.currency;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(title: Text(l10n.txnRecycleBin)),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: context.colors.primary))
          : _deletedTxns.isEmpty
              ? _buildEmptyState(l10n)
              : _buildList(l10n, currency),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete_outline, size: 48, color: context.colors.textTertiary),
          const SizedBox(height: 16),
          Text(l10n.txnRecycleBinEmpty, style: context.textStyles.callout.copyWith(color: context.colors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildList(AppLocalizations l10n, AppCurrency currency) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 8),
      itemCount: _deletedTxns.length,
      itemBuilder: (context, index) {
        final txn = _deletedTxns[index];
        final cat = _categories[txn.categoryId];
        return _buildItem(txn, cat, l10n, currency);
      },
    );
  }

  Widget _buildItem(Transaction txn, Category? cat, AppLocalizations l10n, AppCurrency currency) {
    final isExpense = txn.type == 'expense';
    final amountColor = isExpense ? context.colors.expense : context.colors.income;
    final amountSign = isExpense ? '-' : '+';
    final dateStr = DateFormat('yyyy-MM-dd').format(txn.transactionDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 分类图标
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.colors.primarySurface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: Center(
                child: Text(cat?.icon ?? '📝', style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            // 信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    txn.description.isNotEmpty ? txn.description : (cat?.name ?? ''),
                    style: context.textStyles.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${cat?.name ?? ''} · $dateStr',
                    style: context.textStyles.caption.copyWith(color: context.colors.textTertiary),
                  ),
                ],
              ),
            ),
            // 金额
            Text(
              '$amountSign${currency.formatAmount(txn.amount)}',
              style: context.textStyles.amountList.copyWith(color: amountColor, fontSize: 16),
            ),
            const SizedBox(width: 8),
            // 恢复按钮
            IconButton(
              icon: Icon(Icons.restore, color: context.colors.primary, size: 22),
              onPressed: () => _restore(txn.id),
              tooltip: l10n.txnRestore,
            ),
          ],
        ),
      ),
    );
  }
}
