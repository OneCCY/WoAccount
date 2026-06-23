import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/toast.dart';
import '../../../../core/widgets/voice/voice_recording_overlay.dart';
import '../../../text_ai/data/services/platform_stt_service.dart';
import '../../../../core/utils/responsive.dart';

/// 语音识别模式
enum VoiceInputMode {
  /// 平台原生 STT（实时转文字，无需 API key）
  platform,

  /// Whisper API（录音后发送到云端转写）
  whisper,
}

/// 聊天底部输入栏
/// 左: 记账按钮（醒目，长按语音）  |  中: 文本输入  |  右: 拍照
class ChatInputBar extends StatefulWidget {
  final Function(String) onSubmit;
  final VoidCallback onManualEntry;
  final Function(String filePath) onVoiceRecorded;
  final Function(String filePath) onImageCaptured;
  final Function(String filePath) onVoiceTranscribeOnly;
  final bool isLoading;

  /// 语音识别模式（默认平台原生）
  final VoiceInputMode voiceMode;

  /// 平台 STT 服务（voiceMode 为 platform 时必传）
  final PlatformSttService? sttService;

  const ChatInputBar({
    super.key,
    required this.onSubmit,
    required this.onManualEntry,
    required this.onVoiceRecorded,
    required this.onImageCaptured,
    required this.onVoiceTranscribeOnly,
    this.isLoading = false,
    this.voiceMode = VoiceInputMode.platform,
    this.sttService,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _imagePicker = ImagePicker();

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

  Future<void> _onVoiceStart() async {
    HapticFeedback.heavyImpact();

    if (widget.voiceMode == VoiceInputMode.platform && widget.sttService != null) {
      await _startPlatformStt();
    } else {
      await _startWhisperOverlay();
    }
  }

  /// 平台原生 STT：直接启动实时识别，松开后提交文本
  Future<void> _startPlatformStt() async {
    final stt = widget.sttService!;
    final ok = await stt.startListening();
    if (!ok) {
      // 平台 STT 不可用，降级到 Whisper 录音覆盖层
      if (mounted) await _startWhisperOverlay();
      return;
    }

    if (!mounted) return;

    // 显示实时转写覆盖层
    final result = await showModalBottomSheet<_PlatformSttResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PlatformSttOverlay(sttService: stt),
    );

    if (result == null || result.action == _PlatformSttAction.cancel) {
      await stt.cancel();
      return;
    }

    if (result.text != null && result.text!.isNotEmpty) {
      widget.onSubmit(result.text!);
    }
  }

  /// Whisper 模式：显示全屏录音覆盖层
  Future<void> _startWhisperOverlay() async {
    final result = await VoiceRecordingOverlay.show(context);
    if (result == null) return;

    switch (result.action) {
      case VoiceResultAction.send:
        if (result.filePath != null) {
          widget.onVoiceRecorded(result.filePath!);
        }
        break;
      case VoiceResultAction.transcribe:
        if (result.filePath != null) {
          widget.onVoiceTranscribeOnly(result.filePath!);
        }
        break;
      case VoiceResultAction.cancel:
        break;
    }
  }

  // ==================== 拍照/选图 ====================

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );
      if (picked != null) {
        widget.onImageCaptured(picked.path);
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(context, AppLocalizations.of(context)!.chatInputImageFailed(''));
      }
    }
  }

  void _showImageSourceSheet() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.chatInputCamera),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.chatInputGallery),
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

  // ==================== UI 构建 ====================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.fromLTRB(
        Responsive.s(context, 12),
        Responsive.s(context, 8),
        Responsive.s(context, 12),
        MediaQuery.of(context).padding.bottom + Responsive.s(context, 8),
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.colors.separatorOpaque, width: 0.5)),
      ),
      child: Row(
        children: [
          // 左侧：记账按钮（长按语音）
          GestureDetector(
            onLongPressStart: (_) => _onVoiceStart(),
            onTap: widget.onManualEntry,
            child: Container(
              width: Responsive.s(context, 40),
              height: Responsive.s(context, 40),
              decoration: BoxDecoration(
                color: context.colors.primarySurface,
                borderRadius: BorderRadius.circular(Responsive.s(context, 20)),
              ),
              child: Center(
                child: Text('📝', style: TextStyle(fontSize: Responsive.fs(context, 18))),
              ),
            ),
          ),
          SizedBox(width: Responsive.s(context, 8)),
          // 中间：文本输入框
          Expanded(
            child: Container(
              height: Responsive.s(context, 40),
              decoration: BoxDecoration(
                color: context.colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(Responsive.s(context, 20)),
              ),
              child: Row(
                children: [
                  SizedBox(width: Responsive.s(context, 14)),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      style: context.textStyles.body.copyWith(fontSize: Responsive.fs(context, 14)),
                      decoration: InputDecoration(
                        hintText: l10n.chatInputTextHint,
                        hintStyle: context.textStyles.footnote.copyWith(
                          color: context.colors.textTertiary,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: Responsive.s(context, 10),
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSubmit(),
                    ),
                  ),
                  if (_controller.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _controller.clear();
                        setState(() {});
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: Responsive.s(context, 8)),
                        child: Icon(Icons.cancel, size: 16, color: context.colors.textTertiary),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(width: Responsive.s(context, 8)),
          // 右侧：拍照按钮
          GestureDetector(
            onTap: _showImageSourceSheet,
            child: Container(
              width: Responsive.s(context, 40),
              height: Responsive.s(context, 40),
              decoration: BoxDecoration(
                color: context.colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(Responsive.s(context, 20)),
              ),
              child: Center(
                child: Icon(Icons.camera_alt, size: 20, color: context.colors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 平台 STT 实时转写覆盖层 ====================

enum _PlatformSttAction { submit, cancel }

class _PlatformSttResult {
  final _PlatformSttAction action;
  final String? text;
  const _PlatformSttResult({required this.action, this.text});
}

/// 平台 STT 实时转写覆盖层
///
/// 长按触发后弹出，实时显示转写文字。
/// 手势：左滑取消，松开（默认）提交转写文字。
class _PlatformSttOverlay extends StatefulWidget {
  final PlatformSttService sttService;
  const _PlatformSttOverlay({required this.sttService});

  @override
  State<_PlatformSttOverlay> createState() => _PlatformSttOverlayState();
}

class _PlatformSttOverlayState extends State<_PlatformSttOverlay> {
  String _partialText = '';
  bool _isCancelled = false;
  Offset _dragStart = Offset.zero;
  Offset _dragOffset = Offset.zero;

  static const double _cancelThreshold = -80.0;

  @override
  void initState() {
    super.initState();
    widget.sttService.partialTextStream.listen((text) {
      if (mounted && !_isCancelled) {
        setState(() => _partialText = text);
      }
    });
  }

  void _onPanStart(DragStartDetails details) {
    _dragStart = details.globalPosition;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _dragOffset = details.globalPosition - _dragStart;
    setState(() {});
    if (_dragOffset.dx < _cancelThreshold) {
      if (!_isCancelled) {
        HapticFeedback.heavyImpact();
        setState(() => _isCancelled = true);
      }
    } else if (_isCancelled) {
      setState(() => _isCancelled = false);
    }
  }

  Future<void> _onPanEnd(DragEndDetails details) async {
    if (_isCancelled) {
      Navigator.of(context).pop(const _PlatformSttResult(action: _PlatformSttAction.cancel));
      return;
    }

    final text = _partialText.trim();
    if (text.isEmpty) {
      AppToast.show(context, AppLocalizations.of(context)!.chatInputRecordShort, duration: const Duration(milliseconds: 800));
      Navigator.of(context).pop(const _PlatformSttResult(action: _PlatformSttAction.cancel));
      return;
    }

    HapticFeedback.lightImpact();
    Navigator.of(context).pop(_PlatformSttResult(
      action: _PlatformSttAction.submit,
      text: text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Container(
        color: Colors.black54,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // 中央转写弹窗
            Container(
              margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.25),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              constraints: const BoxConstraints(minWidth: 160, minHeight: 80, maxWidth: 300),
              decoration: BoxDecoration(
                color: _isCancelled
                    ? Colors.red.withValues(alpha: 0.9)
                    : const Color(0xFF2D2D2D).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isCancelled ? Icons.close : Icons.mic,
                        size: 20,
                        color: _isCancelled ? Colors.white : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isCancelled
                            ? AppLocalizations.of(context)!.voiceOverlayCancelLabel
                            : AppLocalizations.of(context)!.chatInputListening,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                  if (_partialText.isNotEmpty && !_isCancelled) ...[
                    const SizedBox(height: 10),
                    Text(
                      _partialText,
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            // 底部提示
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Text(
                AppLocalizations.of(context)!.voiceOverlaySwipeHint,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
