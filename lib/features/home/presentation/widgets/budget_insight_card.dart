import 'package:flutter/material.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 预算提醒卡片
/// 橙色背景，圆角设计，显示预算超支提醒
class BudgetInsightCard extends StatelessWidget {
  final String message;
  final VoidCallback? onTap;

  const BudgetInsightCard({
    super.key,
    required this.message,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.md,
        AppDimensions.sm,
        AppDimensions.md,
        0,
      ),
      child: Material(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.md,
              vertical: 12,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  size: 20,
                  color: Color(0xFFE65100),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: context.textStyles.footnote.copyWith(
                      color: const Color(0xFFE65100),
                    ),
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.homeBudgetDetails,
                  style: context.textStyles.footnote.copyWith(
                    color: context.colors.warning,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
