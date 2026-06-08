import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

/// AI 解析结果确认卡片（底部弹出 Sheet）
class AiConfirmSheet extends StatelessWidget {
  final String originalInput;
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final double confidence;
  final int parseTimeMs;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final VoidCallback? onEditCategory;
  final VoidCallback? onEditAmount;
  final VoidCallback? onEditDate;

  const AiConfirmSheet({
    super.key,
    required this.originalInput,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    required this.confidence,
    required this.parseTimeMs,
    required this.onCancel,
    required this.onConfirm,
    this.onEditCategory,
    this.onEditAmount,
    this.onEditDate,
  });

  static Future<void> show(
    BuildContext context, {
    required String originalInput,
    required double amount,
    required String category,
    required String description,
    required DateTime date,
    required double confidence,
    required int parseTimeMs,
    required VoidCallback onCancel,
    required VoidCallback onConfirm,
    VoidCallback? onEditCategory,
    VoidCallback? onEditAmount,
    VoidCallback? onEditDate,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AiConfirmSheet(
        originalInput: originalInput,
        amount: amount,
        category: category,
        description: description,
        date: date,
        confidence: confidence,
        parseTimeMs: parseTimeMs,
        onCancel: onCancel,
        onConfirm: onConfirm,
        onEditCategory: onEditCategory,
        onEditAmount: onEditAmount,
        onEditDate: onEditDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽把手
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            decoration: BoxDecoration(
              color: context.colors.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 标题
          Text(
            '🤖 AI解析结果',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          // 原始输入
          Text(
            '原始输入: $originalInput',
            style: TextStyle(
              fontSize: 13,
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          // 结果网格
          _buildResultGrid(context),
          const SizedBox(height: 20),
          // 置信度
          _buildConfidenceBar(context),
          const SizedBox(height: 20),
          // 编辑标签
          _buildEditTags(context),
          const SizedBox(height: 20),
          // 按钮行
          _buildButtonRow(context),
        ],
      ),
    );
  }

  Widget _buildResultGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        _buildResultItem(context, '💰 金额', '¥${amount.toStringAsFixed(2)}'),
        _buildResultItem(
          context,
          '📅 日期',
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        ),
        _buildResultItem(context, '🍜 分类', category),
        _buildResultItem(context, '⏱️ 解析耗时', '${parseTimeMs}ms'),
        _buildResultItem(context, '📝 描述', description, fullWidth: true),
      ],
    );
  }

  Widget _buildResultItem(BuildContext context, String label, String value, {bool fullWidth = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: context.colors.textSecondary)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.colors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceBar(BuildContext context) {
    final percent = (confidence * 100).toInt();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('置信度', style: TextStyle(fontSize: 13, color: context.colors.textSecondary)),
            Text('$percent%', style: TextStyle(fontSize: 13, color: context.colors.textSecondary)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: confidence,
            minHeight: 8,
            backgroundColor: context.colors.background,
            valueColor: AlwaysStoppedAnimation<Color>(context.colors.success),
          ),
        ),
      ],
    );
  }

  Widget _buildEditTags(BuildContext context) {
    return Row(
      children: [
        _buildEditTag(context, '修改分类', onEditCategory),
        const SizedBox(width: 8),
        _buildEditTag(context, '修改金额', onEditAmount),
        const SizedBox(width: 8),
        _buildEditTag(context, '修改日期', onEditDate),
      ],
    );
  }

  Widget _buildEditTag(BuildContext context, String label, VoidCallback? onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: context.colors.separator, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: context.colors.textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: context.colors.separator),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text('取消', style: TextStyle(color: context.colors.textSecondary)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: context.colors.textOnPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('确认记账', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}
