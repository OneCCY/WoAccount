import 'package:flutter/material.dart';
import 'app_colors.dart';

/// WoAccount 字体样式系统
/// 静态常量定义尺寸/粗细，context 扩展自动适配主题色
class AppTextStyles {
  AppTextStyles._();

  // === 标题 ===
  static const TextStyle h1 = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w700, height: 34 / 28, letterSpacing: 0.36,
  );
  static const TextStyle h2 = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w600, height: 28 / 22, letterSpacing: 0.35,
  );
  static const TextStyle h3 = TextStyle(
    fontSize: 17, fontWeight: FontWeight.w600, height: 22 / 17, letterSpacing: -0.41,
  );

  // === 正文 ===
  static const TextStyle body = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w400, height: 20 / 15, letterSpacing: -0.24,
  );
  static const TextStyle callout = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w400, height: 22 / 16, letterSpacing: -0.32,
  );

  // === 辅助 ===
  static const TextStyle footnote = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w400, height: 18 / 13, letterSpacing: -0.08,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w400, height: 14 / 11, letterSpacing: 0.07,
  );

  // === 金额数字 ===
  static const TextStyle amountLarge = TextStyle(
    fontSize: 34, fontWeight: FontWeight.w700, height: 41 / 34, letterSpacing: 0.37,
  );
  static const TextStyle amountList = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w600, height: 22 / 16,
  );
  static const TextStyle amountSmall = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w500, height: 20 / 15, letterSpacing: -0.24,
  );

  // === 特殊样式 ===
  static const TextStyle navLabel = TextStyle(
    fontSize: 10, fontWeight: FontWeight.w400, height: 14 / 10,
  );
  static const TextStyle buttonText = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w500, height: 20 / 15,
  );
}

/// BuildContext 扩展 — 获取带主题色的文本样式
/// `context.textStyles.body` → 自动带 textPrimary 颜色
extension AppTextStylesExtension on BuildContext {
  ThemedTextStyles get textStyles => ThemedTextStyles(colors);
}

/// 带主题色的文本样式代理
class ThemedTextStyles {
  final AppColors _c;
  ThemedTextStyles(this._c);

  TextStyle get h1 => AppTextStyles.h1.copyWith(color: _c.textPrimary);
  TextStyle get h2 => AppTextStyles.h2.copyWith(color: _c.textPrimary);
  TextStyle get h3 => AppTextStyles.h3.copyWith(color: _c.textPrimary);
  TextStyle get body => AppTextStyles.body.copyWith(color: _c.textPrimary);
  TextStyle get callout => AppTextStyles.callout.copyWith(color: _c.textPrimary);
  TextStyle get footnote => AppTextStyles.footnote.copyWith(color: _c.textSecondary);
  TextStyle get caption => AppTextStyles.caption.copyWith(color: _c.textTertiary);
  TextStyle get amountLarge => AppTextStyles.amountLarge.copyWith(color: _c.textPrimary);
  TextStyle get amountList => AppTextStyles.amountList.copyWith(color: _c.textPrimary);
  TextStyle get amountSmall => AppTextStyles.amountSmall.copyWith(color: _c.textPrimary);
  TextStyle get navLabel => AppTextStyles.navLabel;
  TextStyle get buttonText => AppTextStyles.buttonText;
}
