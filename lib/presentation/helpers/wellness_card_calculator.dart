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
}
