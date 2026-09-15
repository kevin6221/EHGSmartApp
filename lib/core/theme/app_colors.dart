import 'package:flutter/material.dart';

/// App color palette strictly aligned with the Figma Brand Guide (Node 2:575)
/// and all centralized app screens and components.
class AppColors {
  AppColors._();

  // ===========================================================================
  // 1. Universal Base Swatches
  // ===========================================================================
  /// Pure white (#FFFFFF) used for card backgrounds, buttons, and light text.
  static const Color white = Color(0xFFFFFFFF);

  /// Brand surface pure white (#FFFFFF), semantic alias for [white].
  static const Color surface = Color(0xFFFFFFFF);

  /// 70% white (#B3FFFFFF) used for secondary overlay labels.
  static const Color white70 = Color(0xB3FFFFFF);

  /// Pure black (#000000) used for base shadows, overlays, and contrast.
  static const Color black = Color(0xFF000000);

  /// Completely transparent color (#00000000).
  static const Color transparent = Color(0x00000000);

  // ===========================================================================
  // 2. Brand Guide Core Swatches (Figma Node 2:575)
  // ===========================================================================
  /// Core brand primary blue (#3E83C8) used for CTAs, active states, progress.
  static const Color primary = Color(0xFF3E83C8);

  /// Brand secondary dark slate (#1F2937) used for headlines, inverted buttons.
  static const Color secondary = Color(0xFF1F2937);

  /// Brand tertiary mid slate (#4B5563) used for body copy, secondary text, muted indicators.
  static const Color tertiary = Color(0xFF4B5563);

  /// Brand background light slate (#F8FAFC) used for page scaffold, subtle card fills.
  static const Color background = Color(0xFFF8FAFC);

  // ===========================================================================
  // 3. Primary & Accent Tonal Variations
  // ===========================================================================
  static const Color primaryDark = Color(0xFF1E60A8);
  static const Color primaryLight = Color(0xFFEBF3FB);
  static const Color primaryCyan = Color(0xFF00D2FF);

  /// Vivid Sky Blue (#0072CE) used in membership banner and hydration metrics.
  static const Color primarySky = Color(0xFF0072CE);

  /// Sky header top tone (#5A9FE6) for the screen header banner.
  static const Color primarySkyLight = Color(0xFF5A9FE6);

  /// Sky Blue Accent (#1BB6E3) used in wellness chevron.
  static const Color primarySkyAccent = Color(0xFF1BB6E3);

  /// Electric Blue (#1E93EF) used for button glow and elevated accents.
  static const Color primaryElectric = Color(0xFF1E93EF);

  /// Bright Cyan (#01D5F1) used in active bottom nav indicator & badges.
  static const Color cyanActive = Color(0xFF01D5F1);

  /// Vibrant Cyan Accent (#0EA5E9) used in energy icons and trend markers.
  static const Color cyanAccent = Color(0xFF0EA5E9);

  /// Vibrant Stress Cyan (#00D5F1) used in Vitals stress chart (Figma Node 71:1042).
  static const Color stressCyan = Color(0xFF00D5F1);

  /// Primary gradient blue start tone (#0067B8).
  static const Color primaryGradientStart = Color(0xFF0067B8);

  /// Primary gradient cyan mid tone (#00AEDE).
  static const Color primaryGradientMid = Color(0xFF00AEDE);

  /// Primary gradient cyan bright end tone (#00F1FE).
  static const Color primaryGradientEnd = Color(0xFF00F1FE);

  /// Soft Cyan Tone (#1CB6E3) used in Mind pillar metrics and concentric rings.
  static const Color cyanLight = Color(0xFF1CB6E3);

  // ===========================================================================
  // 4. Wellness Card & 4 Pillars (Figma Node 60:289)
  // ===========================================================================
  /// Move Pillar Indigo-Blue (#3E50C8).
  static const Color movePillar = Color(0xFF3E50C8);

  /// Recover Pillar Blue (#3E83C8, primary brand blue).
  static const Color recoverPillar = Color(0xFF3E83C8);

  /// Mind Pillar Cyan (#1CB6E3).
  static const Color mindPillar = Color(0xFF1CB6E3);

  /// Fuel Pillar Royal Purple (#861CE3).
  static const Color fuelPillar = Color(0xFF861CE3);

  /// Wellness card gradient starting soft blue (#B5D7F2).
  static const Color wellnessCardGradientStart = Color(0xFFB5D7F2);

  /// Wellness card gradient mid pale cyan (#EFFCFF).
  static const Color wellnessCardGradientMid = Color(0xFFEFFCFF);

  /// Onboarding card gradient mid tone (#D6EEF5).
  static const Color onboardingCardGradientMid = Color(0xFFD6EEF5);

  /// Score trend down indicator red (#FF383C).
  static const Color scoreDownRed = Color(0xFFFF383C);

  /// Muted slate dot for wave chart time axes (#94A3B8).
  static const Color chartDotMuted = Color(0xFF94A3B8);

  // ===========================================================================
  // 5. Readiness Card & Sub-Metric Badges (Figma Node 118:917)
  // ===========================================================================
  static const Color readinessSleep = Color(0xFF1259A8);
  static const Color readinessHrv = Color(0xFF0284C7);
  static const Color readinessRest = Color(0xFF16A34A);
  static const Color readinessStress = Color(0xFFBE123C);

  /// Soft blue badge background for Readiness card (#EBF4FE).
  static const Color readinessBadgeBg = Color(0xFFEBF4FE);

  /// Sub-metric tile soft blue background for Sleep (#DBEAFE).
  static const Color tileSleepBg = Color(0xFFDBEAFE);

  /// Sub-metric tile soft cyan/sky background for HRV (#E0F2FE).
  static const Color tileHrvBg = Color(0xFFE0F2FE);

  /// Sub-metric tile soft blue background (#DBEAFE).
  static const Color tileBlueBg = Color(0xFFDBEAFE);

  /// Sub-metric tile soft green background (#DCFCE7).
  static const Color tileGreenBg = Color(0xFFDCFCE7);

  /// Sub-metric tile soft rose background (#FFE4E6).
  static const Color tileRoseBg = Color(0xFFFFE4E6);

  /// Training recent session purple tile background (#FAF5FF).
  static const Color tilePurpleBg = Color(0xFFFAF5FF);

  // ===========================================================================
  // 6. Hydration & Energy Metrics
  // ===========================================================================
  /// Hydration progress bar track background (#E2F0FD).
  static const Color hydrationTrack = Color(0xFFE2F0FD);

  /// Energy progress bar track background (#E0F7FA).
  static const Color energyTrack = Color(0xFFE0F7FA);

  /// Energy burned gradient start (#00F2FE).
  static const Color energyGradientStart = Color(0xFF00F2FE);

  /// Energy burned gradient end (#4FACFE).
  static const Color energyGradientEnd = Color(0xFF4FACFE);

  /// Hydration capsule bar middle tier (#60A5FA).
  static const Color hydrationMiddle = Color(0xFF60A5FA);

  /// Hydration capsule bar light tier (#DBEAFE).
  static const Color hydrationLight = Color(0xFFDBEAFE);

  /// Energy capsule bar middle tier (#99F7FE).
  static const Color energyMiddle = Color(0xFF99F7FE);

  /// Energy capsule bar light tier (#DBF9FE).
  static const Color energyLight = Color(0xFFDBF9FE);

  // ===========================================================================
  // 7. Hypnogram Chart & Sleep Stages
  // ===========================================================================
  static const Color hypnogramDeep = Color(0xFF1E60C8);
  static const Color hypnogramLight = Color(0xFF38BDF8);
  static const Color hypnogramRem = Color(0xFF4ADE80);
  static const Color hypnogramAwake = Color(0xFFF43F5E);

  /// Hypnogram dark tooltip background slate (#334155).
  static const Color chartDarkBg = Color(0xFF334155);

  // ===========================================================================
  // 8. General Health Metrics & Status Indicators
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
  // 9. Input & Component Backgrounds
  // ===========================================================================
  /// Input field filled background (#EFF3FF).
  static const Color inputFilledBackground = Color(0xFFEFF3FF);

  /// Segmented pill bar container background (#F1F5F9).
  static const Color pillBarBg = Color(0xFFF1F5F9);

  /// Weight selector unselected item background (#F3F4F6).
  static const Color weightSelectorBg = Color(0xFFF3F4F6);

  /// Workout card inner subtle container (#F9FAFB).
  static const Color workoutCardBg = Color(0xFFF9FAFB);

  /// Loader circular track background (#33FFFFFF).
  static const Color loaderTrack = Color(0x33FFFFFF);

  /// Device pairing card track border (#CBD5E1).
  static const Color deviceTrackBorder = Color(0xFFCBD5E1);

  /// Connected device status indicator green (#10B981).
  static const Color deviceConnectedGreen = Color(0xFF10B981);

  // ===========================================================================
  // 10. Dividers and Borders
  // ===========================================================================
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
  static const Color divider = Color(0xFFE2E8F0);

  /// Navigation bar border (#E2E8F0).
  static const Color navBorder = Color(0xFFE2E8F0);

  /// Vitals expanded card divider line (#3E83C8 at 15% opacity matching Figma Node 119:1756 Line 11).
  static final Color vitalsDivider = primary.withValues(alpha: 0.15);

  /// Vitals 'Do this' callout banner border (25% opacity primary gradient start).
  static final Color vitalsCalloutBorder = primaryGradientStart.withValues(alpha: 0.25);

  /// Vitals 'Do this' callout banner subtext light tone (#F8FAFC).
  static const Color vitalsCalloutSubtext = Color(0xFFF8FAFC);

  // ===========================================================================
  // 11. Surface Variants
  // ===========================================================================
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color surfaceSubtle = Color(0xFFF8F9FA);

  // ===========================================================================
  // 12. Typography Semantic Roles (Strictly mapped to Brand Guide)
  // ===========================================================================
  static const Color textPrimary = secondary; // #1F2937
  static const Color textSecondary = tertiary; // #4B5563
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textLight = white;

  // ===========================================================================
  // 13. Brand Button Tokens (Figma Node 2:575)
  // ===========================================================================
  static const Color buttonPrimaryBg = primary;
  static const Color buttonPrimaryText = white;

  static const Color buttonSecondaryBg = white;
  static const Color buttonSecondaryText = secondary;

  static const Color buttonInvertedBg = secondary;
  static const Color buttonInvertedText = white;

  static const Color buttonOutlinedBorder = primary;
  static const Color buttonOutlinedText = primary;

  // ===========================================================================
  // 14. Shadow Base Colors & Translucencies
  // ===========================================================================
  /// Base deep navy for subtle card shadows (#0F172A).
  static const Color shadowNavy = Color(0xFF0F172A);

  /// Primary sky glow for bottom navigation active item (40% opacity #0072CE).
  static const Color navActiveGlow = Color(0x400072CE);

  /// Default subtle card shadow.
  static final Color cardShadow = const Color(0xFF0F172A).withValues(alpha: 0.04);

  /// Floating nav bar shadow.
  static final Color floatingNavShadow = const Color(0xFF0F172A).withValues(alpha: 0.08);

  // ===========================================================================
  // 15. Centralized Gradients
  // ===========================================================================
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGradientStart, primaryGradientMid, primaryGradientEnd],
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

  static const LinearGradient screenHeaderGradient = LinearGradient(
    colors: [primarySkyLight, background],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardHeaderGradient = LinearGradient(
    colors: [Color(0xFFEBF4FD), white],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Wellness card top diagonal gradient (Figma Node 118:917 / 60:289).
  static const LinearGradient wellnessCardGradient = LinearGradient(
    colors: [wellnessCardGradientStart, wellnessCardGradientMid, white],
    stops: [0.0, 0.40, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Expanded vitals metric card background start tone (#DCEDFC).
  static const Color vitalsExpandedBgStart = Color(0xFFDCEDFC);

  /// Expanded vitals metric card background mid tone (#EFFBFF).
  static const Color vitalsExpandedBgMid = Color(0xFFEFFBFF);

  /// Expanded vitals metric card diagonal gradient (Figma Node 119:1442).
  static const LinearGradient vitalsExpandedCardGradient = LinearGradient(
    colors: [
      vitalsExpandedBgStart,
      vitalsExpandedBgMid,
      white,
    ],
    stops: [0.0, 0.545, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Sleep summary icon radial gradient (Figma Node 73:1319 / 119:1477).
  static const RadialGradient vitalsSleepIconGradient = RadialGradient(
    colors: [cyanActive, primary],
    center: Alignment.center,
    radius: 0.75,
  );

  /// Onboarding plan card gradient (Figma Node 120:1785).
  static const LinearGradient onboardingCardGradient = LinearGradient(
    colors: [wellnessCardGradientStart, onboardingCardGradientMid, white],
    stops: [0.0, 0.40, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Bottom Navigation Active Indicator Radial Gradient (Figma Ellipse 7).
  static const RadialGradient activeNavCircleGradient = RadialGradient(
    colors: [cyanActive, primary],
    center: Alignment.center,
    radius: 0.85,
  );

  /// Active plan badge gradient (Figma Node 120:1785).
  static const LinearGradient planBadgeGradient = LinearGradient(
    colors: [cyanActive, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Energy burned vertical capsule chart gradient.
  static const LinearGradient energyBurnedGradient = LinearGradient(
    colors: [energyGradientStart, energyGradientEnd],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  // ===========================================================================
  // 12. Training Screen (Figma Node 75:2261)
  // ===========================================================================
  /// Train Runner Icon Circle Background (#F3F9FF)
  static const Color trainRunnerBg = Color(0xFFF3F9FF);

  /// Train Weight Selected Background (#EFF3FF)
  static const Color trainWeightSelectedBg = Color(0xFFEFF3FF);

  /// Train Weight Unselected Background (#F8FAFC)
  static const Color trainWeightUnselectedBg = Color(0xFFF8FAFC);

  /// Train Stat 1 (Time) Gradient Start - rich cyan/blue shader (#CEEEFA)
  static const Color trainStatTimeStart = Color(0xFFCEEEFA);

  /// Train Stat 1 (Time) Gradient End (#F7FDFF)
  static const Color trainStatTimeEnd = Color(0xFFF7FDFF);

  /// Train Stat 1 (Time) Subtle Border (#BCE3FB)
  static const Color trainStatTimeBorder = Color(0xFFBCE3FB);

  /// Train Stat 2 (Peak) Gradient Start - rich mint-green shader (#CEF7E4)
  static const Color trainStatPeakStart = Color(0xFFCEF7E4);

  /// Train Stat 2 (Peak) Gradient End (#F3FFF8)
  static const Color trainStatPeakEnd = Color(0xFFF3FFF8);

  /// Train Stat 2 (Peak) Subtle Border (#B9F6DD)
  static const Color trainStatPeakBorder = Color(0xFFB9F6DD);

  /// Train Stat 3 (Avg) Gradient Start - rich lavender-purple shader (#DCD2FB)
  static const Color trainStatAvgStart = Color(0xFFDCD2FB);

  /// Train Stat 3 (Avg) Gradient End (#F5F1FF)
  static const Color trainStatAvgEnd = Color(0xFFF5F1FF);

  /// Train Stat 3 (Avg) Subtle Border (#D3C7FC)
  static const Color trainStatAvgBorder = Color(0xFFD3C7FC);

  /// Train Play Button Radial Gradient (Figma Node 75:2593)
  static const RadialGradient trainPlayGradient = RadialGradient(
    colors: [cyanActive, primary],
    center: Alignment(0.39, 0.30),
    radius: 0.85,
  );

  /// Train Stat 1 (Time) Gradient (Figma Group 1376157569)
  static const LinearGradient trainStatTimeGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [trainStatTimeStart, trainStatTimeEnd],
  );

  /// Train Stat 2 (Peak) Gradient (Figma Group 1376157568)
  static const LinearGradient trainStatPeakGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [trainStatPeakStart, trainStatPeakEnd],
  );

  /// Train Stat 3 (Avg) Gradient (Figma Group 1376157570)
  static const LinearGradient trainStatAvgGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [trainStatAvgStart, trainStatAvgEnd],
  );

  // ===========================================================================
  // 13. Profile Screen (Figma Node 75:2756)
  // ===========================================================================
  /// Soft blue-tinted input fill background (#EFF3FF)
  static const Color profileInputFill = Color(0xFFEFF3FF);

  /// Profile text input & selector container border (#3E83C8 at 50% opacity, Figma strokeWeight 0.5)
  static const Color profileInputBorder = Color(0x803E83C8);

  /// Subtle divider line color (#7B7B7B with 20% opacity)
  static const Color profileDivider = Color(0x337B7B7B);

  /// Profile data deletion action red (#FF383C)
  static const Color profileDeleteRed = Color(0xFFFF383C);

  /// Circular badge radial gradient for Lock & Band (#01D5F1 -> #3E83C8)
  static const RadialGradient profileBadgeRadial = RadialGradient(
    colors: [cyanActive, primary],
    center: Alignment(0.39, 0.30),
    radius: 0.85,
  );

  /// Profile switch inactive border (Figma Rectangle 136, stroke 0.5px #4B5563 at 30% opacity)
  static const Color profileSwitchBorder = Color(0x4D4B5563);

  /// Profile switch inactive thumb (Figma Ellipse 251, #4B5563 at 40% opacity = #B7BBC1)
  static const Color profileSwitchThumbInactive = Color(0xFFB7BBC1);
}
