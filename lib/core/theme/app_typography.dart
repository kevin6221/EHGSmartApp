import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// App typography system strictly mapped to Figma Brand Guide (Node 2:575).
///
/// Hierarchy Rules:
/// - **Headline**: Funnel Display (for display, headlines, screen titles)
/// - **Body**: Plus Jakarta Sans (for descriptions, reading copy, details)
/// - **Label**: Plus Jakarta Sans (for button labels, badges, captions, microcopy)
class AppTypography {
  AppTypography._();

  // ===========================================================================
  // 1. Headline Family: Funnel Display (Figma Node 2:575)
  // ===========================================================================
  static TextStyle get displayLarge => GoogleFonts.plusJakartaSans(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.secondary,
    letterSpacing: -0.5,
  );

  static TextStyle get displayMedium => GoogleFonts.plusJakartaSans(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.secondary,
    letterSpacing: -0.3,
  );

  static TextStyle get displaySmall => GoogleFonts.plusJakartaSans(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.secondary,
    letterSpacing: -0.2,
  );

  static TextStyle get headlineLarge => GoogleFonts.plusJakartaSans(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.secondary,
  );

  static TextStyle get headlineMedium => GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.secondary,
  );

  static TextStyle get headlineSmall => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.secondary,
  );

  // ===========================================================================
  // 2. Titles & Subtitles (Plus Jakarta Sans)
  // ===========================================================================
  static TextStyle get titleLarge => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.secondary,
  );

  static TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.secondary,
  );

  static TextStyle get titleSmall => GoogleFonts.plusJakartaSans(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.secondary,
  );

  // ===========================================================================
  // 3. Body Family: Plus Jakarta Sans (Figma Node 2:575)
  // ===========================================================================
  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.tertiary,
    height: 1.4,
  );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.tertiary,
    height: 1.35,
  );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  // ===========================================================================
  // 4. Label Family: Plus Jakarta Sans (Figma Node 2:575)
  // ===========================================================================
  static TextStyle get labelLarge => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.secondary,
  );

  static TextStyle get labelMedium => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.tertiary,
  );

  static TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
  );

  static TextStyle get buttonText => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    letterSpacing: -0.11,
  );

  // ===========================================================================
  // 5. Special Metric Numbers
  // ===========================================================================
  static TextStyle get scoreHuge => GoogleFonts.plusJakartaSans(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  static TextStyle get metricValue => GoogleFonts.plusJakartaSans(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.secondary,
  );
}
