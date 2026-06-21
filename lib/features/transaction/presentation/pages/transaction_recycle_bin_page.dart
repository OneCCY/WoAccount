import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../config/database/app_database.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/locale/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/toast.dart';

/// 排序方式
enum RecycleSortBy { deleteTime, amount, date }

/// 类型筛选
enum RecycleFilterType { all, expense, income }

/// 交易回收站 — 支持排序、筛选、多选批量操作
class TransactionRecycleBinPage extends ConsumerStatefulWidget {
  const TransactionRecycleBinPage({super.key});

  @override
  ConsumerState<TransactionRecycleBinPage> createState() => _TransactionRecycleBinPageState();
}

class _TransactionRecycleBinPageState extends ConsumerState<TransactionRecycleBinPage> {
  List<Transaction> _allTxns = [];
  Map<int, Category?> _categories = {};
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
    final cats = <int, Category?>{};
    for (final txn in txns) {
      if (!cats.containsKey(txn.categoryId)) {
        cats[txn.categoryId] = await catRepo.getById(txn.categoryId);
      }
    }

    if (mounted) {
      setState(() {
        _allTxns = txns;
        _categories = cats;
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

  /// 按时间分组（今天 / 本周 / 更早）
  Map<String, List<Transaction>> _groupByTime(List<Transaction> txns) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));

    final groups = <String, List<Transaction>>{};
    for (final t in txns) {
      final key = t.updatedAt.isAfter(todayStart)
          ? 'today'
          : t.updatedAt.isAfter(weekStart)
              ? 'week'
              : 'earlier';
      groups.putIfAbsent(key, () => []).add(t);
    }
    return groups;
  }

  // ==================== 操作 ====================

  Future<void> _restoreSingle(int id) async {
    final txnRepo = ref.read(transactionRepositoryProvider);
    final success = await txnRepo.restore(id);
    if (success && mounted) {
      AppToast.show(context, AppLocalizations.of(context)!.txnRestored);
      await _loadData();
    }
  }

  Future<void> _permanentDeleteSingle(int id) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _confirmPermanentDelete(l10n);
    if (confirmed != true) return;

    final txnRepo = ref.read(transactionRepositoryProvider);
    final success = await txnRepo.permanentDelete(id);
    if (success && mounted) {
      AppToast.show(context, l10n.txnRecycleBatchDeleted(1));
      await _loadData();
    }
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
        // 排序菜单
        PopupMenuButton<RecycleSortBy>(
          icon: Icon(Icons.sort, color: context.colors.textSecondary),
          onSelected: (v) => setState(() => _sortBy = v),
          itemBuilder: (_) => [
            PopupMenuItem(value: RecycleSortBy.deleteTime, child: Text(l10n.txnRecycleSortByDeleteTime)),
            PopupMenuItem(value: RecycleSortBy.amount, child: Text(l10n.txnRecycleSortByAmount)),
            PopupMenuItem(value: RecycleSortBy.date, child: Text(l10n.txnRecycleSortByDate)),
          ],
        ),
        // 进入多选模式
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
    final groups = _groupByTime(txns);
    final groupOrder = ['today', 'week', 'earlier'];
    final groupLabels = {
      'today': l10n.txnRecycleGroupToday,
      'week': l10n.txnRecycleGroupWeek,
      'earlier': l10n.txnRecycleGroupEarlier,
    };

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: groupOrder.fold<int>(0, (sum, key) => sum + (groups[key]?.length ?? 0) + (groups.containsKey(key) ? 1 : 0)),
      itemBuilder: (context, index) {
        var offset = 0;
        for (final key in groupOrder) {
          final items = groups[key];
          if (items == null || items.isEmpty) continue;

          if (index == offset) {
            return _buildGroupHeader(groupLabels[key]!, items.length);
          }
          offset++;

          final itemIndex = index - offset;
          if (itemIndex < items.length) {
            return _buildItem(items[itemIndex], l10n);
          }
          offset += items.length;
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildGroupHeader(String label, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 10),
      color: context.colors.surfaceSecondary,
      child: Row(
        children: [
          Text(label, style: context.textStyles.footnote.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          )),
          const SizedBox(width: 8),
          Text('$count', style: context.textStyles.caption.copyWith(color: context.colors.textTertiary)),
        ],
      ),
    );
  }

  Widget _buildItem(Transaction txn, AppLocalizations l10n) {
    final cat = _categories[txn.categoryId];
    final isExpense = txn.type == 'expense';
    final amountColor = isExpense ? context.colors.expense : context.colors.income;
    final amountSign = isExpense ? '-' : '+';
    final currency = ref.read(localeProviderOverrideProvider).currency;
    final dateStr = DateFormat('MM/dd HH:mm').format(txn.transactionDate);
    final isSelected = _selectedIds.contains(txn.id);

    return Dismissible(
      key: ValueKey(txn.id),
      // 左滑 → 恢复
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        color: context.colors.success,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restore, color: Colors.white, size: 20),
            const SizedBox(width: 6),
            Text(l10n.txnRestore, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
      // 右滑 → 永久删除
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: context.colors.error,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.txnRecyclePermanentDelete, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
            const SizedBox(width: 6),
            const Icon(Icons.delete_forever, color: Colors.white, size: 20),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await _restoreSingle(txn.id);
          return false;
        } else {
          await _permanentDeleteSingle(txn.id);
          return false;
        }
      },
      child: GestureDetector(
        onLongPress: () {
          if (!_isSelectMode) {
            setState(() => _isSelectMode = true);
            _selectedIds.add(txn.id);
          }
        },
        onTap: _isSelectMode ? () => _toggleSelection(txn.id) : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? context.colors.primary.withValues(alpha: 0.08)
                : context.colors.surface,
            border: Border(bottom: BorderSide(color: context.colors.separatorOpaque, width: 0.5)),
          ),
          child: Row(
            children: [
              // 多选勾选框 / 分类图标
              if (_isSelectMode)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 22,
                    color: isSelected ? context.colors.primary : context.colors.textTertiary,
                  ),
                )
              else ...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.colors.primarySurface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: Center(
                    child: Text(cat?.icon ?? '📝', style: const TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              // 信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      txn.description.isNotEmpty ? txn.description : (cat?.name ?? ''),
                      style: context.textStyles.body.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${cat?.name ?? ''} · $dateStr',
                      style: context.textStyles.caption.copyWith(color: context.colors.textTertiary),
                    ),
                  ],
                ),
              ),
              // 金额
              Text(
                '$amountSign${currency.formatAmount(txn.amount)}',
                style: context.textStyles.amountList.copyWith(color: amountColor, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
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
          // 恢复按钮
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
          // 永久删除按钮
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
