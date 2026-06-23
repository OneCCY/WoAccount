import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// 绿色语音气泡绘制器（微信风格）
///
/// 绘制带尾巴的圆角绿色气泡，内部包含：
/// - 圆点声波动画
/// - 录音时长文本
class VoiceBubblePainter extends CustomPainter {
  final List<double> amplitudes;
  final String durationText;
  final Color bubbleColor;

  VoiceBubblePainter({
    required this.amplitudes,
    required this.durationText,
    this.bubbleColor = const Color(0xFF07C160),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 气泡主体（不含尾巴的区域）
    const tailHeight = 12.0;
    final bodyHeight = h - tailHeight;
    final bodyRect = RRect.fromLTRBR(0, 0, w, bodyHeight, const Radius.circular(16));

    // 绘制气泡背景
    final bgPaint = Paint()..color = bubbleColor;
    canvas.drawRRect(bodyRect, bgPaint);

    // 绘制尾巴（底部中间的小三角）
    final tailPath = Path()
      ..moveTo(w / 2 - 10, bodyHeight - 2)
      ..lineTo(w / 2, h)
      ..lineTo(w / 2 + 10, bodyHeight - 2)
      ..close();
    canvas.drawPath(tailPath, bgPaint);

    // 绘制声波圆点
    _drawWaveformDots(canvas, Size(w, bodyHeight));

    // 绘制时长文本
    _drawDuration(canvas, Size(w, bodyHeight));
  }

  void _drawWaveformDots(Canvas canvas, Size size) {
    if (amplitudes.isEmpty) return;

    final centerY = size.height * 0.38;
    final dotRadius = 2.5;
    final maxAmplitude = size.height * 0.15;

    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.7);

    final totalDots = amplitudes.length;
    final totalWidth = totalDots * 8.0;
    final startX = (size.width - totalWidth) / 2;

    for (int i = 0; i < totalDots; i++) {
      final x = startX + i * 8.0 + 4;
      final amplitude = amplitudes[i].clamp(0.0, 1.0);
      final yOffset = amplitude * maxAmplitude;

      // 上半部分圆点
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, centerY - yOffset),
          width: dotRadius * 2,
          height: dotRadius * 2,
        ),
        dotPaint,
      );
      // 下半部分圆点（对称）
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, centerY + yOffset),
          width: dotRadius * 2,
          height: dotRadius * 2,
        ),
        dotPaint,
      );
    }
  }

  void _drawDuration(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: durationText,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.85),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        size.height * 0.62 - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant VoiceBubblePainter oldDelegate) {
    return oldDelegate.amplitudes != amplitudes ||
        oldDelegate.durationText != durationText;
  }
}

/// 声波数据生成器
class WaveformGenerator {
  final Random _random = Random();
  final List<double> _amplitudes = [];
  final int maxBars;

  WaveformGenerator({this.maxBars = 25});

  List<double> get amplitudes => List.unmodifiable(_amplitudes);

  /// 模拟音量更新
  void addSample(double volume) {
    final adjusted = (volume + _random.nextDouble() * 0.3).clamp(0.0, 1.0);
    _amplitudes.add(adjusted);
    if (_amplitudes.length > maxBars) {
      _amplitudes.removeAt(0);
    }
  }

  void clear() {
    _amplitudes.clear();
  }
}
