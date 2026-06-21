import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../config/database/app_database.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/locale/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/toast.dart';
import '../../../transaction/presentation/widgets/transaction_group.dart';

/// 排序方式
enum RecycleSortBy { deleteTime, amount, date }

/// 类型筛选
enum RecycleFilterType { all, expense, income }

/// 账单回收站 — 参考日账单列表设计，支持排序、筛选、多选批量操作
class TransactionRecycleBinPage extends ConsumerStatefulWidget {
  const TransactionRecycleBinPage({super.key});

  @override
  ConsumerState<TransactionRecycleBinPage> createState() => _TransactionRecycleBinPageState();
}

class _TransactionRecycleBinPageState extends ConsumerState<TransactionRecycleBinPage> {
  List<Transaction> _allTxns = [];
  Map<int, Category> _categoryMap = {};
  bool _isLoading = true;

  // 筛选与排序
  RecycleSortBy _sortBy = RecycleSortBy.deleteTime;
  RecycleFilterType _filterType = RecycleFilterType.all;

  // 多选模式
  bool _isSelectMode = false;
  final Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final txnRepo = ref.read(transactionRepositoryProvider);
    final catRepo = ref.read(categoryRepositoryProvider);
    final bookId = ref.read(currentBookProvider);

    final txns = await txnRepo.getDeleted(bookId);
    final cats = <int, Category>{};
    for (final txn in txns) {
      if (!cats.containsKey(txn.categoryId)) {
        final cat = await catRepo.getById(txn.categoryId);
        if (cat != null) cats[txn.categoryId] = cat;
      }
      if (txn.parentCategoryId != null && !cats.containsKey(txn.parentCategoryId!)) {
        final parent = await catRepo.getById(txn.parentCategoryId!);
        if (parent != null) cats[txn.parentCategoryId!] = parent;
      }
    }

    if (mounted) {
      setState(() {
        _allTxns = txns;
        _categoryMap = cats;
        _isLoading = false;
      });
    }
  }

  /// 筛选 + 排序后的交易列表
  List<Transaction> get _filteredTxns {
    var list = _allTxns.where((t) {
      switch (_filterType) {
        case RecycleFilterType.expense:
          return t.type == 'expense';
        case RecycleFilterType.income:
          return t.type == 'income';
        case RecycleFilterType.all:
          return true;
      }
    }).toList();

    switch (_sortBy) {
      case RecycleSortBy.deleteTime:
        list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      case RecycleSortBy.amount:
        list.sort((a, b) => b.amount.compareTo(a.amount));
      case RecycleSortBy.date:
        list.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    }
    return list;
  }

  /// 按删除日期分组
  Map<DateTime, List<Transaction>> _groupByDate(List<Transaction> txns) {
    final map = <DateTime, List<Transaction>>{};
    for (final t in txns) {
      final d = t.updatedAt;
      final dateKey = DateTime(d.year, d.month, d.day);
      map.putIfAbsent(dateKey, () => []).add(t);
    }
    return map;
  }

  // ==================== 操作 ====================

  Future<bool> _restoreSingle(int id) async {
    final txnRepo = ref.read(transactionRepositoryProvider);
    final success = await txnRepo.restore(id);
    if (success && mounted) {
      AppToast.show(context, AppLocalizations.of(context)!.txnRestored);
      _selectedIds.remove(id);
      await _loadData();
    }
    return success;
  }

  Future<void> _permanentDeleteSingle(Transaction txn) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _confirmPermanentDelete(l10n);
    if (confirmed != true) return;

    final txnRepo = ref.read(transactionRepositoryProvider);
    final success = await txnRepo.permanentDelete(txn.id);
    if (success && mounted) {
      AppToast.show(context, l10n.txnRecycleBatchDeleted(1));
      _selectedIds.remove(txn.id);
      await _loadData();
    }
  }

  void _showItemActions(Transaction txn) {
    final l10n = AppLocalizations.of(context)!;
    final currency = ref.read(localeProviderOverrideProvider).currency;
    final isExpense = txn.type == 'expense';

    showModalBottomSheet(
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
              // 交易信息
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  '${txn.description}  ${isExpense ? "-" : "+"}${currency.formatAmount(txn.amount)}',
                  style: context.textStyles.body.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.restore, color: context.colors.success),
                title: Text(l10n.txnRestore),
                onTap: () {
                  Navigator.pop(ctx);
                  _restoreSingle(txn.id);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_forever, color: context.colors.error),
                title: Text(l10n.txnRecyclePermanentDelete, style: TextStyle(color: context.colors.error)),
                onTap: () {
                  Navigator.pop(ctx);
                  _permanentDeleteSingle(txn);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _batchRestore() async {
    final txnRepo = ref.read(transactionRepositoryProvider);
    final count = await txnRepo.restoreBatch(_selectedIds.toList());
    if (mounted) {
      AppToast.show(context, AppLocalizations.of(context)!.txnRecycleBatchRestored(count));
      _exitSelectMode();
      await _loadData();
    }
  }

  Future<void> _batchPermanentDelete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _confirmPermanentDelete(l10n);
    if (confirmed != true) return;

    final txnRepo = ref.read(transactionRepositoryProvider);
    final count = await txnRepo.permanentDeleteBatch(_selectedIds.toList());
    if (mounted) {
      AppToast.show(context, l10n.txnRecycleBatchDeleted(count));
      _exitSelectMode();
      await _loadData();
    }
  }

  Future<bool?> _confirmPermanentDelete(AppLocalizations l10n) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.txnRecyclePermanentDelete),
        content: Text(l10n.txnRecyclePermanentDeleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonConfirm, style: TextStyle(color: context.colors.error)),
          ),
        ],
      ),
    );
  }

  void _toggleSelectMode() {
    setState(() {
      _isSelectMode = !_isSelectMode;
      if (!_isSelectMode) _selectedIds.clear();
    });
  }

  void _exitSelectMode() {
    setState(() {
      _isSelectMode = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _isSelectMode = false;
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectAll() {
    final filtered = _filteredTxns;
    setState(() {
      if (_selectedIds.length == filtered.length) {
        _selectedIds.clear();
      } else {
        _selectedIds.clear();
        _selectedIds.addAll(filtered.map((t) => t.id));
      }
    });
  }

  // ==================== UI ====================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filtered = _filteredTxns;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: _isSelectMode ? _buildSelectAppBar(l10n) : _buildNormalAppBar(l10n),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: context.colors.primary))
          : filtered.isEmpty
              ? _buildEmptyState(l10n)
              : _buildGroupedList(filtered, l10n),
      bottomNavigationBar: _isSelectMode && _selectedIds.isNotEmpty
          ? _buildBatchBar(l10n)
          : null,
    );
  }

  PreferredSizeWidget _buildNormalAppBar(AppLocalizations l10n) {
    return AppBar(
      title: Text(l10n.txnRecycleBin),
      actions: [
        PopupMenuButton<RecycleSortBy>(
          icon: Icon(Icons.sort, color: context.colors.textSecondary),
          onSelected: (v) => setState(() => _sortBy = v),
          itemBuilder: (_) => [
            PopupMenuItem(value: RecycleSortBy.deleteTime, child: Text(l10n.txnRecycleSortByDeleteTime)),
            PopupMenuItem(value: RecycleSortBy.amount, child: Text(l10n.txnRecycleSortByAmount)),
            PopupMenuItem(value: RecycleSortBy.date, child: Text(l10n.txnRecycleSortByDate)),
          ],
        ),
        IconButton(
          icon: Icon(Icons.checklist, color: context.colors.textSecondary),
          onPressed: _filteredTxns.isNotEmpty ? _toggleSelectMode : null,
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(44),
        child: _buildFilterChips(l10n),
      ),
    );
  }

  PreferredSizeWidget _buildSelectAppBar(AppLocalizations l10n) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: _exitSelectMode,
      ),
      title: Text(l10n.txnRecycleSelected(_selectedIds.length)),
      actions: [
        TextButton(
          onPressed: _selectAll,
          child: Text(
            _selectedIds.length == _filteredTxns.length
                ? l10n.txnRecycleDeselectAll
                : l10n.txnRecycleSelectAll,
            style: TextStyle(color: context.colors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(AppLocalizations l10n) {
    final options = <(RecycleFilterType, String)>[
      (RecycleFilterType.all, l10n.txnRecycleFilterAll),
      (RecycleFilterType.expense, l10n.txnRecycleFilterExpense),
      (RecycleFilterType.income, l10n.txnRecycleFilterIncome),
    ];

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      color: context.colors.surface,
      child: Row(
        children: options.map((opt) {
          final isSelected = _filterType == opt.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(opt.$2, style: TextStyle(
                fontSize: 13,
                color: isSelected ? context.colors.primary : context.colors.textSecondary,
              )),
              selected: isSelected,
              onSelected: (_) => setState(() => _filterType = opt.$1),
              selectedColor: context.colors.primarySurface,
              backgroundColor: context.colors.surface,
              side: BorderSide(
                color: isSelected ? context.colors.primary.withValues(alpha: 0.3) : context.colors.separatorOpaque,
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete_outline, size: 48, color: context.colors.textTertiary),
          const SizedBox(height: 16),
          Text(l10n.txnRecycleBinEmpty, style: context.textStyles.callout.copyWith(color: context.colors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildGroupedList(List<Transaction> txns, AppLocalizations l10n) {
    final grouped = _groupByDate(txns);
    final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return GestureDetector(
      onLongPress: _isSelectMode ? null : _toggleSelectMode,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final dayTxns = grouped[date]!;
          return _buildGroup(date, dayTxns);
        },
      ),
    );
  }

  Widget _buildGroup(DateTime date, List<Transaction> txns) {
    // 包装 TransactionGroup，支持多选高亮和长按操作
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 复用 TransactionGroup 的日期头和交易列表
        TransactionGroup(
          date: date,
          transactions: txns,
          categoryMap: _categoryMap,
          onDelete: _restoreSingle,
          onTap: (t) {
            if (_isSelectMode) {
              _toggleSelection(t.id);
            } else {
              _showItemActions(t);
            }
          },
        ),
      ],
    );
  }

  Widget _buildBatchBar(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.md, 12, AppDimensions.md,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.colors.separatorOpaque, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _batchRestore,
              icon: Icon(Icons.restore, size: 18, color: context.colors.success),
              label: Text(l10n.txnRestore, style: TextStyle(color: context.colors.success)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: context.colors.success.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _batchPermanentDelete,
              icon: const Icon(Icons.delete_forever, size: 18, color: Colors.white),
              label: Text(l10n.txnRecyclePermanentDelete, style: const TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.error,
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
}
