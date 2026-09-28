import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../../data/models/user_profile_model.dart';

/// Encapsulates the user's rolling physiological baselines calculated
/// after wearing the band over the initial calibration period (7–14 days).
@immutable
class PersonalizedBaselineData {
  /// Rolling exponential / arithmetic baseline for HRV (rMSSD in milliseconds).
  final double hrvBaseline;

  /// Rolling baseline for Resting Heart Rate (beats per minute).
  final double restingHrBaseline;

  /// Personalized daily restorative sleep goal (in minutes, typically 420–540 min).
  final int sleepTargetMinutes;

  /// Dynamic daily hydration goal (in milliliters) tailored to body mass.
  final int hydrationGoalMl;

  /// Dynamic daily calorie expenditure target based on profile and activity tier.
  final int energyTargetKcal;

  /// Distinct days of biometric data captured by the band.
  final int calibrationDays;

  const PersonalizedBaselineData({
    this.hrvBaseline = 40.0,
    this.restingHrBaseline = 60.0,
    this.sleepTargetMinutes = 480,
    this.hydrationGoalMl = 2000,
    this.energyTargetKcal = 560,
    this.calibrationDays = 0,
  });

  /// True once the user has worn the band for at least 7 days,
  /// establishing statistically significant individual baselines.
  bool get isCalibrated => calibrationDays >= 7;

  /// Status descriptor for UI displays and tooltips.
  String get calibrationStatus {
    if (isCalibrated) {
      return 'Personalized baseline active ($calibrationDays days calibrated)';
    }
    final remaining = 7 - calibrationDays;
    return 'Calibrating personalized baseline (Day $calibrationDays of 7 · $remaining days remaining)';
  }

  PersonalizedBaselineData copyWith({
    double? hrvBaseline,
    double? restingHrBaseline,
    int? sleepTargetMinutes,
    int? hydrationGoalMl,
    int? energyTargetKcal,
    int? calibrationDays,
  }) {
    return PersonalizedBaselineData(
      hrvBaseline: hrvBaseline ?? this.hrvBaseline,
      restingHrBaseline: restingHrBaseline ?? this.restingHrBaseline,
      sleepTargetMinutes: sleepTargetMinutes ?? this.sleepTargetMinutes,
      hydrationGoalMl: hydrationGoalMl ?? this.hydrationGoalMl,
      energyTargetKcal: energyTargetKcal ?? this.energyTargetKcal,
      calibrationDays: calibrationDays ?? this.calibrationDays,
    );
  }

  Map<String, dynamic> toJson() => {
        'hrvBaseline': hrvBaseline,
        'restingHrBaseline': restingHrBaseline,
        'sleepTargetMinutes': sleepTargetMinutes,
        'hydrationGoalMl': hydrationGoalMl,
        'energyTargetKcal': energyTargetKcal,
        'calibrationDays': calibrationDays,
      };

  factory PersonalizedBaselineData.fromJson(Map<String, dynamic> json) =>
      PersonalizedBaselineData(
        hrvBaseline: (json['hrvBaseline'] as num?)?.toDouble() ?? 40.0,
        restingHrBaseline:
            (json['restingHrBaseline'] as num?)?.toDouble() ?? 60.0,
        sleepTargetMinutes:
            (json['sleepTargetMinutes'] as num?)?.toInt() ?? 480,
        hydrationGoalMl: (json['hydrationGoalMl'] as num?)?.toInt() ?? 2000,
        energyTargetKcal: (json['energyTargetKcal'] as num?)?.toInt() ?? 560,
        calibrationDays: (json['calibrationDays'] as num?)?.toInt() ?? 0,
      );
}

/// Advanced Personalized Target & Baseline Engine.
///
/// Converts raw hardware signals into individualized homeostasis baselines
/// rather than rigid population-wide fixed thresholds.
///
/// Follows clinical autonomic neuroscience and sports science standards:
/// - Evaluates HRV relative to the user's rolling individual mean (rMSSD).
/// - Dynamically identifies parasympathetic recovery vs. sympathetic strain.
/// - Calibrates sleep, resting HR, hydration, and energy targets to individual traits.
class PersonalizedBaselineEngine {
  const PersonalizedBaselineEngine._();

  /// Calculates a personalized HRV score (0–100) evaluated strictly
  /// against the user's individual baseline.
  ///
  /// Prevents users with naturally lower resting HRV (e.g. 30–45 ms) from
  /// unfairly receiving poor scores when they are perfectly healthy and recovered.
  static int calculatePersonalizedHrvScore({
    required int currentHrv,
    required double baselineHrv,
    bool isCalibrated = false,
  }) {
    if (currentHrv <= 0) return 0;

    // Use current reading as the temporary anchor if baseline is missing
    final effectiveBaseline = baselineHrv > 0 ? baselineHrv : currentHrv.toDouble();
    if (effectiveBaseline <= 0) return 75;

    // Ratio of today's HRV to the user's homeostatic baseline
    final double ratio = currentHrv / effectiveBaseline;

    // Relative evaluation based on autonomic nervous system balance:
    if (ratio >= 1.15) {
      // Optimal parasympathetic reserve (15%+ above baseline)
      return (92 + (ratio - 1.15) * 25).clamp(92.0, 99.0).round();
    } else if (ratio >= 1.00) {
      // Solid homeostasis (at or up to 15% above baseline)
      return (84 + ((ratio - 1.0) / 0.15) * 8).clamp(84.0, 92.0).round();
    } else if (ratio >= 0.90) {
      // Steady autonomic balance (within 10% below baseline)
      return (75 + ((ratio - 0.90) / 0.10) * 9).clamp(75.0, 83.0).round();
    } else if (ratio >= 0.75) {
      // Moderate autonomic strain (10% to 25% below baseline)
      return (55 + ((ratio - 0.75) / 0.15) * 19).clamp(55.0, 74.0).round();
    } else {
      // Elevated sympathetic load or physical fatigue (>25% below baseline)
      return (20 + (ratio / 0.75) * 34).clamp(15.0, 54.0).round();
    }
  }

  /// Calculates a personalized Resting Heart Rate (RHR) score (0–100)
  /// evaluated against the user's individual resting baseline.
  static int calculatePersonalizedRestHrScore({
    required int currentRestHr,
    required double baselineRestHr,
  }) {
    if (currentRestHr <= 0) return 0;

    final effectiveBaseline =
        baselineRestHr > 0 ? baselineRestHr : currentRestHr.toDouble();
    final double delta = currentRestHr - effectiveBaseline;

    // Lower or equal resting HR indicates strong cardiovascular rest
    if (delta <= 0) {
      return (90 + (-delta) * 1.5).clamp(90.0, 99.0).round();
    } else if (delta <= 3) {
      return (80 + (3 - delta) * 3.3).clamp(80.0, 89.0).round();
    } else if (delta <= 7) {
      return (65 + (7 - delta) * 3.5).clamp(65.0, 79.0).round();
    } else {
      // Elevated RHR indicates incomplete recovery, dehydration, or stress
      return (25 + math.max(0.0, 15.0 - delta) * 2.5).clamp(20.0, 64.0).round();
    }
  }

  /// Calculates a personalized composite Recovery Score (0–100) by combining
  /// personalized Sleep Target, Deep Sleep ratio, individual HRV, and RHR.
  static int calculatePersonalizedRecoverScore({
    required int sleepMinutes,
    required int deepSleepMinutes,
    required int personalizedSleepTargetMinutes,
    required int personalizedHrvScore,
    required int personalizedRestHrScore,
  }) {
    final int target = personalizedSleepTargetMinutes > 0
        ? personalizedSleepTargetMinutes
        : 480;

    // Sleep duration component relative to individual goal
    final double sleepRatio = (sleepMinutes / target).clamp(0.15, 1.25);
    final double sleepScore = (sleepRatio * 100).clamp(15.0, 98.0);

    // Deep sleep quality component (target: 15–25% deep sleep)
    final double deepRatio =
        sleepMinutes > 0 ? (deepSleepMinutes / sleepMinutes) : 0.0;
    final double deepScore =
        (deepRatio >= 0.15 ? 90.0 + (deepRatio - 0.15) * 100 : deepRatio / 0.15 * 90.0)
            .clamp(40.0, 100.0);

    final double effectiveHrv =
        personalizedHrvScore > 0 ? personalizedHrvScore.toDouble() : 75.0;
    final double effectiveRhr =
        personalizedRestHrScore > 0 ? personalizedRestHrScore.toDouble() : 75.0;

    // Weighted physiological recovery composition:
    // 45% sleep duration, 25% HRV autonomic balance, 20% RHR cardiovascular rest, 10% deep sleep
    final composite = 0.45 * sleepScore +
        0.25 * effectiveHrv +
        0.20 * effectiveRhr +
        0.10 * deepScore;

    return composite.clamp(15.0, 99.0).round();
  }

  /// Computes personalized hydration goal based on user profile body weight.
  /// Standard clinical sports hydration: 35 mL per kg of body mass.
  static int calculatePersonalizedHydrationGoal(UserProfileModel? profile) {
    if (profile != null && profile.weight > 30.0 && profile.weight < 250.0) {
      return (profile.weight * 35.0).round().clamp(1800, 3600);
    }
    return 2000;
  }

  /// Extracts and updates rolling baseline data from historical database summaries.
  static PersonalizedBaselineData computeBaselineFromHistoricalRecords({
    required List<double> historicalHrv,
    required List<double> historicalRestingHr,
    required List<int> historicalSleepMinutes,
    required UserProfileModel? profile,
    PersonalizedBaselineData? currentBaseline,
  }) {
    final validHrv = historicalHrv.where((v) => v > 0).toList();
    final validRhr = historicalRestingHr.where((v) => v > 0).toList();
    final validSleep = historicalSleepMinutes.where((v) => v > 120).toList();

    final int calibrationCount = math.max(
      validHrv.length,
      math.max(validRhr.length, validSleep.length),
    );

    // Rolling exponential moving average or arithmetic mean
    final double hrvAvg = validHrv.isNotEmpty
        ? (validHrv.reduce((a, b) => a + b) / validHrv.length)
        : (currentBaseline?.hrvBaseline ?? 40.0);

    final double rhrAvg = validRhr.isNotEmpty
        ? (validRhr.reduce((a, b) => a + b) / validRhr.length)
        : (currentBaseline?.restingHrBaseline ?? 60.0);

    final int sleepAvg = validSleep.isNotEmpty
        ? (validSleep.reduce((a, b) => a + b) ~/ validSleep.length).clamp(420, 540)
        : (currentBaseline?.sleepTargetMinutes ?? 480);

    final hydrationGoal = calculatePersonalizedHydrationGoal(profile);

    return (currentBaseline ?? const PersonalizedBaselineData()).copyWith(
      hrvBaseline: double.parse(hrvAvg.toStringAsFixed(1)),
      restingHrBaseline: double.parse(rhrAvg.toStringAsFixed(1)),
      sleepTargetMinutes: sleepAvg,
      hydrationGoalMl: hydrationGoal,
      calibrationDays: math.max(currentBaseline?.calibrationDays ?? 0, calibrationCount),
    );
  }
}
