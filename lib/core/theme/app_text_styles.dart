import 'package:flutter/material.dart';

/// WoAccount 字体样式系统
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
  static const TextStyle label = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w500, height: 16 / 12,
  );
  static const TextStyle tagText = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w500, height: 16 / 12,
  );
}

/// 兼容包装类 — 支持 `context.textStyles.body` 模式
class AppTextStylesCompat {
  const AppTextStylesCompat();
  TextStyle get h1 => AppTextStyles.h1;
  TextStyle get h2 => AppTextStyles.h2;
  TextStyle get h3 => AppTextStyles.h3;
  TextStyle get body => AppTextStyles.body;
  TextStyle get callout => AppTextStyles.callout;
  TextStyle get footnote => AppTextStyles.footnote;
  TextStyle get caption => AppTextStyles.caption;
  TextStyle get amountLarge => AppTextStyles.amountLarge;
  TextStyle get amountList => AppTextStyles.amountList;
  TextStyle get amountSmall => AppTextStyles.amountSmall;
  TextStyle get navLabel => AppTextStyles.navLabel;
  TextStyle get buttonText => AppTextStyles.buttonText;
  TextStyle get label => AppTextStyles.label;
  TextStyle get tagText => AppTextStyles.tagText;
}

/// 便捷扩展 — `context.textStyles.body` 等同于 `AppTextStyles.body`
extension AppTextStylesContext on BuildContext {
  AppTextStylesCompat get textStyles => const AppTextStylesCompat();
}
