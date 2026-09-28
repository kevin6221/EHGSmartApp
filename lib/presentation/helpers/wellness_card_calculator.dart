import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Data point model for the Syncfusion concentric doughnut chart.
class PillarChartSegment {
  final String label;
  final double value;
  final Color color;

  const PillarChartSegment({
    required this.label,
    required this.value,
    required this.color,
  });
}

/// Precomputed layout specifications for HomeWellnessScoreCard.
class WellnessCardDimensions {
  final double badgeDim;
  final double badgeFontSize;
  final double detailsGap;
  final double ringsDim;
  final double ringsFontSize;
  final double rowSpacing;

  const WellnessCardDimensions({
    required this.badgeDim,
    required this.badgeFontSize,
    required this.detailsGap,
    required this.ringsDim,
    required this.ringsFontSize,
    required this.rowSpacing,
  });

  /// Computes responsive sizing given screen dimensions.
  factory WellnessCardDimensions.compute({
    required double screenWidth,
    required double screenHeight,
  }) {
    final badgeDim = (screenWidth * 0.15).clamp(50.0, 64.0);
    final badgeFontSize = (badgeDim * 0.48).clamp(24.0, 32.0);
    final detailsGap = (screenWidth * 0.035).clamp(10.0, 16.0);
    final ringsDim = (screenWidth * 0.36).clamp(120.0, 160.0);
    final ringsFontSize = (ringsDim * 0.22).clamp(24.0, 32.0);
    final rowSpacing = (screenHeight * 0.014).clamp(10.0, 16.0);

    return WellnessCardDimensions(
      badgeDim: badgeDim,
      badgeFontSize: badgeFontSize,
      detailsGap: detailsGap,
      ringsDim: ringsDim,
      ringsFontSize: ringsFontSize,
      rowSpacing: rowSpacing,
    );
  }
}

/// Pure presentation calculator for the Home Wellness Score Card.
class WellnessCardCalculator {
  WellnessCardCalculator._();

  /// Computes safe progress fraction (0.0 to 1.0) for a 0-100 pillar score.
  static double computeFraction(int score) {
    return (score / 100.0).clamp(0.0, 1.0);
  }

  /// Computes the dynamic transparent spacer gap between chart doughnut segments.
  static double computeChartGap({
    required int recover,
    required int fuel,
    required int mind,
    required int move,
  }) {
    final total = recover + fuel + mind + move;
    return (total * 0.035).clamp(1.0, 5.0);
  }

  /// Builds the complete doughnut chart dataset including spacer segments.
  static List<PillarChartSegment> buildChartSegments({
    required int recoverScore,
    required int fuelScore,
    required int mindScore,
    required int moveScore,
  }) {
    final gap = computeChartGap(
      recover: recoverScore,
      fuel: fuelScore,
      mind: mindScore,
      move: moveScore,
    );

    return [
      PillarChartSegment(
        label: 'Recover',
        value: recoverScore.toDouble(),
        color: AppColors.recoverPillar,
      ),
      PillarChartSegment(
        label: 'gap1',
        value: gap,
        color: Colors.transparent,
      ),
      PillarChartSegment(
        label: 'Fuel',
        value: fuelScore.toDouble(),
        color: AppColors.fuelPillar,
      ),
      PillarChartSegment(
        label: 'gap2',
        value: gap,
        color: Colors.transparent,
      ),
      PillarChartSegment(
        label: 'Mind',
        value: mindScore.toDouble(),
        color: AppColors.mindPillar,
      ),
      PillarChartSegment(
        label: 'gap3',
        value: gap,
        color: Colors.transparent,
      ),
      PillarChartSegment(
        label: 'Move',
        value: moveScore.toDouble(),
        color: AppColors.movePillar,
      ),
      PillarChartSegment(
        label: 'gap4',
        value: gap,
        color: Colors.transparent,
      ),
    ];
  }

  /// Generates dynamic, contextual insights for each pillar by comparing all four scores
  /// and applying score-range thresholds.
  static String computePillarInsight({
    required String pillar,
    required int score,
    required int moveScore,
    required int recoverScore,
    required int mindScore,
    required int fuelScore,
  }) {
    if (score <= 0) {
      return switch (pillar.toLowerCase()) {
        'move' => 'No movement recorded yet today. Take a walk to start tracking.',
        'recover' => 'Wear your band during sleep to calculate your recovery score.',
        'mind' => 'No stress readings yet. Band vitals will populate your mind score.',
        'fuel' => 'Log water intake or meals to start tracking your fuel score.',
        _ => 'No data recorded yet today.',
      };
    }

    final entries = [
      MapEntry('move', moveScore),
      MapEntry('recover', recoverScore),
      MapEntry('mind', mindScore),
      MapEntry('fuel', fuelScore),
    ];

    final minScore = entries.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    final maxScore = entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    // Designate EXACTLY one pillar as the weakest today (lowest score below 75, strictly less than max)
    final String? weakestPillar = (minScore < maxScore && minScore < 75)
        ? entries.firstWhere((e) => e.value == minScore).key
        : null;

    // Designate EXACTLY one pillar as the strongest today (highest score above 75, strictly greater than min)
    final String? strongestPillar = (maxScore > minScore && maxScore >= 75)
        ? entries.firstWhere((e) => e.value == maxScore).key
        : null;

    final String key = pillar.toLowerCase();
    final bool isWeakest = key == weakestPillar;
    final bool isStrongest = key == strongestPillar;

    switch (key) {
      case 'move':
        if (isWeakest) {
          return 'Movement is your weakest pillar today. A brisk 20-min walk will lift your score.';
        }
        if (isStrongest) {
          return 'Movement is your strongest pillar today. Outstanding active output!';
        }
        if (score >= 90) {
          return 'Peak movement today. Outstanding activity level and energy expenditure.';
        }
        if (score >= 75) {
          return 'Strong active output today. On track to exceed your movement goal.';
        }
        if (score >= 50) {
          return 'Moderate activity. A brisk 20-minute walk will boost your score.';
        }
        return 'Activity is low so far today. Take a quick movement break to get moving.';

      case 'recover':
        if (isWeakest) {
          return 'Recovery is your weakest pillar today. Short sleep is holding this down.';
        }
        if (isStrongest) {
          return 'Recovery is your strongest pillar today. Deep rest and optimal readiness.';
        }
        if (score >= 90) {
          return 'Fully recovered. Restorative sleep and excellent physiological readiness.';
        }
        if (score >= 75) {
          return 'Good recovery. Rested vitals and quality restorative sleep.';
        }
        if (score >= 50) {
          return 'Fair recovery. Short or fragmented sleep is holding this down.';
        }
        return 'Recovery is depleted today. Prioritize an early bedtime and relaxation.';

      case 'mind':
        if (isWeakest) {
          return 'Mind is your weakest pillar today. Five minutes of breathing moves this.';
        }
        if (isStrongest) {
          return 'Mind is your strongest pillar today. Deep calm and high resilience.';
        }
        if (score >= 90) {
          return 'Calm and centered. Excellent autonomic nervous system balance.';
        }
        if (score >= 75) {
          return 'Balanced stress response. Good cognitive resilience today.';
        }
        if (score >= 50) {
          return 'Stress load is elevated. Five minutes of breathing moves this.';
        }
        return 'High stress load detected. Take five minutes of guided breathwork to reset.';

      case 'fuel':
        if (isWeakest) {
          return 'Fuel is your weakest pillar today. Hydration is the quickest win available to you.';
        }
        if (isStrongest) {
          return 'Fuel is your strongest pillar today. Perfectly hydrated and fueled.';
        }
        if (score >= 90) {
          return 'Optimal fueling. Fully hydrated with balanced daily energy.';
        }
        if (score >= 75) {
          return 'Well hydrated. Maintaining steady hydration and energy balance.';
        }
        if (score >= 50) {
          return 'Hydration is moderate. A fresh glass of water is your fastest win.';
        }
        return 'Fuel is lagging today. Drinking a glass of water is your fastest win.';

      default:
        return 'Keep up your daily health habits to balance your wellness score.';
    }
  }
}
