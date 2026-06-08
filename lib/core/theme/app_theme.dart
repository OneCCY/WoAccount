import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// WoAccount 主题定义
/// 浅色/深色主题均完整定义
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return _buildTheme(Brightness.light);
  }

  static ThemeData get darkTheme {
    return _buildTheme(Brightness.dark);
  }

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    // 深色模式使用不同的颜色值
    final primary = isDark ? const Color(0xFF66BB6A) : AppColors.primary;
    final surface = isDark ? const Color(0xFF1E1E1E) : AppColors.surface;
    final surfaceSecondary = isDark ? const Color(0xFF2C2C2C) : AppColors.surfaceSecondary;
    final background = isDark ? const Color(0xFF121212) : AppColors.background;
    final textPrimary = isDark ? const Color(0xFFE0E0E0) : AppColors.textPrimary;
    final textSecondary = isDark ? const Color(0xFFAAAAAA) : AppColors.textSecondary;
    final textTertiary = isDark ? const Color(0xFF757575) : AppColors.textTertiary;
    final textHint = isDark ? const Color(0xFF555555) : AppColors.textHint;
    final separatorOpaque = isDark ? const Color(0xFF2A2A2A) : AppColors.separatorOpaque;
    final error = isDark ? const Color(0xFFEF5350) : AppColors.error;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,

      // 色彩方案
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: brightness,
        primary: primary,
        surface: surface,
        error: error,
      ),

      // 背景色
      scaffoldBackgroundColor: background,

      // AppBar 主题
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.h3.copyWith(color: textPrimary),
        iconTheme: IconThemeData(color: textPrimary),
      ),

      // 卡片主题
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: AppTextStyles.body.copyWith(color: textHint),
      ),

      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.h3,
        ),
      ),

      // 文字按钮
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
        ),
      ),

      // OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary),
        ),
      ),

      // 底部导航栏
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // 分割线
      dividerTheme: DividerThemeData(
        color: separatorOpaque,
        thickness: 0.5,
        space: 0,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary.withValues(alpha: 0.3);
          }
          return null;
        }),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        titleTextStyle: AppTextStyles.h3.copyWith(color: textPrimary),
        contentTextStyle: AppTextStyles.body.copyWith(color: textSecondary),
      ),

      // BottomSheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        modalBackgroundColor: surface,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? surfaceSecondary : textPrimary,
        contentTextStyle: AppTextStyles.body.copyWith(
          color: isDark ? textPrimary : surface,
        ),
      ),

      // ListTile
      listTileTheme: ListTileThemeData(
        tileColor: surface,
        textColor: textPrimary,
        iconColor: textTertiary,
      ),
    );
  }
}
