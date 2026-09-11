import 'package:flutter/material.dart';

/// App color palette strictly aligned with the Figma Brand Guide (Node 2:575).
class AppColors {
  AppColors._();

  // ===========================================================================
  // 1. Brand Guide Core Swatches (Figma Node 2:575)
  // ===========================================================================
  /// Core brand primary blue (#3E83C8) used for CTAs, active states, progress.
  static const Color primary = Color(0xFF3E83C8);

  /// Brand secondary dark slate (#1F2937) used for headlines, inverted buttons.
  static const Color secondary = Color(0xFF1F2937);

  /// Brand tertiary mid slate (#4B5563) used for body copy, secondary text, muted indicators.
  static const Color tertiary = Color(0xFF4B5563);

  /// Brand background light slate (#F8FAFC) used for page scaffold, subtle card fills.
  static const Color background = Color(0xFFF8FAFC);

  /// Brand surface pure white (#FFFFFF) used for card backgrounds, secondary buttons.
  static const Color surface = Color(0xFFFFFFFF);

  /// Alias for pure white (#FFFFFF).
  static const Color white = Color(0xFFFFFFFF);

  // ===========================================================================
  // 2. Primary Tonal Variations
  // ===========================================================================
  static const Color primaryDark = Color(0xFF1E60A8);
  static const Color primaryLight = Color(0xFFEBF3FB);
  static const Color primaryCyan = Color(0xFF00D2FF);

  // ===========================================================================
  // 3. Brand Button Tokens (Figma Node 2:575)
  // ===========================================================================
  static const Color buttonPrimaryBg = primary;
  static const Color buttonPrimaryText = white;

  static const Color buttonSecondaryBg = white;
  static const Color buttonSecondaryText = secondary;

  static const Color buttonInvertedBg = secondary;
  static const Color buttonInvertedText = white;

  static const Color buttonOutlinedBorder = primary;
  static const Color buttonOutlinedText = primary;

  static const Color inputFilledBackground = Color(0xFFEFF3FF);

  // ===========================================================================
  // 4. Gradient Definitions
  // ===========================================================================
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0067B8), Color(0xFF00AEDE), Color(0xFF00F1FE)],
    stops: [0.0, 0.545, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Disabled primary gradient (10% opacity primary gradient matching Figma Node 16:4201).
  static const LinearGradient disabledPrimaryGradient = LinearGradient(
    colors: [Color(0x1A0067B8), Color(0x1A00AEDE), Color(0x1A00F1FE)],
    stops: [0.0, 0.545, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient skyHeaderGradient = LinearGradient(
    colors: [Color(0xFF4A90E2), Color(0xFFF8FAFC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.45],
  );

  static const LinearGradient cardHeaderGradient = LinearGradient(
    colors: [Color(0xFFEBF4FD), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ===========================================================================
  // 5. Surface Variants
  // ===========================================================================
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color surfaceSubtle = Color(0xFFF8F9FA);

  // ===========================================================================
  // 6. Typography Semantic Roles (Strictly mapped to Brand Guide)
  // ===========================================================================
  static const Color textPrimary = secondary; // #1F2937
  static const Color textSecondary = tertiary; // #4B5563
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textLight = white;

  // ===========================================================================
  // 7. Health Metrics & Status Indicators
  // ===========================================================================
  static const Color sleep = Color(0xFF2563EB);
  static const Color hrv = Color(0xFF38BDF8);
  static const Color rest = Color(0xFF4ADE80);
  static const Color stress = Color(0xFFF43F5E);
  static const Color hydration = Color(0xFF3B82F6);
  static const Color energy = Color(0xFF06B6D4);
  static const Color orangeMetric = Color(0xFFF97316);
  static const Color greenMetric = Color(0xFF22C55E);
  static const Color purpleMetric = Color(0xFF8B5CF6);

  // ===========================================================================
  // 8. Dividers and Borders
  // ===========================================================================
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
  static const Color divider = Color(0xFFE2E8F0);

  // ===========================================================================
  // 9. Shadows
  // ===========================================================================
  static final Color cardShadow = const Color(0xFF0F172A)
      .withValues(alpha: 0.04);
  static final Color floatingNavShadow = const Color(0xFF0F172A)
      .withValues(alpha: 0.08);
}
