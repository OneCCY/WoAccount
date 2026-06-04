import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../../../../config/database/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';

/// 今日账单列表
class TodayTransactions extends ConsumerWidget {
  final TransactionRepository repository;

  const TodayTransactions({super.key, required this.repository});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<List<Transaction>>(
      stream: repository.watchToday(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.xl),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        final transactions = snapshot.data ?? [];

        if (transactions.isEmpty) {
          return _buildEmptyState();
        }

        return _buildList(context, transactions);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: AppColors.textTertiary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppDimensions.md),
            Text(
              '今天还没有记账',
              style: AppTextStyles.callout.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.xs),
            Text(
              '输入一句话开始记账吧',
              style: AppTextStyles.footnote.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Transaction> transactions) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        return _TransactionListItem(
          transaction: transactions[index],
          onDelete: () => repository.delete(transactions[index].id),
        );
      },
    );
  }
}

/// 单条交易记录
class _TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onDelete;

  const _TransactionListItem({
    required this.transaction,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: 12,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            bottom: BorderSide(
              color: AppColors.separatorOpaque,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // 分类图标
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: const Center(
                child: Text('💰', style: TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: AppDimensions.sm),
            // 描述
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
                    DateFormat('HH:mm').format(transaction.transactionDate),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // 金额
            Text(
              '-¥${transaction.amount.toStringAsFixed(2)}',
              style: AppTextStyles.amountList.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
