import 'package:flutter/material.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 支付方式选择 BottomSheet
class PayMethodSelectionSheet extends StatefulWidget {
  final String? currentPayMethod;
  final List<(String?, String)> methods;
  final IconData Function(String?) getPayMethodIcon;

  const PayMethodSelectionSheet({
    super.key,
    required this.currentPayMethod,
    required this.methods,
    required this.getPayMethodIcon,
  });

  static Future<String?> show({
    required BuildContext context,
    required String? currentPayMethod,
    required List<(String?, String)> methods,
    required IconData Function(String?) getPayMethodIcon,
  }) {
    return showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PayMethodSelectionSheet(
        currentPayMethod: currentPayMethod,
        methods: methods,
        getPayMethodIcon: getPayMethodIcon,
      ),
    );
  }

  @override
  State<PayMethodSelectionSheet> createState() => _PayMethodSelectionSheetState();
}

class _PayMethodSelectionSheetState extends State<PayMethodSelectionSheet> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽把手
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: context.colors.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // 支付方式列表
          ...widget.methods.map((m) => ListTile(
            leading: Icon(m.$1 == null ? Icons.payment : widget.getPayMethodIcon(m.$1),
              color: widget.currentPayMethod == m.$1 ? context.colors.primary : context.colors.textSecondary),
            title: Text(m.$2, style: TextStyle(
              fontWeight: widget.currentPayMethod == m.$1 ? FontWeight.w600 : FontWeight.w400,
              color: widget.currentPayMethod == m.$1 ? context.colors.primary : null,
            )),
            onTap: () => Navigator.of(context).pop(m.$1),
          )),
          const Divider(height: 1, thickness: 0.5),
          ListTile(
            leading: const Icon(Icons.edit_outlined, color: Colors.grey),
            title: Text(l10n.payMethodCustom, style: const TextStyle(color: Colors.grey)),
            onTap: () => _showCustomInput(context, l10n),
          ),
        ],
      ),
    );
  }

  void _showCustomInput(BuildContext context, AppLocalizations l10n) {
    Navigator.of(context).pop();
    CustomPayMethodInputSheet.show(context, onSubmitted: (value) {
      if (mounted) Navigator.of(context).pop(value);
    });
  }
}

/// 支付方式自定义输入 BottomSheet
class CustomPayMethodInputSheet extends StatefulWidget {
  final void Function(String) onSubmitted;

  const CustomPayMethodInputSheet({super.key, required this.onSubmitted});

  static Future<String?> show(BuildContext context, {required void Function(String) onSubmitted}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomPayMethodInputSheet(onSubmitted: onSubmitted),
    );
  }

  @override
  State<CustomPayMethodInputSheet> createState() => _CustomPayMethodInputSheetState();
}

class _CustomPayMethodInputSheetState extends State<CustomPayMethodInputSheet> {
  late final TextEditingController _controller;
  late final AppLocalizations _l10n;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _l10n = AppLocalizations.of(context)!;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 拖拽把手
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: context.colors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // 标题
          Text(_l10n.payMethodCustom, style: context.textStyles.h3),
          const SizedBox(height: 16),
          // 输入框
          TextField(
            controller: _controller,
            autofocus: true,
            style: context.textStyles.body,
            decoration: InputDecoration(
              hintText: _l10n.payMethodCustom,
              hintStyle: context.textStyles.body.copyWith(color: context.colors.textHint),
              filled: true,
              fillColor: context.colors.surfaceSecondary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 16),
          // 按钮行
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    ),
                  ),
                  child: Text(_l10n.commonCancel, style: AppTextStyles.buttonText),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final value = _controller.text.trim();
                    if (value.isNotEmpty) {
                      widget.onSubmitted(value);
                      Navigator.of(context).pop(value);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    ),
                  ),
                  child: Text(_l10n.commonSave, style: AppTextStyles.buttonText.copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
