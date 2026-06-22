import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/toast.dart';
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
  final _audioRecorder = AudioRecorder();
  final _imagePicker = ImagePicker();

  bool _isRecording = false;
  bool _isCancelled = false;
  Offset _dragOffset = Offset.zero;
  DateTime? _recordStartTime;

  // 平台 STT 实时转写文本
  String _partialText = '';
  StreamSubscription<String>? _partialSub;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _audioRecorder.dispose();
    _partialSub?.cancel();
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

  Future<void> _onVoiceStart(LongPressStartDetails details) async {
    HapticFeedback.heavyImpact();

    setState(() {
      _isRecording = true;
      _isCancelled = false;
      _dragOffset = Offset.zero;
      _partialText = '';
    });

    if (widget.voiceMode == VoiceInputMode.platform && widget.sttService != null) {
      final ok = await _startPlatformStt();
      // 平台 STT 启动失败时，降级到 Whisper 录音
      if (!ok && mounted) {
        await _startWhisperRecording();
      }
    } else {
      await _startWhisperRecording();
    }
  }

  /// 平台原生 STT：实时语音转文字
  /// 返回 true 表示成功启动，false 表示失败
  Future<bool> _startPlatformStt() async {
    final stt = widget.sttService!;
    final ok = await stt.startListening();
    if (!ok) return false;

    // 监听实时转写结果
    _partialSub?.cancel();
    _partialSub = stt.partialTextStream.listen((text) {
      if (mounted && _isRecording && !_isCancelled) {
        setState(() => _partialText = text);
      }
    });
    return true;
  }

  /// Whisper 模式：录音保存文件
  Future<void> _startWhisperRecording() async {
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
        AppToast.show(context, AppLocalizations.of(context)!.chatInputMicPermission);
      }
      return;
    }

    _recordStartTime = DateTime.now();

    try {
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
        AppToast.show(context, AppLocalizations.of(context)!.chatInputMicPermission);
      }
    }
  }

  void _onVoiceUpdate(LongPressMoveUpdateDetails details) {
    final dx = details.offsetFromOrigin.dx;
    final dy = details.offsetFromOrigin.dy;

    setState(() => _dragOffset = details.offsetFromOrigin);

    // 左滑取消（水平滑动超过阈值）
    if (dx < -60) {
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

    // 先保存取消状态，再重置 UI 状态
    final wasCancelled = _isCancelled;

    setState(() {
      _isRecording = false;
      _isCancelled = false;
      _dragOffset = Offset.zero;
    });

    if (wasCancelled) {
      // 取消：停止录音/识别，不提交
      _partialSub?.cancel();
      _partialSub = null;
      setState(() => _partialText = '');
      try {
        if (widget.voiceMode == VoiceInputMode.platform && widget.sttService != null) {
          await widget.sttService!.cancel();
        }
        await _audioRecorder.stop();
      } catch (_) {}
      return;
    }

    // 正常结束
    if (widget.voiceMode == VoiceInputMode.platform && widget.sttService != null) {
      await _stopPlatformStt();
    } else {
      await _stopWhisperRecording();
    }
  }

  /// 平台 STT：停止识别，获取最终文本
  Future<void> _stopPlatformStt() async {
    _partialSub?.cancel();
    _partialSub = null;

    final stt = widget.sttService!;
    final finalText = await stt.stopListening();

    final text = (finalText ?? _partialText).trim();
    setState(() => _partialText = '');

    if (text.isEmpty) {
      if (mounted) {
        AppToast.show(context, AppLocalizations.of(context)!.chatInputRecordShort, duration: const Duration(milliseconds: 800));
      }
      return;
    }

    // 直接作为文本提交到记账管线（不经过 Whisper）
    HapticFeedback.lightImpact();
    widget.onSubmit(text);
  }

  /// Whisper 模式：停止录音，发送文件路径
  Future<void> _stopWhisperRecording() async {
    final path = await _audioRecorder.stop();

    if (path == null || path.isEmpty) return;

    final duration = _recordStartTime != null
        ? DateTime.now().difference(_recordStartTime!)
        : Duration.zero;
    if (duration.inMilliseconds < 500) {
      if (mounted) {
        AppToast.show(context, AppLocalizations.of(context)!.chatInputRecordShort, duration: const Duration(milliseconds: 800));
      }
      return;
    }

    HapticFeedback.lightImpact();
    widget.onVoiceRecorded(path);
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
    final isPlatformStt = widget.voiceMode == VoiceInputMode.platform;

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 平台 STT 实时转写显示区
          if (isPlatformStt && _isRecording && _partialText.isNotEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.s(context, 12),
                vertical: Responsive.s(context, 8),
              ),
              margin: EdgeInsets.only(bottom: Responsive.s(context, 6)),
              decoration: BoxDecoration(
                color: context.colors.primarySurface,
                borderRadius: BorderRadius.circular(Responsive.s(context, 8)),
              ),
              child: Row(
                children: [
                  Icon(Icons.mic, size: 16, color: context.colors.primary),
                  SizedBox(width: Responsive.s(context, 8)),
                  Expanded(
                    child: Text(
                      _partialText,
                      style: context.textStyles.body.copyWith(
                        fontSize: Responsive.fs(context, 14),
                        color: context.colors.primary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          // 录音状态提示条
          if (_isRecording)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.s(context, 12),
                vertical: Responsive.s(context, 6),
              ),
              margin: EdgeInsets.only(bottom: Responsive.s(context, 6)),
              decoration: BoxDecoration(
                color: _isCancelled
                    ? context.colors.error.withValues(alpha: 0.1)
                    : context.colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Responsive.s(context, 6)),
              ),
              child: Text(
                _isCancelled
                    ? l10n.chatInputVoiceCancel
                    : (isPlatformStt ? l10n.chatInputListening : l10n.chatInputRecording),
                style: context.textStyles.caption.copyWith(
                  color: _isCancelled ? context.colors.error : context.colors.primary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          Row(
            children: [
              // 左侧：记账按钮（长按语音）
              GestureDetector(
                onLongPressStart: _onVoiceStart,
                onLongPressMoveUpdate: _onVoiceUpdate,
                onLongPressEnd: _onVoiceEnd,
                onTap: widget.onManualEntry,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: Responsive.s(context, 40),
                  height: Responsive.s(context, 40),
                  decoration: BoxDecoration(
                    color: _isRecording
                        ? (_isCancelled ? context.colors.error : context.colors.primary)
                        : context.colors.primarySurface,
                    borderRadius: BorderRadius.circular(Responsive.s(context, 20)),
                  ),
                  child: Center(
                    child: _isRecording
                        ? Icon(
                            _isCancelled ? Icons.close : Icons.mic,
                            color: Colors.white,
                            size: 20,
                          )
                        : Text('📝', style: TextStyle(fontSize: Responsive.fs(context, 18))),
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
        ],
      ),
    );
  }
}
