import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../config/database/app_database.dart';
import '../../../../core/locale/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 按日期分组的交易列表
class TransactionGroup extends StatelessWidget {
  final DateTime date;
  final List<Transaction> transactions;
  final Future<bool> Function(int id) onDelete;
  final void Function(Transaction transaction)? onTap;
  final Map<int, Category> categoryMap;
  /// 当前排序方式，null 表示不显示排序切换
  final String? sortLabel;
  final VoidCallback? onSortToggle;

  const TransactionGroup({
    super.key,
    required this.date,
    required this.transactions,
    required this.onDelete,
    this.onTap,
    this.categoryMap = const {},
    this.sortLabel,
    this.onSortToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    double totalExpense = 0;
    double totalIncome = 0;
    for (final t in transactions) {
      final cat = categoryMap[t.categoryId];
      if (cat?.isExpense ?? true) {
        totalExpense += t.amount;
      } else {
        totalIncome += t.amount;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 日期头
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 10),
          color: context.colors.surfaceSecondary,
          child: Row(
            children: [
              // 日期 + 星期
              Text(
                '${DateFormat(l10n.txnDayFormat).format(date)} ${_getWeekday(date, l10n)}',
                style: context.textStyles.footnote.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              // 支出 + 收入明细
              if (totalExpense > 0)
                Text(
                  l10n.txnGroupExpenseLabel(context.localeProvider.currency.formatAmount(totalExpense)),
                  style: context.textStyles.caption.copyWith(color: context.colors.expense),
                ),
              if (totalExpense > 0 && totalIncome > 0) const SizedBox(width: 8),
              if (totalIncome > 0)
                Text(
                  l10n.txnGroupIncomeLabel(context.localeProvider.currency.formatAmount(totalIncome)),
                  style: context.textStyles.caption.copyWith(color: context.colors.income),
                ),
              const Spacer(),
              // 排序切换
              if (sortLabel != null && onSortToggle != null)
                GestureDetector(
                  onTap: onSortToggle,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        sortLabel == l10n.txnSortByTime ? Icons.access_time : Icons.sort,
                        size: 13,
                        color: context.colors.textTertiary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        sortLabel!,
                        style: context.textStyles.caption.copyWith(color: context.colors.textTertiary, fontSize: 11),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        // 交易列表
        ...transactions.map((t) => _TransactionItem(
              transaction: t,
              category: categoryMap[t.categoryId],
              subcategory: t.subcategoryId != null ? categoryMap[t.subcategoryId] : null,
              onDelete: () => onDelete(t.id),
              onTap: onTap != null ? () => onTap!(t) : null,
            )),
      ],
    );
  }

  String _getWeekday(DateTime date, AppLocalizations l10n) {
    final weekdays = [
      l10n.weekMonFull, l10n.weekTueFull, l10n.weekWedFull,
      l10n.weekThuFull, l10n.weekFriFull, l10n.weekSatFull, l10n.weekSunFull,
    ];
    return weekdays[date.weekday - 1];
  }
}

/// 单条交易记录（自定义滑动删除）
class _TransactionItem extends StatefulWidget {
  final Transaction transaction;
  final Category? category;
  final Category? subcategory;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const _TransactionItem({
    required this.transaction,
    this.category,
    this.subcategory,
    required this.onDelete,
    this.onTap,
  });

  @override
  State<_TransactionItem> createState() => _TransactionItemState();
}

class _TransactionItemState extends State<_TransactionItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _dragExtent = 0;
  bool _isDragging = false;

  static const double _deleteThreshold = 0.2;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = Tween<double>(begin: 0, end: 0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    _isDragging = true;
    _controller.stop();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    final delta = details.primaryDelta ?? 0;
    if (delta < 0 || _dragExtent < 0) {
      setState(() {
        _dragExtent += delta;
        final maxDrag = -MediaQuery.of(context).size.width * _deleteThreshold;
        _dragExtent = _dragExtent.clamp(maxDrag, 0);
      });
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    _isDragging = false;

    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = -screenWidth * _deleteThreshold * 0.5;

    if (_dragExtent < threshold) {
      _animateTo(-screenWidth * _deleteThreshold);
    } else {
      _animateTo(0);
    }
  }

  void _animateTo(double target) {
    _animation = Tween<double>(begin: _dragExtent, end: target).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.reset();
    _controller.forward().then((_) {
      setState(() => _dragExtent = target);
    });
    _controller.addListener(() {
      setState(() => _dragExtent = _animation.value);
    });
  }

  void _resetPosition() => _animateTo(0);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categoryName = widget.category?.name;
    final (icon, bgColor) = _getCategoryStyle(categoryName);
    final isExpense = widget.category?.isExpense ?? true;
    final amountColor = isExpense ? context.colors.expense : context.colors.income;
    final screenWidth = MediaQuery.of(context).size.width;

    // 二级分类
    final subName = widget.subcategory?.name ?? l10n.txnGroupNoSubcategory;

    return GestureDetector(
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: SizedBox(
        height: 68,
        child: Stack(
          children: [
            // 删除按钮（底层，右侧 20%）
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: screenWidth * _deleteThreshold,
              child: GestureDetector(
                onTap: () {
                  _resetPosition();
                  widget.onDelete();
                },
                child: Container(
                  color: context.colors.error,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.delete_outline, color: Colors.white, size: 22),
                        const SizedBox(height: 2),
                        Text(l10n.commonDelete, style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // 交易内容（上层，可滑动，80%宽度）
            Transform.translate(
              offset: Offset(_dragExtent, 0),
              child: GestureDetector(
                onTap: _dragExtent.abs() > 1 ? _resetPosition : widget.onTap,
                child: Container(
                  color: context.colors.surface,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: context.colors.separatorOpaque, width: 0.5)),
                    ),
                    child: Row(
                      children: [
                        // 分类图标
                        Container(
                          width: AppDimensions.categoryIconSize,
                          height: AppDimensions.categoryIconSize,
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                          ),
                          child: Center(
                            child: Icon(icon, size: 20, color: context.colors.textPrimary),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 信息（分类 + 二级分类 + 时间）
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.transaction.description,
                                style: context.textStyles.body,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${DateFormat('HH:mm:ss').format(widget.transaction.transactionDate)} · ${categoryName ?? l10n.txnGroupUncategorized} · $subName',
                                style: context.textStyles.caption,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // 金额
                        Text(
                          context.localeProvider.currency.formatWithSign(widget.transaction.amount, isExpense),
                          style: context.textStyles.amountList.copyWith(color: amountColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  (IconData, Color) _getCategoryStyle(String? categoryName) {
    switch (categoryName) {
      case '餐饮美食':
        return (Icons.restaurant, context.colors.categoryFoodBg);
      case '交通出行':
        return (Icons.directions_car, context.colors.categoryTransportBg);
      case '日用百货':
        return (Icons.shopping_bag, context.colors.categoryShoppingBg);
      case '居住':
        return (Icons.home, context.colors.categoryHousingBg);
      case '休闲娱乐':
        return (Icons.sports_esports, context.colors.categoryEntertainmentBg);
      case '教育学习':
        return (Icons.school, context.colors.categoryEducationBg);
      case '医疗健康':
        return (Icons.local_hospital, context.colors.categoryMedicalBg);
      case '社交人情':
        return (Icons.people, context.colors.categorySocialBg);
      default:
        return (Icons.more_horiz, context.colors.categoryOtherBg);
    }
  }
}
