import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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

/// 单条交易记录
class _TransactionItem extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    final categoryName = category?.name;
    final (icon, bgColor) = _getCategoryStyle(categoryName);
    final isExpense = category?.isExpense ?? true;
    final amountPrefix = isExpense ? '-' : '+';
    final amountColor = isExpense ? AppColors.expense : AppColors.income;

    final content = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: 12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
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
              children: [
                Text(
                  transaction.description,
                  style: AppTextStyles.body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${DateFormat('HH:mm').format(transaction.transactionDate)} · ${categoryName ?? '未分类'}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          // 金额
          Text(
            '$amountPrefix¥${transaction.amount.toStringAsFixed(2)}',
            style: AppTextStyles.amountList.copyWith(color: amountColor),
          ),
        ],
      ),
    );

    return Slidable(
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.textOnPrimary,
            icon: Icons.delete_outline,
            label: '删除',
          ),
        ],
      ),
      child: onTap != null
          ? InkWell(onTap: onTap, child: content)
          : content,
    );
  }
}
