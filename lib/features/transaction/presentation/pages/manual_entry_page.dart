import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:intl/intl.dart';
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
import '../../presentation/widgets/datetime_edit_sheet.dart';
import '../../../../core/widgets/toast.dart';

/// 记账类型
enum EntryType { expense, income, other }

/// 手动记账页
/// 类型切换 → 分类网格（自动进入子分类）→ 已选分类 + 金额 + 数字键盘
class ManualEntryPage extends ConsumerStatefulWidget {
  const ManualEntryPage({super.key});

  @override
  ConsumerState<ManualEntryPage> createState() => _ManualEntryPageState();
}

class _ManualEntryPageState extends ConsumerState<ManualEntryPage> {
  EntryType _entryType = EntryType.expense;
  Category? _selectedCategory;
  Category? _selectedSubCategory;
  Category? _parentCategory; // 子分类的父分类
  bool _showSubCategories = false;
  DateTime _selectedDate = DateTime.now();
  String _note = '';
  late final CategoryRepository _catRepo;
  late final TransactionRepository _txnRepo;

  // ==================== 栈式计算器状态 ====================
  /// 表达式显示字符串，如 "100+50-30"
  String _expression = '';
  /// 当前正在输入的数字
  String _currentInput = '';
  /// 运算数栈（存储中间结果）
  final List<double> _operandStack = [];
  /// 运算符栈
  final List<String> _operatorStack = [];
  /// 最终计算结果
  double _result = 0.0;

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
          Expanded(
            child: _showSubCategories && _parentCategory != null
                ? _buildSubCategoryGrid(_parentCategory!)
                : _buildCategoryGrid(),
          ),
          _buildSelectedCategoryBar(l10n),
          _buildAmountNoteRow(l10n),
          _buildNumpad(l10n),
        ],
      ),
    );
  }

  // ==================== 顶部栏 ====================

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

  // ==================== 类型切换 ====================

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
                _parentCategory = null;
                _showSubCategories = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                border: isActive
                    ? Border(bottom: BorderSide(color: context.colors.primary, width: 2))
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

  // ==================== 一级分类网格 ====================

  Widget _buildCategoryGrid() {
    return FutureBuilder<List<Category>>(
      future: _catRepo.getTopLevel(),
      builder: (context, snapshot) {
        final allCategories = snapshot.data ?? [];
        final categories = _filterCategories(allCategories);

        if (categories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
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
              final isSelected = _selectedCategory?.id == cat.id &&
                  _selectedSubCategory == null;
              return _CategoryItem(
                category: cat,
                isSelected: isSelected,
                onTap: () => _onCategoryTap(cat),
              );
            },
          ),
        );
      },
    );
  }

  // ==================== 二级分类网格 ====================

  Widget _buildSubCategoryGrid(Category parent) {
    return FutureBuilder<List<Category>>(
      future: _catRepo.getChildren(parent.id),
      builder: (context, snapshot) {
        final children = snapshot.data ?? [];

        return Column(
          children: [
            // 返回按钮 + 父分类名
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showSubCategories = false;
                        _parentCategory = null;
                        _selectedSubCategory = null;
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back_ios, size: 14, color: context.colors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          getCategoryDisplayName(parent, AppLocalizations.of(context)!),
                          style: context.textStyles.body.copyWith(color: context.colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // 选择父分类（无子分类时直接选这个）
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = parent;
                        _selectedSubCategory = null;
                        _showSubCategories = false;
                        _parentCategory = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: context.colors.primarySurface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.entrySelectThisCategory,
                        style: context.textStyles.caption.copyWith(color: context.colors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 子分类网格
            Expanded(
              child: children.isEmpty
                  ? Center(
                      child: Text(
                        AppLocalizations.of(context)!.entryNoSubCategory,
                        style: context.textStyles.body.copyWith(color: context.colors.textTertiary),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
                      child: GridView.builder(
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
                                _selectedCategory = parent;
                                _showSubCategories = false;
                                _parentCategory = null;
                              });
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  // ==================== 分类点击逻辑 ====================

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

  Future<void> _onCategoryTap(Category cat) async {
    // 检查是否有子分类
    final children = await _catRepo.getChildren(cat.id);
    if (!mounted) return;

    if (children.isNotEmpty) {
      // 有子分类 → 自动进入子分类界面
      setState(() {
        _parentCategory = cat;
        _showSubCategories = true;
        _selectedSubCategory = null;
      });
    } else {
      // 无子分类 → 直接选中
      setState(() {
        _selectedCategory = cat;
        _selectedSubCategory = null;
        _showSubCategories = false;
        _parentCategory = null;
      });
    }
  }

  // ==================== 已选分类栏 ====================

  Widget _buildSelectedCategoryBar(AppLocalizations l10n) {
    if (_selectedCategory == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 10),
        color: context.colors.surface,
        child: Row(
          children: [
            Icon(Icons.category_outlined, size: 18, color: context.colors.textHint),
            const SizedBox(width: 8),
            Text(
              l10n.entrySelectCategoryHint,
              style: context.textStyles.body.copyWith(color: context.colors.textHint),
            ),
          ],
        ),
      );
    }

    final cat = _selectedCategory!;
    final sub = _selectedSubCategory;
    final catName = getCategoryDisplayName(cat, l10n);
    final subName = sub != null ? getCategoryDisplayName(sub, l10n) : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 10),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(bottom: BorderSide(color: context.colors.separatorOpaque, width: 0.5)),
      ),
      child: Row(
        children: [
          // 图标
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: context.colors.primarySurface,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(sub?.icon ?? cat.icon ?? '📦', style: const TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 8),
          // 分类名
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: subName ?? catName,
                    style: AppTextStyles.body.copyWith(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subName != null) ...[
                    TextSpan(
                      text: '  ›  ',
                      style: AppTextStyles.body.copyWith(color: context.colors.textTertiary),
                    ),
                    TextSpan(
                      text: catName,
                      style: AppTextStyles.caption.copyWith(color: context.colors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // 清除按钮
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = null;
                _selectedSubCategory = null;
              });
            },
            child: Icon(Icons.close, size: 16, color: context.colors.textTertiary),
          ),
        ],
      ),
    );
  }

  // ==================== 金额 + 备注行 ====================

  Widget _buildAmountNoteRow(AppLocalizations l10n) {
    final amountColor = switch (_entryType) {
      EntryType.expense => context.colors.expense,
      EntryType.income => context.colors.income,
      EntryType.other => context.colors.textPrimary,
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: context.colors.surface,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 备注输入
                TextField(
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
                // 表达式历史
                if (_expressionText.isNotEmpty)
                  Text(
                    _expressionText,
                    style: context.textStyles.caption.copyWith(color: context.colors.textTertiary),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // 金额显示（大字）
          Text(
            _displayText,
            style: context.textStyles.amountLarge.copyWith(color: amountColor),
          ),
        ],
      ),
    );
  }

  // ==================== 自定义数字键盘 ====================

  Widget _buildNumpad(AppLocalizations l10n) {
    final dateLabel = DateFormat('MM/dd').format(_selectedDate);
    final isToday = _selectedDate.year == DateTime.now().year &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.day == DateTime.now().day;

    return Container(
      color: context.colors.surface,
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Row 1: 1 2 3 退格
            Row(
              children: [
                _NumpadKey(label: '1', onTap: () => _onDigit('1')),
                _NumpadKey(label: '2', onTap: () => _onDigit('2')),
                _NumpadKey(label: '3', onTap: () => _onDigit('3')),
                _NumpadKey(
                  label: '⌫',
                  onTap: _onDelete,
                  icon: Icons.backspace_outlined,
                ),
              ],
            ),
            // Row 2: 4 5 6 +
            Row(
              children: [
                _NumpadKey(label: '4', onTap: () => _onDigit('4')),
                _NumpadKey(label: '5', onTap: () => _onDigit('5')),
                _NumpadKey(label: '6', onTap: () => _onDigit('6')),
                _NumpadKey(
                  label: '+',
                  onTap: _onPlus,
                  textStyle: context.textStyles.h3.copyWith(color: context.colors.income),
                ),
              ],
            ),
            // Row 3: 7 8 9 -
            Row(
              children: [
                _NumpadKey(label: '7', onTap: () => _onDigit('7')),
                _NumpadKey(label: '8', onTap: () => _onDigit('8')),
                _NumpadKey(label: '9', onTap: () => _onDigit('9')),
                _NumpadKey(
                  label: '−',
                  onTap: _onMinus,
                  textStyle: context.textStyles.h3.copyWith(color: context.colors.expense),
                ),
              ],
            ),
            // Row 4: .  0  日期  完成
            Row(
              children: [
                _NumpadKey(label: '.', onTap: _onDot),
                _NumpadKey(label: '0', onTap: () => _onDigit('0')),
                _NumpadKey(
                  label: isToday ? l10n.entryNumpadToday : dateLabel,
                  onTap: _showDatePickerSheet,
                  textStyle: context.textStyles.caption.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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

  // ==================== 栈式计算器 ====================

  bool get _canSubmit => _result > 0 && _selectedCategory != null;

  /// 获取显示文本：表达式 + 当前输入
  String get _displayText {
    if (_currentInput.isNotEmpty) return _currentInput;
    if (_operandStack.isNotEmpty) return _formatAmount(_result);
    return '0.00';
  }

  /// 获取副显示文本：表达式历史
  String get _expressionText {
    if (_expression.isEmpty) return '';
    return _expression;
  }

  /// 输入数字
  void _onDigit(String d) {
    setState(() {
      // 小数点后最多2位
      final dotIndex = _currentInput.indexOf('.');
      if (dotIndex != -1 && _currentInput.length - dotIndex > 2) return;
      // 最大长度
      if (_currentInput.length >= 12) return;
      _currentInput += d;
      _updateResult();
    });
  }

  /// 输入小数点
  void _onDot() {
    setState(() {
      if (_currentInput.contains('.')) return;
      _currentInput += _currentInput.isEmpty ? '0.' : '.';
    });
  }

  /// 退格
  void _onDelete() {
    setState(() {
      if (_currentInput.isNotEmpty) {
        _currentInput = _currentInput.substring(0, _currentInput.length - 1);
        _updateResult();
      } else if (_operatorStack.isNotEmpty) {
        // 撤回最后一个运算符，恢复上一个操作数
        _operatorStack.removeLast();
        if (_operandStack.isNotEmpty) {
          _result = _operandStack.removeLast();
        }
        _rebuildExpression();
      }
    });
  }

  /// 加法
  void _onPlus() {
    setState(() {
      _commitCurrentInput();
      _operatorStack.add('+');
      _rebuildExpression();
    });
  }

  /// 减法
  void _onMinus() {
    setState(() {
      // 如果还没输入任何数字，允许输入负号作为开头
      if (_operandStack.isEmpty && _currentInput.isEmpty) {
        _currentInput = '-';
        return;
      }
      _commitCurrentInput();
      _operatorStack.add('-');
      _rebuildExpression();
    });
  }

  /// 将当前输入提交到栈并计算中间结果
  void _commitCurrentInput() {
    if (_currentInput.isEmpty || _currentInput == '-') return;
    final value = double.tryParse(_currentInput);
    if (value == null) return;

    if (_operandStack.isEmpty) {
      // 第一个操作数
      _operandStack.add(value);
      _result = value;
    } else {
      // 有前一个操作数和运算符，执行计算
      final prev = _operandStack.last;
      final op = _operatorStack.isNotEmpty ? _operatorStack.last : '+';
      final computed = _applyOperator(prev, value, op);
      _operandStack.add(computed);
      _result = computed;
    }
    _currentInput = '';
  }

  /// 执行运算
  double _applyOperator(double a, double b, String op) {
    switch (op) {
      case '+': return a + b;
      case '-': return a - b;
      default: return a + b;
    }
  }

  /// 实时更新结果预览（不提交到栈）
  void _updateResult() {
    if (_currentInput.isEmpty || _currentInput == '-') return;
    final value = double.tryParse(_currentInput);
    if (value == null) return;

    if (_operandStack.isEmpty) {
      _result = value;
    } else {
      final prev = _operandStack.last;
      final op = _operatorStack.isNotEmpty ? _operatorStack.last : '+';
      _result = _applyOperator(prev, value, op);
    }
  }

  /// 重建表达式字符串
  void _rebuildExpression() {
    _expression = '';
    for (int i = 0; i < _operandStack.length; i++) {
      if (i == 0) {
        // 第一个操作数取最新计算值
        _expression = _formatAmount(_operandStack[i]);
      }
      if (i < _operatorStack.length) {
        _expression += _operatorStack[i];
      }
    }
  }

  /// 格式化金额（最多2位小数，去除尾部零）
  String _formatAmount(double value) {
    // 精确到分
    final rounded = (value * 100).roundToDouble() / 100;
    if (rounded == rounded.roundToDouble()) {
      return rounded.toStringAsFixed(0);
    }
    final str = rounded.toStringAsFixed(2);
    return str.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  Future<void> _showDatePickerSheet() async {
    final result = await DatetimeEditSheet.show(context, initialDateTime: _selectedDate);
    if (result != null && mounted) {
      setState(() => _selectedDate = result);
    }
  }

  Future<void> _onSubmit() async {
    if (!_canSubmit) return;

    final l10n = AppLocalizations.of(context)!;
    // 如果有未提交的输入，先提交
    if (_currentInput.isNotEmpty && _currentInput != '-') {
      _commitCurrentInput();
    }
    final amount = _result;
    if (amount <= 0) return;

    final category = _selectedSubCategory ?? _selectedCategory!;

    try {
      await _txnRepo.insert(TransactionsCompanion.insert(
        amount: amount,
        description: _note.isEmpty ? category.name : _note,
        categoryId: category.id,
        subcategoryId: _selectedSubCategory != null
            ? Value(_selectedCategory!.id)
            : const Value.absent(),
        transactionDate: _selectedDate,
        originalInput: Value(_note),
        aiSource: const Value('manual'),
        accountBookId: ref.read(currentBookProvider),
      ));

      if (mounted) {
        AppToast.show(context, l10n.entrySuccess(
            context.localeProvider.currency.formatAmount(amount)));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(context, l10n.entryFailure(e.toString()));
      }
    }
  }
}

// ==================== 子组件 ====================

/// 分类网格项
class _CategoryItem extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.category,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(context, category.color);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
              child: Text(category.icon ?? '📦', style: const TextStyle(fontSize: 22)),
            ),
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
                    : Text(label, style: textStyle ?? context.textStyles.h3),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
