import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 聊天底部输入栏
/// 文本输入 + 语音按钮（长按录音） + 发送
class ChatInputBar extends StatefulWidget {
  final Function(String) onSubmit;
  final VoidCallback onManualEntry;
  final bool isLoading;

  const ChatInputBar({
    super.key,
    required this.onSubmit,
    required this.onManualEntry,
    this.isLoading = false,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  bool _isRecording = false;
  bool _isCancelled = false;
  Offset _dragOffset = Offset.zero;

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

  /// 长按开始录音
  void _onVoiceStart(LongPressStartDetails details) {
    HapticFeedback.mediumImpact();
    setState(() {
      _isRecording = true;
      _isCancelled = false;
      _dragOffset = Offset.zero;
    });
  }

  /// 长按拖动中
  void _onVoiceUpdate(LongPressMoveUpdateDetails details) {
    setState(() {
      _dragOffset = details.offsetFromOrigin;
    });

    // 左上滑动超过阈值 → 取消
    if (_dragOffset.dx < -60 && _dragOffset.dy < -30) {
      if (!_isCancelled) {
        HapticFeedback.heavyImpact();
        setState(() => _isCancelled = true);
      }
    } else {
      if (_isCancelled) {
        setState(() => _isCancelled = false);
      }
    }
  }

  /// 长按结束
  void _onVoiceEnd(LongPressEndDetails details) {
    if (!_isCancelled && _isRecording) {
      // 右上滑动或松手 → 发送（模拟语音转文字）
      _simulateVoiceInput();
    }
    setState(() {
      _isRecording = false;
      _isCancelled = false;
      _dragOffset = Offset.zero;
    });
  }

  /// 模拟语音输入（实际需接入语音识别 SDK）
  void _simulateVoiceInput() {
    HapticFeedback.lightImpact();
    // TODO: 接入真实语音识别（如 whisper、讯飞 SDK）
    // 模拟：将当前输入框文本作为语音识别结果
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      _handleSubmit();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('语音识别功能开发中，请先使用文字输入'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppDimensions.md, 8, AppDimensions.md, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          top: BorderSide(color: AppColors.separatorOpaque, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0A000000),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 手动记账按钮
            GestureDetector(
              onTap: widget.onManualEntry,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.separator, width: 1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Icon(Icons.add, size: 20, color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(width: 8),

            // 文本输入框
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 40, maxHeight: 120),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: !widget.isLoading && !_isRecording,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _handleSubmit(),
                  maxLines: null,
                  style: AppTextStyles.body,
                  decoration: InputDecoration(
                    hintText: _isRecording ? '松手发送，左滑取消' : '输入记账内容...',
                    hintStyle: AppTextStyles.body.copyWith(color: AppColors.textHint),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // 语音/发送按钮
            _buildVoiceButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceButton() {
    final hasText = _controller.text.trim().isNotEmpty;

    // 有文本时显示发送按钮，无文本时显示语音按钮
    if (hasText && !_isRecording) {
      return GestureDetector(
        onTap: _handleSubmit,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: widget.isLoading ? AppColors.surfaceSecondary : AppColors.primary,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: widget.isLoading
              ? const Padding(
                  padding: EdgeInsets.all(10),
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textOnPrimary),
                )
              : const Icon(Icons.send, size: 20, color: AppColors.textOnPrimary),
        ),
      );
    }

    // 语音按钮（长按录音）
    return GestureDetector(
      onLongPressStart: _onVoiceStart,
      onLongPressMoveUpdate: _onVoiceUpdate,
      onLongPressEnd: _onVoiceEnd,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _isRecording
              ? (_isCancelled ? AppColors.error : AppColors.primary)
              : AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: _isRecording
              ? Border.all(color: _isCancelled ? AppColors.error : AppColors.primary, width: 2)
              : Border.all(color: AppColors.separator, width: 1),
        ),
        child: _isRecording
            ? Icon(
                _isCancelled ? Icons.close : Icons.mic,
                size: 20,
                color: AppColors.textOnPrimary,
              )
            : Icon(Icons.mic_none, size: 20, color: AppColors.textSecondary),
      ),
    );
  }
}
