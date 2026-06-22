import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:go_router/go_router.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../config/database/app_database.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/locale/category_l10n.dart';
import '../../../../core/locale/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
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

  // 添加子分类预算（仅显示当前一级分类下的子分类）
  Future<void> _onAddBudget() async {
    final catRepo = ref.read(categoryRepositoryProvider);
    final children = await catRepo.getChildren(widget.parentCategoryId);

    if (children.isEmpty || !mounted) return;

    final selected = await showModalBottomSheet<Category>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ChildCategoryPickerSheet(
        categories: children,
        existingIds: _childProgresses.map((p) => p.budget.categoryId).whereType<int>().toSet(),
      ),
    );
    if (selected == null || !mounted) return;

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
    final monthLabel = l10n.reportMonthLabel(
      _currentMonth.year.toString(), _currentMonth.month.toString(),
    );

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: context.colors.textTertiary),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: () => _showMonthPicker(l10n),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.parentCategoryIcon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 6),
              Flexible(child: Text(widget.parentCategoryName, overflow: TextOverflow.ellipsis, style: context.textStyles.h3)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: context.colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(monthLabel, style: context.textStyles.caption.copyWith(
                      color: context.colors.textSecondary, fontWeight: FontWeight.w500,
                    )),
                    const SizedBox(width: 2),
                    Icon(Icons.keyboard_arrow_down, size: 14, color: context.colors.textTertiary),
                  ],
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: context.colors.primary))
          : Column(
              children: [
                _buildSummaryCard(totalBudget, totalSpent, l10n),
                const SizedBox(height: 8),
                Expanded(
                  child: _childProgresses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.category_outlined, size: 48, color: context.colors.textTertiary.withValues(alpha: 0.5)),
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
                _buildAddButton(l10n),
              ],
            ),
    );
  }

  /// 弹出月份选择器
  void _showMonthPicker(AppLocalizations l10n) {
    final months = <DateTime>[];
    for (int y = 2020; y <= 2100; y++) {
      for (int m = 1; m <= 12; m++) {
        final d = DateTime(y, m);
        if (d.isAfter(DateTime(2100, 12))) break;
        months.add(d);
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: 300,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: context.colors.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: months.length,
                itemBuilder: (ctx, i) {
                  final m = months[months.length - 1 - i];
                  final isSelected = m.year == _currentMonth.year && m.month == _currentMonth.month;
                  return ListTile(
                    title: Center(
                      child: Text(
                        l10n.reportMonthLabel(m.year.toString(), m.month.toString()),
                        style: context.textStyles.body.copyWith(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? context.colors.primary : context.colors.textPrimary,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _currentMonth = m;
                        _isLoading = true;
                      });
                      _loadData();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 汇总卡片 — 渐变绿背景，参考一级分类总预算卡片设计
  Widget _buildSummaryCard(double totalBudget, double totalSpent, AppLocalizations l10n) {
    final percentage = totalBudget > 0 ? (totalSpent / totalBudget * 100) : 0.0;
    final remaining = totalBudget - totalSpent;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.md, 8, AppDimensions.md, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.colors.primaryDark.withValues(alpha: 0.85),
              context.colors.primary.withValues(alpha: 0.7),
              context.colors.primaryLight.withValues(alpha: 0.55),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          boxShadow: [
            BoxShadow(
              color: context.colors.primary.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题行 + 子分类数量
            Row(
              children: [
                Text(widget.parentCategoryIcon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(widget.parentCategoryName, style: context.textStyles.footnote.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                )),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    l10n.budgetCategoryCount(_childProgresses.length.toString()),
                    style: context.textStyles.caption.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 金额行：已花费 / 总预算（同一行）
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  context.localeProvider.currency.formatAmount(totalSpent, decimals: 0),
                  style: context.textStyles.amountLarge.copyWith(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  ' / ${context.localeProvider.currency.formatAmount(totalBudget, decimals: 0)}',
                  style: context.textStyles.body.copyWith(color: Colors.white.withValues(alpha: 0.65)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // 进度条
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: (percentage / 100).clamp(0, 1),
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            // 底部信息行
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    l10n.budgetUsedPercent(percentage.toStringAsFixed(0)),
                    style: context.textStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
                const Spacer(),
                Text(
                  l10n.budgetRemaining(context.localeProvider.currency.formatAmount(remaining, decimals: 0)),
                  style: context.textStyles.caption.copyWith(
                    color: remaining < 0 ? const Color(0xFFFFCDD2) : Colors.white.withValues(alpha: 0.7),
                    fontWeight: remaining < 0 ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 子分类行 — 卡片化布局 + 彩色进度条
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
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: context.colors.error,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () => _navigateToTransactions(progress),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            boxShadow: context.colors.cardShadow,
          ),
          child: Row(
            children: [
              // 图标容器
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withValues(alpha: 0.12), color.withValues(alpha: 0.22)],
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Center(child: Text(cat?.icon ?? '📦', style: const TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 12),
              // 名称 + 进度条
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(cat?.name ?? '', style: context.textStyles.body.copyWith(fontWeight: FontWeight.w500))),
                        Text('${percentage.toStringAsFixed(0)}%', style: context.textStyles.caption.copyWith(
                          color: barColor, fontWeight: FontWeight.w500,
                        )),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
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
              // 金额
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(context.localeProvider.currency.formatAmount(progress.spent, decimals: 0),
                    style: context.textStyles.amountSmall.copyWith(
                      color: progress.isOverBudget ? context.colors.error : context.colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    )),
                  const SizedBox(height: 2),
                  Text('/ ${context.localeProvider.currency.formatAmount(progress.budget.amount, decimals: 0)}',
                    style: context.textStyles.caption.copyWith(fontSize: 10)),
                ],
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

  /// 底部新增按钮 — 渐变绿圆角矩形 + 缩放动效
  Widget _buildAddButton(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.md, 8, AppDimensions.md,
        MediaQuery.of(context).viewPadding.bottom + 12,
      ),
      child: _ScaleOnTap(
        onTap: _onAddBudget,
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [context.colors.primaryDark, context.colors.primary, context.colors.primaryLight],
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            boxShadow: [
              BoxShadow(
                color: context.colors.primary.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add, color: Colors.white, size: 20),
                const SizedBox(width: 6),
                Text(l10n.budgetAddCategoryBudget, style: context.textStyles.buttonText.copyWith(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 跳转到子分类的账单列表
  void _navigateToTransactions(BudgetProgress progress) {
    final cat = progress.category;
    if (cat == null) return;
    context.push('/budget/transactions', extra: {
      'categoryId': cat.id,
      'categoryName': cat.name,
      'categoryIcon': cat.icon ?? '📦',
      'year': _currentMonth.year,
      'month': _currentMonth.month,
    });
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

/// 点击缩放动效组件
class _ScaleOnTap extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _ScaleOnTap({required this.child, required this.onTap});

  @override
  State<_ScaleOnTap> createState() => _ScaleOnTapState();
}

class _ScaleOnTapState extends State<_ScaleOnTap> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100), reverseDuration: const Duration(milliseconds: 150));
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

/// 子分类选择器（仅展示当前一级分类下的子分类，已有预算的灰显不可选）
class _ChildCategoryPickerSheet extends StatelessWidget {
  final List<Category> categories;
  final Set<int> existingIds;

  const _ChildCategoryPickerSheet({required this.categories, required this.existingIds});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppDimensions.md, 8, AppDimensions.md,
        MediaQuery.of(context).viewInsets.bottom + AppDimensions.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: context.colors.textTertiary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.budgetAddCategoryBudget, style: AppTextStyles.h3.copyWith(fontSize: 16)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: categories.length,
            itemBuilder: (ctx, i) {
              final cat = categories[i];
              final hasExisting = existingIds.contains(cat.id);
              final color = _parseColorHex(cat.color, context);
              return GestureDetector(
                onTap: hasExisting
                    ? () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.budgetCategoryAlreadyExists),
                          behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 1)))
                    : () => Navigator.pop(context, cat),
                child: Opacity(
                  opacity: hasExisting ? 0.4 : 1.0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                        child: Center(child: Text(cat.icon ?? '📦', style: const TextStyle(fontSize: 22))),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        getCategoryDisplayName(cat, l10n),
                        style: context.textStyles.caption.copyWith(
                          color: hasExisting ? context.colors.textHint : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  static Color _parseColorHex(String? hex, BuildContext context) {
    try {
      if (hex == null || hex.isEmpty) return context.colors.textTertiary;
      return Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16));
    } catch (_) {
      return context.colors.textTertiary;
    }
  }
}
