import 'package:flutter/material.dart';

/// WoAccount 颜色系统
/// ThemeExtension 实现，支持浅色/深色模式自动切换
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.primarySurface,
    required this.background,
    required this.surface,
    required this.surfaceSecondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textHint,
    required this.textOnPrimary,
    required this.separator,
    required this.separatorOpaque,
    required this.success,
    required this.warning,
    required this.error,
    required this.income,
    required this.expense,
    required this.categoryFood,
    required this.categoryTransport,
    required this.categoryShopping,
    required this.categoryHousing,
    required this.categoryEntertainment,
    required this.categoryEducation,
    required this.categoryMedical,
    required this.categorySocial,
    required this.categoryOther,
    required this.categoryFoodBg,
    required this.categoryTransportBg,
    required this.categoryShoppingBg,
    required this.categoryHousingBg,
    required this.categoryEntertainmentBg,
    required this.categoryEducationBg,
    required this.categoryMedicalBg,
    required this.categorySocialBg,
    required this.categoryOtherBg,
    required this.aiEntryGradient,
    required this.cardShadow,
    required this.floatingShadow,
  });

  // ==================== 实例字段 ====================
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color primarySurface;
  final Color background;
  final Color surface;
  final Color surfaceSecondary;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textHint;
  final Color textOnPrimary;
  final Color separator;
  final Color separatorOpaque;
  final Color success;
  final Color warning;
  final Color error;
  final Color income;
  final Color expense;
  final Color categoryFood;
  final Color categoryTransport;
  final Color categoryShopping;
  final Color categoryHousing;
  final Color categoryEntertainment;
  final Color categoryEducation;
  final Color categoryMedical;
  final Color categorySocial;
  final Color categoryOther;
  final Color categoryFoodBg;
  final Color categoryTransportBg;
  final Color categoryShoppingBg;
  final Color categoryHousingBg;
  final Color categoryEntertainmentBg;
  final Color categoryEducationBg;
  final Color categoryMedicalBg;
  final Color categorySocialBg;
  final Color categoryOtherBg;
  final LinearGradient aiEntryGradient;
  final List<BoxShadow> cardShadow;
  final List<BoxShadow> floatingShadow;

  // ==================== 浅色模式 ====================
  factory AppColors.light() => const AppColors(
    primary: Color(0xFF4CAF50),
    primaryLight: Color(0xFF66BB6A),
    primaryDark: Color(0xFF2E7D32),
    primarySurface: Color(0xFFE8F5E9),
    background: Color(0xFFFAFAFA),
    surface: Color(0xFFFFFFFF),
    surfaceSecondary: Color(0xFFF5F5F5),
    textPrimary: Color(0xFF212121),
    textSecondary: Color(0xFF757575),
    textTertiary: Color(0xFF9E9E9E),
    textHint: Color(0xFFBDBDBD),
    textOnPrimary: Color(0xFFFFFFFF),
    separator: Color(0xFFE0E0E0),
    separatorOpaque: Color(0xFFF0F0F0),
    success: Color(0xFF4CAF50),
    warning: Color(0xFFFF9800),
    error: Color(0xFFF44336),
    income: Color(0xFF4CAF50),
    expense: Color(0xFFF44336),
    categoryFood: Color(0xFFFF9800),
    categoryTransport: Color(0xFF2196F3),
    categoryShopping: Color(0xFFE91E63),
    categoryHousing: Color(0xFF9C27B0),
    categoryEntertainment: Color(0xFF4CAF50),
    categoryEducation: Color(0xFF00BCD4),
    categoryMedical: Color(0xFFF44336),
    categorySocial: Color(0xFFFF5722),
    categoryOther: Color(0xFF607D8B),
    categoryFoodBg: Color(0xFFFFF3E0),
    categoryTransportBg: Color(0xFFE3F2FD),
    categoryShoppingBg: Color(0xFFFCE4EC),
    categoryHousingBg: Color(0xFFF3E5F5),
    categoryEntertainmentBg: Color(0xFFE8F5E9),
    categoryEducationBg: Color(0xFFE0F7FA),
    categoryMedicalBg: Color(0xFFFFEBEE),
    categorySocialBg: Color(0xFFFBE9E7),
    categoryOtherBg: Color(0xFFECEFF1),
    aiEntryGradient: LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9)],
    ),
    cardShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
    floatingShadow: [BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, -2))],
  );

  // ==================== 深色模式 ====================
  factory AppColors.dark() => const AppColors(
    primary: Color(0xFF66BB6A),
    primaryLight: Color(0xFF81C784),
    primaryDark: Color(0xFF4CAF50),
    primarySurface: Color(0xFF1B3A1B),
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    surfaceSecondary: Color(0xFF2C2C2C),
    textPrimary: Color(0xFFE0E0E0),
    textSecondary: Color(0xFFAAAAAA),
    textTertiary: Color(0xFF757575),
    textHint: Color(0xFF555555),
    textOnPrimary: Color(0xFFFFFFFF),
    separator: Color(0xFF3A3A3A),
    separatorOpaque: Color(0xFF2A2A2A),
    success: Color(0xFF66BB6A),
    warning: Color(0xFFFFB74D),
    error: Color(0xFFEF5350),
    income: Color(0xFF66BB6A),
    expense: Color(0xFFEF5350),
    categoryFood: Color(0xFFFFB74D),
    categoryTransport: Color(0xFF64B5F6),
    categoryShopping: Color(0xFFF06292),
    categoryHousing: Color(0xFFBA68C8),
    categoryEntertainment: Color(0xFF81C784),
    categoryEducation: Color(0xFF4DD0E1),
    categoryMedical: Color(0xFFEF5350),
    categorySocial: Color(0xFFFF8A65),
    categoryOther: Color(0xFF90A4AE),
    categoryFoodBg: Color(0xFF2D2218),
    categoryTransportBg: Color(0xFF1A2332),
    categoryShoppingBg: Color(0xFF2D1A22),
    categoryHousingBg: Color(0xFF231A2D),
    categoryEntertainmentBg: Color(0xFF1B2D1B),
    categoryEducationBg: Color(0xFF1A2D2D),
    categoryMedicalBg: Color(0xFF2D1A1A),
    categorySocialBg: Color(0xFF2D2018),
    categoryOtherBg: Color(0xFF252A2E),
    aiEntryGradient: LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFF1B3A1B), Color(0xFF1A2E1A)],
    ),
    cardShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2))],
    floatingShadow: [BoxShadow(color: Color(0x26000000), blurRadius: 12, offset: Offset(0, -2))],
  );

  // ==================== ThemeExtension ====================
  @override
  AppColors copyWith({
    Color? primary, Color? primaryLight, Color? primaryDark, Color? primarySurface,
    Color? background, Color? surface, Color? surfaceSecondary,
    Color? textPrimary, Color? textSecondary, Color? textTertiary, Color? textHint, Color? textOnPrimary,
    Color? separator, Color? separatorOpaque,
    Color? success, Color? warning, Color? error, Color? income, Color? expense,
    Color? categoryFood, Color? categoryTransport, Color? categoryShopping,
    Color? categoryHousing, Color? categoryEntertainment, Color? categoryEducation,
    Color? categoryMedical, Color? categorySocial, Color? categoryOther,
    Color? categoryFoodBg, Color? categoryTransportBg, Color? categoryShoppingBg,
    Color? categoryHousingBg, Color? categoryEntertainmentBg, Color? categoryEducationBg,
    Color? categoryMedicalBg, Color? categorySocialBg, Color? categoryOtherBg,
    LinearGradient? aiEntryGradient, List<BoxShadow>? cardShadow, List<BoxShadow>? floatingShadow,
  }) {
    return AppColors(
      primary: primary ?? this.primary, primaryLight: primaryLight ?? this.primaryLight,
      primaryDark: primaryDark ?? this.primaryDark, primarySurface: primarySurface ?? this.primarySurface,
      background: background ?? this.background, surface: surface ?? this.surface,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      textPrimary: textPrimary ?? this.textPrimary, textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary, textHint: textHint ?? this.textHint,
      textOnPrimary: textOnPrimary ?? this.textOnPrimary,
      separator: separator ?? this.separator, separatorOpaque: separatorOpaque ?? this.separatorOpaque,
      success: success ?? this.success, warning: warning ?? this.warning,
      error: error ?? this.error, income: income ?? this.income, expense: expense ?? this.expense,
      categoryFood: categoryFood ?? this.categoryFood, categoryTransport: categoryTransport ?? this.categoryTransport,
      categoryShopping: categoryShopping ?? this.categoryShopping, categoryHousing: categoryHousing ?? this.categoryHousing,
      categoryEntertainment: categoryEntertainment ?? this.categoryEntertainment, categoryEducation: categoryEducation ?? this.categoryEducation,
      categoryMedical: categoryMedical ?? this.categoryMedical, categorySocial: categorySocial ?? this.categorySocial,
      categoryOther: categoryOther ?? this.categoryOther,
      categoryFoodBg: categoryFoodBg ?? this.categoryFoodBg, categoryTransportBg: categoryTransportBg ?? this.categoryTransportBg,
      categoryShoppingBg: categoryShoppingBg ?? this.categoryShoppingBg, categoryHousingBg: categoryHousingBg ?? this.categoryHousingBg,
      categoryEntertainmentBg: categoryEntertainmentBg ?? this.categoryEntertainmentBg, categoryEducationBg: categoryEducationBg ?? this.categoryEducationBg,
      categoryMedicalBg: categoryMedicalBg ?? this.categoryMedicalBg, categorySocialBg: categorySocialBg ?? this.categorySocialBg,
      categoryOtherBg: categoryOtherBg ?? this.categoryOtherBg,
      aiEntryGradient: aiEntryGradient ?? this.aiEntryGradient,
      cardShadow: cardShadow ?? this.cardShadow, floatingShadow: floatingShadow ?? this.floatingShadow,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primarySurface: Color.lerp(primarySurface, other.primarySurface, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSecondary: Color.lerp(surfaceSecondary, other.surfaceSecondary, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      textOnPrimary: Color.lerp(textOnPrimary, other.textOnPrimary, t)!,
      separator: Color.lerp(separator, other.separator, t)!,
      separatorOpaque: Color.lerp(separatorOpaque, other.separatorOpaque, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      categoryFood: Color.lerp(categoryFood, other.categoryFood, t)!,
      categoryTransport: Color.lerp(categoryTransport, other.categoryTransport, t)!,
      categoryShopping: Color.lerp(categoryShopping, other.categoryShopping, t)!,
      categoryHousing: Color.lerp(categoryHousing, other.categoryHousing, t)!,
      categoryEntertainment: Color.lerp(categoryEntertainment, other.categoryEntertainment, t)!,
      categoryEducation: Color.lerp(categoryEducation, other.categoryEducation, t)!,
      categoryMedical: Color.lerp(categoryMedical, other.categoryMedical, t)!,
      categorySocial: Color.lerp(categorySocial, other.categorySocial, t)!,
      categoryOther: Color.lerp(categoryOther, other.categoryOther, t)!,
      categoryFoodBg: Color.lerp(categoryFoodBg, other.categoryFoodBg, t)!,
      categoryTransportBg: Color.lerp(categoryTransportBg, other.categoryTransportBg, t)!,
      categoryShoppingBg: Color.lerp(categoryShoppingBg, other.categoryShoppingBg, t)!,
      categoryHousingBg: Color.lerp(categoryHousingBg, other.categoryHousingBg, t)!,
      categoryEntertainmentBg: Color.lerp(categoryEntertainmentBg, other.categoryEntertainmentBg, t)!,
      categoryEducationBg: Color.lerp(categoryEducationBg, other.categoryEducationBg, t)!,
      categoryMedicalBg: Color.lerp(categoryMedicalBg, other.categoryMedicalBg, t)!,
      categorySocialBg: Color.lerp(categorySocialBg, other.categorySocialBg, t)!,
      categoryOtherBg: Color.lerp(categoryOtherBg, other.categoryOtherBg, t)!,
      aiEntryGradient: aiEntryGradient,
      cardShadow: cardShadow, floatingShadow: floatingShadow,
    );
  }
}

/// BuildContext 扩展 — `context.colors.primary`
extension AppColorsExtension on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
