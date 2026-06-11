import 'dart:math';
import 'package:flutter/material.dart';

/// 声波动画绘制器
/// 根据音量数据绘制跳动的波形条
class WaveformPainter extends CustomPainter {
  final List<double> amplitudes;
  final Color color;
  final bool isCancelled;
  final bool isTranscribe;

  WaveformPainter({
    required this.amplitudes,
    this.color = Colors.white,
    this.isCancelled = false,
    this.isTranscribe = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (amplitudes.isEmpty) return;

    final barWidth = 3.0;
    final barGap = 2.5;
    final maxBarHeight = size.height * 0.8;
    final centerY = size.height / 2;

    final paint = Paint()
      ..color = isCancelled
          ? Colors.red.withValues(alpha: 0.8)
          : isTranscribe
              ? const Color(0xFF2196F3).withValues(alpha: 0.8)
              : color.withValues(alpha: 0.9)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = barWidth;

    final totalBars = amplitudes.length;
    final totalWidth = totalBars * (barWidth + barGap) - barGap;
    final startX = (size.width - totalWidth) / 2;

    for (int i = 0; i < totalBars; i++) {
      final x = startX + i * (barWidth + barGap);
      final amplitude = amplitudes[i].clamp(0.0, 1.0);
      final barHeight = max(4.0, amplitude * maxBarHeight);

      canvas.drawLine(
        Offset(x, centerY - barHeight / 2),
        Offset(x, centerY + barHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.amplitudes != amplitudes ||
        oldDelegate.isCancelled != isCancelled ||
        oldDelegate.isTranscribe != isTranscribe;
  }
}

/// 声波数据生成器
class WaveformGenerator {
  final Random _random = Random();
  final List<double> _amplitudes = [];
  final int maxBars;

  WaveformGenerator({this.maxBars = 25});

  List<double> get amplitudes => List.unmodifiable(_amplitudes);

  /// 模拟音量更新（实际应从录音 API 获取）
  void addSample(double volume) {
    // 添加一些随机性使波形更自然
    final adjusted = (volume + _random.nextDouble() * 0.3).clamp(0.0, 1.0);
    _amplitudes.add(adjusted);
    if (_amplitudes.length > maxBars) {
      _amplitudes.removeAt(0);
    }
  }

  /// 生成静音帧
  void addSilence() {
    _amplitudes.add(_random.nextDouble() * 0.1);
    if (_amplitudes.length > maxBars) {
      _amplitudes.removeAt(0);
    }
  }

  void clear() {
    _amplitudes.clear();
  }
}
