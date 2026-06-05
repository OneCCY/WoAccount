import 'package:flutter/material.dart';
import 'app_colors.dart';

/// WoAccount 字体样式系统
/// 思源黑体（中文）+ SF Pro（英文），由系统自动匹配
class AppTextStyles {
  AppTextStyles._();

  // === 标题 ===
  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 34 / 28,
    letterSpacing: 0.36,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 28 / 22,
    letterSpacing: 0.35,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 22 / 17,
    letterSpacing: -0.41,
    color: AppColors.textPrimary,
  );

  // === 正文 ===
  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 20 / 15,
    letterSpacing: -0.24,
    color: AppColors.textPrimary,
  );

  static const TextStyle callout = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 22 / 16,
    letterSpacing: -0.32,
    color: AppColors.textPrimary,
  );

  // === 辅助 ===
  static const TextStyle footnote = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 18 / 13,
    letterSpacing: -0.08,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 14 / 11,
    letterSpacing: 0.07,
    color: AppColors.textTertiary,
  );

  // === 标签 ===
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    color: AppColors.textTertiary,
  );

  // === 金额数字 ===
  static const TextStyle amountLarge = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    height: 41 / 34,
    letterSpacing: 0.37,
    color: AppColors.textPrimary,
  );

  static const TextStyle amountList = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 22 / 16,
    color: AppColors.textPrimary,
  );

  static const TextStyle amountSmall = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 20 / 15,
    letterSpacing: -0.24,
    color: AppColors.textPrimary,
  );

  // === 特殊样式 ===
  static const TextStyle navLabel = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 14 / 10,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 20 / 15,
  );

  static const TextStyle tagText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
  );
}
