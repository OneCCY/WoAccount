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
  List<Category> _allCategories = [];
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
    final categories = await ref.read(categoryRepositoryProvider).getAll();
    if (!mounted) return;
    setState(() {
      _progresses = progresses;
      _allCategories = categories;
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

  void _onAddCategoryBudget() {
    final l10n = AppLocalizations.of(context)!;

    // 获取已设置预算的分类 ID
    final existingCatIds = _progresses
        .where((p) => p.budget.categoryId != null)
        .map((p) => p.budget.categoryId!)
        .toSet();

    // 筛选支出子分类（level 2）且未设置预算的
    final available = _allCategories
        .where((c) => c.level == 2 && c.isExpense && !existingCatIds.contains(c.id))
        .toList();

    if (available.isEmpty) {
      AppToast.show(context, l10n.budgetNoCategoryAvailable, duration: const Duration(seconds: 1));
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _CategoryBudgetSheet(
        categories: available,
        allCategories: _allCategories,
        onSave: (categoryId, amount) => _saveCategoryBudget(categoryId, amount, ctx),
      ),
    );
  }

  Future<void> _saveCategoryBudget(int categoryId, double amount, BuildContext dialogCtx) async {
    final bookId = ref.read(currentBookProvider);
    await _budgetRepo.insert(BudgetsCompanion(
      accountBookId: drift.Value(bookId),
      categoryId: drift.Value(categoryId),
      amount: drift.Value(amount),
      year: drift.Value(now.year),
      month: drift.Value(now.month),
      period: const drift.Value('monthly'),
    ));
    if (dialogCtx.mounted) Navigator.pop(dialogCtx);
    _loadData();
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

// ==================== 分类预算选择底部弹窗 ====================

/// 分类选择 + 金额输入 底部弹窗
class _CategoryBudgetSheet extends StatefulWidget {
  final List<Category> categories;
  final List<Category> allCategories;
  final void Function(int categoryId, double amount) onSave;

  const _CategoryBudgetSheet({
    required this.categories,
    required this.allCategories,
    required this.onSave,
  });

  @override
  State<_CategoryBudgetSheet> createState() => _CategoryBudgetSheetState();
}

class _CategoryBudgetSheetState extends State<_CategoryBudgetSheet> {
  int? _selectedCategoryId;
  final _amountController = TextEditingController();

  /// 按父分类分组
  Map<Category, List<Category>> get _grouped {
    final map = <Category, List<Category>>{};
    for (final cat in widget.categories) {
      final parent = widget.allCategories.firstWhere(
        (c) => c.id == cat.parentId,
        orElse: () => cat,
      );
      map.putIfAbsent(parent, () => []).add(cat);
    }
    return map;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽指示条
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.textHint,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // 标题栏
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(l10n.budgetAddCategoryBudget,
                    style: context.textStyles.h3.copyWith(fontSize: 17)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, size: 22, color: context.colors.textSecondary),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // 金额输入
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n.budgetInputAmount,
                prefixText: '${context.localeProvider.currency.symbol} ',
                filled: true,
                fillColor: context.colors.surfaceSecondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          // 分类列表
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _grouped.entries.map((entry) {
                  final parent = entry.key;
                  final children = entry.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 6),
                        child: Text(
                          '${parent.icon ?? ''} ${parent.name}',
                          style: context.textStyles.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: children.map((cat) {
                          final isSelected = _selectedCategoryId == cat.id;
                          return ChoiceChip(
                            label: Text(cat.name, style: const TextStyle(fontSize: 13)),
                            selected: isSelected,
                            selectedColor: context.colors.primarySurface,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategoryId = selected ? cat.id : null;
                                if (selected) {
                                  FocusScope.of(context).nextFocus();
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          // 底部按钮
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: _canSave ? _save : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.textOnPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(l10n.commonSave, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool get _canSave =>
      _selectedCategoryId != null &&
      double.tryParse(_amountController.text) != null &&
      double.parse(_amountController.text) > 0;

  void _save() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0 || _selectedCategoryId == null) return;
    widget.onSave(_selectedCategoryId!, amount);
  }
}
