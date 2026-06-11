import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 聊天底部输入栏
/// 左: 记账按钮（醒目，长按语音）  |  中: 文本输入  |  右: 拍照
class ChatInputBar extends StatefulWidget {
  final Function(String) onSubmit;
  final VoidCallback onManualEntry;
  final Function(String filePath) onVoiceRecorded;
  final Function(String filePath) onImageCaptured;
  final bool isLoading;

  const ChatInputBar({
    super.key,
    required this.onSubmit,
    required this.onManualEntry,
    required this.onVoiceRecorded,
    required this.onImageCaptured,
    this.isLoading = false,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _audioRecorder = AudioRecorder();
  final _imagePicker = ImagePicker();

  bool _isRecording = false;
  bool _isCancelled = false;
  Offset _dragOffset = Offset.zero;
  DateTime? _recordStartTime;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isLoading) return;
    widget.onSubmit(text);
    _controller.clear();
    _focusNode.unfocus();
  }

  // ==================== 语音交互（真实录音） ====================

  Future<void> _onVoiceStart(LongPressStartDetails details) async {
    HapticFeedback.heavyImpact();

    // 先设置录音状态（给用户视觉反馈）
    setState(() {
      _isRecording = true;
      _isCancelled = false;
      _dragOffset = Offset.zero;
    });

    // 检查录音权限（带超时，防止 hasPermission 挂起）
    bool hasPermission = false;
    try {
      hasPermission = await _audioRecorder.hasPermission()
          .timeout(const Duration(seconds: 3), onTimeout: () => false);
    } catch (_) {
      hasPermission = false;
    }

    if (!hasPermission) {
      if (mounted) {
        setState(() => _isRecording = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.chatInputMicPermission), behavior: SnackBarBehavior.floating),
        );
      }
      return;
    }

    _recordStartTime = DateTime.now();

    // 开始录音
    try {
      // 生成明确的临时文件路径（Android 16 不支持空路径）
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: tempPath,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isRecording = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.chatInputMicPermission), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  void _onVoiceUpdate(LongPressMoveUpdateDetails details) {
    setState(() => _dragOffset = details.offsetFromOrigin);

    if (_dragOffset.dx < -50 && _dragOffset.dy < -20) {
      if (!_isCancelled) {
        HapticFeedback.heavyImpact();
        setState(() => _isCancelled = true);
      }
    } else if (_isCancelled) {
      setState(() => _isCancelled = false);
    }
  }

  Future<void> _onVoiceEnd(LongPressEndDetails details) async {
    if (!_isRecording) return;

    final path = await _audioRecorder.stop();

    setState(() {
      _isRecording = false;
      _isCancelled = false;
      _dragOffset = Offset.zero;
    });

    if (_isCancelled || path == null || path.isEmpty) {
      // 取消或录音失败
      return;
    }

    // 检查录音时长（太短则忽略）
    final duration = _recordStartTime != null
        ? DateTime.now().difference(_recordStartTime!)
        : Duration.zero;
    if (duration.inMilliseconds < 500) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.chatInputRecordShort), behavior: SnackBarBehavior.floating, duration: Duration(milliseconds: 800)),
        );
      }
      return;
    }

    HapticFeedback.lightImpact();
    widget.onVoiceRecorded(path);
  }

  // ==================== 拍照/选图 ====================

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image != null) {
        widget.onImageCaptured(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.chatInputImageFailed(e.toString())), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(AppLocalizations.of(context)!.chatInputCamera),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(AppLocalizations.of(context)!.chatInputGallery),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          top: BorderSide(color: context.colors.separatorOpaque, width: 0.5),
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
            _buildRecordButton(),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 40, maxHeight: 120),
                decoration: BoxDecoration(
                  color: context.colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: !widget.isLoading && !_isRecording,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _handleSubmit(),
                  onChanged: (_) => setState(() {}),
                  maxLines: null,
                  style: context.textStyles.body.copyWith(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: _isRecording ? AppLocalizations.of(context)!.chatInputVoiceHint : AppLocalizations.of(context)!.chatInputTextHint,
                    hintStyle: context.textStyles.body.copyWith(
                      color: _isRecording ? context.colors.primary : context.colors.textHint,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildRightButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
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
                      ? [context.colors.error, context.colors.error.withValues(alpha: 0.8)]
                      : [context.colors.primary, context.colors.primary.withValues(alpha: 0.7)],
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
                      ? (_isCancelled ? context.colors.error : context.colors.primary)
                      : context.colors.primary)
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
                  color: context.colors.textOnPrimary,
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_note, size: 22, color: context.colors.textOnPrimary),
                    Text(AppLocalizations.of(context)!.navRecord, style: TextStyle(fontSize: 9, color: context.colors.textOnPrimary, fontWeight: FontWeight.w600)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildRightButton() {
    final hasText = _controller.text.trim().isNotEmpty;

    if (hasText) {
      return GestureDetector(
        onTap: widget.isLoading ? null : _handleSubmit,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: widget.isLoading ? context.colors.surfaceSecondary : context.colors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: widget.isLoading
              ? Padding(
                  padding: const EdgeInsets.all(10),
                  child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.textOnPrimary),
                )
              : Icon(Icons.arrow_upward, size: 22, color: context.colors.textOnPrimary),
        ),
      );
    }

    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: context.colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.colors.separator, width: 1),
        ),
        child: Icon(Icons.camera_alt_outlined, size: 20, color: context.colors.textSecondary),
      ),
    );
  }
}
