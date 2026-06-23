import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/toast.dart';
import '../../../text_ai/data/services/platform_stt_service.dart';

/// 语音录制结果模式
enum VoiceEndAction {
  /// 发送完整管线（语音→转文字→AI解析）
  send,

  /// 仅转文字，填入输入框
  transcribeOnly,

  /// 取消（左滑或录音太短）
  cancel,
}

/// 底部固定记账输入栏
/// 左: 记账按钮（醒目，长按语音）  |  中: 文本输入  |  右: 拍照
class AiInputBar extends StatefulWidget {
  final Function(String) onSubmit;
  final VoidCallback onManualEntry;
  final VoidCallback onCamera;

  /// 语音录制完成回调 [action] 决定后续行为，[filePath] 录音文件路径，[platformText] PlatformStt 实时识别结果
  final Function(VoiceEndAction action, String filePath, String? platformText)? onVoiceRecorded;
  final bool isLoading;

  /// 可选的外部 TextEditingController，用于外部设置输入框文本
  final TextEditingController? controller;

  /// 平台原生语音识别服务
  final PlatformSttService? sttService;

  const AiInputBar({
    super.key,
    required this.onSubmit,
    required this.onManualEntry,
    required this.onCamera,
    this.onVoiceRecorded,
    this.isLoading = false,
    this.controller,
    this.sttService,
  });

  @override
  State<AiInputBar> createState() => _AiInputBarState();
}

class _AiInputBarState extends State<AiInputBar> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();
  final _audioRecorder = AudioRecorder();

  bool _isRecording = false;
  bool _isCancelled = false;
  bool _isTranscribeOnly = false;
  Offset _dragOffset = Offset.zero;
  DateTime? _recordStartTime;
  String? _platformText;  // PlatformStt 实时识别结果

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
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
      _isTranscribeOnly = false;
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
        AppToast.show(context, AppLocalizations.of(context)!.chatInputMicPermission);
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

      // 启动 PlatformStt 实时识别
      if (widget.sttService != null) {
        await widget.sttService!.startListening();
        widget.sttService!.partialTextStream.listen((text) {
          if (mounted) _platformText = text;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRecording = false);
        AppToast.show(context, AppLocalizations.of(context)!.chatInputMicPermission);
      }
    }
  }

  void _onVoiceUpdate(LongPressMoveUpdateDetails details) {
    setState(() => _dragOffset = details.offsetFromOrigin);

    // 左滑取消：dx < -50 且 dy < -20
    if (_dragOffset.dx < -50 && _dragOffset.dy < -20) {
      if (!_isCancelled) {
        HapticFeedback.heavyImpact();
        setState(() {
          _isCancelled = true;
          _isTranscribeOnly = false;
        });
      }
    }
    // 右滑仅转文字：dx > 50 且 dy < -20
    else if (_dragOffset.dx > 50 && _dragOffset.dy < -20) {
      if (!_isTranscribeOnly) {
        HapticFeedback.heavyImpact();
        setState(() {
          _isTranscribeOnly = true;
          _isCancelled = false;
        });
      }
    }
    // 回到中间区域，重置状态
    else if (_isCancelled || _isTranscribeOnly) {
      setState(() {
        _isCancelled = false;
        _isTranscribeOnly = false;
      });
    }
  }

  Future<void> _onVoiceEnd(LongPressEndDetails details) async {
    if (!_isRecording) return;

    final path = await _audioRecorder.stop();

    // 停止 PlatformStt 并获取结果
    String? platformText;
    if (widget.sttService != null) {
      platformText = await widget.sttService!.stopListening();
    }
    platformText ??= _platformText;
    _platformText = null;

    // 先保存状态再重置
    final wasCancelled = _isCancelled;
    final wasTranscribeOnly = _isTranscribeOnly;

    setState(() {
      _isRecording = false;
      _isCancelled = false;
      _isTranscribeOnly = false;
      _dragOffset = Offset.zero;
    });

    if (wasCancelled || path == null || path.isEmpty) {
      // 取消或录音失败
      return;
    }

    // 检查录音时长（太短则忽略）
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

    // 根据手势决定行为
    final action = wasTranscribeOnly
        ? VoiceEndAction.transcribeOnly
        : VoiceEndAction.send;
    widget.onVoiceRecorded?.call(action, path, platformText);
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
            _buildRecordButton(),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: AppDimensions.inputHeight,
                decoration: BoxDecoration(color: context.colors.surfaceSecondary, borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: !widget.isLoading && !_isRecording,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _handleSubmit(),
                  style: context.textStyles.body,
                  decoration: InputDecoration(
                    hintText: _isRecording
                        ? AppLocalizations.of(context)!.chatInputVoiceHint
                        : AppLocalizations.of(context)!.homeInputHint,
                    hintStyle: context.textStyles.body.copyWith(
                      color: _isRecording ? context.colors.primary : context.colors.textHint,
                    ),
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

  Widget _buildRecordButton() {
    return SizedBox(
      width: _isRecording ? 52 : AppDimensions.sideButtonSize,
      height: _isRecording ? 52 : AppDimensions.sideButtonSize,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onManualEntry,
        onLongPressStart: _onVoiceStart,
        onLongPressMoveUpdate: _onVoiceUpdate,
        onLongPressEnd: _onVoiceEnd,
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _isRecording ? 52 : AppDimensions.sideButtonSize,
        height: _isRecording ? 52 : AppDimensions.sideButtonSize,
        decoration: BoxDecoration(
          gradient: _isRecording
              ? LinearGradient(
                  colors: _isCancelled
                      ? [context.colors.error, context.colors.error.withValues(alpha: 0.8)]
                      : _isTranscribeOnly
                          ? [const Color(0xFF2196F3), const Color(0xFF1565C0)]
                          : [context.colors.primary, context.colors.primary.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [const Color(0xFF4CAF50), const Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(_isRecording ? 26 : AppDimensions.radiusMd),
          border: _isRecording ? null : Border.all(color: context.colors.separator, width: 1),
          boxShadow: [
            BoxShadow(
              color: (_isRecording
                      ? (_isCancelled
                          ? context.colors.error
                          : _isTranscribeOnly
                              ? const Color(0xFF2196F3)
                              : context.colors.primary)
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
                  _isCancelled
                      ? Icons.close
                      : _isTranscribeOnly
                          ? Icons.text_snippet
                          : Icons.mic,
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
