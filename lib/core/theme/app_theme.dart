import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_typography.dart';
export 'app_theme_extensions.dart';

/// Centralized application theme strictly aligned with Figma Brand Guide (Node 2:575).
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        surface: AppColors.surface,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.secondary,
        error: AppColors.stress,
        outline: AppColors.border,
      ),
      textTheme: TextTheme(
        // Headline Family: Funnel Display (Node 2:575)
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        displaySmall: AppTypography.displaySmall,
        headlineLarge: AppTypography.headlineLarge,
        headlineMedium: AppTypography.headlineMedium,
        headlineSmall: AppTypography.headlineSmall,

        // Label / Title Family: Plus Jakarta Sans (Node 2:575)
        titleLarge: AppTypography.titleLarge,
        titleMedium: AppTypography.titleMedium,
        titleSmall: AppTypography.titleSmall,

        // Body Family: Plus Jakarta Sans (Node 2:575)
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,

        // Label Family: Plus Jakarta Sans (Node 2:575)
        labelLarge: AppTypography.labelLarge,
        labelMedium: AppTypography.labelMedium,
        labelSmall: AppTypography.labelSmall,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textMuted,
        ),
        prefixIconColor: AppColors.tertiary,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.midnightBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.white,
        tertiary: AppColors.midnightTextMuted,
        surface: AppColors.midnightSurface,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.midnightTextPrimary,
        error: AppColors.stress,
        outline: AppColors.midnightBorder,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(color: AppColors.midnightTextPrimary),
        displayMedium: AppTypography.displayMedium.copyWith(color: AppColors.midnightTextPrimary),
        displaySmall: AppTypography.displaySmall.copyWith(color: AppColors.midnightTextPrimary),
        headlineLarge: AppTypography.headlineLarge.copyWith(color: AppColors.midnightTextPrimary),
        headlineMedium: AppTypography.headlineMedium.copyWith(color: AppColors.midnightTextPrimary),
        headlineSmall: AppTypography.headlineSmall.copyWith(color: AppColors.midnightTextPrimary),
        titleLarge: AppTypography.titleLarge.copyWith(color: AppColors.midnightTextPrimary),
        titleMedium: AppTypography.titleMedium.copyWith(color: AppColors.midnightTextPrimary),
        titleSmall: AppTypography.titleSmall.copyWith(color: AppColors.midnightTextPrimary),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.midnightTextPrimary),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.midnightTextMuted),
        bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.midnightTextMuted),
        labelLarge: AppTypography.labelLarge.copyWith(color: AppColors.midnightTextPrimary),
        labelMedium: AppTypography.labelMedium.copyWith(color: AppColors.midnightTextMuted),
        labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.midnightTextMuted),
      ),
      cardTheme: CardThemeData(
        color: AppColors.midnightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.midnightBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.midnightBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.midnightTextMuted,
        ),
        prefixIconColor: AppColors.midnightTextMuted,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.midnightBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.midnightBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.midnightBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
