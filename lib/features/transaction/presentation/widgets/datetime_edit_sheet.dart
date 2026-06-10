import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 日期时间编辑 BottomSheet（Cupertino 滚轮选择器）
class DatetimeEditSheet extends StatefulWidget {
  final DateTime initialDateTime;

  const DatetimeEditSheet({super.key, required this.initialDateTime});

  /// 显示日期时间编辑 Sheet，返回选择的 DateTime，取消返回 null
  static Future<DateTime?> show(BuildContext context, {required DateTime initialDateTime}) {
    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DatetimeEditSheet(initialDateTime: initialDateTime),
    );
  }

  @override
  State<DatetimeEditSheet> createState() => _DatetimeEditSheetState();
}

class _DatetimeEditSheetState extends State<DatetimeEditSheet> {
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.initialDateTime;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 拖拽把手
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: context.colors.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 标题栏
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.commonCancel, style: context.textStyles.body.copyWith(color: context.colors.textSecondary)),
                ),
                Text(l10n.commonSelectDateTime, style: context.textStyles.footnote.copyWith(fontWeight: FontWeight.w600)),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(_selectedDateTime),
                  child: Text(l10n.commonConfirm, style: context.textStyles.body.copyWith(color: context.colors.primary, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Cupertino 日期时间选择器
          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.dateAndTime,
              initialDateTime: _selectedDateTime,
              maximumDate: DateTime.now().add(const Duration(days: 1)),
              minimumYear: 2020,
              maximumYear: DateTime.now().year + 1,
              use24hFormat: true,
              onDateTimeChanged: (dt) => _selectedDateTime = dt,
            ),
          ),
        ],
      ),
    );
  }
}
