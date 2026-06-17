import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../core/locale/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 记账成功卡片（参考 ConfirmCard 样式，70% 宽度，左侧对齐）
class SavedCard extends StatelessWidget {
  final double amount;
  final String type;
  final String category;
  final String? subcategory;
  final String description;
  final String? note;
  final DateTime date;
  final String? payMethod;
  final String? aiIcon;

  const SavedCard({
    super.key,
    required this.amount,
    required this.type,
    required this.category,
    this.subcategory,
    required this.description,
    this.note,
    required this.date,
    this.payMethod,
    this.aiIcon,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isExpense = type == 'expense';
    final amountColor = isExpense ? context.colors.expense : context.colors.income;
    final prefix = isExpense ? '-' : '+';
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI 头像
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [context.colors.primary, context.colors.primary.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(aiIcon ?? '🤖', style: const TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 8),
          // 卡片内容（70% 宽度）
          SizedBox(
            width: screenWidth * 0.7,
            child: Container(
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.colors.success.withValues(alpha: 0.3), width: 1),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, l10n, amountColor),
                  _buildAmountDisplay(context, amountColor, prefix),
                  const SizedBox(height: 4),
                  _buildFormCard(context, l10n),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 顶部标题 + 类型标签
  Widget _buildHeader(BuildContext context, AppLocalizations l10n, Color amountColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 14, color: context.colors.success),
          const SizedBox(width: 4),
          Text(l10n.chatPageSaveSuccessTitle, style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w600, color: context.colors.success,
          )),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: amountColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              type == 'expense' ? l10n.entryExpense : type == 'income' ? l10n.entryIncome : l10n.entryOther,
              style: AppTextStyles.caption.copyWith(color: amountColor, fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// 金额大字显示
  Widget _buildAmountDisplay(BuildContext context, Color amountColor, String prefix) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Text(
        '$prefix${context.localeProvider.currency.formatAmount(amount)}',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: amountColor, height: 1.2),
      ),
    );
  }

  /// 表单信息卡片
  Widget _buildFormCard(BuildContext context, AppLocalizations l10n) {
    final catDisplay = subcategory != null && subcategory!.isNotEmpty
        ? '$category > $subcategory'
        : category;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _FormRow(
            icon: Icons.category_outlined,
            iconColor: context.colors.primary,
            label: l10n.chatConfirmCategory,
            value: catDisplay,
          ),
          _FormRow(
            icon: Icons.edit_outlined,
            iconColor: context.colors.textSecondary,
            label: l10n.chatConfirmDescription,
            value: description,
          ),
          _FormRow(
            icon: Icons.notes,
            iconColor: context.colors.textTertiary,
            label: l10n.txnDetailNote,
            value: (note == null || note!.isEmpty) ? '无' : note!,
          ),
          _FormRow(
            icon: _getPayMethodIcon(payMethod),
            iconColor: context.colors.textSecondary,
            label: l10n.txnDetailPayMethod,
            value: _getPayMethodLabel(payMethod, l10n),
          ),
          _FormRow(
            icon: Icons.calendar_today_outlined,
            iconColor: context.colors.primary,
            label: l10n.chatConfirmDate,
            value: DateFormat('MM/dd HH:mm').format(date),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  IconData _getPayMethodIcon(String? method) {
    switch (method) {
      case 'wechat': return Icons.chat_bubble;
      case 'alipay': return Icons.account_balance_wallet;
      case 'card': return Icons.credit_card;
      case 'cash': return Icons.payments_outlined;
      default: return Icons.payment;
    }
  }

  String _getPayMethodLabel(String? method, AppLocalizations l10n) {
    switch (method) {
      case 'wechat': return l10n.payMethodWechat;
      case 'alipay': return l10n.payMethodAlipay;
      case 'card': return l10n.payMethodCard;
      case 'cash': return l10n.payMethodCash;
      default: return l10n.payMethodDefault;
    }
  }
}

/// 表单信息行（只读无点击）
class _FormRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool showDivider;

  const _FormRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: showDivider
          ? BoxDecoration(border: Border(bottom: BorderSide(color: context.colors.separatorOpaque, width: 0.5)))
          : null,
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.caption.copyWith(color: context.colors.textTertiary)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
