import 'package:flutter/material.dart';

/// 录音手势区域
enum GestureZone {
  none,       // 未判定
  send,       // 中间：松开发送
  cancel,     // 左上：取消
  transcribe, // 右上：转文字
}

/// 底部手势面板绘制器（微信风格）
///
/// 布局：
/// - 上部左：「取消」圆角矩形
/// - 上部右：「滑到这里 转文字」圆角矩形
/// - 下部：「松开 发送」大圆角区域（主操作区）
///
/// 三区域通过弧形分隔线区分，形成扇形外观。
class FanShapePainter extends CustomPainter {
  final GestureZone activeZone;
  final double panelProgress;

  FanShapePainter({
    required this.activeZone,
    this.panelProgress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 面板高度分配
    final topZoneHeight = h * 0.42;  // 上部两个按钮区域
    final bottomZoneTop = topZoneHeight + 4;  // 下部区域起始Y

    // 分割X位置（上部两个区域的分界线）
    final splitX = w / 2;

    // ===== 绘制各区域背景 =====

    // 左上区域（取消）
    final leftTopPath = _createTopLeftPath(w, topZoneHeight, splitX);
    _drawZoneBackground(
      canvas,
      leftTopPath,
      isZoneActive: activeZone == GestureZone.cancel,
      activeColor: Colors.red,
    );

    // 右上区域（转文字）
    final rightTopPath = _createTopRightPath(w, topZoneHeight, splitX);
    _drawZoneBackground(
      canvas,
      rightTopPath,
      isZoneActive: activeZone == GestureZone.transcribe,
      activeColor: const Color(0xFF2196F3),
    );

    // 下部大区域（发送）
    final bottomPath = _createBottomPath(w, h, bottomZoneTop);
    _drawZoneBackground(
      canvas,
      bottomPath,
      isZoneActive: activeZone == GestureZone.send,
      activeColor: Colors.white,
    );

    // ===== 绘制弧形分隔线 =====
    _drawCurvedDividers(canvas, w, h, topZoneHeight, splitX);

    // ===== 绘制标签文字 =====
    _drawLabels(canvas, w, h, topZoneHeight, splitX);
  }

  Path _createTopLeftPath(double w, double topH, double splitX) {
    final path = Path();
    // 从左上角开始，沿顶部弧线到中间
    path.moveTo(0, topH + 20);
    path.quadraticBezierTo(w * 0.15, topH - 15, splitX - 2, topH + 8);
    // 向下到底部，再回到左边
    path.lineTo(splitX - 2, topH + 6);
    path.lineTo(splitX - 2, topH + 6);
    path.lineTo(0, topH + 6);
    path.close();
    return path;
  }

  Path _createTopRightPath(double w, double topH, double splitX) {
    final path = Path();
    path.moveTo(splitX + 2, topH + 8);
    path.quadraticBezierTo(w * 0.85, topH - 15, w, topH + 20);
    path.lineTo(w, topH + 6);
    path.lineTo(splitX + 2, topH + 6);
    path.close();
    return path;
  }

  Path _createBottomPath(double w, double h, double topStart) {
    final path = Path();
    // 顶部弧线
    path.moveTo(0, topStart + 18);
    path.quadraticBezierTo(w * 0.15, topStart - 8, w / 2, topStart - 20);
    path.quadraticBezierTo(w * 0.85, topStart - 8, w, topStart + 18);
    // 右下到底部
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();
    return path;
  }

  void _drawZoneBackground(
    Canvas canvas,
    Path path, {
    required bool isZoneActive,
    required Color activeColor,
  }) {
    final color = isZoneActive
        ? activeColor.withValues(alpha: 0.35)
        : Colors.white.withValues(alpha: 0.12);
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawCurvedDividers(
    Canvas canvas,
    double w,
    double h,
    double topH,
    double splitX,
  ) {
    final dividerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // 左弧形分隔线
    final leftDivider = Path()
      ..moveTo(0, topH + 6)
      ..quadraticBezierTo(w * 0.15, topH - 12, splitX, topH + 6);
    canvas.drawPath(leftDivider, dividerPaint);

    // 右弧形分隔线
    final rightDivider = Path()
      ..moveTo(splitX, topH + 6)
      ..quadraticBezierTo(w * 0.85, topH - 12, w, topH + 6);
    canvas.drawPath(rightDivider, dividerPaint);

    // 底部弧形分隔线
    final bottomDivider = Path()
      ..moveTo(0, topH + 18)
      ..quadraticBezierTo(w * 0.15, topH - 8, w / 2, topH - 20)
      ..quadraticBezierTo(w * 0.85, topH - 8, w, topH + 18);
    canvas.drawPath(bottomDivider, dividerPaint);
  }

  void _drawLabels(
    Canvas canvas,
    double w,
    double h,
    double topH,
    double splitX,
  ) {
    // 取消标签（左上区域中心）
    _drawLabel(
      canvas,
      '取消',
      Offset(splitX / 2, topH / 2 + 2),
      isActive: activeZone == GestureZone.cancel,
      activeColor: Colors.red,
    );

    // 转文字标签（右上区域中心）
    _drawLabel(
      canvas,
      '滑到这里 转文字',
      Offset(splitX + (w - splitX) / 2, topH / 2 + 2),
      isActive: activeZone == GestureZone.transcribe,
      activeColor: const Color(0xFF2196F3),
    );

    // 发送标签（下部区域中心）
    _drawLabel(
      canvas,
      '松开 发送',
      Offset(w / 2, topH + (h - topH) / 2 + 8),
      isActive: activeZone == GestureZone.send,
      activeColor: Colors.white,
      fontSize: 16,
      isBold: true,
    );
  }

  void _drawLabel(
    Canvas canvas,
    String text,
    Offset position, {
    required bool isActive,
    required Color activeColor,
    double fontSize = 14,
    bool isBold = false,
  }) {
    final textStyle = TextStyle(
      color: isActive ? activeColor : Colors.white.withValues(alpha: 0.6),
      fontSize: fontSize,
      fontWeight: isBold
          ? FontWeight.w700
          : (isActive ? FontWeight.w600 : FontWeight.normal),
    );

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant FanShapePainter oldDelegate) {
    return oldDelegate.activeZone != activeZone ||
        oldDelegate.panelProgress != panelProgress;
  }
}
