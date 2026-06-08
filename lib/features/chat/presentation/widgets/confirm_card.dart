import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../pages/ai_chat_page.dart';

/// AI 解析结果确认卡片
/// 展示解析结果，支持修改各字段，确认后保存
class ConfirmCard extends StatelessWidget {
  final ConfirmData data;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final ValueChanged<ConfirmData> onEdit;

  const ConfirmCard({
    super.key,
    required this.data,
    required this.onConfirm,
    required this.onCancel,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = data.type == 'expense';
    final amountColor = isExpense ? context.colors.expense : context.colors.income;
    final amountPrefix = isExpense ? '-' : '+';

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
              color: context.colors.primarySurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(child: Text('🤖', style: TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 8),

          // 确认卡片
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.colors.primary.withValues(alpha: 0.3), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 16, color: context.colors.primary),
                        const SizedBox(width: 6),
                        Text('AI 解析结果', style: AppTextStyles.footnote.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.colors.primary,
                        )),
                        const Spacer(),
                        // 置信度
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _confidenceColor(data.confidence, context).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${(data.confidence * 100).toInt()}%',
                            style: AppTextStyles.caption.copyWith(
                              color: _confidenceColor(data.confidence, context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 金额（大字醒目）
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      '$amountPrefix¥${data.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: amountColor,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 可编辑信息行
                  _EditableRow(
                    icon: Icons.category_outlined,
                    label: '分类',
                    value: data.category + (data.subcategory != null ? ' > ${data.subcategory}' : ''),
                    onTap: () => _editCategory(context),
                  ),
                  _EditableRow(
                    icon: Icons.edit_outlined,
                    label: '描述',
                    value: data.description,
                    onTap: () => _editDescription(context),
                  ),
                  _EditableRow(
                    icon: Icons.calendar_today_outlined,
                    label: '日期',
                    value: DateFormat('yyyy-MM-dd').format(data.date),
                    onTap: () => _editDate(context),
                  ),
                  _EditableRow(
                    icon: Icons.attach_money,
                    label: '金额',
                    value: data.amount.toStringAsFixed(2),
                    onTap: () => _editAmount(context),
                    showDivider: false,
                  ),

                  // 操作按钮
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onCancel,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              side: BorderSide(color: context.colors.textTertiary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                              ),
                            ),
                            child: Text('取消', style: AppTextStyles.body.copyWith(color: context.colors.textSecondary)),
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                              ),
                            ),
                            child: Text('确认保存', style: AppTextStyles.body.copyWith(
                              color: context.colors.textOnPrimary,
                              fontWeight: FontWeight.w600,
                            )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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

  void _editCategory(BuildContext context) async {
    // TODO: 弹出分类选择器
    // 暂时用简单对话框
    final controller = TextEditingController(text: data.category);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('修改分类'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '输入分类名称', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('确定')),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && result != data.category) {
      onEdit(data.copyWith(category: result));
    }
  }

  void _editDescription(BuildContext context) async {
    final controller = TextEditingController(text: data.description);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('修改描述'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '输入描述', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('确定')),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && result != data.description) {
      onEdit(data.copyWith(description: result));
    }
  }

  void _editDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: data.date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null && picked != data.date) {
      onEdit(data.copyWith(date: picked));
    }
  }

  void _editAmount(BuildContext context) async {
    final controller = TextEditingController(text: data.amount.toStringAsFixed(2));
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('修改金额'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(hintText: '输入金额', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('确定')),
        ],
      ),
    );
    if (result != null) {
      final newAmount = double.tryParse(result);
      if (newAmount != null && newAmount > 0) {
        onEdit(data.copyWith(amount: newAmount));
      }
    }
  }
}

/// 可点击编辑的信息行
class _EditableRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool showDivider;

  const _EditableRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: showDivider
            ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: context.colors.separatorOpaque, width: 0.5),
                ),
              )
            : null,
        child: Row(
          children: [
            Icon(icon, size: 16, color: context.colors.textTertiary),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.caption.copyWith(color: context.colors.textTertiary)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(value, style: AppTextStyles.body.copyWith(fontSize: 14)),
            ),
            Icon(Icons.chevron_right, size: 18, color: context.colors.textTertiary),
          ],
        ),
      ),
    );
  }
}
