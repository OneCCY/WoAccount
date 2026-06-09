import 'package:flutter/material.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 底部固定记账输入栏
class AiInputBar extends StatefulWidget {
  final Function(String) onSubmit;
  final VoidCallback onManualEntry;
  final VoidCallback onCamera;
  final bool isLoading;

  const AiInputBar({
    super.key,
    required this.onSubmit,
    required this.onManualEntry,
    required this.onCamera,
    this.isLoading = false,
  });

  @override
  State<AiInputBar> createState() => _AiInputBarState();
}

class _AiInputBarState extends State<AiInputBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isLoading) return;
    widget.onSubmit(text);
    _controller.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppDimensions.md, 12, AppDimensions.md, 12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.colors.separatorOpaque, width: 0.5)),
        boxShadow: [BoxShadow(color: const Color(0x0A000000), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _SideButton(icon: Icons.add, onPressed: widget.onManualEntry, tooltip: AppLocalizations.of(context)!.homeInputManual),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: AppDimensions.inputHeight,
                decoration: BoxDecoration(color: context.colors.surfaceSecondary, borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: !widget.isLoading,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _handleSubmit(),
                  style: context.textStyles.body,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.homeInputHint,
                    hintStyle: context.textStyles.body.copyWith(color: context.colors.textHint),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    suffixIcon: widget.isLoading
                        ? Padding(
                            padding: const EdgeInsets.all(12),
                            child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.primary)),
                          )
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            _SideButton(icon: Icons.camera_alt_outlined, onPressed: widget.onCamera, tooltip: AppLocalizations.of(context)!.homeInputCamera),
          ],
        ),
      ),
    );
  }
}

class _SideButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  const _SideButton({required this.icon, required this.onPressed, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.sideButtonSize,
      height: AppDimensions.sideButtonSize,
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.separator, width: 1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: Icon(icon, size: 20, color: context.colors.textPrimary),
        ),
      ),
    );
  }
}
