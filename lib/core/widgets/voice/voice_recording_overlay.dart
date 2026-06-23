import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../features/text_ai/data/services/platform_stt_service.dart';
import 'fan_shape_painter.dart';
import '../toast.dart';
import 'waveform_painter.dart';

/// 语音录制结果
enum VoiceResultAction {
  send,         // 发送完整管线
  transcribe,   // 仅转文字
  cancel,       // 取消
}

/// 语音录制结果数据
class VoiceResult {
  final VoiceResultAction action;
  final String? filePath;
  final String? platformText;  // PlatformStt 实时识别结果

  const VoiceResult({required this.action, this.filePath, this.platformText});
}

/// 微信风格「按住说话」全屏覆盖层
///
/// 布局：
/// - 顶部：绿色语音气泡（声波 + 时长）
/// - 底部：三区域手势面板（取消 / 发送 / 转文字）
/// - 半透明暗色背景
///
/// 交互：
/// 1. 长按触发 → 显示覆盖层 + 开始录音
/// 2. 手指不放 → 顶部绿色气泡显示声波动画
/// 3. 上滑左移 → 取消 | 上滑右移 → 转文字 | 不滑/上滑中间 → 发送
/// 4. 松手 → 根据区域执行操作
class VoiceRecordingOverlay {
  static Future<VoiceResult?> show(
    BuildContext context, {
    PlatformSttService? sttService,
  }) async {
    return Navigator.of(context).push<VoiceResult>(
      _VoiceRecordingRoute(sttService: sttService),
    );
  }
}

class _VoiceRecordingRoute extends PageRouteBuilder<VoiceResult> {
  final PlatformSttService? sttService;
  _VoiceRecordingRoute({this.sttService})
      : super(
          opaque: false,
          barrierColor: Colors.transparent,
          transitionDuration: const Duration(milliseconds: 150),
          reverseTransitionDuration: const Duration(milliseconds: 100),
          pageBuilder: (context, animation, secondaryAnimation) =>
              _VoiceRecordingPage(animation: animation, sttService: sttService),
        );
}

class _VoiceRecordingPage extends StatefulWidget {
  final Animation<double> animation;
  final PlatformSttService? sttService;
  const _VoiceRecordingPage({required this.animation, this.sttService});

  @override
  State<_VoiceRecordingPage> createState() => _VoiceRecordingPageState();
}

class _VoiceRecordingPageState extends State<_VoiceRecordingPage> {
  final _audioRecorder = AudioRecorder();
  final _waveformGenerator = WaveformGenerator();

  GestureZone _activeZone = GestureZone.send; // 默认发送区域
  DateTime? _recordStartTime;
  String? _recordFilePath;
  String? _platformText;  // PlatformStt 实时识别结果
  StreamSubscription<String>? _sttSubscription;

  Timer? _waveformTimer;
  Timer? _durationTimer;

  // 手势追踪
  Offset? _touchStart;
  static const double _verticalThreshold = 60.0;  // 上滑阈值
  static const double _horizontalThreshold = 50.0; // 左右偏移阈值

  @override
  void initState() {
    super.initState();
    _startRecording();
  }

  @override
  void dispose() {
    _sttSubscription?.cancel();
    _waveformTimer?.cancel();
    _durationTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  // ==================== 录音 ====================

  Future<void> _startRecording() async {
    bool hasPermission = false;
    try {
      hasPermission = await _audioRecorder.hasPermission()
          .timeout(const Duration(seconds: 3), onTimeout: () => false);
    } catch (_) {
      hasPermission = false;
    }

    if (!hasPermission) {
      if (mounted) {
        Navigator.of(context)
            .pop(const VoiceResult(action: VoiceResultAction.cancel));
        AppToast.show(
            context, AppLocalizations.of(context)!.chatInputMicPermission);
      }
      return;
    }

    _recordStartTime = DateTime.now();

    try {
      final tempDir = await getTemporaryDirectory();
      _recordFilePath =
          '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _recordFilePath!,
      );

      // 启动 PlatformStt 实时识别
      if (widget.sttService != null) {
        await widget.sttService!.startListening();
        _sttSubscription = widget.sttService!.partialTextStream.listen((text) {
          if (mounted) _platformText = text;
        });
      }

      if (mounted) {
        _startWaveformSimulation();
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context)
            .pop(const VoiceResult(action: VoiceResultAction.cancel));
      }
    }
  }

  void _startWaveformSimulation() {
    _waveformTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (!mounted) return;
      setState(() {
        _waveformGenerator.addSample(
            0.3 + (DateTime.now().millisecondsSinceEpoch % 100) / 140.0);
      });
    });
  }

  // ==================== 手势处理（Listener 原始触摸事件）====================

  void _onPointerDown(PointerDownEvent event) {
    _touchStart = event.position;
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_touchStart == null) return;

    final dx = event.position.dx - _touchStart!.dx;
    final dy = _touchStart!.dy - event.position.dy; // 正值 = 上滑

    GestureZone newZone;

    if (dy > _verticalThreshold) {
      // 已上滑超过阈值
      if (dx < -_horizontalThreshold) {
        newZone = GestureZone.cancel;      // 左上 → 取消
      } else if (dx > _horizontalThreshold) {
        newZone = GestureZone.transcribe;   // 右上 → 转文字
      } else {
        newZone = GestureZone.send;         // 正上 → 发送
      }
    } else {
      newZone = GestureZone.send;  // 未上滑，默认发送
    }

    if (newZone != _activeZone) {
      HapticFeedback.lightImpact();
      setState(() => _activeZone = newZone);
    }
  }

  Future<void> _onPointerUp(PointerUpEvent event) async {
    _waveformTimer?.cancel();
    _sttSubscription?.cancel();

    final action = switch (_activeZone) {
      GestureZone.cancel => VoiceResultAction.cancel,
      GestureZone.transcribe => VoiceResultAction.transcribe,
      _ => VoiceResultAction.send,
    };

    await _audioRecorder.stop();

    // 停止 PlatformStt 并获取结果
    String? platformText;
    if (widget.sttService != null) {
      platformText = await widget.sttService!.stopListening();
    }
    platformText ??= _platformText;

    // 最小时长检查（取消除外）
    if (action != VoiceResultAction.cancel) {
      final duration = _recordStartTime != null
          ? DateTime.now().difference(_recordStartTime!)
          : Duration.zero;
      if (duration.inMilliseconds < 500) {
        if (mounted) {
          Navigator.of(context)
              .pop(const VoiceResult(action: VoiceResultAction.cancel));
          AppToast.show(context, AppLocalizations.of(context)!.chatInputRecordShort,
              duration: const Duration(milliseconds: 800));
        }
        return;
      }
    }

    HapticFeedback.lightImpact();

    if (mounted) {
      Navigator.of(context).pop(VoiceResult(
        action: action,
        filePath: action != VoiceResultAction.cancel ? _recordFilePath : null,
        platformText: action != VoiceResultAction.cancel ? platformText : null,
      ));
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _waveformTimer?.cancel();
    _sttSubscription?.cancel();
    _audioRecorder.stop();
    widget.sttService?.cancel();  // 停止 PlatformStt
    if (mounted) {
      Navigator.of(context)
          .pop(const VoiceResult(action: VoiceResultAction.cancel));
    }
  }

  String _formatDuration() {
    if (_recordStartTime == null) return '0:00';
    final duration = DateTime.now().difference(_recordStartTime!);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // ==================== UI 构建 ====================

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        return Scaffold(
          backgroundColor:
              Colors.black.withValues(alpha: 0.5 * widget.animation.value),
          body: Listener(
            onPointerDown: _onPointerDown,
            onPointerMove: _onPointerMove,
            onPointerUp: _onPointerUp,
            onPointerCancel: _onPointerCancel,
            behavior: HitTestBehavior.translucent,
            child: Stack(
              children: [
                // ===== 顶部绿色语音气泡 =====
                Positioned(
                  top: screenSize.height * 0.12,
                  left: 0,
                  right: 0,
                  child: Center(child: _buildVoiceBubble()),
                ),

                // ===== 底部手势面板（视觉指示） =====
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: screenSize.height * 0.28,
                  child: CustomPaint(
                    size: Size(screenSize.width, screenSize.height * 0.28),
                    painter: FanShapePainter(
                      activeZone: _activeZone,
                      panelProgress: widget.animation.value,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 顶部绿色语音气泡（微信风格）
  Widget _buildVoiceBubble() {
    return CustomPaint(
      size: const Size(160, 90),
      painter: VoiceBubblePainter(
        amplitudes: _waveformGenerator.amplitudes,
        durationText: _formatDuration(),
      ),
    );
  }
}
