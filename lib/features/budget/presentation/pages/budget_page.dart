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
import '../../domain/repositories/budget_repository.dart';
import '../../../category/domain/repositories/category_repository.dart';

/// 预算视图模式
enum _BudgetView { month, year }

/// 预算管理页 — 精简设计
/// 月视图：纯净的一级分类预算列表（无二级图标、无总预算卡片、无添加按钮）
/// 年视图：12 个月汇总
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(l10n.budgetTitle),
        actions: [_buildViewToggle(l10n)],
      ),
      body: Column(
        children: [
          _buildMonthNav(l10n),
          Expanded(
            child: _view == _BudgetView.month
                ? _buildMonthView(l10n)
                : _buildYearView(l10n),
          ),
        ],
      ),
    );
  }

  /// 月/年切换
  Widget _buildViewToggle(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? context.colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        child: Text(label,
          style: context.textStyles.caption.copyWith(
            color: active ? context.colors.textOnPrimary : context.colors.textSecondary,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          )),
      ),
    );
  }

  /// 月份导航
  Widget _buildMonthNav(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 8),
      color: context.colors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 24),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            onPressed: () => setState(() {
              _currentMonth = _view == _BudgetView.month
                  ? DateTime(_currentMonth.year, _currentMonth.month - 1)
                  : DateTime(_currentMonth.year - 1, _currentMonth.month);
            }),
          ),
          const SizedBox(width: 16),
          Text(
            _view == _BudgetView.month
                ? l10n.reportMonthLabel(_currentMonth.year.toString(), _currentMonth.month.toString())
                : l10n.budgetYearLabel(_currentMonth.year.toString()),
            style: context.textStyles.h3.copyWith(fontSize: 16),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 24),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            onPressed: () {
              final now = DateTime.now();
              final next = _view == _BudgetView.month
                  ? DateTime(_currentMonth.year, _currentMonth.month + 1)
                  : DateTime(_currentMonth.year + 1, _currentMonth.month);
              if (_view == _BudgetView.month) {
                if (next.isAfter(DateTime(now.year, now.month))) return;
              } else {
                if (next.year > now.year) return;
              }
              setState(() => _currentMonth = next);
            },
          ),
        ],
      ),
    );
  }

  // ==================== 月视图：纯净一级分类列表 ====================

  Widget _buildMonthView(AppLocalizations l10n) {
    final catRepo = ref.read(categoryRepositoryProvider);
    final budgetRepo = ref.read(budgetRepositoryProvider);
    final bookId = ref.watch(currentBookProvider);

    return FutureBuilder<(List<Category>, List<BudgetProgress>)>(
      future: _loadMonthData(catRepo, budgetRepo, bookId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: context.colors.primary));
        }

        final (parentCats, allProgress) = snap.data ?? (<Category>[], <BudgetProgress>[]);

        if (parentCats.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.category_outlined, size: 48, color: context.colors.textTertiary),
                const SizedBox(height: 16),
                Text(l10n.budgetEmpty, style: context.textStyles.callout.copyWith(color: context.colors.textSecondary)),
              ],
            ),
          );
        }

        // 按 parentId 分组预算进度
        final progressByParent = <int, List<BudgetProgress>>{};
        for (final p in allProgress) {
          if (p.budget.categoryId == null) continue;
          final cat = p.category;
          if (cat == null) continue;
          final pid = cat.parentId ?? cat.id;
          progressByParent.putIfAbsent(pid, () => []).add(p);
        }

        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: parentCats.length,
            itemBuilder: (context, index) {
              final parent = parentCats[index];
              final children = progressByParent[parent.id] ?? [];
              final groupBudget = children.fold<double>(0, (s, p) => s + p.budget.amount);
              final groupSpent = children.fold<double>(0, (s, p) => s + p.spent);
              return _buildParentItem(parent, groupBudget, groupSpent);
            },
          ),
        );
      },
    );
  }

  /// 并行加载一级分类 + 当月预算进度
  Future<(List<Category>, List<BudgetProgress>)> _loadMonthData(
    CategoryRepository catRepo, BudgetRepository budgetRepo, int bookId,
  ) async {
    final cats = await catRepo.getTopLevel();
    final expenseCats = cats.where((c) => c.isExpense).toList();
    final progress = await budgetRepo.getBudgetProgress(bookId, _currentMonth.year, _currentMonth.month);
    return (expenseCats, progress);
  }

  /// 一级分类行 — 纯净设计：图标 + 名称 + 进度条 + 金额
  Widget _buildParentItem(Category parent, double budget, double spent) {
    final l10n = AppLocalizations.of(context)!;
    final color = _parseColor(parent.color);
    final hasBudget = budget > 0;
    final percentage = hasBudget ? (spent / budget * 100) : 0.0;
    final barColor = percentage > 90 ? context.colors.error : percentage > 70 ? context.colors.warning : context.colors.success;
    final name = getCategoryDisplayName(parent, l10n);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 4),
      child: GestureDetector(
        onTap: () => context.push('/budget/detail', extra: {
          'parentCategoryId': parent.id,
          'parentCategoryName': name,
          'parentCategoryIcon': parent.icon ?? '📦',
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Row(
            children: [
              // 图标
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Center(child: Text(parent.icon ?? '📦', style: const TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 12),
              // 名称 + 进度条
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: context.textStyles.body.copyWith(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    if (hasBudget) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: (percentage / 100).clamp(0, 1),
                          minHeight: 5,
                          backgroundColor: context.colors.surfaceSecondary,
                          valueColor: AlwaysStoppedAnimation(barColor),
                        ),
                      ),
                    ] else
                      Container(
                        height: 5,
                        decoration: BoxDecoration(
                          color: context.colors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(3),
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
                  Text(
                    hasBudget ? context.localeProvider.currency.formatAmount(spent, decimals: 0) : '—',
                    style: context.textStyles.amountSmall.copyWith(
                      color: hasBudget && spent > budget ? context.colors.error : context.colors.textPrimary,
                    ),
                  ),
                  if (hasBudget)
                    Text('/ ${context.localeProvider.currency.formatAmount(budget, decimals: 0)}',
                      style: context.textStyles.caption),
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

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildYearTotalCard(yearTotal, monthlyData.length, l10n),
              const SizedBox(height: 16),
              ...List.generate(12, (i) {
                final month = i + 1;
                final budget = monthlyData[month];
                final isCurrentOrPast = _currentMonth.year < now.year ||
                    (_currentMonth.year == now.year && month <= now.month);
                return _buildMonthRow(month, budget, isCurrentOrPast, l10n);
              }),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildYearTotalCard(double yearTotal, int monthsCount, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [context.colors.primary.withValues(alpha: 0.08), context.colors.primary.withValues(alpha: 0.15)],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: context.colors.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.budgetYearTotal, style: context.textStyles.footnote.copyWith(color: context.colors.primary)),
            const SizedBox(height: 8),
            Text(context.localeProvider.currency.formatAmount(yearTotal, decimals: 0),
              style: context.textStyles.amountLarge.copyWith(color: context.colors.primaryDark)),
            const SizedBox(height: 4),
            Text(l10n.budgetMonthCount(monthsCount.toString()),
              style: context.textStyles.caption.copyWith(color: context.colors.textTertiary)),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthRow(int month, double? budget, bool isCurrentOrPast, AppLocalizations l10n) {
    final hasBudget = budget != null && budget > 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 3),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Row(
          children: [
            SizedBox(width: 48, child: Text(l10n.budgetMonthShort(month.toString()),
              style: context.textStyles.body.copyWith(
                fontWeight: FontWeight.w500,
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 48, color: context.colors.textTertiary),
          const SizedBox(height: 16),
          Text(l10n.budgetEmpty, style: context.textStyles.callout.copyWith(color: context.colors.textSecondary)),
        ],
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
