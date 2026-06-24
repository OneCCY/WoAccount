import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/locale/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../transaction/presentation/widgets/amount_edit_sheet.dart';
import '../../../transaction/presentation/widgets/category_picker_sheet.dart';
import '../../../transaction/presentation/widgets/datetime_edit_sheet.dart';
import '../../../transaction/presentation/widgets/note_edit_sheet.dart';
import '../pages/ai_chat_page.dart';

/// AI 解析结果确认卡片（重构版）
/// 参考账单编辑界面，使用底部弹窗编辑器
class ConfirmCard extends StatelessWidget {
  final ConfirmData data;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final ValueChanged<ConfirmData> onEdit;
  final String? aiIcon;

  const ConfirmCard({
    super.key,
    required this.data,
    required this.onConfirm,
    required this.onCancel,
    required this.onEdit,
    this.aiIcon,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isExpense = data.type == 'expense';
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
                border: Border.all(color: context.colors.primary.withValues(alpha: 0.3), width: 1),
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
                  _buildActionButtons(context, l10n),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 顶部标题 + 置信度 + 类型标签
  Widget _buildHeader(BuildContext context, AppLocalizations l10n, Color amountColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, size: 14, color: context.colors.primary),
          const SizedBox(width: 4),
          Text(l10n.chatConfirmTitle, style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w600, color: context.colors.primary,
          )),
          const SizedBox(width: 6),
          // 类型标签（可点击切换）
          GestureDetector(
            onTap: () => _toggleType(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: amountColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                data.type == 'expense' ? l10n.entryExpense : data.type == 'income' ? l10n.entryIncome : l10n.entryOther,
                style: AppTextStyles.caption.copyWith(color: amountColor, fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const Spacer(),
          // 置信度
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: _confidenceColor(data.confidence, context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${(data.confidence * 100).toInt()}%',
              style: AppTextStyles.caption.copyWith(
                color: _confidenceColor(data.confidence, context),
                fontWeight: FontWeight.w600, fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 金额大字显示（可点击编辑）
  Widget _buildAmountDisplay(BuildContext context, Color amountColor, String prefix) {
    return GestureDetector(
      onTap: () => _editAmount(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Row(
          children: [
            Text(
              '$prefix${context.localeProvider.currency.formatAmount(data.amount)}',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: amountColor, height: 1.2),
            ),
            const SizedBox(width: 4),
            Icon(Icons.edit_outlined, size: 14, color: context.colors.textTertiary),
          ],
        ),
      ),
    );
  }

  /// 表单信息卡片
  Widget _buildFormCard(BuildContext context, AppLocalizations l10n) {
    final catDisplay = data.subcategory != null
        ? '${data.category} > ${data.subcategory}'
        : data.category;

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
            onTap: () => _editCategory(context),
          ),
          _FormRow(
            icon: Icons.edit_outlined,
            iconColor: context.colors.textSecondary,
            label: l10n.chatConfirmDescription,
            value: data.description,
            onTap: () => _editDescription(context),
          ),
          _FormRow(
            icon: Icons.notes,
            iconColor: context.colors.textTertiary,
            label: l10n.txnDetailNote,
            value: (data.note == null || data.note!.isEmpty) ? l10n.txnDetailAddNoteHint : data.note!,
            valueColor: (data.note == null || data.note!.isEmpty) ? context.colors.textHint : null,
            onTap: () => _editNote(context),
          ),
          _FormRow(
            icon: _getPayMethodIcon(data.payMethod),
            iconColor: context.colors.textSecondary,
            label: l10n.txnDetailPayMethod,
            value: _getPayMethodLabel(data.payMethod, l10n),
            onTap: () => _editPayMethod(context),
          ),
          _FormRow(
            icon: Icons.calendar_today_outlined,
            iconColor: context.colors.primary,
            label: l10n.chatConfirmDate,
            value: DateFormat('MM/dd HH:mm').format(data.date),
            onTap: () => _editDate(context),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  /// 操作按钮
  Widget _buildActionButtons(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                side: BorderSide(color: context.colors.textTertiary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSm)),
              ),
              child: Text(l10n.commonCancel, style: AppTextStyles.body.copyWith(color: context.colors.textSecondary)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                backgroundColor: context.colors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSm)),
              ),
              child: Text(l10n.chatConfirmSave, style: AppTextStyles.body.copyWith(
                color: context.colors.textOnPrimary, fontWeight: FontWeight.w600,
              )),
            ),
          ),
        ],
      ),
    );
  }

  Color _confidenceColor(double c, BuildContext context) {
    if (c >= 0.9) return context.colors.success;
    if (c >= 0.7) return context.colors.warning;
    return context.colors.error;
  }

  // ==================== 编辑操作（底部弹窗） ====================

  void _toggleType(BuildContext context) {
    final types = ['expense', 'income', 'other'];
    final idx = types.indexOf(data.type);
    final nextType = types[(idx + 1) % types.length];
    onEdit(data.copyWith(type: nextType));
  }

  Future<void> _editCategory(BuildContext context) async {
    // Map type string to category type int: 0=expense, 1=income, 2=other
    final catType = data.type == 'expense' ? 0 : (data.type == 'other' ? 2 : 1);
    final picked = await CategoryPickerSheet.show(
      context,
      initialIsExpense: data.type == 'expense',
      initialCategoryType: catType,
      selectedCategoryId: data.categoryId,
    );
    if (picked == null) return;
    final isSub = picked.parentId != null;
    // Look up parent category name when a subcategory is picked
    String categoryName = picked.name;
    if (isSub && picked.parentId != null) {
      final catRepo = ProviderScope.containerOf(context).read(categoryRepositoryProvider);
      final parent = await catRepo.getById(picked.parentId!);
      if (parent != null) categoryName = parent.name;
    }
    onEdit(data.copyWith(
      category: categoryName,
      categoryId: picked.id,
      subcategory: isSub ? picked.name : null,
      parentCategoryId: isSub ? picked.parentId : null,
    ));
  }

  Future<void> _editAmount(BuildContext context) async {
    final result = await AmountEditSheet.show(
      context,
      initialAmount: data.amount,
      isExpense: data.type == 'expense',
    );
    if (result != null) {
      onEdit(data.copyWith(amount: result));
    }
  }

  Future<void> _editDate(BuildContext context) async {
    final result = await DatetimeEditSheet.show(context, initialDateTime: data.date);
    if (result != null) {
      onEdit(data.copyWith(date: result));
    }
  }

  Future<void> _editDescription(BuildContext context) async {
    final result = await NoteEditSheet.show(context, initialNote: data.description);
    if (result != null && result.isNotEmpty) {
      onEdit(data.copyWith(description: result));
    }
  }

  Future<void> _editNote(BuildContext context) async {
    final result = await NoteEditSheet.show(context, initialNote: data.note ?? '');
    if (result != null) {
      onEdit(data.copyWith(note: result.isEmpty ? null : result));
    }
  }

  Future<void> _editPayMethod(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final methods = <(String?, String)>[
      (null, l10n.payMethodDefault),
      ('cash', l10n.payMethodCash),
      ('wechat', l10n.payMethodWechat),
      ('alipay', l10n.payMethodAlipay),
      ('card', l10n.payMethodCard),
    ];
    final result = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: context.colors.textTertiary.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
              ...methods.map((m) => ListTile(
                leading: Icon(m.$1 == null ? Icons.payment : _getPayMethodIcon(m.$1),
                  color: data.payMethod == m.$1 ? context.colors.primary : context.colors.textSecondary),
                title: Text(m.$2, style: TextStyle(
                  fontWeight: data.payMethod == m.$1 ? FontWeight.w600 : FontWeight.w400,
                  color: data.payMethod == m.$1 ? context.colors.primary : null,
                )),
                onTap: () => Navigator.pop(ctx, m.$1),
              )),
            ],
          ),
        ),
      ),
    );
    if (result != data.payMethod) {
      onEdit(data.copyWith(payMethod: result));
    }
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

/// 表单信息行（参考账单详情样式）
class _FormRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color? valueColor;
  final VoidCallback onTap;
  final bool showDivider;

  const _FormRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueColor,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
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
                style: AppTextStyles.body.copyWith(fontSize: 14, color: valueColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 16, color: context.colors.textTertiary),
          ],
        ),
      ),
    );
  }
}
