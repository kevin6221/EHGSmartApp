import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum ReadinessSegmentType { sleep, hrv, rest, stress }

/// Raw definition of a bar segment extracted from Figma specs.
class ReadinessBarSegmentDef {
  final double baseHeight;
  final ReadinessSegmentType type;

  const ReadinessBarSegmentDef(this.baseHeight, this.type);
}

/// Precomputed render-ready specification for a timeline bar segment.
class RenderReadyBarSegment {
  final double height;
  final Color color;

  const RenderReadyBarSegment({
    required this.height,
    required this.color,
  });
}

/// Precomputed layout specifications for HomeReadinessCard.
class ReadinessCardDimensions {
  final double itemSpacing;
  final double headerGap;
  final double chartHeight;
  final double tilePadH;
  final double tilePadV;

  const ReadinessCardDimensions({
    required this.itemSpacing,
    required this.headerGap,
    required this.chartHeight,
    required this.tilePadH,
    required this.tilePadV,
  });

  /// Computes responsive dimensions from screen dimensions.
  factory ReadinessCardDimensions.compute({
    required double screenWidth,
    required double screenHeight,
  }) {
    return ReadinessCardDimensions(
      itemSpacing: (screenHeight * 0.016).clamp(12.0, 18.0),
      headerGap: (screenWidth * 0.02).clamp(6.0, 10.0),
      chartHeight: (screenHeight * 0.125).clamp(95.0, 120.0),
      tilePadH: (screenWidth * 0.035).clamp(10.0, 16.0),
      tilePadV: (screenHeight * 0.014).clamp(10.0, 14.0),
    );
  }
}

/// Pure calculation helper for HomeReadinessCard layout and timeline bars.
class ReadinessCardCalculator {
  ReadinessCardCalculator._();

  /// Baseline reference height from Figma node 118:917.
  static const double baseReferenceHeight = 106.0;

  /// Resolves the semantic color for a readiness segment type.
  static Color resolveColor(ReadinessSegmentType type) {
    switch (type) {
      case ReadinessSegmentType.sleep:
        return AppColors.readinessSleep;
      case ReadinessSegmentType.hrv:
        return AppColors.readinessHrv;
      case ReadinessSegmentType.rest:
        return AppColors.readinessRest;
      case ReadinessSegmentType.stress:
        return AppColors.readinessStress;
    }
  }

  /// Computes bar width clamped to aesthetic bounds.
  static double computeBarWidth(double availableWidth) {
    return (availableWidth / 32.0).clamp(4.2, 5.8);
  }

  /// Precomputes all scaled segments for a single column.
  static List<RenderReadyBarSegment> computeColumnSegments({
    required List<ReadinessBarSegmentDef> columnDefs,
    required double chartHeight,
  }) {
    final scale = chartHeight / baseReferenceHeight;
    return columnDefs.map((def) {
      return RenderReadyBarSegment(
        height: def.baseHeight * scale,
        color: resolveColor(def.type),
      );
    }).toList(growable: false);
  }
}
