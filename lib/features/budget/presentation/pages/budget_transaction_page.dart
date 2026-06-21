import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:go_router/go_router.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../config/database/app_database.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/locale/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../transaction/presentation/widgets/transaction_group.dart';

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
  Map<int, Category> _categoryMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final budgetRepo = ref.read(budgetRepositoryProvider);
    final txnRepo = ref.read(transactionRepositoryProvider);
    final catRepo = ref.read(categoryRepositoryProvider);
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

    // 构建分类映射（用于 TransactionGroup 展示）
    final catIds = <int>{};
    for (final t in categoryTxns) {
      catIds.add(t.categoryId);
      if (t.parentCategoryId != null) catIds.add(t.parentCategoryId!);
    }
    final catMap = <int, Category>{};
    for (final id in catIds) {
      final cat = await catRepo.getById(id);
      if (cat != null) catMap[id] = cat;
    }

    if (mounted) {
      setState(() {
        _budget = budget;
        _spent = spent;
        _transactions = categoryTxns..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
        _categoryMap = catMap;
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
                // 账单列表（按日期分组，只读模式）
                Expanded(
                  child: _transactions.isEmpty
                      ? Center(
                          child: Text(l10n.txnDayDetailEmpty,
                            style: context.textStyles.callout.copyWith(color: context.colors.textSecondary)),
                        )
                      : _buildGroupedList(),
                ),
              ],
            ),
    );
  }

  /// 按日期分组的账单列表
  Widget _buildGroupedList() {
    final grouped = <DateTime, List<Transaction>>{};
    for (final t in _transactions) {
      final dateKey = DateTime(t.transactionDate.year, t.transactionDate.month, t.transactionDate.day);
      grouped.putIfAbsent(dateKey, () => []).add(t);
    }
    final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final date = dates[index];
        final txns = grouped[date]!;
        return TransactionGroup(
          date: date,
          transactions: txns,
          categoryMap: _categoryMap,
          onDelete: null, // 只读，不支持滑动删除
          onTap: (t) => context.push('/budget/transactions/detail/${t.id}'),
        );
      },
    );
  }

  Widget _buildBudgetHeader(double budgetAmount, double percentage, AppLocalizations l10n) {
    final barColor = percentage > 90 ? context.colors.error : percentage > 70 ? context.colors.warning : context.colors.success;
    final currency = context.localeProvider.currency;
    final remaining = budgetAmount - _spent;
    final hasBudget = budgetAmount > 0;
    // 根据消费比例使用对应颜色的淡色背景，与下方白色列表形成对比
    final statusColor = percentage > 90 ? context.colors.error : percentage > 70 ? context.colors.warning : context.colors.expense;
    final bgTint = statusColor.withValues(alpha: 0.06);

    return Container(
      margin: const EdgeInsets.fromLTRB(AppDimensions.md, 0, AppDimensions.md, 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: bgTint,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: statusColor.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          // 分类图标 + 已消费标签 + 编辑按钮
          Row(
            children: [
              Text(widget.categoryIcon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(l10n.budgetSpent(''), style: context.textStyles.footnote.copyWith(
                color: context.colors.textSecondary, fontWeight: FontWeight.w500,
              )),
              const Spacer(),
              Icon(Icons.edit_outlined, size: 16, color: context.colors.textTertiary),
            ],
          ),
          const SizedBox(height: 8),
          // 已消费金额（主视觉焦点）
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              currency.formatAmount(_spent, decimals: 0),
              style: AppTextStyles.amountLarge.copyWith(
                color: percentage > 100 ? context.colors.error : context.colors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 进度条
          if (hasBudget) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (percentage / 100).clamp(0, 1),
                minHeight: 6,
                backgroundColor: context.colors.surfaceSecondary,
                valueColor: AlwaysStoppedAnimation(barColor),
              ),
            ),
            const SizedBox(height: 8),
            // 预算总额 / 剩余 / 百分比
            Row(
              children: [
                Text(
                  '${l10n.budgetMonthlyTotal} ${currency.formatAmount(budgetAmount, decimals: 0)}',
                  style: context.textStyles.caption.copyWith(color: context.colors.textTertiary),
                ),
                const SizedBox(width: 6),
                Text('${percentage.toStringAsFixed(1)}%', style: context.textStyles.caption.copyWith(
                  color: barColor, fontWeight: FontWeight.w600,
                )),
                const Spacer(),
                Text(
                  l10n.budgetRemaining(currency.formatAmount(remaining, decimals: 0)),
                  style: context.textStyles.caption.copyWith(
                    color: remaining < 0 ? context.colors.error : context.colors.textTertiary,
                    fontWeight: remaining < 0 ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ] else
            Text(
              l10n.budgetSetButton,
              style: context.textStyles.footnote.copyWith(color: context.colors.textHint),
            ),
        ],
      ),
    );
  }
}
