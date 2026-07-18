import 'package:flutter/material.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 支付方式选择 BottomSheet（含自定义输入）
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
  bool _showCustomInput = false;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + MediaQuery.of(context).padding.bottom),
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
          if (_showCustomInput)
            _buildCustomInput(context, l10n)
          else
            _buildMethodList(context, l10n),
        ],
      ),
    );
  }

  Widget _buildMethodList(BuildContext context, AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
          onTap: () => setState(() => _showCustomInput = true),
        ),
      ],
    );
  }

  Widget _buildCustomInput(BuildContext context, AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 返回按钮
        GestureDetector(
          onTap: () => setState(() => _showCustomInput = false),
          child: Row(
            children: [
              Icon(Icons.arrow_back, size: 20, color: context.colors.primary),
              const SizedBox(width: 4),
              Text(l10n.payMethodCustom, style: context.textStyles.h3),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // 输入框（与备注完全一致）
        TextField(
          controller: _controller,
          autofocus: true,
          style: context.textStyles.body,
          decoration: InputDecoration(
            hintText: l10n.payMethodCustom,
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
        // 按钮行（与备注完全一致）
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
                child: Text(l10n.commonCancel, style: AppTextStyles.buttonText),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  final value = _controller.text.trim();
                  if (value.isNotEmpty) Navigator.of(context).pop(value);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                ),
                child: Text(l10n.commonSave, style: AppTextStyles.buttonText.copyWith(color: Colors.white)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}