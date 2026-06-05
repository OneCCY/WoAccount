import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../config/database/app_database.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 账单详情页
/// 头部（图标+金额）+ 信息卡片 + 编辑/复制/删除
class TransactionDetailPage extends ConsumerStatefulWidget {
  final int transactionId;
  const TransactionDetailPage({super.key, required this.transactionId});

  @override
  ConsumerState<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends ConsumerState<TransactionDetailPage> {
  Transaction? _transaction;
  Category? _category;
  Category? _parentCategory;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final txnRepo = ref.read(transactionRepositoryProvider);
    final catRepo = ref.read(categoryRepositoryProvider);

    final txn = await txnRepo.getById(widget.transactionId);
    if (txn == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final cat = await catRepo.getById(txn.categoryId);
    Category? parent;
    if (cat?.parentId != null) {
      parent = await catRepo.getById(cat!.parentId!);
    }

    if (mounted) {
      setState(() {
        _transaction = txn;
        _category = cat;
        _parentCategory = parent;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('账单详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _onEdit,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transaction == null
              ? const Center(child: Text('账单不存在'))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final isExpense = _category?.isExpense ?? true;
    final amountColor = isExpense ? AppColors.expense : AppColors.income;
    final amountPrefix = isExpense ? '-' : '+';
    final categoryPath = _parentCategory != null
        ? '${_parentCategory!.name} > ${_category!.name}'
        : _category?.name ?? '未分类';

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),

          // 头部：图标 + 分类路径 + 金额
          _buildHeader(categoryPath, amountPrefix, amountColor),

          const SizedBox(height: 24),

          // 信息卡片
          _buildInfoCard(),

          const SizedBox(height: 24),

          // 操作按钮
          _buildActionButtons(),

          const SizedBox(height: 16),

          // 删除按钮
          _buildDeleteButton(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader(String categoryPath, String amountPrefix, Color amountColor) {
    final icon = _category?.icon ?? '📦';

    return Column(
      children: [
        // 分类图标
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: _parseColor(_category?.color).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 28)),
          ),
        ),
        const SizedBox(height: 12),
        // 分类路径
        Text(
          categoryPath,
          style: AppTextStyles.footnote.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        // 金额
        Text(
          '$amountPrefix¥${_transaction!.amount.toStringAsFixed(2)}',
          style: AppTextStyles.amountLarge.copyWith(color: amountColor),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    final txn = _transaction!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _buildInfoRow('描述', txn.description),
            _buildInfoRow('日期', DateFormat('yyyy-MM-dd HH:mm').format(txn.transactionDate)),
            _buildInfoRow('分类', _category?.name ?? '未分类'),
            if (txn.originalInput != null && txn.originalInput!.isNotEmpty)
              _buildInfoRow('原始输入', txn.originalInput!),
            _buildInfoRow('创建时间', DateFormat('yyyy-MM-dd HH:mm').format(txn.createdAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.separatorOpaque, width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: AppTextStyles.footnote),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.body),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _onEdit,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
              ),
              child: Text(
                '编辑',
                style: AppTextStyles.buttonText.copyWith(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _onCopy,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
              ),
              child: Text(
                '复制',
                style: AppTextStyles.buttonText.copyWith(color: AppColors.textOnPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton() {
    return TextButton(
      onPressed: _onDelete,
      child: Text(
        '删除此账单',
        style: AppTextStyles.body.copyWith(color: AppColors.error),
      ),
    );
  }

  void _onEdit() {
    // TODO: 跳转到手动记账页（编辑模式）
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('编辑功能开发中'), behavior: SnackBarBehavior.floating),
    );
  }

  void _onCopy() {
    // TODO: 复制交易记录
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('复制功能开发中'), behavior: SnackBarBehavior.floating),
    );
  }

  void _onDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('删除后可在回收站恢复'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final repo = ref.read(transactionRepositoryProvider);
              await repo.delete(widget.transactionId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已删除'), behavior: SnackBarBehavior.floating),
                );
                Navigator.of(context).pop();
              }
            },
            child: Text('删除', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return AppColors.textTertiary;
    final clean = hex.replaceFirst('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }
}
