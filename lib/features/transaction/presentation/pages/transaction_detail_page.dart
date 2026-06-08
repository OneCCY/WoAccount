import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:intl/intl.dart';
import '../../../../config/database/app_database.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/amount_edit_sheet.dart';
import '../widgets/datetime_edit_sheet.dart';
import '../widgets/category_picker_sheet.dart';
import '../widgets/note_edit_sheet.dart';

/// 账单详情页（重设计）
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
  bool _isDirty = false;
  bool _aiExpanded = false;

  // 编辑态（本地副本，保存时才写库）
  late double _amount;
  late int _categoryId;
  late int? _subcategoryId;
  late DateTime _transactionDate;
  late String _description;
  String? _originalInput;

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
        _amount = txn.amount;
        _categoryId = txn.categoryId;
        _subcategoryId = txn.subcategoryId;
        _transactionDate = txn.transactionDate;
        _description = txn.description;
        _originalInput = txn.originalInput;
        _isLoading = false;
      });
    }
  }

  Future<void> _save() async {
    final txn = _transaction;
    if (txn == null || !_isDirty) return;

    final repo = ref.read(transactionRepositoryProvider);
    final now = DateTime.now();

    final companion = TransactionsCompanion(
      id: Value(txn.id),
      amount: Value(_amount),
      description: Value(_description),
      categoryId: Value(_categoryId),
      subcategoryId: Value(_subcategoryId),
      transactionDate: Value(_transactionDate),
      originalInput: Value(_originalInput),
      aiConfidence: Value(txn.aiConfidence),
      aiSource: Value(txn.aiSource),
      userConfirmed: const Value(true),
      isDeleted: Value(txn.isDeleted),
      createdAt: Value(txn.createdAt),
      updatedAt: Value(now),
    );

    final success = await repo.update(companion);
    if (success && mounted) {
      setState(() {
        _isDirty = false;
        _transaction = Transaction(
          id: txn.id,
          amount: _amount,
          description: _description,
          categoryId: _categoryId,
          subcategoryId: _subcategoryId,
          transactionDate: _transactionDate,
          originalInput: _originalInput,
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

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('删除后将无法恢复，确定要删除这条账单吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('删除', style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final repo = ref.read(transactionRepositoryProvider);
      await repo.delete(widget.transactionId);
      if (mounted) Navigator.of(context).pop();
    }
  }

  // ==================== 编辑操作 ====================

  Future<void> _reloadCategory() async {
    final catRepo = ref.read(categoryRepositoryProvider);
    final cat = await catRepo.getById(_categoryId);
    Category? parent;
    if (cat?.parentId != null) {
      parent = await catRepo.getById(cat!.parentId!);
    }
    if (mounted) {
      setState(() {
        _category = cat;
        _parentCategory = parent;
      });
    }
  }

  // ==================== 编辑操作 ====================

  Future<void> _editCategory() async {
    final isExpense = _category?.isExpense ?? true;
    final picked = await CategoryPickerSheet.show(
      context,
      initialIsExpense: isExpense,
      selectedCategoryId: _categoryId,
    );
    if (picked != null && mounted) {
      setState(() {
        _categoryId = picked.id;
        _subcategoryId = picked.parentId != null ? picked.id : null;
        _isDirty = true;
      });
      await _reloadCategory();
    }
  }

  Future<void> _editAmount() async {
    final isExpense = _category?.isExpense ?? true;
    final result = await AmountEditSheet.show(
      context,
      initialAmount: _amount,
      isExpense: isExpense,
    );
    if (result != null && mounted) {
      setState(() {
        _amount = result;
        _isDirty = true;
      });
    }
  }

  Future<void> _editDatetime() async {
    final result = await DatetimeEditSheet.show(context, initialDateTime: _transactionDate);
    if (result != null && mounted) {
      setState(() {
        _transactionDate = result;
        _isDirty = true;
      });
    }
  }

  Future<void> _editNote() async {
    final result = await NoteEditSheet.show(context, initialNote: _description);
    if (result != null && mounted && result != _description) {
      setState(() {
        _description = result;
        _isDirty = true;
      });
    }
  }

  // ==================== UI 构建 ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('账单详情'),
        backgroundColor: AppColors.surface,
        actions: [
          if (_isDirty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: _save,
                child: Text('保存', style: AppTextStyles.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                )),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _isLoading || _transaction == null
          ? null
          : _buildBottomBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transaction == null
              ? const Center(child: Text('账单不存在'))
              : _buildContent(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.md,
        12,
        AppDimensions.md,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.separatorOpaque, width: 0.5)),
      ),
      child: Row(
        children: [
          // 删除按钮
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _delete,
              icon: Icon(Icons.delete_outline, size: 18, color: AppColors.expense),
              label: Text('删除', style: AppTextStyles.buttonText.copyWith(color: AppColors.expense)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: AppColors.expense.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 保存按钮
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _isDirty ? _save : null,
              icon: const Icon(Icons.check, size: 18, color: Colors.white),
              label: Text('保存', style: AppTextStyles.buttonText.copyWith(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isDirty ? AppColors.primary : AppColors.textHint,
                disabledBackgroundColor: AppColors.textHint,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final isExpense = _category?.isExpense ?? true;
    final amountColor = isExpense ? AppColors.expense : AppColors.income;
    final prefix = isExpense ? '-' : '+';

    return SingleChildScrollView(
      child: Column(
        children: [
          // 金额卡片
          _buildAmountCard(isExpense, amountColor, prefix),
          const SizedBox(height: 12),
          // 表单列表
          _buildFormCard(),
          // AI 解析记录
          if (_originalInput != null && _originalInput!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildAiCard(),
          ],
          // 创建时间
          const SizedBox(height: 12),
          _buildMetaCard(),
          const SizedBox(height: 100), // 底部留白给操作栏
        ],
      ),
    );
  }

  Widget _buildAmountCard(bool isExpense, Color amountColor, String prefix) {
    final icon = _category?.icon ?? '📦';
    final catName = _parentCategory != null
        ? '${_parentCategory!.name} > ${_category!.name}'
        : _category?.name ?? '未分类';
    final bgColor = isExpense
        ? AppColors.expense.withValues(alpha: 0.05)
        : AppColors.income.withValues(alpha: 0.05);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: amountColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 分类图标 + 路径
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _parseColor(_category?.color).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Center(child: Text(icon, style: const TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 8),
              Text(
                catName,
                style: AppTextStyles.footnote.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 金额
          Text(
            '$prefix¥${_amount.toStringAsFixed(2)}',
            style: AppTextStyles.amountLarge.copyWith(color: amountColor),
          ),
          const SizedBox(height: 8),
          // 日期
          Text(
            DateFormat('yyyy年M月d日 HH:mm').format(_transactionDate),
            style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    final catName = _parentCategory != null
        ? '${_parentCategory!.name} > ${_category!.name}'
        : _category?.name ?? '未分类';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildFormRow(
            icon: Icons.category_outlined,
            iconColor: _parseColor(_category?.color),
            label: '分类',
            value: catName,
            onTap: _editCategory,
          ),
          _buildFormRow(
            icon: Icons.attach_money,
            iconColor: AppColors.primary,
            label: '金额',
            value: '¥${_amount.toStringAsFixed(2)}',
            onTap: _editAmount,
          ),
          _buildFormRow(
            icon: Icons.calendar_today_outlined,
            iconColor: AppColors.primary,
            label: '日期',
            value: DateFormat('MM/dd HH:mm').format(_transactionDate),
            onTap: _editDatetime,
          ),
          _buildFormRow(
            icon: Icons.notes,
            iconColor: AppColors.textSecondary,
            label: '备注',
            value: _description.isEmpty ? '点击添加备注' : _description,
            valueColor: _description.isEmpty ? AppColors.textHint : null,
            onTap: _editNote,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildFormRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Color? valueColor,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: showDivider
            ? const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.separatorOpaque, width: 0.5)),
              )
            : null,
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 12),
            Text(label, style: AppTextStyles.body),
            const Spacer(),
            Flexible(
              child: Text(
                value,
                style: AppTextStyles.footnote.copyWith(color: valueColor ?? AppColors.textSecondary),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 18, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _buildAiCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _aiExpanded = !_aiExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('AI解析记录', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _aiExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down, size: 20, color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),
          ),
          if (_aiExpanded) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAiRow('原始输入', _originalInput ?? '-'),
                  if (_transaction?.aiSource != null) ...[
                    const SizedBox(height: 8),
                    _buildAiRow('解析来源', _transaction!.aiSource),
                  ],
                  if (_transaction?.aiConfidence != null) ...[
                    const SizedBox(height: 8),
                    _buildAiRow('置信度', '${(_transaction!.aiConfidence! * 100).toStringAsFixed(0)}%'),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAiRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
        ),
        Expanded(child: Text(value, style: AppTextStyles.footnote)),
      ],
    );
  }

  Widget _buildMetaCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, size: 16, color: AppColors.textTertiary),
          const SizedBox(width: 8),
          Text('创建时间', style: AppTextStyles.footnote.copyWith(color: AppColors.textTertiary)),
          const Spacer(),
          Text(
            DateFormat('yyyy-MM-dd HH:mm').format(_transaction!.createdAt),
            style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
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
