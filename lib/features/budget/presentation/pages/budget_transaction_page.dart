import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../config/database/app_database.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/locale/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 预算关联账单页 — 展示某子分类当月账单，顶部预算金额可直接编辑
class BudgetTransactionPage extends ConsumerStatefulWidget {
  final int categoryId;
  final String categoryName;
  final String categoryIcon;
  final int year;
  final int month;

  const BudgetTransactionPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.year,
    required this.month,
  });

  @override
  ConsumerState<BudgetTransactionPage> createState() => _BudgetTransactionPageState();
}

class _BudgetTransactionPageState extends ConsumerState<BudgetTransactionPage> {
  Budget? _budget;
  double _spent = 0;
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final budgetRepo = ref.read(budgetRepositoryProvider);
    final txnRepo = ref.read(transactionRepositoryProvider);
    final bookId = ref.read(currentBookProvider);

    // 查预算
    final budget = await budgetRepo.getByCategoryId(bookId, widget.categoryId, widget.year, widget.month);

    // 查消费
    final start = DateTime(widget.year, widget.month, 1);
    final end = DateTime(widget.year, widget.month + 1, 1);
    final allTxns = await txnRepo.getByDateRange(bookId, start, end);
    final categoryTxns = allTxns.where((t) =>
        t.categoryId == widget.categoryId || t.parentCategoryId == widget.categoryId).toList();

    final spent = categoryTxns.fold<double>(0, (s, t) => s + (t.type == 'expense' ? t.amount : 0));

    if (mounted) {
      setState(() {
        _budget = budget;
        _spent = spent;
        _transactions = categoryTxns..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
        _isLoading = false;
      });
    }
  }

  /// 点击顶部卡片 → 弹出金额编辑对话框
  Future<void> _editBudgetAmount() async {
    final l10n = AppLocalizations.of(context)!;
    final existing = _budget;
    final controller = TextEditingController(
      text: existing != null ? existing.amount.toStringAsFixed(0) : '',
    );

    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing != null ? l10n.budgetEditTotalTitle : l10n.budgetSetTotalTitle),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.budgetInputAmount,
            prefixText: '${context.localeProvider.currency.symbol} ',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.commonCancel)),
          if (existing != null)
            TextButton(
              onPressed: () async {
                final budgetRepo = ref.read(budgetRepositoryProvider);
                await budgetRepo.delete(existing.id);
                if (ctx.mounted) Navigator.pop(ctx, 0); // 0 = deleted
              },
              child: Text(l10n.commonDelete, style: TextStyle(color: context.colors.error)),
            ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount == null || amount <= 0) return;
              Navigator.pop(ctx, amount);
            },
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );

    if (result == null || !mounted) return;
    if (result == 0) {
      // 删除了预算
      _loadData();
      return;
    }

    final budgetRepo = ref.read(budgetRepositoryProvider);
    final bookId = ref.read(currentBookProvider);
    if (existing != null) {
      await budgetRepo.update(BudgetsCompanion(
        id: drift.Value(existing.id),
        accountBookId: drift.Value(bookId),
        categoryId: drift.Value(widget.categoryId),
        amount: drift.Value(result),
        year: drift.Value(widget.year),
        month: drift.Value(widget.month),
        period: const drift.Value('monthly'),
      ));
    } else {
      await budgetRepo.insert(BudgetsCompanion(
        accountBookId: drift.Value(bookId),
        categoryId: drift.Value(widget.categoryId),
        amount: drift.Value(result),
        year: drift.Value(widget.year),
        month: drift.Value(widget.month),
        period: const drift.Value('monthly'),
      ));
    }
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final budgetAmount = _budget?.amount ?? 0;
    final percentage = budgetAmount > 0 ? (_spent / budgetAmount * 100) : 0.0;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.categoryIcon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(widget.categoryName),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: context.colors.primary))
          : Column(
              children: [
                // 顶部预算卡片（点击直接编辑）
                GestureDetector(
                  onTap: _editBudgetAmount,
                  child: _buildBudgetHeader(budgetAmount, percentage, l10n),
                ),
                // 账单列表
                Expanded(
                  child: _transactions.isEmpty
                      ? Center(
                          child: Text(l10n.txnDayDetailEmpty,
                            style: context.textStyles.callout.copyWith(color: context.colors.textSecondary)),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
                          itemCount: _transactions.length,
                          itemBuilder: (context, index) => _buildTransactionItem(_transactions[index]),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildBudgetHeader(double budgetAmount, double percentage, AppLocalizations l10n) {
    final barColor = percentage > 90 ? context.colors.error : percentage > 70 ? context.colors.warning : context.colors.success;
    final currency = context.localeProvider.currency;

    return Container(
      margin: const EdgeInsets.all(AppDimensions.md),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: context.colors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          // 预算金额 + 实际消费
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.budgetMonthlyTotal, style: context.textStyles.caption.copyWith(color: context.colors.textTertiary)),
                  const SizedBox(height: 2),
                  Text(
                    budgetAmount > 0 ? currency.formatAmount(budgetAmount, decimals: 0) : l10n.budgetSetButton,
                    style: context.textStyles.h3.copyWith(
                      color: budgetAmount > 0 ? context.colors.textPrimary : context.colors.textHint,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(l10n.budgetSpent(''), style: context.textStyles.caption.copyWith(color: context.colors.textTertiary)),
                  const SizedBox(height: 2),
                  Text(
                    currency.formatAmount(_spent, decimals: 0),
                    style: context.textStyles.h3.copyWith(
                      color: percentage > 100 ? context.colors.error : context.colors.textPrimary,
                    ),
                  ),
                ],
              ),
              Icon(Icons.edit_outlined, size: 18, color: context.colors.textTertiary),
            ],
          ),
          if (budgetAmount > 0) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (percentage / 100).clamp(0, 1),
                minHeight: 8,
                backgroundColor: context.colors.surfaceSecondary,
                valueColor: AlwaysStoppedAnimation(barColor),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${percentage.toStringAsFixed(1)}%', style: context.textStyles.caption.copyWith(color: barColor)),
                Text(
                  l10n.budgetRemaining(currency.formatAmount(budgetAmount - _spent, decimals: 0)),
                  style: context.textStyles.caption,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction txn) {
    final isExpense = txn.type == 'expense';
    final amountColor = isExpense ? context.colors.expense : context.colors.income;
    final amountSign = isExpense ? '-' : '+';
    final dateStr = DateFormat('MM/dd HH:mm').format(txn.transactionDate);

    return GestureDetector(
      onTap: () => context.push('/transactions/${txn.id}'),
      child: Container(
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
                  Text(
                    txn.note?.isNotEmpty == true ? txn.note! : txn.description,
                    style: context.textStyles.body.copyWith(
                      fontWeight: txn.note?.isNotEmpty == true ? FontWeight.w500 : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(dateStr, style: context.textStyles.caption.copyWith(color: context.colors.textTertiary)),
                ],
              ),
            ),
            Text(
              '$amountSign${context.localeProvider.currency.formatAmount(txn.amount)}',
              style: context.textStyles.amountList.copyWith(color: amountColor),
            ),
          ],
        ),
      ),
    );
  }
}
