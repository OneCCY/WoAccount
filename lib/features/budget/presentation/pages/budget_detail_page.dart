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
import '../../../../core/widgets/toast.dart';
import '../../../transaction/presentation/widgets/category_picker_sheet.dart';
import '../../domain/repositories/budget_repository.dart';

/// 预算详情页 — 展示某一父分类下的所有子分类预算
/// 支持添加/编辑/删除子分类预算，点击子分类可查看关联账单
class BudgetDetailPage extends ConsumerStatefulWidget {
  final int parentCategoryId;
  final String parentCategoryName;
  final String parentCategoryIcon;

  const BudgetDetailPage({
    super.key,
    required this.parentCategoryId,
    required this.parentCategoryName,
    required this.parentCategoryIcon,
  });

  @override
  ConsumerState<BudgetDetailPage> createState() => _BudgetDetailPageState();
}

class _BudgetDetailPageState extends ConsumerState<BudgetDetailPage> {
  late DateTime _currentMonth;
  List<BudgetProgress> _childProgresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _loadData();
  }

  Future<void> _loadData() async {
    final budgetRepo = ref.read(budgetRepositoryProvider);
    final bookId = ref.read(currentBookProvider);
    final allProgress = await budgetRepo.getBudgetProgress(bookId, _currentMonth.year, _currentMonth.month);

    // 过滤出当前父分类下的子分类预算
    final catRepo = ref.read(categoryRepositoryProvider);
    final children = await catRepo.getChildren(widget.parentCategoryId);
    final childIds = children.map((c) => c.id).toSet();

    final childProgresses = allProgress.where((p) =>
        p.budget.categoryId != null && childIds.contains(p.budget.categoryId)).toList();

    if (mounted) {
      setState(() {
        _childProgresses = childProgresses;
        _isLoading = false;
      });
    }
  }

  // 月份导航
  void _changeMonth(int delta) {
    final now = DateTime.now();
    final next = DateTime(_currentMonth.year, _currentMonth.month + delta);
    if (delta > 0 && next.isAfter(DateTime(now.year, now.month))) return;
    setState(() {
      _currentMonth = next;
      _isLoading = true;
    });
    _loadData();
  }

  // 添加子分类预算
  Future<void> _onAddBudget() async {
    final l10n = AppLocalizations.of(context)!;
    final selected = await showModalBottomSheet<Category>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CategoryPickerSheet(initialIsExpense: true),
    );
    if (selected == null || !mounted) return;

    // 检查是否已有该分类预算
    if (_childProgresses.any((p) => p.budget.categoryId == selected.id)) {
      AppToast.show(context, l10n.budgetCategoryAlreadyExists);
      return;
    }

    _showAmountDialog(
      title: '${selected.icon ?? ''} ${selected.name}',
      onConfirm: (amount) async {
        final budgetRepo = ref.read(budgetRepositoryProvider);
        final bookId = ref.read(currentBookProvider);
        await budgetRepo.insert(BudgetsCompanion(
          accountBookId: drift.Value(bookId),
          categoryId: drift.Value(selected.id),
          amount: drift.Value(amount),
          year: drift.Value(_currentMonth.year),
          month: drift.Value(_currentMonth.month),
          period: const drift.Value('monthly'),
        ));
        _loadData();
      },
    );
  }

  // 编辑子分类预算
  void _onEditBudget(BudgetProgress progress) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: progress.budget.amount.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.budgetEditCategoryTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(progress.category?.icon ?? '📦', style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(progress.category?.name ?? '', style: context.textStyles.body.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n.budgetInputAmount,
                prefixText: '${context.localeProvider.currency.symbol} ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.commonCancel)),
          TextButton(
            onPressed: () async {
              final budgetRepo = ref.read(budgetRepositoryProvider);
              await budgetRepo.delete(progress.budget.id);
              if (ctx.mounted) Navigator.pop(ctx);
              _loadData();
            },
            child: Text(l10n.commonDelete, style: TextStyle(color: context.colors.error)),
          ),
          TextButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text);
              if (amount == null || amount <= 0) return;
              final budgetRepo = ref.read(budgetRepositoryProvider);
              await budgetRepo.update(BudgetsCompanion(
                id: drift.Value(progress.budget.id),
                accountBookId: drift.Value(progress.budget.accountBookId),
                categoryId: drift.Value(progress.budget.categoryId),
                amount: drift.Value(amount),
                year: drift.Value(_currentMonth.year),
                month: drift.Value(_currentMonth.month),
                period: const drift.Value('monthly'),
              ));
              if (ctx.mounted) Navigator.pop(ctx);
              _loadData();
            },
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
  }

  // 删除子分类预算
  Future<bool?> _onDeleteBudget(BudgetProgress progress) async {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.budgetDeleteTitle),
        content: Text(l10n.budgetDeleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          TextButton(
            onPressed: () async {
              final budgetRepo = ref.read(budgetRepositoryProvider);
              await budgetRepo.delete(progress.budget.id);
              if (ctx.mounted) Navigator.pop(ctx, true);
              _loadData();
            },
            child: Text(l10n.commonDelete, style: TextStyle(color: context.colors.error)),
          ),
        ],
      ),
    );
  }

  void _showAmountDialog({required String title, required void Function(double amount) onConfirm}) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
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
          TextButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount == null || amount <= 0) return;
              Navigator.pop(ctx);
              onConfirm(amount);
            },
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalBudget = _childProgresses.fold<double>(0, (s, p) => s + p.budget.amount);
    final totalSpent = _childProgresses.fold<double>(0, (s, p) => s + p.spent);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.parentCategoryIcon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(widget.parentCategoryName),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _onAddBudget),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: context.colors.primary))
          : Column(
              children: [
                // 月份导航
                _buildMonthNav(l10n),
                // 顶部预算汇总卡片（可点击编辑）
                _buildSummaryCard(totalBudget, totalSpent, l10n),
                const SizedBox(height: 8),
                // 子分类预算列表
                Expanded(
                  child: _childProgresses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.category_outlined, size: 48, color: context.colors.textTertiary),
                              const SizedBox(height: 12),
                              Text(l10n.budgetNoBudgets, style: context.textStyles.callout.copyWith(color: context.colors.textSecondary)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
                          itemCount: _childProgresses.length,
                          itemBuilder: (context, index) => _buildChildItem(_childProgresses[index]),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildMonthNav(AppLocalizations l10n) {
    final now = DateTime.now();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 8),
      color: context.colors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 24),
            onPressed: () => _changeMonth(-1),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          const SizedBox(width: 16),
          Text(
            l10n.reportMonthLabel(_currentMonth.year.toString(), _currentMonth.month.toString()),
            style: context.textStyles.h3.copyWith(fontSize: 16),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: Icon(Icons.chevron_right, size: 24,
              color: DateTime(_currentMonth.year, _currentMonth.month + 1).isAfter(DateTime(now.year, now.month))
                  ? context.colors.textHint : null),
            onPressed: () => _changeMonth(1),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double totalBudget, double totalSpent, AppLocalizations l10n) {
    final percentage = totalBudget > 0 ? (totalSpent / totalBudget * 100) : 0.0;
    final barColor = percentage > 90 ? context.colors.error : percentage > 70 ? context.colors.warning : context.colors.success;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.md, 8, AppDimensions.md, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.budgetSpent(context.localeProvider.currency.formatAmount(totalSpent, decimals: 0)),
                  style: context.textStyles.body.copyWith(fontWeight: FontWeight.w500)),
                Text('/ ${context.localeProvider.currency.formatAmount(totalBudget, decimals: 0)}',
                  style: context.textStyles.footnote.copyWith(color: context.colors.textSecondary)),
              ],
            ),
            const SizedBox(height: 8),
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
                Text(l10n.budgetRemaining(context.localeProvider.currency.formatAmount(totalBudget - totalSpent, decimals: 0)),
                  style: context.textStyles.caption),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildItem(BudgetProgress progress) {
    final cat = progress.category;
    final color = _parseColor(cat?.color);
    final percentage = progress.percentage;
    final barColor = percentage > 90 ? context.colors.error : percentage > 70 ? context.colors.warning : context.colors.success;

    return Dismissible(
      key: ValueKey(progress.budget.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _onDeleteBudget(progress),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: context.colors.error,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () => _navigateToTransactions(progress),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    ),
                    child: Center(child: Text(cat?.icon ?? '📦', style: const TextStyle(fontSize: 18))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(cat?.name ?? '', style: context.textStyles.body),
                            Text('${percentage.toStringAsFixed(1)}%', style: context.textStyles.caption.copyWith(color: barColor)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (percentage / 100).clamp(0, 1),
                            minHeight: 6,
                            backgroundColor: context.colors.surfaceSecondary,
                            valueColor: AlwaysStoppedAnimation(barColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(context.localeProvider.currency.formatAmount(progress.spent, decimals: 0),
                        style: context.textStyles.amountSmall.copyWith(
                          color: progress.isOverBudget ? context.colors.error : context.colors.textPrimary,
                        )),
                      Text('/ ${context.localeProvider.currency.formatAmount(progress.budget.amount, decimals: 0)}',
                        style: context.textStyles.caption),
                    ],
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => _onEditBudget(progress),
                    child: Icon(Icons.edit_outlined, size: 18, color: context.colors.textTertiary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 跳转到子分类的账单列表
  void _navigateToTransactions(BudgetProgress progress) {
    final cat = progress.category;
    if (cat == null) return;
    context.push('/budget/transactions?categoryId=${cat.id}&categoryName=${Uri.encodeComponent(cat.name)}&categoryIcon=${cat.icon ?? "📦"}&year=${_currentMonth.year}&month=${_currentMonth.month}');
  }

  Color _parseColor(String? hex) {
    try {
      if (hex == null || hex.isEmpty) return context.colors.textTertiary;
      final clean = hex.replaceFirst('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return context.colors.textTertiary;
    }
  }
}
