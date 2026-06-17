import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../config/database/app_database.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/locale/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/toast.dart';
import '../../../../core/widgets/page_refresh_mixin.dart';
import '../../../transaction/presentation/widgets/category_picker_sheet.dart';
import '../../domain/repositories/budget_repository.dart';

/// 预算设置页
/// 总预算 + 分类预算列表 + 添加/编辑/删除
class BudgetSettingPage extends ConsumerStatefulWidget {
  const BudgetSettingPage({super.key});

  @override
  ConsumerState<BudgetSettingPage> createState() => _BudgetSettingPageState();
}

class _BudgetSettingPageState extends ConsumerState<BudgetSettingPage> with PageRefreshMixin {
  @override
  String get routePath => '/budget/setting';

  @override
  void onRefresh() => _loadData();

  late final BudgetRepository _budgetRepo;
  final now = DateTime.now();
  List<BudgetProgress> _progresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _budgetRepo = ref.read(budgetRepositoryProvider);
    _loadData();
  }

  Future<void> _loadData() async {
    final bookId = ref.read(currentBookProvider);
    final progresses = await _budgetRepo.getBudgetProgress(bookId, now.year, now.month);
    if (!mounted) return;
    setState(() {
      _progresses = progresses;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalBudget = _progresses
        .where((p) => p.budget.categoryId == null)
        .fold<double>(0, (sum, p) => sum + p.budget.amount);
    final totalSpent = _progresses
        .where((p) => p.budget.categoryId == null)
        .fold<double>(0, (sum, p) => sum + p.spent);
    final categoryProgresses =
        _progresses.where((p) => p.budget.categoryId != null).toList();

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(title: Text(l10n.budgetSettingTitle)),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: context.colors.primary))
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // 总预算（可点击编辑）
                  GestureDetector(
                    onTap: () => _showTotalBudgetDialog(totalBudget > 0
                        ? _progresses.firstWhere((p) => p.budget.categoryId == null)
                        : null),
                    child: Column(
                      children: [
                        Text(
                          context.localeProvider.currency.formatAmount(totalBudget, decimals: 0),
                          style: context.textStyles.amountLarge,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.budgetCategoryCount('${categoryProgresses.length}'),
                              style: context.textStyles.caption,
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.edit_outlined, size: 14, color: context.colors.textTertiary),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 使用进度
                  if (totalBudget > 0) _buildUsageBar(totalBudget, totalSpent),

                  const SizedBox(height: 24),

                  // 分类预算列表
                  ...categoryProgresses.map((p) => _buildCategoryBudgetItem(context, p)),

                  // 添加按钮
                  Padding(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    child: OutlinedButton.icon(
                      onPressed: _onAddCategoryBudget,
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(l10n.budgetAddCategoryBudget),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        side: BorderSide(color: context.colors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildUsageBar(double total, double spent) {
    final l10n = AppLocalizations.of(context)!;
    final percentage = total > 0 ? (spent / total * 100) : 0.0;
    final barColor = percentage > 90
        ? context.colors.error
        : percentage > 70
            ? context.colors.warning
            : context.colors.success;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (percentage / 100).clamp(0, 1),
                minHeight: 10,
                backgroundColor: context.colors.surfaceSecondary,
                valueColor: AlwaysStoppedAnimation(barColor),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.budgetUsedPercent(percentage.toStringAsFixed(1)), style: context.textStyles.caption),
                Text(l10n.budgetRemaining(context.localeProvider.currency.formatAmount(total - spent, decimals: 0)), style: context.textStyles.caption),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBudgetItem(BuildContext context, BudgetProgress progress) {
    final cat = progress.category;
    final color = _parseColor(context, cat?.color);

    return Dismissible(
      key: ValueKey(progress.budget.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDeleteBudget(progress),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 4),
        decoration: BoxDecoration(
          color: context.colors.error,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: 4,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Center(
                  child: Text(cat?.icon ?? '📦', style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cat?.name ?? AppLocalizations.of(context)!.budgetUncategorized, style: context.textStyles.body),
                    const SizedBox(height: 4),
                    Text(
                      '${AppLocalizations.of(context)!.budgetSpent(context.localeProvider.currency.formatAmount(progress.spent, decimals: 0))}  ·  ${progress.percentage.toStringAsFixed(0)}%',
                      style: context.textStyles.caption.copyWith(
                        color: progress.isOverBudget ? context.colors.error : null,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                context.localeProvider.currency.formatAmount(progress.budget.amount, decimals: 0),
                style: context.textStyles.amountSmall,
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _onEditBudget(progress),
                child: Icon(Icons.edit_outlined, size: 18, color: context.colors.textTertiary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== 总预算设置/编辑 ====================

  void _showTotalBudgetDialog(BudgetProgress? existing) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(
      text: existing != null ? existing.budget.amount.toStringAsFixed(0) : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing != null ? l10n.budgetEditTotalTitle : l10n.budgetSetTotalTitle),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.budgetInputAmount,
            prefixText: '${context.localeProvider.currency.symbol} ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonCancel),
          ),
          if (existing != null)
            TextButton(
              onPressed: () async {
                await _budgetRepo.delete(existing.budget.id);
                if (ctx.mounted) Navigator.pop(ctx);
                _loadData();
              },
              child: Text(l10n.commonDelete, style: TextStyle(color: context.colors.error)),
            ),
          TextButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text);
              if (amount == null || amount <= 0) return;
              final bookId = ref.read(currentBookProvider);
              if (existing != null) {
                await _budgetRepo.update(BudgetsCompanion(
                  id: drift.Value(existing.budget.id),
                  accountBookId: drift.Value(bookId),
                  amount: drift.Value(amount),
                  year: drift.Value(now.year),
                  month: drift.Value(now.month),
                  period: const drift.Value('monthly'),
                ));
              } else {
                await _budgetRepo.insert(BudgetsCompanion(
                  accountBookId: drift.Value(bookId),
                  amount: drift.Value(amount),
                  year: drift.Value(now.year),
                  month: drift.Value(now.month),
                  period: const drift.Value('monthly'),
                ));
              }
              if (ctx.mounted) Navigator.pop(ctx);
              _loadData();
            },
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
  }

  // ==================== 添加分类预算 ====================

  void _onAddCategoryBudget() async {
    final l10n = AppLocalizations.of(context)!;

    // 1. 打开分类选择器（复用 CategoryPickerSheet）
    final selected = await _showCategoryPicker();
    if (selected == null || !mounted) return;

    // 2. 检查是否已有该分类预算
    final existingCatIds = _progresses
        .where((p) => p.budget.categoryId != null)
        .map((p) => p.budget.categoryId!)
        .toSet();
    if (existingCatIds.contains(selected.id)) {
      AppToast.show(context, l10n.budgetCategoryAlreadyExists, duration: const Duration(seconds: 1));
      return;
    }

    // 3. 弹出金额输入对话框
    _showAmountDialog(
      title: '${selected.icon ?? ''} ${selected.name}',
      onConfirm: (amount) => _saveCategoryBudget(selected.id, amount),
    );
  }

  /// 复用 CategoryPickerSheet，只允许选择未设置预算的支出子分类
  Future<Category?> _showCategoryPicker() async {
    // 先弹出分类选择器
    final picked = await showModalBottomSheet<Category>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CategoryPickerSheet(initialIsExpense: true),
    );
    return picked;
  }

  Future<void> _saveCategoryBudget(int categoryId, double amount) async {
    final bookId = ref.read(currentBookProvider);
    await _budgetRepo.insert(BudgetsCompanion(
      accountBookId: drift.Value(bookId),
      categoryId: drift.Value(categoryId),
      amount: drift.Value(amount),
      year: drift.Value(now.year),
      month: drift.Value(now.month),
      period: const drift.Value('monthly'),
    ));
    _loadData();
  }

  /// 金额输入对话框
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
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.budgetInputAmount,
            prefixText: '${context.localeProvider.currency.symbol} ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonCancel),
          ),
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

  // ==================== 编辑分类预算 ====================

  void _onEditBudget(BudgetProgress progress) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(
      text: progress.budget.amount.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.budgetEditCategoryTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 分类名称
            Row(
              children: [
                Text(progress.category?.icon ?? '📦', style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(progress.category?.name ?? l10n.budgetUncategorized,
                    style: context.textStyles.body.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n.budgetInputAmount,
                prefixText: '${context.localeProvider.currency.symbol} ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () async {
              await _budgetRepo.delete(progress.budget.id);
              if (ctx.mounted) Navigator.pop(ctx);
              _loadData();
            },
            child: Text(l10n.commonDelete, style: TextStyle(color: context.colors.error)),
          ),
          TextButton(
            onPressed: () => _updateCategoryBudget(progress, controller.text, ctx),
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
  }

  Future<void> _updateCategoryBudget(BudgetProgress progress, String amountStr, BuildContext dialogCtx) async {
    final amount = double.tryParse(amountStr);
    if (amount == null || amount <= 0) return;

    await _budgetRepo.update(BudgetsCompanion(
      id: drift.Value(progress.budget.id),
      accountBookId: drift.Value(progress.budget.accountBookId),
      categoryId: drift.Value(progress.budget.categoryId),
      amount: drift.Value(amount),
      year: drift.Value(progress.budget.year),
      month: drift.Value(progress.budget.month),
      period: drift.Value(progress.budget.period),
    ));

    if (dialogCtx.mounted) Navigator.pop(dialogCtx);
    _loadData();
  }

  // ==================== 删除确认 ====================

  Future<bool?> _confirmDeleteBudget(BudgetProgress progress) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.budgetDeleteTitle),
        content: Text(l10n.budgetDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () async {
              await _budgetRepo.delete(progress.budget.id);
              if (ctx.mounted) Navigator.pop(ctx, true);
              _loadData();
            },
            child: Text(l10n.commonDelete, style: TextStyle(color: context.colors.error)),
          ),
        ],
      ),
    );
  }

  Color _parseColor(BuildContext context, String? hex) {
    if (hex == null || hex.isEmpty) return context.colors.textTertiary;
    final clean = hex.replaceFirst('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }
}
