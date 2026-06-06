import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:intl/intl.dart';
import '../../../../config/database/app_database.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 账单详情页
/// 头部（图标+金额）+ 信息卡片（可点击编辑，自动保存）
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

  /// 自动保存修改
  Future<void> _autoSave({String? description, DateTime? transactionDate, String? originalInput}) async {
    final txn = _transaction;
    if (txn == null) return;

    final repo = ref.read(transactionRepositoryProvider);
    final now = DateTime.now();

    final companion = TransactionsCompanion(
      id: Value(txn.id),
      amount: Value(txn.amount),
      description: Value(description ?? txn.description),
      categoryId: Value(txn.categoryId),
      subcategoryId: Value(txn.subcategoryId),
      transactionDate: Value(transactionDate ?? txn.transactionDate),
      originalInput: Value(originalInput ?? txn.originalInput),
      aiConfidence: Value(txn.aiConfidence),
      aiSource: Value(txn.aiSource),
      userConfirmed: const Value(true),
      isDeleted: Value(txn.isDeleted),
      createdAt: Value(txn.createdAt),
      updatedAt: Value(now),
    );

    final success = await repo.update(companion);
    if (success && mounted) {
      // 更新本地状态
      setState(() {
        _transaction = Transaction(
          id: txn.id,
          amount: txn.amount,
          description: description ?? txn.description,
          categoryId: txn.categoryId,
          subcategoryId: txn.subcategoryId,
          transactionDate: transactionDate ?? txn.transactionDate,
          originalInput: originalInput ?? txn.originalInput,
          aiConfidence: txn.aiConfidence,
          aiSource: txn.aiSource,
          userConfirmed: true,
          isDeleted: txn.isDeleted,
          createdAt: txn.createdAt,
          updatedAt: now,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已保存'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('账单详情'),
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

          // 信息卡片（可编辑）
          _buildInfoCard(),

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
            // 描述（点击可编辑）
            _buildEditableRow(
              label: '描述',
              value: txn.description,
              onTap: () => _editDescription(txn.description),
            ),
            // 日期（点击弹出日期时间选择器）
            _buildEditableRow(
              label: '日期',
              value: DateFormat('yyyy-MM-dd HH:mm').format(txn.transactionDate),
              onTap: _editDate,
            ),
            // 分类（只读）
            _buildInfoRow('分类', _category?.name ?? '未分类'),
            // 原始输入（点击可编辑，条件显示）
            if (txn.originalInput != null && txn.originalInput!.isNotEmpty)
              _buildEditableRow(
                label: '原始输入',
                value: txn.originalInput!,
                onTap: () => _editOriginalInput(txn.originalInput!),
              ),
            // 创建时间（只读）
            _buildInfoRow('创建时间', DateFormat('yyyy-MM-dd HH:mm').format(txn.createdAt)),
          ],
        ),
      ),
    );
  }

  /// 可点击编辑的行（带箭头提示）
  Widget _buildEditableRow({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.separatorOpaque, width: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 80,
              child: Text(label, style: AppTextStyles.footnote),
            ),
            Expanded(
              child: Text(value, style: AppTextStyles.body),
            ),
            Icon(Icons.chevron_right, size: 18, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  /// 只读信息行
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

  // ==================== 编辑操作 ====================

  /// 编辑描述（内联弹窗）
  Future<void> _editDescription(String current) async {
    final controller = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('编辑描述'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入描述',
            border: OutlineInputBorder(),
          ),
          maxLines: null,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (result != null && result != current && result.isNotEmpty) {
      await _autoSave(description: result);
    }
  }

  /// 编辑日期（日期+时间选择器）
  Future<void> _editDate() async {
    final txn = _transaction!;
    final currentDate = txn.transactionDate;

    // 弹出日期选择器
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      locale: const Locale('zh', 'CN'),
    );
    if (pickedDate == null || !mounted) return;

    // 弹出时间选择器
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentDate),
    );
    if (pickedTime == null || !mounted) return;

    final newDate = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    await _autoSave(transactionDate: newDate);
  }

  /// 编辑原始输入
  Future<void> _editOriginalInput(String current) async {
    final controller = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('编辑原始输入'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入原始内容',
            border: OutlineInputBorder(),
          ),
          maxLines: null,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (result != null && result != current) {
      await _autoSave(originalInput: result);
    }
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return AppColors.textTertiary;
    final clean = hex.replaceFirst('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }
}
