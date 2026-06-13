import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:intl/intl.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../config/database/app_database.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/locale/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/amount_edit_sheet.dart';
import '../widgets/datetime_edit_sheet.dart';
import '../widgets/category_picker_sheet.dart';
import '../widgets/note_edit_sheet.dart';
import '../../../../core/widgets/toast.dart';

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
      accountBookId: Value(txn.accountBookId),
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
          accountBookId: txn.accountBookId,
          createdAt: txn.createdAt,
          updatedAt: now,
        );
      });
      AppToast.show(context, AppLocalizations.of(context)!.txnDetailSaved, duration: const Duration(seconds: 1));
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.txnDetailDeleteConfirmTitle),
        content: Text(l10n.txnDetailDeleteConfirmContent),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.commonCancel)),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.commonDelete, style: TextStyle(color: context.colors.expense)),
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(l10n.txnDetailTitle),
        backgroundColor: context.colors.surface,
        actions: [
          if (_isDirty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: _save,
                child: Text(l10n.commonSave, style: context.textStyles.body.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w600,
                )),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _isLoading || _transaction == null
          ? null
          : _buildBottomBar(l10n),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transaction == null
              ? Center(child: Text(l10n.txnDetailNotFound))
              : _buildContent(l10n),
    );
  }

  Widget _buildBottomBar(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.md,
        12,
        AppDimensions.md,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.colors.separatorOpaque, width: 0.5)),
      ),
      child: Row(
        children: [
          // 删除按钮
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _delete,
              icon: Icon(Icons.delete_outline, size: 18, color: context.colors.expense),
              label: Text(l10n.commonDelete, style: AppTextStyles.buttonText.copyWith(color: context.colors.expense)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: context.colors.expense.withValues(alpha: 0.3)),
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
              label: Text(l10n.commonSave, style: AppTextStyles.buttonText.copyWith(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isDirty ? context.colors.primary : context.colors.textHint,
                disabledBackgroundColor: context.colors.textHint,
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

  Widget _buildContent(AppLocalizations l10n) {
    final isExpense = _category?.isExpense ?? true;
    final amountColor = isExpense ? context.colors.expense : context.colors.income;
    final prefix = isExpense ? '-' : '+';

    return SingleChildScrollView(
      child: Column(
        children: [
          // 金额卡片
          _buildAmountCard(isExpense, amountColor, prefix, l10n),
          const SizedBox(height: 12),
          // 表单列表
          _buildFormCard(l10n),
          // AI 解析记录
          if (_originalInput != null && _originalInput!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildAiCard(l10n),
          ],
          // 创建时间
          const SizedBox(height: 12),
          _buildMetaCard(l10n),
          const SizedBox(height: 100), // 底部留白给操作栏
        ],
      ),
    );
  }

  Widget _buildAmountCard(bool isExpense, Color amountColor, String prefix, AppLocalizations l10n) {
    final icon = _category?.icon ?? '📦';
    final catName = _parentCategory != null
        ? '${_parentCategory!.name} > ${_category!.name}'
        : _category?.name ?? l10n.txnDetailUncategorized;
    final bgColor = isExpense
        ? context.colors.expense.withValues(alpha: 0.05)
        : context.colors.income.withValues(alpha: 0.05);

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
                style: context.textStyles.footnote.copyWith(color: context.colors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 金额
          Text(
            context.localeProvider.currency.formatWithSign(_amount, isExpense),
            style: context.textStyles.amountLarge.copyWith(color: amountColor),
          ),
          const SizedBox(height: 8),
          // 日期
          Text(
            DateFormat('yyyy-MM-dd HH:mm').format(_transactionDate),
            style: context.textStyles.caption.copyWith(color: context.colors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(AppLocalizations l10n) {
    final catName = _parentCategory != null
        ? '${_parentCategory!.name} > ${_category!.name}'
        : _category?.name ?? l10n.txnDetailUncategorized;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildFormRow(
            icon: Icons.category_outlined,
            iconColor: _parseColor(_category?.color),
            label: l10n.txnDetailCategory,
            value: catName,
            onTap: _editCategory,
          ),
          _buildFormRow(
            icon: Icons.attach_money,
            iconColor: context.colors.primary,
            label: l10n.txnDetailAmount,
            value: context.localeProvider.currency.formatAmount(_amount),
            onTap: _editAmount,
          ),
          _buildFormRow(
            icon: Icons.calendar_today_outlined,
            iconColor: context.colors.primary,
            label: l10n.txnDetailDate,
            value: DateFormat('MM/dd HH:mm').format(_transactionDate),
            onTap: _editDatetime,
          ),
          _buildFormRow(
            icon: Icons.notes,
            iconColor: context.colors.textSecondary,
            label: l10n.txnDetailNote,
            value: _description.isEmpty ? l10n.txnDetailAddNoteHint : _description,
            valueColor: _description.isEmpty ? context.colors.textHint : null,
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
            ? BoxDecoration(
                border: Border(bottom: BorderSide(color: context.colors.separatorOpaque, width: 0.5)),
              )
            : null,
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 12),
            Text(label, style: context.textStyles.body),
            const Spacer(),
            Flexible(
              child: Text(
                value,
                style: context.textStyles.footnote.copyWith(color: valueColor ?? context.colors.textSecondary),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 18, color: context.colors.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _buildAiCard(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
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
                  Icon(Icons.auto_awesome, size: 18, color: context.colors.primary),
                  const SizedBox(width: 8),
                  Text(l10n.txnDetailAiRecord, style: context.textStyles.body.copyWith(fontWeight: FontWeight.w500)),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _aiExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down, size: 20, color: context.colors.textTertiary),
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
                  _buildAiRow(l10n.txnDetailOriginalInput, _originalInput ?? '-'),
                  if (_transaction?.aiSource != null) ...[
                    const SizedBox(height: 8),
                    _buildAiRow(l10n.txnDetailParseSource, _transaction!.aiSource),
                  ],
                  if (_transaction?.aiConfidence != null) ...[
                    const SizedBox(height: 8),
                    _buildAiRow(l10n.txnDetailConfidence, '${(_transaction!.aiConfidence! * 100).toStringAsFixed(0)}%'),
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
          child: Text(label, style: context.textStyles.caption.copyWith(color: context.colors.textTertiary)),
        ),
        Expanded(child: Text(value, style: context.textStyles.footnote)),
      ],
    );
  }

  Widget _buildMetaCard(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, size: 16, color: context.colors.textTertiary),
          const SizedBox(width: 8),
          Text(l10n.txnDetailCreatedAt, style: context.textStyles.footnote.copyWith(color: context.colors.textTertiary)),
          const Spacer(),
          Text(
            DateFormat('yyyy-MM-dd HH:mm').format(_transaction!.createdAt),
            style: context.textStyles.caption.copyWith(color: context.colors.textTertiary),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return context.colors.textTertiary;
    final clean = hex.replaceFirst('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }
}
