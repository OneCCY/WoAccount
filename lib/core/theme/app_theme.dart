import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// WoAccount 主题定义
/// 浅色/深色主题均完整定义，注册 AppColors ThemeExtension
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final colors = AppColors.light();
    return _buildTheme(colors, Brightness.light);
  }

  static ThemeData get darkTheme {
    final colors = AppColors.dark();
    return _buildTheme(colors, Brightness.dark);
  }

  static ThemeData _buildTheme(AppColors colors, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      extensions: [colors],

      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        brightness: brightness,
        primary: colors.primary,
        surface: colors.surface,
        error: colors.error,
      ),

      scaffoldBackgroundColor: colors.background,

      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.h3.copyWith(color: colors.textPrimary),
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),

      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: AppTextStyles.body.copyWith(color: colors.textHint),
      ),

      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: AppTextStyles.body.copyWith(color: colors.textPrimary),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTextStyles.h3,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colors.primary),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.primary),
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      dividerTheme: DividerThemeData(
        color: colors.separatorOpaque,
        thickness: 0.5,
        space: 0,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colors.primary;
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary.withValues(alpha: 0.3);
          }
          return null;
        }),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        titleTextStyle: AppTextStyles.h3.copyWith(color: colors.textPrimary),
        contentTextStyle: AppTextStyles.body.copyWith(color: colors.textSecondary),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        modalBackgroundColor: colors.surface,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? colors.surfaceSecondary : colors.textPrimary,
        contentTextStyle: AppTextStyles.body.copyWith(
          color: isDark ? colors.textPrimary : colors.surface,
        ),
      ),

      listTileTheme: ListTileThemeData(
        tileColor: colors.surface,
        textColor: colors.textPrimary,
        iconColor: colors.textTertiary,
      ),
    );
  }
}
