import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Senior Flutter theme context extension.
/// Provides reactive, semantic getters for typography and container surfaces across themes.
extension AppThemeContext on BuildContext {
  /// Whether dark / midnight theme is currently active.
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Ambient ThemeData.
  ThemeData get theme => Theme.of(this);

  /// Ambient ColorScheme.
  ColorScheme get colorScheme => theme.colorScheme;

  /// Ambient TextTheme.
  TextTheme get textTheme => theme.textTheme;

  /// High-contrast primary text color:
  /// Pure/Off-White (#F8FAFC) in Midnight dark mode, Navy/Dark Slate (#1F2937) in Light mode.
  Color get textPrimary => isDark ? AppColors.midnightTextPrimary : AppColors.secondary;

  /// Medium-contrast secondary text color:
  /// Muted Slate (#94A3B8) in Midnight dark mode, Mid Slate (#4B5563) in Light mode.
  Color get textSecondary => isDark ? AppColors.midnightTextMuted : AppColors.tertiary;

  /// Low-contrast muted / caption text color.
  Color get textMuted => isDark ? AppColors.midnightTextMuted : AppColors.textMuted;

  /// Elevated surface/card container background color.
  Color get cardBackground => isDark ? AppColors.midnightSurface : AppColors.surface;

  /// Card container border color.
  Color get cardBorder => isDark ? AppColors.midnightBorder : AppColors.borderLight;

  /// Input container background fill.
  Color get inputFill => isDark ? AppColors.midnightBackground : AppColors.profileInputFill;

  /// Input container border.
  Color get inputBorder => isDark ? AppColors.midnightBorder : AppColors.profileInputBorder;

  /// Subtle divider line color.
  Color get dividerColor => isDark ? AppColors.midnightBorder : AppColors.divider;

  // Context-aware typography getters
  TextStyle get displayLarge => AppTypography.displayLarge.copyWith(color: textPrimary);
  TextStyle get displayMedium => AppTypography.displayMedium.copyWith(color: textPrimary);
  TextStyle get displaySmall => AppTypography.displaySmall.copyWith(color: textPrimary);
  TextStyle get headlineLarge => AppTypography.headlineLarge.copyWith(color: textPrimary);
  TextStyle get headlineMedium => AppTypography.headlineMedium.copyWith(color: textPrimary);
  TextStyle get headlineSmall => AppTypography.headlineSmall.copyWith(color: textPrimary);
  TextStyle get titleLarge => AppTypography.titleLarge.copyWith(color: textPrimary);
  TextStyle get titleMedium => AppTypography.titleMedium.copyWith(color: textPrimary);
  TextStyle get titleSmall => AppTypography.titleSmall.copyWith(color: textPrimary);
  TextStyle get bodyLarge => AppTypography.bodyLarge.copyWith(color: textPrimary);
  TextStyle get bodyMedium => AppTypography.bodyMedium.copyWith(color: textSecondary);
  TextStyle get bodySmall => AppTypography.bodySmall.copyWith(color: textSecondary);
  TextStyle get labelLarge => AppTypography.labelLarge.copyWith(color: textPrimary);
  TextStyle get labelMedium => AppTypography.labelMedium.copyWith(color: textSecondary);
  TextStyle get labelSmall => AppTypography.labelSmall.copyWith(color: textSecondary);
  TextStyle get metricValue => AppTypography.metricValue.copyWith(color: textPrimary);
  TextStyle get scoreHuge => AppTypography.scoreHuge.copyWith(color: textPrimary);
}
