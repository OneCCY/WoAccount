import 'package:flutter/material.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';

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
            leading: Icon(Icons.more_horiz, color: Colors.grey),
            title: Text(l10n.payMethodCustom, style: const TextStyle(color: Colors.grey)),
            onTap: () => Navigator.of(context).pop('other'),
          ),
        ],
      ),
    );
  }
}