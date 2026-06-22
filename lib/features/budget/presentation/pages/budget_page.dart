import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../config/database/app_database.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/locale/category_l10n.dart';
import '../../../../core/locale/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/toast.dart';
import '../../domain/repositories/budget_repository.dart';

/// 预算视图模式
enum _BudgetView { month, year }

/// 预算管理页
/// 月视图：仅展示有二级预算的一级分类，月份在 AppBar 可滚动切换
class BudgetPage extends ConsumerStatefulWidget {
  const BudgetPage({super.key});

  @override
  ConsumerState<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends ConsumerState<BudgetPage> {
  late DateTime _currentMonth;
  _BudgetView _view = _BudgetView.month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
  }

  /// 弹出月份选择器（可上下滚动）
  void _showMonthPicker(AppLocalizations l10n) {
    final now = DateTime.now();
    final months = <DateTime>[];
    for (int y = now.year - 1; y <= now.year; y++) {
      for (int m = 1; m <= 12; m++) {
        final d = DateTime(y, m);
        if (d.isAfter(DateTime(now.year, now.month))) break;
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
                      setState(() => _currentMonth = m);
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final monthLabel = l10n.reportMonthLabel(
      _currentMonth.year.toString(),
      _currentMonth.month.toString(),
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
              Text(l10n.budgetTitle, style: context.textStyles.h3),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: context.colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(monthLabel, style: context.textStyles.caption.copyWith(
                      color: context.colors.textSecondary,
                      fontWeight: FontWeight.w500,
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
        actions: [_buildViewToggle(l10n)],
      ),
      body: _view == _BudgetView.month
          ? _buildMonthView(l10n)
          : _buildYearView(l10n),
    );
  }

  /// 从一级分类选择器进入详情页（仅显示一级分类）
  Future<void> _onAddBudget(AppLocalizations l10n) async {
    final catRepo = ref.read(categoryRepositoryProvider);
    final allCats = await catRepo.getTopLevel();
    final expenseParents = allCats.where((c) => c.isExpense).toList();

    if (expenseParents.isEmpty || !mounted) return;

    // 查询已有预算的父分类 ID
    final budgetRepo = ref.read(budgetRepositoryProvider);
    final bookId = ref.read(currentBookProvider);
    final allProgress = await budgetRepo.getBudgetProgress(bookId, _currentMonth.year, _currentMonth.month);
    final categoryProgresses = allProgress.where((p) => p.budget.categoryId != null).toList();
    final existingParentIds = <int>{};
    for (final p in categoryProgresses) {
      final cat = p.category;
      if (cat == null) continue;
      existingParentIds.add(cat.parentId ?? cat.id);
    }

    if (!mounted) return;

    final selected = await showModalBottomSheet<Category>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ParentCategoryPickerSheet(
        categories: expenseParents,
        existingIds: existingParentIds,
      ),
    );
    if (selected == null || !mounted) return;

    final name = getCategoryDisplayName(selected, l10n);
    context.push('/budget/detail', extra: {
      'parentCategoryId': selected.id,
      'parentCategoryName': name,
      'parentCategoryIcon': selected.icon ?? '📦',
    });
  }

  /// 月/年切换 — 胶囊型
  Widget _buildViewToggle(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleBtn(l10n.budgetViewMonth, _BudgetView.month),
          _toggleBtn(l10n.budgetViewYear, _BudgetView.year),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, _BudgetView v) {
    final active = _view == v;
    return GestureDetector(
      onTap: () => setState(() => _view = v),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: active ? context.colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: active ? [
            BoxShadow(color: context.colors.primary.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 1)),
          ] : null,
        ),
        child: Text(label,
          style: context.textStyles.caption.copyWith(
            color: active ? context.colors.textOnPrimary : context.colors.textSecondary,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          )),
      ),
    );
  }

  // ==================== 月视图：仅展示有预算的一级分类 ====================

  Widget _buildMonthView(AppLocalizations l10n) {
    final budgetRepo = ref.read(budgetRepositoryProvider);
    final bookId = ref.watch(currentBookProvider);

    return FutureBuilder<List<BudgetProgress>>(
      future: budgetRepo.getBudgetProgress(bookId, _currentMonth.year, _currentMonth.month),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: context.colors.primary));
        }

        final allProgress = snap.data ?? [];
        final categoryProgresses = allProgress.where((p) => p.budget.categoryId != null).toList();

        if (categoryProgresses.isEmpty) {
          return _buildEmptyState(l10n);
        }

        // 计算总预算和总花费
        final totalBudget = categoryProgresses.fold<double>(0, (s, p) => s + p.budget.amount);
        final totalSpent = categoryProgresses.fold<double>(0, (s, p) => s + p.spent);
        final globalBudgets = allProgress.where((p) => p.budget.categoryId == null).toList();
        final globalBudget = globalBudgets.fold<double>(0, (s, p) => s + p.budget.amount);

        // 按父分类分组
        final parentGroups = <int, List<BudgetProgress>>{};
        for (final p in categoryProgresses) {
          final cat = p.category;
          if (cat == null) continue;
          final pid = cat.parentId ?? cat.id;
          parentGroups.putIfAbsent(pid, () => []).add(p);
        }

        final catRepo = ref.read(categoryRepositoryProvider);
        return FutureBuilder<List<Category>>(
          future: catRepo.getTopLevel(),
          builder: (context, catSnap) {
            final allParents = catSnap.data ?? [];
            final parentMap = {for (final c in allParents) c.id: c};

            return Column(
              children: [
                _buildMonthTotalCard(totalBudget, totalSpent, globalBudget, parentGroups.length, l10n),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => setState(() {}),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(AppDimensions.md, 4, AppDimensions.md, 8),
                      itemCount: parentGroups.length,
                      itemBuilder: (context, index) {
                        final entry = parentGroups.entries.elementAt(index);
                        final parent = parentMap[entry.key];
                        if (parent == null) return const SizedBox.shrink();
                        final children = entry.value;
                        final groupBudget = children.fold<double>(0, (s, p) => s + p.budget.amount);
                        final groupSpent = children.fold<double>(0, (s, p) => s + p.spent);
                        return _buildParentItem(parent, groupBudget, groupSpent, children.length, l10n);
                      },
                    ),
                  ),
                ),
                _buildAddButton(l10n),
              ],
            );
          },
        );
      },
    );
  }

  /// 总预算汇总卡片 — 渐变绿背景 + 大数字 + 动态进度条
  Widget _buildMonthTotalCard(double totalBudget, double totalSpent, double globalBudget, int categoryCount, AppLocalizations l10n) {
    final effectiveBudget = globalBudget > totalBudget ? globalBudget : totalBudget;
    final percentage = effectiveBudget > 0 ? (totalSpent / effectiveBudget * 100) : 0.0;
    final remaining = effectiveBudget - totalSpent;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.md, 8, AppDimensions.md, 4),
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
            // 标题行 + 分类数量
            Row(
              children: [
                Text(l10n.budgetMonthlyTotal, style: context.textStyles.footnote.copyWith(
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
                    l10n.budgetCategoryCount(categoryCount.toString()),
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
                  ' / ${context.localeProvider.currency.formatAmount(effectiveBudget, decimals: 0)}',
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
                valueColor: AlwaysStoppedAnimation(Colors.white),
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

  /// 一级分类行 — 卡片化布局 + 彩色进度条
  Widget _buildParentItem(Category parent, double budget, double spent, int childCount, AppLocalizations l10n) {
    final color = _parseColor(parent.color);
    final percentage = budget > 0 ? (spent / budget * 100) : 0.0;
    final barColor = percentage > 90 ? context.colors.error : percentage > 70 ? context.colors.warning : context.colors.success;
    final name = getCategoryDisplayName(parent, l10n);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: GestureDetector(
        onTap: () => context.push('/budget/detail', extra: {
          'parentCategoryId': parent.id,
          'parentCategoryName': name,
          'parentCategoryIcon': parent.icon ?? '📦',
        }),
        child: Container(
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
                width: 44, height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withValues(alpha: 0.12), color.withValues(alpha: 0.22)],
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Center(child: Text(parent.icon ?? '📦', style: const TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 12),
              // 名称 + 进度条
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(name, style: context.textStyles.body.copyWith(fontWeight: FontWeight.w600))),
                        Text('${percentage.toStringAsFixed(0)}%', style: context.textStyles.caption.copyWith(
                          color: barColor, fontWeight: FontWeight.w500,
                        )),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(l10n.budgetCategoryCount(childCount.toString()),
                      style: context.textStyles.caption.copyWith(color: context.colors.textTertiary, fontSize: 10)),
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
              // 金额 + 箭头
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(context.localeProvider.currency.formatAmount(spent, decimals: 0),
                    style: context.textStyles.amountSmall.copyWith(
                      color: spent > budget ? context.colors.error : context.colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    )),
                  const SizedBox(height: 2),
                  Text('/ ${context.localeProvider.currency.formatAmount(budget, decimals: 0)}',
                    style: context.textStyles.caption.copyWith(fontSize: 10)),
                ],
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 18, color: context.colors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== 年视图 ====================

  Widget _buildYearView(AppLocalizations l10n) {
    final repo = ref.read(budgetRepositoryProvider);
    final bookId = ref.watch(currentBookProvider);

    return FutureBuilder<List<Budget>>(
      future: repo.getAll(bookId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: context.colors.primary));
        }

        final allBudgets = snapshot.data ?? [];
        final yearBudgets = allBudgets.where((b) => b.year == _currentMonth.year).toList();
        if (yearBudgets.isEmpty) return _buildEmptyState(l10n);

        final monthlyData = <int, double>{};
        for (final b in yearBudgets) {
          monthlyData[b.month] = (monthlyData[b.month] ?? 0) + b.amount;
        }
        final now = DateTime.now();
        final yearTotal = monthlyData.values.fold<double>(0, (s, v) => s + v);

        return Column(
          children: [
            _buildYearTotalCard(yearTotal, monthlyData.length, l10n),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(AppDimensions.md, 0, AppDimensions.md, 8),
                itemCount: 12,
                itemBuilder: (context, i) {
                  final month = i + 1;
                  final budget = monthlyData[month];
                  final isCurrentOrPast = _currentMonth.year < now.year ||
                      (_currentMonth.year == now.year && month <= now.month);
                  return _buildMonthRow(month, budget, isCurrentOrPast, l10n);
                },
              ),
            ),
            _buildAddButton(l10n),
          ],
        );
      },
    );
  }

  Widget _buildYearTotalCard(double yearTotal, int monthsCount, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.md, 8, AppDimensions.md, 4),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [
              context.colors.primaryDark.withValues(alpha: 0.85),
              context.colors.primary.withValues(alpha: 0.7),
              context.colors.primaryLight.withValues(alpha: 0.55),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          boxShadow: [
            BoxShadow(color: context.colors.primary.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.budgetYearTotal, style: context.textStyles.footnote.copyWith(
              color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Text(context.localeProvider.currency.formatAmount(yearTotal, decimals: 0),
              style: context.textStyles.amountLarge.copyWith(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(l10n.budgetMonthCount(monthsCount.toString()),
              style: context.textStyles.caption.copyWith(color: Colors.white.withValues(alpha: 0.65))),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthRow(int month, double? budget, bool isCurrentOrPast, AppLocalizations l10n) {
    final hasBudget = budget != null && budget > 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          boxShadow: context.colors.cardShadow,
        ),
        child: Row(
          children: [
            SizedBox(width: 48, child: Text(l10n.budgetMonthShort(month.toString()),
              style: context.textStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: isCurrentOrPast ? context.colors.textPrimary : context.colors.textTertiary,
              ))),
            const SizedBox(width: 12),
            Expanded(
              child: hasBudget
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: 0.5, minHeight: 6,
                        backgroundColor: context.colors.surfaceSecondary,
                        valueColor: AlwaysStoppedAnimation(context.colors.primary.withValues(alpha: 0.5)),
                      ),
                    )
                  : Container(height: 6, decoration: BoxDecoration(
                      color: context.colors.surfaceSecondary, borderRadius: BorderRadius.circular(3))),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 80,
              child: Text(
                hasBudget ? context.localeProvider.currency.formatAmount(budget, decimals: 0) : '—',
                style: context.textStyles.amountSmall.copyWith(
                  color: hasBudget ? context.colors.textPrimary : context.colors.textHint),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.account_balance_wallet_outlined, size: 56, color: context.colors.textTertiary.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                Text(l10n.budgetEmpty, style: context.textStyles.callout.copyWith(color: context.colors.textSecondary)),
              ],
            ),
          ),
        ),
        _buildAddButton(l10n),
      ],
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
        onTap: () => _onAddBudget(l10n),
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

  Color _parseColor(String? hex) {
    try {
      if (hex == null || hex.isEmpty) return context.colors.textTertiary;
      return Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16));
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

/// 一级分类选择器（已有预算的灰显不可选）
class _ParentCategoryPickerSheet extends StatelessWidget {
  final List<Category> categories;
  final Set<int> existingIds;

  const _ParentCategoryPickerSheet({required this.categories, required this.existingIds});

  @override
  Widget build(BuildContext context) {
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
          Text(AppLocalizations.of(context)!.budgetAddCategoryBudget,
            style: AppTextStyles.h3.copyWith(fontSize: 16)),
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
              final color = _parsePickerColor(cat.color, context);
              return GestureDetector(
                onTap: hasExisting
                    ? () => AppToast.show(context, AppLocalizations.of(context)!.budgetCategoryAlreadyExists)
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
                        getCategoryDisplayName(cat, AppLocalizations.of(context)!),
                        style: context.textStyles.caption,
                        maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
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

  static Color _parsePickerColor(String? hex, BuildContext context) {
    try {
      if (hex == null || hex.isEmpty) return context.colors.textTertiary;
      return Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16));
    } catch (_) {
      return context.colors.textTertiary;
    }
  }
}
