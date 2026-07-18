import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
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
import '../../../../core/widgets/page_refresh_mixin.dart';

/// 账单详情页（重设计）
class TransactionDetailPage extends ConsumerStatefulWidget {
  final int transactionId;
  final bool readOnly;
  const TransactionDetailPage({super.key, required this.transactionId, this.readOnly = false});

  @override
  ConsumerState<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends ConsumerState<TransactionDetailPage> with PageRefreshMixin {
  @override
  String get routePath => '/transaction/detail';

  @override
  void onRefresh() => _loadData();

  Transaction? _transaction;
  Category? _category;
  Category? _parentCategory;
  bool _isLoading = true;
  bool _isDirty = false;
  bool _aiExpanded = false;

  // 编辑态（本地副本，保存时才写库）
  late double _amount;
  late String _type;
  String? _note;
  String? _payMethod;
  late int _categoryId;
  late int? _parentCategoryId;
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

    final txn = widget.readOnly
        ? await txnRepo.getByIdIncludeDeleted(widget.transactionId)
        : await txnRepo.getById(widget.transactionId);
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
        _type = txn.type;
        _note = txn.note;
        _payMethod = txn.payMethod;
        _categoryId = txn.categoryId;
        _parentCategoryId = txn.parentCategoryId;
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
      type: Value(_type),
      description: Value(_description),
      note: Value(_note),
      payMethod: Value(_payMethod),
      categoryId: Value(_categoryId),
      parentCategoryId: Value(_parentCategoryId),
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
      AppToast.show(context, AppLocalizations.of(context)!.txnDetailSaved, duration: const Duration(seconds: 1));
      if (mounted) context.pop(true);
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
      if (mounted) context.pop();
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
        _parentCategoryId = picked.parentId;
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
    final result = await NoteEditSheet.show(context, initialNote: _note ?? '');
    if (result != null && mounted) {
      setState(() {
        _note = result.isNotEmpty ? result : null;
        _isDirty = true;
      });
    }
  }

  // ==================== 支付方式 ====================

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
      case null: return l10n.payMethodDefault;
      default: return method;
    }
  }

  Future<void> _editPayMethod() async {
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
                  color: _payMethod == m.$1 ? context.colors.primary : context.colors.textSecondary),
                title: Text(m.$2, style: TextStyle(
                  fontWeight: _payMethod == m.$1 ? FontWeight.w600 : FontWeight.w400,
                  color: _payMethod == m.$1 ? context.colors.primary : null,
                )),
                onTap: () => Navigator.pop(ctx, m.$1),
              )),
              const Divider(height: 1, thickness: 0.5),
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: Colors.grey),
                title: Text(l10n.payMethodCustom, style: const TextStyle(color: Colors.grey)),
                onTap: () async {
                  final custom = await _showCustomPayMethodInput(ctx, l10n);
                  if (custom != null && ctx.mounted && mounted) Navigator.pop(ctx, custom);
                },
              ),
            ],
          ),
        ),
      ),
    );
    if (mounted && result != _payMethod) {
      setState(() {
        _payMethod = result;
        _isDirty = true;
      });
    }
  }

  Future<String?> _showCustomPayMethodInput(BuildContext ctx, AppLocalizations l10n) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.payMethodCustom),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.payMethodCustom,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.pop(dialogCtx, value);
            },
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.dispose());
    return result;
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
          if (_isDirty && !widget.readOnly)
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
      bottomNavigationBar: _isLoading || _transaction == null || widget.readOnly
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
    final isExpense = _type == 'expense';
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
          // 日期 + 类型标签
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('yyyy-MM-dd HH:mm').format(_transactionDate),
                style: context.textStyles.caption.copyWith(color: context.colors.textTertiary),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: amountColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _type == 'expense' ? l10n.entryExpense : _type == 'income' ? l10n.entryIncome : l10n.entryOther,
                  style: context.textStyles.caption.copyWith(color: amountColor, fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
            ],
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
            value: (_note == null || _note!.isEmpty) ? l10n.txnDetailAddNoteHint : _note!,
            valueColor: (_note == null || _note!.isEmpty) ? context.colors.textHint : null,
            onTap: _editNote,
          ),
          _buildFormRow(
            icon: _getPayMethodIcon(_payMethod),
            iconColor: context.colors.textSecondary,
            label: l10n.txnDetailPayMethod,
            value: _getPayMethodLabel(_payMethod, l10n),
            onTap: _editPayMethod,
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
    VoidCallback? onTap,
    bool showDivider = true,
  }) {
    final effectiveOnTap = widget.readOnly ? null : onTap;
    return InkWell(
      onTap: effectiveOnTap,
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
            if (!widget.readOnly) ...[
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 18, color: context.colors.textTertiary),
            ],
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
