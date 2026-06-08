import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 备注编辑 BottomSheet
class NoteEditSheet extends StatefulWidget {
  final String? initialNote;

  const NoteEditSheet({super.key, this.initialNote});

  /// 显示备注编辑 Sheet，返回编辑后的字符串，取消返回 null
  static Future<String?> show(BuildContext context, {String? initialNote}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NoteEditSheet(initialNote: initialNote),
    );
  }

  @override
  State<NoteEditSheet> createState() => _NoteEditSheetState();
}

class _NoteEditSheetState extends State<NoteEditSheet> {
  late TextEditingController _controller;
  static const int _maxLength = 500;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomInset),
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
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // 标题
          Text('备注', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          // 输入框
          TextField(
            controller: _controller,
            autofocus: true,
            maxLines: 5,
            minLines: 3,
            maxLength: _maxLength,
            style: AppTextStyles.body,
            decoration: InputDecoration(
              hintText: '添加备注...',
              hintStyle: AppTextStyles.body.copyWith(color: AppColors.textHint),
              filled: true,
              fillColor: AppColors.surfaceSecondary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
              counterStyle: AppTextStyles.caption,
            ),
            onChanged: (_) => setState(() {}),
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
                  child: Text('取消', style: AppTextStyles.buttonText),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    ),
                  ),
                  child: Text('保存', style: AppTextStyles.buttonText.copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
