import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:wo_account/l10n/app_localizations.dart';
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

  const VoiceResult({required this.action, this.filePath});
}

/// 微信风格「按住说话」全屏覆盖层
///
/// 交互流程：
/// 1. 长按触发 → 显示覆盖层 + 开始录音
/// 2. 手势追踪 → 判定热区（取消/发送/转文字）
/// 3. 松手 → 根据热区执行操作
class VoiceRecordingOverlay {
  /// 显示语音录制覆盖层，返回录制结果
  static Future<VoiceResult?> show(BuildContext context) async {
    return Navigator.of(context).push<VoiceResult>(
      _VoiceRecordingRoute(),
    );
  }
}

/// 自定义路由，从底部弹出
class _VoiceRecordingRoute extends PageRouteBuilder<VoiceResult> {
  _VoiceRecordingRoute()
      : super(
          opaque: false,
          barrierColor: Colors.transparent,
          transitionDuration: const Duration(milliseconds: 200),
          reverseTransitionDuration: const Duration(milliseconds: 150),
          pageBuilder: (context, animation, secondaryAnimation) =>
              _VoiceRecordingPage(animation: animation),
        );
}

/// 语音录制页面
class _VoiceRecordingPage extends StatefulWidget {
  final Animation<double> animation;

  const _VoiceRecordingPage({required this.animation});

  @override
  State<_VoiceRecordingPage> createState() => _VoiceRecordingPageState();
}

class _VoiceRecordingPageState extends State<_VoiceRecordingPage> {
  final _audioRecorder = AudioRecorder();
  final _waveformGenerator = WaveformGenerator();

  GestureZone _activeZone = GestureZone.none;
  DateTime? _recordStartTime;
  String? _recordFilePath;

  // 声波模拟定时器
  Timer? _waveformTimer;

  // 手势追踪起点（按钮中心位置）
  Offset _gestureOrigin = Offset.zero;

  // 热区判定阈值
  static const double _verticalThreshold = 80.0; // Y轴上滑阈值
  static const double _horizontalThreshold = 60.0; // X轴偏移阈值

  @override
  void initState() {
    super.initState();
    _startRecording();
  }

  @override
  void dispose() {
    _waveformTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    // 检查权限
    bool hasPermission = false;
    try {
      hasPermission = await _audioRecorder.hasPermission()
          .timeout(const Duration(seconds: 3), onTimeout: () => false);
    } catch (_) {
      hasPermission = false;
    }

    if (!hasPermission) {
      if (mounted) {
        Navigator.of(context).pop(const VoiceResult(action: VoiceResultAction.cancel));
        AppToast.show(context, AppLocalizations.of(context)!.chatInputMicPermission);
      }
      return;
    }

    _recordStartTime = DateTime.now();

    try {
      final tempDir = await getTemporaryDirectory();
      _recordFilePath = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _recordFilePath!,
      );

      if (mounted) {
        _startWaveformSimulation();
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(const VoiceResult(action: VoiceResultAction.cancel));
      }
    }
  }

  /// 模拟声波数据（实际应从录音 API 的振幅回调获取）
  void _startWaveformSimulation() {
    _waveformTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (!mounted) return;
      setState(() {
        // 模拟随机音量
        _waveformGenerator.addSample(0.3 + (DateTime.now().millisecondsSinceEpoch % 100) / 140.0);
      });
    });
  }

  void _onPanStart(DragStartDetails details) {
    // 记录手势起点（屏幕下半部分中心）
    final size = MediaQuery.of(context).size;
    _gestureOrigin = Offset(size.width / 2, size.height - 100);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final position = details.globalPosition;
    final dx = position.dx - _gestureOrigin.dx;
    final dy = _gestureOrigin.dy - position.dy; // 正值 = 手指上移

    GestureZone newZone;

    if (dy > _verticalThreshold) {
      if (dx < -_horizontalThreshold) {
        newZone = GestureZone.cancel;
      } else if (dx > _horizontalThreshold) {
        newZone = GestureZone.transcribe;
      } else {
        newZone = GestureZone.send;
      }
    } else {
      newZone = GestureZone.send; // 默认中间区域
    }

    if (newZone != _activeZone) {
      HapticFeedback.lightImpact();
      setState(() => _activeZone = newZone);
    }
  }

  Future<void> _onPanEnd(DragEndDetails details) async {
    _waveformTimer?.cancel();

    final action = switch (_activeZone) {
      GestureZone.cancel => VoiceResultAction.cancel,
      GestureZone.transcribe => VoiceResultAction.transcribe,
      _ => VoiceResultAction.send,
    };

    // 停止录音
    await _audioRecorder.stop();

    // 检查最小时长
    if (action != VoiceResultAction.cancel) {
      final duration = _recordStartTime != null
          ? DateTime.now().difference(_recordStartTime!)
          : Duration.zero;
      if (duration.inMilliseconds < 500) {
        if (mounted) {
          Navigator.of(context).pop(const VoiceResult(action: VoiceResultAction.cancel));
          AppToast.show(context, AppLocalizations.of(context)!.chatInputRecordShort, duration: const Duration(milliseconds: 800));
        }
        return;
      }
    }

    HapticFeedback.lightImpact();

    if (mounted) {
      Navigator.of(context).pop(VoiceResult(
        action: action,
        filePath: action != VoiceResultAction.cancel ? _recordFilePath : null,
      ));
    }
  }

  String _formatDuration() {
    if (_recordStartTime == null) return '0:00';
    final duration = DateTime.now().difference(_recordStartTime!);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.black.withValues(alpha: 0.5 * widget.animation.value),
          body: GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: Stack(
              children: [
                // 中央反馈弹窗
                Positioned(
                  left: screenSize.width / 2 - 80,
                  bottom: screenSize.height * 0.35,
                  child: _buildCentralPopup(),
                ),

                // 底部扇形面板
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: screenSize.height * 0.3,
                  child: CustomPaint(
                    size: Size(screenSize.width, screenSize.height * 0.3),
                    painter: FanShapePainter(
                      activeZone: _activeZone,
                      panelProgress: widget.animation.value,
                    ),
                  ),
                ),

                // 底部提示文字
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 20,
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.voiceOverlaySwipeHint,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
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

  Widget _buildCentralPopup() {
    final isCancel = _activeZone == GestureZone.cancel;
    final isTranscribe = _activeZone == GestureZone.transcribe;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isTranscribe ? 200 : 160,
      height: isTranscribe ? 120 : 80,
      decoration: BoxDecoration(
        color: isCancel
            ? Colors.red.withValues(alpha: 0.9)
            : isTranscribe
                ? const Color(0xFF1E1E1E).withValues(alpha: 0.95)
                : const Color(0xFF2D2D2D).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图标和时长
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isCancel ? Icons.close : Icons.mic,
                size: 20,
                color: isCancel ? Colors.white : Colors.green,
              ),
              const SizedBox(width: 8),
              Text(
                isCancel ? AppLocalizations.of(context)!.voiceOverlayCancelLabel : _formatDuration(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 声波
          SizedBox(
            width: isTranscribe ? 180 : 130,
            height: 24,
            child: CustomPaint(
              painter: WaveformPainter(
                amplitudes: _waveformGenerator.amplitudes,
                isCancelled: isCancel,
                isTranscribe: isTranscribe,
              ),
            ),
          ),
          // 转文字提示
          if (isTranscribe) ...[
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.voiceOverlayTranscribeLabel,
              style: TextStyle(
                color: const Color(0xFF2196F3).withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
