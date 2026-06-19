import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../config/database/app_database.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/locale/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/repositories/budget_repository.dart';

/// 预算视图模式
enum _BudgetView { month, year }

/// 预算管理页
/// 支持月/年视图切换 + 月份导航
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
    final repo = ref.read(budgetRepositoryProvider);
    final bookId = ref.watch(currentBookProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(l10n.budgetTitle),
        actions: [
          // 月/年切换
          _buildViewToggle(l10n),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              await context.push('/budget/setting');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 月份导航栏
          _buildMonthNav(l10n),
          // 内容区
          Expanded(
            child: _view == _BudgetView.month
                ? _buildMonthView(repo, bookId, l10n)
                : _buildYearView(repo, bookId, l10n),
          ),
        ],
      ),
    );
  }

  /// 月/年视图切换
  Widget _buildViewToggle(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: context.colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleItem(l10n.budgetViewMonth, _BudgetView.month),
          _buildToggleItem(l10n.budgetViewYear, _BudgetView.year),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, _BudgetView view) {
    final isActive = _view == view;
    return GestureDetector(
      onTap: () => setState(() => _view = view),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? context.colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        child: Text(
          label,
          style: context.textStyles.caption.copyWith(
            color: isActive ? context.colors.textOnPrimary : context.colors.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  /// 月份导航栏
  Widget _buildMonthNav(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 8),
      color: context.colors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 24),
            onPressed: () => setState(() {
              _currentMonth = _view == _BudgetView.month
                  ? DateTime(_currentMonth.year, _currentMonth.month - 1)
                  : DateTime(_currentMonth.year - 1, _currentMonth.month);
            }),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
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
            onPressed: () {
              final now = DateTime.now();
              final next = _view == _BudgetView.month
                  ? DateTime(_currentMonth.year, _currentMonth.month + 1)
                  : DateTime(_currentMonth.year + 1, _currentMonth.month);
              // 不超过当前月/年
              if (_view == _BudgetView.month) {
                if (next.isAfter(DateTime(now.year, now.month))) return;
              } else {
                if (next.year > now.year) return;
              }
              setState(() => _currentMonth = next);
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }

  // ==================== 月视图 ====================

  Widget _buildMonthView(BudgetRepository repo, int bookId, AppLocalizations l10n) {
    return FutureBuilder<List<BudgetProgress>>(
      future: repo.getBudgetProgress(bookId, _currentMonth.year, _currentMonth.month),
      builder: (context, progressSnap) {
        if (progressSnap.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: context.colors.primary));
        }

        final progresses = progressSnap.data ?? [];
        if (progresses.isEmpty) return _buildEmptyState(l10n);

        // 总预算（categoryId == null）
        final totalProgresses = progresses.where((p) => p.budget.categoryId == null).toList();
        final totalBudget = totalProgresses.fold<double>(0, (s, p) => s + p.budget.amount);
        final totalSpent = totalProgresses.fold<double>(0, (s, p) => s + p.spent);

        // 分类预算（categoryId != null）按父分类分组
        final categoryProgresses = progresses.where((p) => p.budget.categoryId != null).toList();
        final parentGroups = _groupByParent(categoryProgresses);

        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 16),
                if (totalBudget > 0)
                  _buildTotalCard(context, totalBudget, totalSpent, l10n),
                if (categoryProgresses.any((p) => p.isOverBudget))
                  _buildOverBudgetWarning(context, categoryProgresses, l10n),
                const SizedBox(height: 16),
                if (parentGroups.isNotEmpty)
                  ...parentGroups.entries.map((e) => _buildParentGroupItem(context, e.key, e.value))
                else if (totalBudget > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text(l10n.budgetNoBudgets,
                      style: context.textStyles.caption.copyWith(color: context.colors.textTertiary)),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 按父分类分组：返回 Map<parentCategoryId, List<BudgetProgress>>
  Map<int, List<BudgetProgress>> _groupByParent(List<BudgetProgress> progresses) {
    final grouped = <int, List<BudgetProgress>>{};
    for (final p in progresses) {
      final cat = p.category;
      if (cat == null) continue;
      final parentId = cat.parentId ?? cat.id;
      grouped.putIfAbsent(parentId, () => []).add(p);
    }
    return grouped;
  }

  /// 父分类预算卡片（聚合子分类）
  Widget _buildParentGroupItem(BuildContext context, int parentId, List<BudgetProgress> children) {
    final firstChild = children.first;
    final parentCat = firstChild.category;
    // 如果子分类有 parentId，需要找父分类信息；否则该分类本身就是一级
    final isParentLevel = parentCat?.parentId == null;
    final parentName = isParentLevel ? (parentCat?.name ?? '') : _resolveParentName(parentId, children);
    final parentIcon = isParentLevel ? (parentCat?.icon ?? '📦') : _resolveParentIcon(parentId, children);

    final groupBudget = children.fold<double>(0, (s, p) => s + p.budget.amount);
    final groupSpent = children.fold<double>(0, (s, p) => s + p.spent);
    final percentage = groupBudget > 0 ? (groupSpent / groupBudget * 100) : 0.0;
    final barColor = percentage > 90 ? context.colors.error : percentage > 70 ? context.colors.warning : context.colors.success;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 4),
      child: GestureDetector(
        onTap: () => _navigateToDetail(parentId, parentName, parentIcon),
        child: Container(
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
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: _parseColor(context, parentCat?.color).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    ),
                    child: Center(child: Text(parentIcon, style: const TextStyle(fontSize: 20))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(parentName, style: context.textStyles.body.copyWith(fontWeight: FontWeight.w500)),
                            Text('${percentage.toStringAsFixed(1)}%',
                              style: context.textStyles.caption.copyWith(color: barColor)),
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
                      Text(context.localeProvider.currency.formatAmount(groupSpent, decimals: 0),
                        style: context.textStyles.amountSmall.copyWith(
                          color: groupSpent > groupBudget ? context.colors.error : context.colors.textPrimary,
                        )),
                      Text('/ ${context.localeProvider.currency.formatAmount(groupBudget, decimals: 0)}',
                        style: context.textStyles.caption),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 18, color: context.colors.textTertiary),
                ],
              ),
              // 子分类摘要
              if (children.length > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: children.map((c) {
                      final cat = c.category;
                      return Text(
                        '${cat?.icon ?? ""} ${context.localeProvider.currency.formatAmount(c.spent, decimals: 0)}',
                        style: context.textStyles.caption.copyWith(color: context.colors.textTertiary),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _resolveParentName(int parentId, List<BudgetProgress> children) {
    // 尝试从子分类的 parentCategoryId 推断父分类名
    for (final c in children) {
      if (c.category?.id == parentId) return c.category!.name;
    }
    // 如果子分类有 parentCategoryId，说明 parentId 就是父分类 ID
    // 但我们没有直接查父分类，用第一个子分类的名称兜底
    return children.first.category?.name ?? '';
  }

  String _resolveParentIcon(int parentId, List<BudgetProgress> children) {
    for (final c in children) {
      if (c.category?.id == parentId) return c.category!.icon ?? '📦';
    }
    return children.first.category?.icon ?? '📦';
  }

  /// 跳转到父分类预算详情
  void _navigateToDetail(int parentId, String name, String icon) {
    context.push('/budget/detail', extra: {
      'parentCategoryId': parentId,
      'parentCategoryName': name,
      'parentCategoryIcon': icon,
    });
  }

  // ==================== 年视图 ====================

  Widget _buildYearView(BudgetRepository repo, int bookId, AppLocalizations l10n) {
    return FutureBuilder<List<Budget>>(
      future: repo.getAll(bookId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: context.colors.primary));
        }

        final allBudgets = snapshot.data ?? [];
        final yearBudgets = allBudgets.where((b) => b.year == _currentMonth.year).toList();

        if (yearBudgets.isEmpty) {
          return _buildEmptyState(l10n);
        }

        // 按月分组并计算每月总预算
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
              // 年度总预算卡片
              _buildYearTotalCard(yearTotal, monthlyData.length, l10n),
              const SizedBox(height: 16),
              // 12 个月列表
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

  /// 年度总预算卡片
  Widget _buildYearTotalCard(double yearTotal, int monthsCount, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.colors.primary.withValues(alpha: 0.08),
              context.colors.primary.withValues(alpha: 0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: context.colors.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.budgetYearTotal, style: context.textStyles.footnote.copyWith(color: context.colors.primary)),
            const SizedBox(height: 8),
            Text(
              context.localeProvider.currency.formatAmount(yearTotal, decimals: 0),
              style: context.textStyles.amountLarge.copyWith(color: context.colors.primaryDark),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.budgetMonthCount(monthsCount.toString()),
              style: context.textStyles.caption.copyWith(color: context.colors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  /// 月份行（年视图中的每月汇总）
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
            // 月份标签
            SizedBox(
              width: 48,
              child: Text(
                l10n.budgetMonthShort(month.toString()),
                style: context.textStyles.body.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isCurrentOrPast ? context.colors.textPrimary : context.colors.textTertiary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 预算进度条
            Expanded(
              child: hasBudget
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: 0.5, // 年视图只显示预算额度，不计算实际消费
                        minHeight: 6,
                        backgroundColor: context.colors.surfaceSecondary,
                        valueColor: AlwaysStoppedAnimation(context.colors.primary.withValues(alpha: 0.5)),
                      ),
                    )
                  : Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: context.colors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            // 预算金额
            SizedBox(
              width: 80,
              child: Text(
                hasBudget
                    ? context.localeProvider.currency.formatAmount(budget, decimals: 0)
                    : '—',
                style: context.textStyles.amountSmall.copyWith(
                  color: hasBudget ? context.colors.textPrimary : context.colors.textHint,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 通用组件 ====================

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 48, color: context.colors.textTertiary),
          const SizedBox(height: 16),
          Text(l10n.budgetEmpty, style: context.textStyles.callout.copyWith(color: context.colors.textSecondary)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => context.push('/budget/setting'),
            child: Text(l10n.budgetSetButton),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard(BuildContext context, double total, double spent, AppLocalizations l10n) {
    final percentage = total > 0 ? (spent / total * 100) : 0.0;
    final remaining = total - spent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF3E0), Color(0xFFFFECB3)],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.budgetMonthlyTotal, style: context.textStyles.footnote.copyWith(color: const Color(0xFFE65100))),
            const SizedBox(height: 8),
            Text(
              context.localeProvider.currency.formatAmount(total, decimals: 0),
              style: context.textStyles.amountLarge.copyWith(color: const Color(0xFFE65100)),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (percentage / 100).clamp(0, 1),
                minHeight: 8,
                backgroundColor: const Color(0x33E65100),
                valueColor: AlwaysStoppedAnimation(
                  percentage > 90 ? context.colors.error : context.colors.warning,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.budgetSpent(context.localeProvider.currency.formatAmount(spent, decimals: 0)), style: context.textStyles.caption),
                Text(l10n.budgetRemaining(context.localeProvider.currency.formatAmount(remaining, decimals: 0)), style: context.textStyles.caption),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverBudgetWarning(BuildContext context, List<BudgetProgress> progresses, AppLocalizations l10n) {
    final overBudget = progresses.where((p) => p.isOverBudget).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.md, 12, AppDimensions.md, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        child: Column(
          children: overBudget.map((p) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Icon(Icons.warning_amber, size: 16, color: context.colors.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.budgetOverSpent(
                      p.category?.name ?? l10n.budgetUnknownCategory,
                      context.localeProvider.currency.formatAmount(p.spent - p.budget.amount, decimals: 0),
                    ),
                    style: context.textStyles.caption.copyWith(color: context.colors.error),
                  ),
                ),
              ],
            ),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, BudgetProgress progress) {
    final cat = progress.category;
    final color = _parseColor(context, cat?.color);
    final percentage = progress.percentage;
    final barColor = percentage > 90
        ? context.colors.error
        : percentage > 70
            ? context.colors.warning
            : context.colors.success;

    return Padding(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(cat?.name ?? AppLocalizations.of(context)!.budgetUncategorized, style: context.textStyles.body),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: context.textStyles.caption.copyWith(color: barColor),
                      ),
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
                Text(
                  context.localeProvider.currency.formatAmount(progress.spent, decimals: 0),
                  style: context.textStyles.amountSmall.copyWith(
                    color: progress.isOverBudget ? context.colors.error : context.colors.textPrimary,
                  ),
                ),
                Text(
                  '/ ${context.localeProvider.currency.formatAmount(progress.budget.amount, decimals: 0)}',
                  style: context.textStyles.caption,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(BuildContext context, String? hex) {
    try {
      if (hex == null || hex.isEmpty) return context.colors.textTertiary;
      final clean = hex.replaceFirst('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return context.colors.textTertiary;
    }
  }
}
