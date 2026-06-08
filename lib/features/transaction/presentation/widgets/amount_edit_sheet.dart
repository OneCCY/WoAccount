import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 金额编辑 BottomSheet（数字键盘）
class AmountEditSheet extends StatefulWidget {
  final double initialAmount;
  final bool isExpense;

  const AmountEditSheet({
    super.key,
    required this.initialAmount,
    required this.isExpense,
  });

  /// 显示金额编辑 Sheet，返回编辑后的金额，取消返回 null
  static Future<double?> show(BuildContext context, {
    required double initialAmount,
    required bool isExpense,
  }) {
    return showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AmountEditSheet(initialAmount: initialAmount, isExpense: isExpense),
    );
  }

  @override
  State<AmountEditSheet> createState() => _AmountEditSheetState();
}

class _AmountEditSheetState extends State<AmountEditSheet> {
  late String _amountStr;

  @override
  void initState() {
    super.initState();
    final fixed = widget.initialAmount.toStringAsFixed(2);
    // 去掉末尾多余的 0 但保留至少一位小数
    _amountStr = fixed.endsWith('00')
        ? widget.initialAmount.toStringAsFixed(0)
        : fixed;
  }

  void _onDigit(String d) {
    final dotIndex = _amountStr.indexOf('.');
    if (dotIndex != -1 && _amountStr.length - dotIndex > 2) return;
    if (_amountStr.length >= 12) return;
    setState(() => _amountStr += d);
  }

  void _onDelete() {
    if (_amountStr.isNotEmpty) {
      setState(() => _amountStr = _amountStr.substring(0, _amountStr.length - 1));
    }
  }

  double? get _amount => double.tryParse(_amountStr);

  @override
  Widget build(BuildContext context) {
    final amountColor = widget.isExpense ? context.colors.expense : context.colors.income;
    final prefix = widget.isExpense ? '-' : '+';

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽把手
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            decoration: BoxDecoration(
              color: context.colors.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 金额显示
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$prefix¥',
                  style: context.textStyles.h2.copyWith(color: amountColor),
                ),
                const SizedBox(width: 4),
                Text(
                  _amountStr.isEmpty ? '0' : _amountStr,
                  style: context.textStyles.amountLarge.copyWith(color: amountColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 数字键盘
          Container(
            color: context.colors.surfaceSecondary,
            padding: const EdgeInsets.all(4),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Row(
                    children: [
                      _key('1'), _key('2'), _key('3'),
                    ],
                  ),
                  Row(
                    children: [
                      _key('4'), _key('5'), _key('6'),
                    ],
                  ),
                  Row(
                    children: [
                      _key('7'), _key('8'), _key('9'),
                    ],
                  ),
                  Row(
                    children: [
                      _key('.'), _key('0'),
                      _KeyButton(
                        label: '删除',
                        icon: Icons.backspace_outlined,
                        onTap: _onDelete,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2, 0, 2, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Material(
                              color: context.colors.surfaceSecondary,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                              child: InkWell(
                                onTap: () => Navigator.of(context).pop(),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                                child: SizedBox(
                                  height: 48,
                                  child: Center(
                                    child: Text('取消', style: context.textStyles.body.copyWith(color: context.colors.textSecondary)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Material(
                              color: _amount != null && _amount! > 0
                                  ? context.colors.primary
                                  : context.colors.textHint,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                              child: InkWell(
                                onTap: _amount != null && _amount! > 0
                                    ? () => Navigator.of(context).pop(_amount)
                                    : null,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                                child: SizedBox(
                                  height: 48,
                                  child: Center(
                                    child: Text('确认', style: AppTextStyles.buttonText.copyWith(color: Colors.white)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _key(String label) {
    return _KeyButton(label: label, onTap: () => _onDigit(label));
  }
}

class _KeyButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  const _KeyButton({required this.label, required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Material(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            child: SizedBox(
              height: 48,
              child: Center(
                child: icon != null
                    ? Icon(icon, size: 20, color: context.colors.textPrimary)
                    : Text(label, style: context.textStyles.h3),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
