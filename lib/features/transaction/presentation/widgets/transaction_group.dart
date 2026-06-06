import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../config/database/app_database.dart';
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

  const TransactionGroup({
    super.key,
    required this.date,
    required this.transactions,
    required this.onDelete,
    this.onTap,
    this.categoryMap = const {},
  });

  @override
  Widget build(BuildContext context) {
    final totalExpense = transactions.fold<double>(0, (sum, t) => sum + t.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 日期头
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.md,
            vertical: 10,
          ),
          color: AppColors.surfaceSecondary,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    DateFormat('M月d日').format(date),
                    style: AppTextStyles.footnote.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getWeekday(date),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              Text(
                '支出 ¥${totalExpense.toStringAsFixed(2)}',
                style: AppTextStyles.footnote,
              ),
            ],
          ),
        ),
        // 交易列表
        ...transactions.map((t) => _TransactionItem(
              transaction: t,
              category: categoryMap[t.categoryId],
              onDelete: () => onDelete(t.id),
              onTap: onTap != null ? () => onTap!(t) : null,
            )),
      ],
    );
  }

  String _getWeekday(DateTime date) {
    const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return weekdays[date.weekday - 1];
  }
}

/// 单条交易记录（自定义滑动删除）
class _TransactionItem extends StatefulWidget {
  final Transaction transaction;
  final Category? category;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const _TransactionItem({
    required this.transaction,
    this.category,
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

  static const double _deleteThreshold = 0.2; // 20% 宽度触发删除

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
    // 只允许向左滑动（负值）
    if (delta < 0 || _dragExtent < 0) {
      setState(() {
        _dragExtent += delta;
        // 限制最大滑动距离
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
      // 滑动超过阈值，显示删除按钮
      _animateTo(-screenWidth * _deleteThreshold);
    } else {
      // 未超过阈值，回弹
      _animateTo(0);
    }
  }

  void _animateTo(double target) {
    _animation = Tween<double>(
      begin: _dragExtent,
      end: target,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.reset();
    _controller.forward().then((_) {
      setState(() {
        _dragExtent = target;
      });
    });

    _controller.addListener(() {
      setState(() {
        _dragExtent = _animation.value;
      });
    });
  }

  void _resetPosition() {
    _animateTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final categoryName = widget.category?.name;
    final (icon, bgColor) = _getCategoryStyle(categoryName);
    final isExpense = widget.category?.isExpense ?? true;
    final amountPrefix = isExpense ? '-' : '+';
    final amountColor = isExpense ? AppColors.expense : AppColors.income;
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: SizedBox(
        height: 64,
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
                  color: AppColors.error,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.delete_outline, color: Colors.white, size: 22),
                        SizedBox(height: 2),
                        Text('删除', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // 交易内容（上层，可滑动）
            Transform.translate(
              offset: Offset(_dragExtent, 0),
              child: GestureDetector(
                onTap: _dragExtent.abs() > 1 ? _resetPosition : widget.onTap,
                child: Container(
                  color: AppColors.surface,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.md,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.separatorOpaque, width: 0.5),
                      ),
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
                            child: Icon(icon, size: 20, color: AppColors.textPrimary),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 信息
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.transaction.description,
                                style: AppTextStyles.body,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${DateFormat('HH:mm').format(widget.transaction.transactionDate)} · ${categoryName ?? '未分类'}',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                        // 金额
                        Text(
                          '$amountPrefix¥${widget.transaction.amount.toStringAsFixed(2)}',
                          style: AppTextStyles.amountList.copyWith(color: amountColor),
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

  /// 根据分类名称获取图标和背景色
  (IconData, Color) _getCategoryStyle(String? categoryName) {
    switch (categoryName) {
      case '餐饮':
        return (Icons.restaurant, AppColors.categoryFoodBg);
      case '交通':
        return (Icons.directions_car, AppColors.categoryTransportBg);
      case '购物':
        return (Icons.shopping_bag, AppColors.categoryShoppingBg);
      case '住房':
        return (Icons.home, AppColors.categoryHousingBg);
      case '娱乐':
        return (Icons.sports_esports, AppColors.categoryEntertainmentBg);
      case '教育':
        return (Icons.school, AppColors.categoryEducationBg);
      case '医疗':
        return (Icons.local_hospital, AppColors.categoryMedicalBg);
      case '社交':
        return (Icons.people, AppColors.categorySocialBg);
      default:
        return (Icons.more_horiz, AppColors.categoryOtherBg);
    }
  }
}
