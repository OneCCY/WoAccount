import 'package:flutter/material.dart';

/// WoAccount 颜色系统
/// 基于原型设计，绿色主题，温暖友好
class AppColors {
  AppColors._();

  // === 主色调（绿色系）===
  static const Color primary = Color(0xFF4CAF50);        // 主绿
  static const Color primaryLight = Color(0xFF66BB6A);   // 浅绿
  static const Color primaryDark = Color(0xFF2E7D32);    // 深绿
  static const Color primarySurface = Color(0xFFE8F5E9); // 绿底色

  // === 背景色 ===
  static const Color background = Color(0xFFFAFAFA);     // 浅灰背景
  static const Color surface = Color(0xFFFFFFFF);        // 卡片/表面
  static const Color surfaceSecondary = Color(0xFFF5F5F5);

  // === 文字色 ===
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // === 分割线 ===
  static const Color separator = Color(0xFFE0E0E0);
  static const Color separatorOpaque = Color(0xFFF0F0F0);

  // === 功能色 ===
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color income = Color(0xFF4CAF50);         // 收入绿
  static const Color expense = Color(0xFFF44336);        // 支出红

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

  // === 分类背景色 ===
  static const Color categoryFoodBg = Color(0xFFFFF3E0);
  static const Color categoryTransportBg = Color(0xFFE3F2FD);
  static const Color categoryShoppingBg = Color(0xFFFCE4EC);
  static const Color categoryHousingBg = Color(0xFFF3E5F5);
  static const Color categoryEntertainmentBg = Color(0xFFE8F5E9);
  static const Color categoryEducationBg = Color(0xFFE0F7FA);
  static const Color categoryMedicalBg = Color(0xFFFFEBEE);
  static const Color categorySocialBg = Color(0xFFFBE9E7);
  static const Color categoryOtherBg = Color(0xFFECEFF1);

  // === 渐变 ===
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9)],
  );

  static const LinearGradient aiEntryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9)],
  );
}
