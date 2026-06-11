import 'package:flutter/material.dart';

/// 录音手势区域
enum GestureZone {
  none,      // 未判定
  send,      // 中间：松开发送
  cancel,    // 左上：取消
  transcribe, // 右上：转文字
}

/// 扇形手势面板绘制器
///
/// 底部弧形面板，分为三个热区：
/// - 中间：松开发送
/// - 左上：取消
/// - 右上：转文字
class FanShapePainter extends CustomPainter {
  final GestureZone activeZone;
  final double panelProgress; // 0.0 ~ 1.0 面板展开动画进度

  FanShapePainter({
    required this.activeZone,
    this.panelProgress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 扇形参数
    final arcRadius = w * 0.55;
    final arcCenter = Offset(w / 2, h);
    final bottomY = h;
    final arcTopY = h - arcRadius * 0.6;

    // 绘制半透明背景
    _drawBackground(canvas, size, arcCenter, arcRadius, bottomY, arcTopY);

    // 绘制分割线
    _drawDividers(canvas, size, arcCenter, arcRadius, bottomY, arcTopY);

    // 绘制文字标签
    _drawLabels(canvas, size, arcCenter, arcRadius, bottomY, arcTopY);
  }

  void _drawBackground(Canvas canvas, Size size, Offset arcCenter,
      double arcRadius, double bottomY, double arcTopY) {
    final w = size.width;

    // 左侧区域（取消）
    final leftPath = Path()
      ..moveTo(0, bottomY)
      ..lineTo(0, arcTopY + 30)
      ..quadraticBezierTo(w * 0.15, arcTopY - 10, w / 3, arcTopY + 10)
      ..lineTo(w / 3, bottomY)
      ..close();

    // 中间区域（发送）
    final centerPath = Path()
      ..moveTo(w / 3, bottomY)
      ..lineTo(w / 3, arcTopY + 10)
      ..quadraticBezierTo(w / 2, arcTopY - 30, w * 2 / 3, arcTopY + 10)
      ..lineTo(w * 2 / 3, bottomY)
      ..close();

    // 右侧区域（转文字）
    final rightPath = Path()
      ..moveTo(w * 2 / 3, bottomY)
      ..lineTo(w * 2 / 3, arcTopY + 10)
      ..quadraticBezierTo(w * 0.85, arcTopY - 10, w, arcTopY + 30)
      ..lineTo(w, bottomY)
      ..close();

    // 绘制各区域背景
    final activeAlpha = 0.35;
    final inactiveAlpha = 0.15;

    // 左侧（取消）
    final leftColor = activeZone == GestureZone.cancel
        ? Colors.red.withValues(alpha: activeAlpha)
        : Colors.white.withValues(alpha: inactiveAlpha);
    canvas.drawPath(leftPath, Paint()..color = leftColor);

    // 中间（发送）
    final centerColor = activeZone == GestureZone.send
        ? Colors.white.withValues(alpha: activeAlpha)
        : Colors.white.withValues(alpha: inactiveAlpha);
    canvas.drawPath(centerPath, Paint()..color = centerColor);

    // 右侧（转文字）
    final rightColor = activeZone == GestureZone.transcribe
        ? const Color(0xFF2196F3).withValues(alpha: activeAlpha)
        : Colors.white.withValues(alpha: inactiveAlpha);
    canvas.drawPath(rightPath, Paint()..color = rightColor);

    // 顶部弧线
    final arcPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final arcPath = Path()
      ..moveTo(0, arcTopY + 30)
      ..quadraticBezierTo(w * 0.15, arcTopY - 10, w / 3, arcTopY + 10)
      ..quadraticBezierTo(w / 2, arcTopY - 30, w * 2 / 3, arcTopY + 10)
      ..quadraticBezierTo(w * 0.85, arcTopY - 10, w, arcTopY + 30);

    canvas.drawPath(arcPath, arcPaint);
  }

  void _drawDividers(Canvas canvas, Size size, Offset arcCenter,
      double arcRadius, double bottomY, double arcTopY) {
    final w = size.width;
    final dividerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 1;

    // 左分割线
    canvas.drawLine(
      Offset(w / 3, arcTopY + 10),
      Offset(w / 3, bottomY),
      dividerPaint,
    );

    // 右分割线
    canvas.drawLine(
      Offset(w * 2 / 3, arcTopY + 10),
      Offset(w * 2 / 3, bottomY),
      dividerPaint,
    );
  }

  void _drawLabels(Canvas canvas, Size size, Offset arcCenter,
      double arcRadius, double bottomY, double arcTopY) {
    final w = size.width;
    final labelY = bottomY - 50;

    // 取消标签
    _drawLabel(canvas, '取消', Offset(w / 6, labelY),
        isActive: activeZone == GestureZone.cancel,
        activeColor: Colors.red);

    // 发送标签
    _drawLabel(canvas, '松开 发送', Offset(w / 2, labelY),
        isActive: activeZone == GestureZone.send,
        activeColor: Colors.white);

    // 转文字标签
    _drawLabel(canvas, '转文字', Offset(w * 5 / 6, labelY),
        isActive: activeZone == GestureZone.transcribe,
        activeColor: const Color(0xFF2196F3));
  }

  void _drawLabel(Canvas canvas, String text, Offset position,
      {required bool isActive, required Color activeColor}) {
    final textStyle = TextStyle(
      color: isActive ? activeColor : Colors.white.withValues(alpha: 0.6),
      fontSize: 13,
      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
    );

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(position.dx - textPainter.width / 2, position.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant FanShapePainter oldDelegate) {
    return oldDelegate.activeZone != activeZone ||
        oldDelegate.panelProgress != panelProgress;
  }
}
