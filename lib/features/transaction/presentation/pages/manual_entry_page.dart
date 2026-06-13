import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../config/database/app_database.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/locale/category_l10n.dart';
import '../../../../core/locale/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../category/domain/repositories/category_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../../../core/widgets/toast.dart';

/// 记账类型
enum EntryType { expense, income, other }

/// 手动记账页
/// 类型切换 → 分类网格 → 子分类 → 备注+金额 → 数字键盘
class ManualEntryPage extends ConsumerStatefulWidget {
  const ManualEntryPage({super.key});

  @override
  ConsumerState<ManualEntryPage> createState() => _ManualEntryPageState();
}

class _ManualEntryPageState extends ConsumerState<ManualEntryPage> {
  EntryType _entryType = EntryType.expense;
  Category? _selectedCategory;
  Category? _selectedSubCategory;
  DateTime _selectedDate = DateTime.now();
  String _amountStr = '';
  String _note = '';
  bool _showSubCategoryOverlay = false;
  bool _showDatePicker = false;
  late final CategoryRepository _catRepo;
  late final TransactionRepository _txnRepo;

  @override
  void initState() {
    super.initState();
    _catRepo = ref.read(categoryRepositoryProvider);
    _txnRepo = ref.read(transactionRepositoryProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          _buildTopBar(l10n),
          _buildTypeTabs(l10n),
          Expanded(child: _buildCategoryGrid()),
          if (_selectedCategory != null) _buildSelectedCategoryBar(),
          _buildNoteAmountRow(l10n),
          _buildNumpad(l10n),
        ],
      ),
    );
  }

  /// 顶部栏
  Widget _buildTopBar(AppLocalizations l10n) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      color: context.colors.surface,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 24),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          Text(l10n.entryTitle, style: context.textStyles.h3),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: context.colors.primarySurface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Text(
              l10n.entryBookType,
              style: context.textStyles.caption.copyWith(color: context.colors.primaryDark),
            ),
          ),
        ],
      ),
    );
  }

  /// 类型切换 Tab
  Widget _buildTypeTabs(AppLocalizations l10n) {
    return Container(
      color: context.colors.surface,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      child: Row(
        children: EntryType.values.map((type) {
          final isActive = _entryType == type;
          final label = switch (type) {
            EntryType.expense => l10n.entryExpense,
            EntryType.income => l10n.entryIncome,
            EntryType.other => l10n.entryOther,
          };
          return GestureDetector(
            onTap: () {
              setState(() {
                _entryType = type;
                _selectedCategory = null;
                _selectedSubCategory = null;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                border: isActive
                    ? Border(
                        bottom: BorderSide(color: context.colors.primary, width: 2),
                      )
                    : null,
              ),
              child: Text(
                label,
                style: context.textStyles.callout.copyWith(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? context.colors.primary : context.colors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 分类网格
  Widget _buildCategoryGrid() {
    return FutureBuilder<List<Category>>(
      future: _catRepo.getTopLevel(),
      builder: (context, snapshot) {
        final allCategories = snapshot.data ?? [];
        final categories = _filterCategories(allCategories);

        if (categories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = _selectedCategory?.id == cat.id;
                  return _CategoryItem(
                    category: cat,
                    isSelected: isSelected,
                    onTap: () => _onCategoryTap(cat),
                    onSubTap: () => _onSubCategoryTap(cat),
                  );
                },
              ),
            ),
            // 子分类浮层
            if (_showSubCategoryOverlay && _selectedCategory != null)
              _buildSubCategoryOverlay(_selectedCategory!),
            // 日期选择器
            if (_showDatePicker) _buildDatePickerOverlay(),
          ],
        );
      },
    );
  }

  List<Category> _filterCategories(List<Category> categories) {
    const otherKeys = {'catOtherTransfer', 'catOtherRepayment', 'catOtherSocial'};
    switch (_entryType) {
      case EntryType.expense:
        return categories.where((c) => c.isExpense).toList();
      case EntryType.income:
        return categories.where((c) => !c.isExpense && (c.l10nKey == null || !otherKeys.contains(c.l10nKey))).toList();
      case EntryType.other:
        return categories.where((c) => c.l10nKey != null && otherKeys.contains(c.l10nKey)).toList();
    }
  }

  void _onCategoryTap(Category cat) {
    setState(() {
      _selectedCategory = cat;
      _selectedSubCategory = null;
      _showSubCategoryOverlay = false;
    });
  }

  void _onSubCategoryTap(Category cat) {
    setState(() {
      _selectedCategory = cat;
      _showSubCategoryOverlay = true;
    });
  }

  /// 子分类浮层
  Widget _buildSubCategoryOverlay(Category parent) {
    return FutureBuilder<List<Category>>(
      future: _catRepo.getChildren(parent.id),
      builder: (context, snapshot) {
        final children = snapshot.data ?? [];
        if (children.isEmpty) {
          return const SizedBox.shrink();
        }

        return Positioned.fill(
          child: Container(
            color: context.colors.surface,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, size: 20),
                        onPressed: () {
                          setState(() => _showSubCategoryOverlay = false);
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      Text(AppLocalizations.of(context)!.entrySubCategoryTitle(parent.name), style: context.textStyles.h3),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: children.length,
                    itemBuilder: (context, index) {
                      final sub = children[index];
                      final isSelected = _selectedSubCategory?.id == sub.id;
                      return _CategoryItem(
                        category: sub,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedSubCategory = sub;
                            _showSubCategoryOverlay = false;
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 已选分类显示栏
  Widget _buildSelectedCategoryBar() {
    final category = _selectedSubCategory ?? _selectedCategory!;
    final parentName = _selectedSubCategory != null ? '${_selectedCategory!.name}/' : '';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: 8,
      ),
      color: context.colors.primarySurface,
      child: Row(
        children: [
          Text(
            '$parentName${getCategoryDisplayName(category, AppLocalizations.of(context)!)}',
            style: context.textStyles.footnote.copyWith(color: context.colors.primaryDark),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = null;
                _selectedSubCategory = null;
              });
            },
            child: Icon(Icons.close, size: 16, color: context.colors.primaryDark),
          ),
        ],
      ),
    );
  }

  /// 备注输入 + 金额显示
  Widget _buildNoteAmountRow(AppLocalizations l10n) {
    final amountColor = switch (_entryType) {
      EntryType.expense => context.colors.expense,
      EntryType.income => context.colors.income,
      EntryType.other => context.colors.textPrimary,
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: context.colors.surface,
      child: Row(
        children: [
          // 备注输入
          Expanded(
            child: TextField(
              style: context.textStyles.body,
              decoration: InputDecoration(
                hintText: l10n.entryNoteHint,
                hintStyle: context.textStyles.body.copyWith(color: context.colors.textHint),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (v) => _note = v,
            ),
          ),
          const SizedBox(width: 16),
          // 金额显示
          Text(
            _amountStr.isEmpty ? '0.00' : _amountStr,
            style: context.textStyles.amountLarge.copyWith(color: amountColor),
          ),
        ],
      ),
    );
  }

  /// 自定义数字键盘
  Widget _buildNumpad(AppLocalizations l10n) {
    return Container(
      color: context.colors.surface,
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              children: [
                _NumpadKey(label: '1', onTap: () => _onDigit('1')),
                _NumpadKey(label: '2', onTap: () => _onDigit('2')),
                _NumpadKey(label: '3', onTap: () => _onDigit('3')),
                _NumpadKey(
                  label: l10n.entryNumpadToday,
                  onTap: () => setState(() => _showDatePicker = !_showDatePicker),
                  textStyle: context.textStyles.caption.copyWith(color: context.colors.primary),
                ),
              ],
            ),
            Row(
              children: [
                _NumpadKey(label: '4', onTap: () => _onDigit('4')),
                _NumpadKey(label: '5', onTap: () => _onDigit('5')),
                _NumpadKey(label: '6', onTap: () => _onDigit('6')),
                _NumpadKey(
                  label: l10n.entryNumpadDelete,
                  onTap: _onDelete,
                  icon: Icons.backspace_outlined,
                ),
              ],
            ),
            Row(
              children: [
                _NumpadKey(label: '7', onTap: () => _onDigit('7')),
                _NumpadKey(label: '8', onTap: () => _onDigit('8')),
                _NumpadKey(label: '9', onTap: () => _onDigit('9')),
                _NumpadKey(
                  label: '+/-',
                  onTap: _onToggleSign,
                  textStyle: context.textStyles.body.copyWith(color: context.colors.textSecondary),
                ),
              ],
            ),
            Row(
              children: [
                _NumpadKey(label: '.', onTap: _onDot),
                _NumpadKey(label: '0', onTap: () => _onDigit('0')),
                _NumpadKey(
                  label: l10n.entryNumpadDone,
                  onTap: _onSubmit,
                  backgroundColor: _canSubmit ? context.colors.primary : context.colors.surfaceSecondary,
                  textStyle: AppTextStyles.buttonText.copyWith(
                    color: _canSubmit ? context.colors.textOnPrimary : context.colors.textHint,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool get _canSubmit {
    final amount = double.tryParse(_amountStr);
    return amount != null && amount > 0 && _selectedCategory != null;
  }

  void _onDigit(String d) {
    setState(() {
      // 小数点后最多2位
      final dotIndex = _amountStr.indexOf('.');
      if (dotIndex != -1 && _amountStr.length - dotIndex > 2) return;
      // 最大长度
      if (_amountStr.length >= 12) return;
      _amountStr += d;
    });
  }

  void _onDot() {
    setState(() {
      if (_amountStr.contains('.')) return;
      if (_amountStr.isEmpty) {
        _amountStr = '0.';
      } else {
        _amountStr += '.';
      }
    });
  }

  void _onDelete() {
    setState(() {
      if (_amountStr.isNotEmpty) {
        _amountStr = _amountStr.substring(0, _amountStr.length - 1);
      }
    });
  }

  void _onToggleSign() {
    // 简单实现：在金额前加/减号
    // 实际可扩展为计算器模式
  }

  Future<void> _onSubmit() async {
    if (!_canSubmit) return;

    final amount = double.parse(_amountStr);
    final category = _selectedSubCategory ?? _selectedCategory!;

    try {
      await _txnRepo.insert(TransactionsCompanion.insert(
        amount: amount,
        description: _note.isEmpty ? category.name : _note,
        categoryId: category.id,
        subcategoryId: _selectedSubCategory != null ? Value(_selectedCategory!.id) : const Value.absent(),
        transactionDate: _selectedDate,
        originalInput: Value(_note),
        aiSource: const Value('manual'),
        accountBookId: ref.read(currentBookProvider),
      ));

      if (mounted) {
        AppToast.show(context, AppLocalizations.of(context)!.entrySuccess(context.localeProvider.currency.formatAmount(amount)));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(context, AppLocalizations.of(context)!.entryFailure(e.toString()));
      }
    }
  }

  /// 日期选择器浮层
  Widget _buildDatePickerOverlay() {
    return Positioned.fill(
      child: Container(
        color: context.colors.surface,
        child: _SimpleCalendar(
          selectedDate: _selectedDate,
          onDateSelected: (date) {
            setState(() {
              _selectedDate = date;
              _showDatePicker = false;
            });
          },
        ),
      ),
    );
  }
}

/// 分类网格项
class _CategoryItem extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onSubTap;

  const _CategoryItem({
    required this.category,
    required this.onTap,
    this.isSelected = false,
    this.onSubTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(context, category.color);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: isSelected
                      ? Border.all(color: context.colors.primary, width: 2)
                      : null,
                ),
                child: Center(
                  child: Text(
                    category.icon ?? '📦',
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              // 子分类指示点
              if (onSubTap != null)
                Positioned(
                  right: -2,
                  top: -2,
                  child: GestureDetector(
                    onTap: onSubTap,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: context.colors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(Icons.add, size: 10, color: context.colors.textOnPrimary),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            getCategoryDisplayName(category, AppLocalizations.of(context)!),
            style: context.textStyles.caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _parseColor(BuildContext context, String? hex) {
    if (hex == null || hex.isEmpty) return context.colors.textTertiary;
    final clean = hex.replaceFirst('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }
}

/// 数字键盘按键
class _NumpadKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final TextStyle? textStyle;
  final Color? backgroundColor;

  const _NumpadKey({
    required this.label,
    required this.onTap,
    this.icon,
    this.textStyle,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Material(
          color: backgroundColor ?? context.colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            child: SizedBox(
              height: 48,
              child: Center(
                child: icon != null
                    ? Icon(icon, size: 20, color: context.colors.textPrimary)
                    : Text(
                        label,
                        style: textStyle ?? context.textStyles.h3,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 简单日历组件
class _SimpleCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const _SimpleCalendar({
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final firstDay = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDay = DateTime(selectedDate.year, selectedDate.month + 1, 0);
    final startWeekday = firstDay.weekday % 7; // 0=Sunday

    return Column(
      children: [
        // 月份标题
        Padding(
          padding: const EdgeInsets.all(AppDimensions.md),
          child: Text(
            l10n.reportMonthLabel(selectedDate.year.toString(), selectedDate.month.toString()),
            style: context.textStyles.h3,
          ),
        ),
        // 星期标题
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
          child: Row(
            children: [l10n.weekSun, l10n.weekMon, l10n.weekTue, l10n.weekWed, l10n.weekThu, l10n.weekFri, l10n.weekSat]
                .map((d) => Expanded(
                      child: Center(
                        child: Text(d, style: context.textStyles.caption),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        // 日期网格
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: startWeekday + lastDay.day,
            itemBuilder: (context, index) {
              if (index < startWeekday) {
                return const SizedBox.shrink();
              }
              final day = index - startWeekday + 1;
              final date = DateTime(selectedDate.year, selectedDate.month, day);
              final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
              final isSelected = date.year == selectedDate.year &&
                  date.month == selectedDate.month &&
                  date.day == selectedDate.day;

              return GestureDetector(
                onTap: () => onDateSelected(date),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? context.colors.primary : (isToday ? context.colors.primarySurface : null),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: context.textStyles.body.copyWith(
                        color: isSelected ? context.colors.textOnPrimary : context.colors.textPrimary,
                        fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
