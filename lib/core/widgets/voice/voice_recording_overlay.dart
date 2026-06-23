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
/// 2. 手指按住不放 → 弹窗显示录音状态，三个热区在弹窗上方
/// 3. 上滑左移 → 取消 | 上滑右移 → 转文字 | 不滑/上滑中间 → 发送
/// 4. 松手 → 根据热区执行操作
class VoiceRecordingOverlay {
  static Future<VoiceResult?> show(BuildContext context) async {
    return Navigator.of(context).push<VoiceResult>(
      _VoiceRecordingRoute(),
    );
  }
}

class _VoiceRecordingRoute extends PageRouteBuilder<VoiceResult> {
  _VoiceRecordingRoute()
      : super(
          opaque: false,
          barrierColor: Colors.transparent,
          transitionDuration: const Duration(milliseconds: 150),
          reverseTransitionDuration: const Duration(milliseconds: 100),
          pageBuilder: (context, animation, secondaryAnimation) =>
              _VoiceRecordingPage(animation: animation),
        );
}

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
    _waveformTimer?.cancel();
    _durationTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

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
        setState(() {}); // 触发 UI 刷新显示计时
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(const VoiceResult(action: VoiceResultAction.cancel));
      }
    }
  }

  void _startWaveformSimulation() {
    _waveformTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (!mounted) return;
      setState(() {
        _waveformGenerator.addSample(0.3 + (DateTime.now().millisecondsSinceEpoch % 100) / 140.0);
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

    final action = switch (_activeZone) {
      GestureZone.cancel => VoiceResultAction.cancel,
      GestureZone.transcribe => VoiceResultAction.transcribe,
      _ => VoiceResultAction.send,
    };

    // 停止录音
    await _audioRecorder.stop();

    // 检查最小时长（取消除外）
    if (action != VoiceResultAction.cancel) {
      final duration = _recordStartTime != null
          ? DateTime.now().difference(_recordStartTime!)
          : Duration.zero;
      if (duration.inMilliseconds < 500) {
        if (mounted) {
          Navigator.of(context).pop(const VoiceResult(action: VoiceResultAction.cancel));
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
      ));
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _waveformTimer?.cancel();
    _audioRecorder.stop();
    if (mounted) {
      Navigator.of(context).pop(const VoiceResult(action: VoiceResultAction.cancel));
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
    final isCancel = _activeZone == GestureZone.cancel;
    final isTranscribe = _activeZone == GestureZone.transcribe;

    // 录音弹窗位置（屏幕中下部）
    final popupBottom = screenSize.height * 0.32;

    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.black.withValues(alpha: 0.5 * widget.animation.value),
          body: Listener(
            onPointerDown: _onPointerDown,
            onPointerMove: _onPointerMove,
            onPointerUp: _onPointerUp,
            onPointerCancel: _onPointerCancel,
            behavior: HitTestBehavior.translucent,
            child: Stack(
              children: [
                // ===== 三个热区指示器（弹窗上方） =====
                Positioned(
                  left: 0, right: 0,
                  bottom: popupBottom + 140,  // 弹窗上方
                  height: 120,
                  child: _buildZoneIndicators(),
                ),

                // ===== 中央录音弹窗 =====
                Positioned(
                  left: screenSize.width / 2 - (isTranscribe ? 100 : 80),
                  bottom: popupBottom,
                  child: _buildRecordingPopup(),
                ),

                // ===== 底部扇形面板 =====
                Positioned(
                  left: 0, right: 0,
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

                // ===== 底部提示 =====
                Positioned(
                  left: 0, right: 0,
                  bottom: 16,
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

  /// 三个热区指示器（录音弹窗上方，横向排列）
  Widget _buildZoneIndicators() {
    final isCancel = _activeZone == GestureZone.cancel;
    final isSend = _activeZone == GestureZone.send;
    final isTranscribe = _activeZone == GestureZone.transcribe;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // 左：取消
          Expanded(
            child: _buildZoneIcon(
              icon: Icons.close,
              label: AppLocalizations.of(context)!.voiceOverlayCancelLabel,
              isActive: isCancel,
              activeColor: Colors.red,
            ),
          ),
          // 中：发送
          Expanded(
            child: _buildZoneIcon(
              icon: Icons.send,
              label: AppLocalizations.of(context)!.chatInputVoiceSend,
              isActive: isSend,
              activeColor: Colors.white,
            ),
          ),
          // 右：转文字
          Expanded(
            child: _buildZoneIcon(
              icon: Icons.text_fields,
              label: AppLocalizations.of(context)!.voiceOverlayTranscribeLabel,
              isActive: isTranscribe,
              activeColor: const Color(0xFF2196F3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneIcon({
    required IconData icon,
    required String label,
    required bool isActive,
    required Color activeColor,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isActive
                  ? activeColor.withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: isActive
                  ? Border.all(color: activeColor.withValues(alpha: 0.6), width: 1.5)
                  : null,
            ),
            child: Icon(
              icon,
              color: isActive ? activeColor : Colors.white54,
              size: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? activeColor : Colors.white38,
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// 中央录音弹窗
  Widget _buildRecordingPopup() {
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
