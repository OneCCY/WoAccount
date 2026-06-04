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
      decoration: const BoxDecoration(
        color: AppColors.surface,
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
              color: AppColors.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 标题
          const Text(
            '🤖 AI解析结果',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          // 原始输入
          Text(
            '原始输入: $originalInput',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          // 结果网格
          _buildResultGrid(),
          const SizedBox(height: 20),
          // 置信度
          _buildConfidenceBar(),
          const SizedBox(height: 20),
          // 编辑标签
          _buildEditTags(),
          const SizedBox(height: 20),
          // 按钮行
          _buildButtonRow(),
        ],
      ),
    );
  }

  Widget _buildResultGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        _buildResultItem('💰 金额', '¥${amount.toStringAsFixed(2)}'),
        _buildResultItem(
          '📅 日期',
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        ),
        _buildResultItem('🍜 分类', category),
        _buildResultItem('⏱️ 解析耗时', '${parseTimeMs}ms'),
        _buildResultItem('📝 描述', description, fullWidth: true),
      ],
    );
  }

  Widget _buildResultItem(String label, String value, {bool fullWidth = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceBar() {
    final percent = (confidence * 100).toInt();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('置信度', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            Text('$percent%', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: confidence,
            minHeight: 8,
            backgroundColor: AppColors.background,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
          ),
        ),
      ],
    );
  }

  Widget _buildEditTags() {
    return Row(
      children: [
        _buildEditTag('修改分类', onEditCategory),
        const SizedBox(width: 8),
        _buildEditTag('修改金额', onEditAmount),
        const SizedBox(width: 8),
        _buildEditTag('修改日期', onEditDate),
      ],
    );
  }

  Widget _buildEditTag(String label, VoidCallback? onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.separator, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonRow() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.separator),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('取消', style: TextStyle(color: AppColors.textSecondary)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
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
