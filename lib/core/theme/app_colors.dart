import 'package:flutter/material.dart';

/// WoAccount 颜色系统
/// 基于 UI 设计系统规范，Cupertino 风格为主
class AppColors {
  AppColors._();

  // === 主色调 ===
  static const Color primary = Color(0xFF007AFF);       // iOS 蓝
  static const Color primaryLight = Color(0xFF4DA3FF);
  static const Color primaryDark = Color(0xFF0056CC);

  // === 背景色 ===
  static const Color background = Color(0xFFF2F2F7);     // iOS 浅灰背景
  static const Color surface = Color(0xFFFFFFFF);        // 卡片/表面
  static const Color surfaceSecondary = Color(0xFFF2F2F7);

  // === 文字色 ===
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textTertiary = Color(0xFFC7C7CC);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // === 分割线 ===
  static const Color separator = Color(0xFFC6C6C8);
  static const Color separatorOpaque = Color(0xFFE5E5EA);

  // === 功能色 ===
  static const Color success = Color(0xFF34C759);        // iOS 绿
  static const Color warning = Color(0xFFFF9500);        // iOS 橙
  static const Color error = Color(0xFFFF3B30);          // iOS 红
  static const Color info = Color(0xFF5AC8FA);           // iOS 浅蓝

  // === 分类色 ===
  static const Color categoryFood = Color(0xFFFF9800);       // 餐饮
  static const Color categoryTransport = Color(0xFF2196F3);  // 交通
  static const Color categoryShopping = Color(0xFFE91E63);   // 购物
  static const Color categoryHousing = Color(0xFF9C27B0);    // 住房
  static const Color categoryEntertainment = Color(0xFF4CAF50); // 娱乐
  static const Color categoryEducation = Color(0xFF00BCD4);  // 教育
  static const Color categoryMedical = Color(0xFFF44336);    // 医疗
  static const Color categorySocial = Color(0xFFFF5722);     // 社交
  static const Color categoryOther = Color(0xFF607D8B);      // 其他
}
