import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Centralized app gradients palette aligned with Figma Brand Guide (Node 2:575)
/// and all screen components across the EHG Smart Wellness App.
class AppGradients {
  AppGradients._();

  // ===========================================================================
  // 1. Primary & Brand Gradients
  // ===========================================================================
  /// Core primary horizontal gradient (#0067B8 -> #00AEDE -> #00F1FE).
  static const LinearGradient primary = LinearGradient(
    colors: [
      AppColors.primaryGradientStart,
      AppColors.primaryGradientMid,
      AppColors.primaryGradientEnd,
    ],
    stops: [0.0, 0.545, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Semantic alias for [primary].
  static const LinearGradient primaryGradient = primary;

  /// Semantic alias for [AppColors.primaryGradientStart].
  static const Color primaryStart = AppColors.primaryGradientStart;

  /// Disabled primary gradient (10% opacity primary gradient matching Figma Node 16:4201).
  static const LinearGradient disabledPrimary = LinearGradient(
    colors: [Color(0x1A0067B8), Color(0x1A00AEDE), Color(0x1A00F1FE)],
    stops: [0.0, 0.545, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Semantic alias for [disabledPrimary].
  static const LinearGradient disabledPrimaryGradient = disabledPrimary;

  // ===========================================================================
  // 2. Header Gradients
  // ===========================================================================
  /// Top sky banner header gradient.
  static const LinearGradient skyHeader = LinearGradient(
    colors: [Color(0xFF4A90E2), Color(0xFFF8FAFC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.45],
  );

  /// Semantic alias for [skyHeader].
  static const LinearGradient skyHeaderGradient = skyHeader;

  /// Screen header top banner gradient.
  static const LinearGradient screenHeader = LinearGradient(
    colors: [AppColors.primarySkyLight, AppColors.background],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Semantic alias for [screenHeader].
  static const LinearGradient screenHeaderGradient = screenHeader;

  /// Card header subtle vertical gradient.
  static const LinearGradient cardHeader = LinearGradient(
    colors: [Color(0xFFEBF4FD), AppColors.white],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Semantic alias for [cardHeader].
  static const LinearGradient cardHeaderGradient = cardHeader;

  // ===========================================================================
  // 3. Wellness & Vitals Card Gradients
  // ===========================================================================
  /// Wellness card top diagonal gradient (Figma Node 118:917 / 60:289).
  static const LinearGradient wellnessCard = LinearGradient(
    colors: [
      AppColors.wellnessCardGradientStart,
      AppColors.wellnessCardGradientMid,
      AppColors.white,
    ],
    stops: [0.0, 0.40, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Semantic alias for [wellnessCard].
  static const LinearGradient wellnessCardGradient = wellnessCard;

  /// Expanded vitals metric card diagonal gradient (Figma Node 119:1442).
  static const LinearGradient vitalsExpandedCard = LinearGradient(
    colors: [
      AppColors.vitalsExpandedBgStart,
      AppColors.vitalsExpandedBgMid,
      AppColors.white,
    ],
    stops: [0.0, 0.545, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Semantic alias for [vitalsExpandedCard].
  static const LinearGradient vitalsExpandedCardGradient = vitalsExpandedCard;

  /// Sleep summary icon radial gradient (Figma Node 73:1319 / 119:1477).
  static const RadialGradient vitalsSleepIcon = RadialGradient(
    colors: [AppColors.cyanActive, AppColors.primary],
    center: Alignment.center,
    radius: 0.75,
  );

  /// Semantic alias for [vitalsSleepIcon].
  static const RadialGradient vitalsSleepIconGradient = vitalsSleepIcon;

  // ===========================================================================
  // 4. Onboarding & Navigation Gradients
  // ===========================================================================
  /// Onboarding plan card gradient (Figma Node 120:1785).
  static const LinearGradient onboardingCard = LinearGradient(
    colors: [
      AppColors.wellnessCardGradientStart,
      AppColors.onboardingCardGradientMid,
      AppColors.white,
    ],
    stops: [0.0, 0.40, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Semantic alias for [onboardingCard].
  static const LinearGradient onboardingCardGradient = onboardingCard;

  /// Bottom Navigation Active Indicator Radial Gradient (Figma Ellipse 7).
  static const RadialGradient activeNavCircle = RadialGradient(
    colors: [AppColors.cyanActive, AppColors.primary],
    center: Alignment.center,
    radius: 0.85,
  );

  /// Semantic alias for [activeNavCircle].
  static const RadialGradient activeNavCircleGradient = activeNavCircle;

  /// Active plan badge gradient (Figma Node 120:1785).
  static const LinearGradient planBadge = LinearGradient(
    colors: [AppColors.cyanActive, AppColors.primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Semantic alias for [planBadge].
  static const LinearGradient planBadgeGradient = planBadge;

  /// Energy burned vertical capsule chart gradient.
  static const LinearGradient energyBurned = LinearGradient(
    colors: [AppColors.energyGradientStart, AppColors.energyGradientEnd],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  /// Semantic alias for [energyBurned].
  static const LinearGradient energyBurnedGradient = energyBurned;

  // ===========================================================================
  // 5. Training Screen Gradients (Figma Node 75:2261 / 128:554)
  // ===========================================================================
  /// Train Play Button Radial Gradient (Figma Node 75:2593).
  static const RadialGradient trainPlay = RadialGradient(
    colors: [AppColors.cyanActive, AppColors.primary],
    center: Alignment(0.39, 0.30),
    radius: 0.85,
  );

  /// Semantic alias for [trainPlay].
  static const RadialGradient trainPlayGradient = trainPlay;

  /// Train Stat 1 (Time) Gradient (Figma Group 1376157569).
  static const LinearGradient trainStatTime = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.trainStatTimeStart, AppColors.trainStatTimeEnd],
  );

  /// Semantic alias for [trainStatTime].
  static const LinearGradient trainStatTimeGradient = trainStatTime;

  /// Train Stat 2 (Peak) Gradient (Figma Group 1376157568).
  static const LinearGradient trainStatPeak = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.trainStatPeakStart, AppColors.trainStatPeakEnd],
  );

  /// Semantic alias for [trainStatPeak].
  static const LinearGradient trainStatPeakGradient = trainStatPeak;

  /// Train Stat 3 (Avg) Gradient (Figma Group 1376157570).
  static const LinearGradient trainStatAvg = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.trainStatAvgStart, AppColors.trainStatAvgEnd],
  );

  /// Semantic alias for [trainStatAvg].
  static const LinearGradient trainStatAvgGradient = trainStatAvg;

  /// Training Session Timer Card vertical soft gradient (Figma Node 128:554).
  static const LinearGradient timerCard = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.timerCardGradientStart,
      AppColors.timerCardGradientMid,
      AppColors.white,
    ],
    stops: [0.0, 0.40, 1.0],
  );

  /// Semantic alias for [timerCard].
  static const LinearGradient timerCardGradient = timerCard;

  // ===========================================================================
  // 6. Profile Screen Gradients (Figma Node 75:2756)
  // ===========================================================================
  /// Circular badge radial gradient for Lock & Band (#01D5F1 -> #3E83C8).
  static const RadialGradient profileBadgeRadial = RadialGradient(
    colors: [AppColors.cyanActive, AppColors.primary],
    center: Alignment(0.39, 0.30),
    radius: 0.85,
  );

  // ===========================================================================
  // 7. Membership Screen Gradients (Figma Node 133:774)
  // ===========================================================================
  /// Route one membership card soft diagonal gradient matching Figma Node 133:774.
  static const LinearGradient membershipCard = LinearGradient(
    colors: [
      AppColors.wellnessCardGradientStart,
      AppColors.wellnessCardGradientMid,
      AppColors.white,
    ],
    stops: [0.0, 0.76, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Semantic alias for [membershipCard].
  static const LinearGradient membershipCardGradient = membershipCard;

  // ===========================================================================
  // 8. Systems, Journal & Rewards Gradients
  // ===========================================================================
  /// Recover card soft diagonal gradient matching Figma Node 143:2187.
  static const LinearGradient recoverCard = LinearGradient(
    colors: [
      AppColors.recoverCardGradientStart,
      AppColors.recoverCardGradientMid,
      AppColors.white,
    ],
    stops: [0.0, 0.50, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Journal "Pattern the band found" horizontal banner gradient matching Figma Node 143:2654.
  static const LinearGradient journalPatternBanner = LinearGradient(
    colors: [
      AppColors.journalPatternBannerStart,
      AppColors.journalPatternBannerEnd,
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Rewards Bronze member tier card soft diagonal gradient matching Figma Node 143:3009.
  static const LinearGradient rewardsTierCard = LinearGradient(
    colors: [
      AppColors.rewardsTierCardStart,
      AppColors.rewardsTierCardMid,
      AppColors.white,
    ],
    stops: [0.0, 0.50, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Rewards Balance Card soft gradient matching Figma Node 143:3009 (#E5F3FB -> #F6FDFF).
  static const LinearGradient rewardsBalanceCard = LinearGradient(
    colors: [
      AppColors.rewardsBalanceBgStart,
      AppColors.rewardsBalanceBgEnd,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
