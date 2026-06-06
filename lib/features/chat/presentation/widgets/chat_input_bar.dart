import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 聊天底部输入栏
/// 左: 记账按钮（醒目，长按语音）  |  中: 文本输入  |  右: 拍照
class ChatInputBar extends StatefulWidget {
  final Function(String) onSubmit;
  final VoidCallback onManualEntry;
  final VoidCallback onCamera;
  final bool isLoading;

  const ChatInputBar({
    super.key,
    required this.onSubmit,
    required this.onManualEntry,
    required this.onCamera,
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

  // ==================== 语音交互 ====================

  /// 长按开始录音
  void _onVoiceStart(LongPressStartDetails details) {
    HapticFeedback.heavyImpact();
    setState(() {
      _isRecording = true;
      _isCancelled = false;
      _dragOffset = Offset.zero;
    });
  }

  /// 长按拖动中
  void _onVoiceUpdate(LongPressMoveUpdateDetails details) {
    setState(() => _dragOffset = details.offsetFromOrigin);

    // 左上滑动超过阈值 → 取消
    if (_dragOffset.dx < -50 && _dragOffset.dy < -20) {
      if (!_isCancelled) {
        HapticFeedback.heavyImpact();
        setState(() => _isCancelled = true);
      }
    } else if (_isCancelled) {
      setState(() => _isCancelled = false);
    }
  }

  /// 长按结束
  void _onVoiceEnd(LongPressEndDetails details) {
    if (!_isCancelled && _isRecording) {
      // 松手 → 发送语音（模拟）
      HapticFeedback.lightImpact();
      _simulateVoiceInput();
    }
    setState(() {
      _isRecording = false;
      _isCancelled = false;
      _dragOffset = Offset.zero;
    });
  }

  /// 模拟语音输入
  void _simulateVoiceInput() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('语音识别功能开发中，请使用文字输入'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
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
            // ========== 左侧：记账按钮（醒目 + 长按语音） ==========
            _buildRecordButton(),
            const SizedBox(width: 8),

            // ========== 中间：文本输入框 ==========
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 40, maxHeight: 120),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: !widget.isLoading && !_isRecording,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _handleSubmit(),
                  onChanged: (_) => setState(() {}), // 刷新发送按钮状态
                  maxLines: null,
                  style: AppTextStyles.body.copyWith(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: _isRecording ? '松手发送，左滑取消 ↖' : '说点什么...',
                    hintStyle: AppTextStyles.body.copyWith(
                      color: _isRecording ? AppColors.primary : AppColors.textHint,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // ========== 右侧：发送/拍照按钮 ==========
            _buildRightButton(),
          ],
        ),
      ),
    );
  }

  /// 醒目的记账按钮（长按录音，点击手动记账）
  Widget _buildRecordButton() {
    return GestureDetector(
      onTap: widget.onManualEntry,
      onLongPressStart: _onVoiceStart,
      onLongPressMoveUpdate: _onVoiceUpdate,
      onLongPressEnd: _onVoiceEnd,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _isRecording ? 52 : 48,
        height: _isRecording ? 52 : 48,
        decoration: BoxDecoration(
          gradient: _isRecording
              ? LinearGradient(
                  colors: _isCancelled
                      ? [AppColors.error, AppColors.error.withValues(alpha: 0.8)]
                      : [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(_isRecording ? 26 : 16),
          boxShadow: [
            BoxShadow(
              color: (_isRecording
                      ? (_isCancelled ? AppColors.error : AppColors.primary)
                      : AppColors.primary)
                  .withValues(alpha: 0.3),
              blurRadius: _isRecording ? 12 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: _isRecording
              ? Icon(
                  _isCancelled ? Icons.close : Icons.mic,
                  size: 24,
                  color: AppColors.textOnPrimary,
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_note, size: 22, color: AppColors.textOnPrimary),
                    Text('记账', style: TextStyle(fontSize: 9, color: AppColors.textOnPrimary, fontWeight: FontWeight.w600)),
                  ],
                ),
        ),
      ),
    );
  }

  /// 右侧按钮：有文本时发送，无文本时拍照
  Widget _buildRightButton() {
    final hasText = _controller.text.trim().isNotEmpty;

    if (hasText) {
      // 发送按钮
      return GestureDetector(
        onTap: widget.isLoading ? null : _handleSubmit,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: widget.isLoading ? AppColors.surfaceSecondary : AppColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: widget.isLoading
              ? const Padding(
                  padding: EdgeInsets.all(10),
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textOnPrimary),
                )
              : const Icon(Icons.arrow_upward, size: 22, color: AppColors.textOnPrimary),
        ),
      );
    }

    // 拍照按钮
    return GestureDetector(
      onTap: widget.onCamera,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.separator, width: 1),
        ),
        child: Icon(Icons.camera_alt_outlined, size: 20, color: AppColors.textSecondary),
      ),
    );
  }
}
