import 'package:flutter/material.dart';

/// 响应式缩放工具
/// 基于 375px 设计稿宽度，自动缩放尺寸和字体
class Responsive {
  Responsive._();

  /// 设计稿基准宽度（iPhone 标准）
  static const double _designWidth = 375.0;

  /// 缩放因子上下限，避免极端缩放
  static const double _minScale = 0.8;
  static const double _maxScale = 1.3;

  /// 获取当前屏幕宽度
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// 获取缩放因子（基于屏幕宽度）
  static double scaleFactor(BuildContext context) {
    final width = screenWidth(context);
    final scale = width / _designWidth;
    return scale.clamp(_minScale, _maxScale);
  }

  /// 缩放尺寸（间距、圆角、组件尺寸等）
  static double s(BuildContext context, double size) {
    return size * scaleFactor(context);
  }

  /// 缩放字体大小
  static double fs(BuildContext context, double fontSize) {
    return fontSize * scaleFactor(context);
  }

  /// 响应式水平内边距
  static EdgeInsets horizontalPadding(BuildContext context, {double base = 16}) {
    final padding = s(context, base);
    return EdgeInsets.symmetric(horizontal: padding);
  }

  /// 响应式对称内边距
  static EdgeInsets symmetric(BuildContext context, {double h = 0, double v = 0}) {
    return EdgeInsets.symmetric(
      horizontal: s(context, h),
      vertical: s(context, v),
    );
  }
}
