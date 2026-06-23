import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
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

/// 录音手势区域
enum _GestureZone {
  none,
  send,       // 默认/上滑中间 → 发送
  cancel,     // 左上滑 → 取消
  transcribe, // 右上滑 → 转文字
}

/// 聊天底部输入栏
class ChatInputBar extends StatefulWidget {
  final Function(String) onSubmit;
  final VoidCallback onManualEntry;
  final Function(String filePath) onVoiceRecorded;
  final Function(String filePath) onImageCaptured;
  final Function(String filePath) onVoiceTranscribeOnly;
  final bool isLoading;
  final VoiceInputMode voiceMode;
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

  // 录音状态
  bool _isVoiceActive = false;
  _GestureZone _zone = _GestureZone.none;
  Offset _gestureOrigin = Offset.zero;

  // 平台 STT
  String _partialText = '';

  static const double _verticalThreshold = 60.0;
  static const double _horizontalThreshold = 50.0;

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

  // ==================== 长按手势（同一根手指全程追踪）====================

  void _onLongPressStart(LongPressStartDetails details) {
    HapticFeedback.heavyImpact();
    _gestureOrigin = details.globalPosition;
    setState(() {
      _isVoiceActive = true;
      _zone = _GestureZone.send;
      _partialText = '';
    });

    // 立即启动平台 STT（同一根手指，无需二次按下）
    if (widget.voiceMode == VoiceInputMode.platform && widget.sttService != null) {
      widget.sttService!.startListening();
      widget.sttService!.partialTextStream.listen((text) {
        if (mounted && _isVoiceActive) {
          setState(() => _partialText = text);
        }
      });
    }
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (!_isVoiceActive) return;

    final dx = details.offsetFromOrigin.dx;
    final dy = -details.offsetFromOrigin.dy; // 正值 = 上滑

    _GestureZone newZone;
    if (dy > _verticalThreshold) {
      if (dx < -_horizontalThreshold) {
        newZone = _GestureZone.cancel;
      } else if (dx > _horizontalThreshold) {
        newZone = _GestureZone.transcribe;
      } else {
        newZone = _GestureZone.send;
      }
    } else {
      newZone = _GestureZone.send;
    }

    if (newZone != _zone) {
      HapticFeedback.lightImpact();
      setState(() => _zone = newZone);
    }
  }

  Future<void> _onLongPressEnd(LongPressEndDetails details) async {
    if (!_isVoiceActive) return;

    final zone = _zone;
    setState(() {
      _isVoiceActive = false;
      _zone = _GestureZone.none;
    });

    switch (zone) {
      case _GestureZone.cancel:
        // 取消 — 不执行任何操作
        break;
      case _GestureZone.transcribe:
        // 转文字 — 走平台 STT 或 Whisper
        await _handleTranscribe();
        break;
      case _GestureZone.send:
      case _GestureZone.none:
        // 发送 — 走完整记账管线
        await _handleSend();
        break;
    }
  }

  /// 发送：平台 STT 文本 → 记账管线，或 Whisper 录音文件 → 记账管线
  Future<void> _handleSend() async {
    if (widget.voiceMode == VoiceInputMode.platform && widget.sttService != null) {
      // 平台 STT：识别后提交文本
      final text = await widget.sttService!.stopListening();
      final result = (text ?? _partialText).trim();
      if (result.isNotEmpty) {
        widget.onSubmit(result);
      } else {
        if (mounted) AppToast.show(context, AppLocalizations.of(context)!.chatInputRecordShort);
      }
    } else {
      // Whisper：已经在长按开始时开始录音（由调用方处理）
      // 这里需要录音逻辑 — 使用 record 包
      // 注意：当前架构下，Whisper 模式的录音由 VoiceRecordingOverlay 处理
      // 但内联模式下，我们需要自己管理录音
      // 此分支暂不支持内联 Whisper 录音，提示用户切换模式
      if (mounted) {
        AppToast.show(context, '请在设置中切换为平台原生语音模式');
      }
    }
  }

  /// 转文字：平台 STT → 填入输入框，或 Whisper → 填入输入框
  Future<void> _handleTranscribe() async {
    if (widget.voiceMode == VoiceInputMode.platform && widget.sttService != null) {
      final text = await widget.sttService!.stopListening();
      final result = (text ?? _partialText).trim();
      if (result.isNotEmpty) {
        // 填入输入框供用户编辑
        _controller.text = result;
        _focusNode.requestFocus();
      } else {
        if (mounted) AppToast.show(context, AppLocalizations.of(context)!.chatInputRecordShort);
      }
    } else {
      if (mounted) {
        AppToast.show(context, '请在设置中切换为平台原生语音模式');
      }
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
      if (picked != null) widget.onImageCaptured(picked.path);
    } catch (e) {
      if (mounted) AppToast.show(context, AppLocalizations.of(context)!.chatInputImageFailed(''));
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
              onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.camera); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.chatInputGallery),
              onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.gallery); },
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

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ===== 输入栏主体 =====
        Container(
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
              // 左侧：记账按钮（长按录音）
              GestureDetector(
                onLongPressStart: _onLongPressStart,
                onLongPressMoveUpdate: _onLongPressMoveUpdate,
                onLongPressEnd: _onLongPressEnd,
                onTap: widget.onManualEntry,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: Responsive.s(context, 40),
                  height: Responsive.s(context, 40),
                  decoration: BoxDecoration(
                    color: _isVoiceActive
                        ? (_zone == _GestureZone.cancel ? context.colors.error : context.colors.primary)
                        : context.colors.primarySurface,
                    borderRadius: BorderRadius.circular(Responsive.s(context, 20)),
                  ),
                  child: Center(
                    child: _isVoiceActive
                        ? Icon(
                            _zone == _GestureZone.cancel ? Icons.close : Icons.mic,
                            color: Colors.white, size: 20,
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
                            hintStyle: context.textStyles.footnote.copyWith(color: context.colors.textTertiary),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: Responsive.s(context, 10)),
                          ),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _handleSubmit(),
                        ),
                      ),
                      if (_controller.text.isNotEmpty)
                        GestureDetector(
                          onTap: () { _controller.clear(); setState(() {}); },
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
        ),

        // ===== 录音时弹出的覆盖层（内联，不是 Modal）=====
        if (_isVoiceActive)
          Positioned(
            bottom: Responsive.s(context, 60), // 输入栏上方
            left: 0, right: 0,
            child: _buildVoiceOverlay(l10n),
          ),
      ],
    );
  }

  /// 录音覆盖层（显示在输入栏上方）
  Widget _buildVoiceOverlay(AppLocalizations l10n) {
    final isCancel = _zone == _GestureZone.cancel;
    final isTranscribe = _zone == _GestureZone.transcribe;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 三个热区指示器
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Responsive.s(context, 24)),
          child: Row(
            children: [
              _buildZoneChip(
                icon: Icons.close,
                label: l10n.voiceOverlayCancelLabel,
                isActive: isCancel,
                activeColor: context.colors.error,
              ),
              const Spacer(),
              _buildZoneChip(
                icon: Icons.send,
                label: l10n.chatInputVoiceSend,
                isActive: !isCancel && !isTranscribe,
                activeColor: context.colors.textPrimary,
              ),
              const Spacer(),
              _buildZoneChip(
                icon: Icons.text_fields,
                label: l10n.voiceOverlayTranscribeLabel,
                isActive: isTranscribe,
                activeColor: const Color(0xFF2196F3),
              ),
            ],
          ),
        ),
        SizedBox(height: Responsive.s(context, 8)),
        // 录音状态弹窗
        Container(
          margin: EdgeInsets.symmetric(horizontal: Responsive.s(context, 40)),
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.s(context, 20),
            vertical: Responsive.s(context, 14),
          ),
          decoration: BoxDecoration(
            color: isCancel
                ? context.colors.error.withValues(alpha: 0.9)
                : context.colors.textPrimary.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(Responsive.s(context, 14)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isCancel ? Icons.close : Icons.mic,
                size: 18,
                color: isCancel ? Colors.white : Colors.greenAccent,
              ),
              SizedBox(width: Responsive.s(context, 8)),
              Text(
                isCancel ? l10n.chatInputVoiceCanceling : l10n.chatInputListening,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildZoneChip({
    required IconData icon,
    required String label,
    required bool isActive,
    required Color activeColor,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.s(context, 10),
        vertical: Responsive.s(context, 6),
      ),
      decoration: BoxDecoration(
        color: isActive
            ? activeColor.withValues(alpha: 0.15)
            : context.colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(Responsive.s(context, 16)),
        border: isActive
            ? Border.all(color: activeColor.withValues(alpha: 0.4), width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isActive ? activeColor : context.colors.textTertiary),
          SizedBox(width: Responsive.s(context, 4)),
          Text(
            label,
            style: context.textStyles.caption.copyWith(
              color: isActive ? activeColor : context.colors.textTertiary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
