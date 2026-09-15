import 'dart:ui';
import '../../core/theme/responsive.dart';

/// Precomputed layout dimensions for Vitals cards to keep widget build() trees 100% calculation-free.
class VitalsCardDimensions {
  final double cardRadius;
  final double cardPadding;
  final double itemSpacing;
  final double titleFontSize;
  final double valueFontSize;
  final double unitFontSize;
  final double subtitleFontSize;
  final double sparklineHeight;
  final double iconSize;

  const VitalsCardDimensions({
    required this.cardRadius,
    required this.cardPadding,
    required this.itemSpacing,
    required this.titleFontSize,
    required this.valueFontSize,
    required this.unitFontSize,
    required this.subtitleFontSize,
    required this.sparklineHeight,
    required this.iconSize,
  });

  factory VitalsCardDimensions.fromResponsive(Responsive r) {
    return VitalsCardDimensions(
      cardRadius: 24.0,
      cardPadding: r.isSmall ? 12.0 : 16.0,
      itemSpacing: (r.height * 0.016).clamp(10.0, 16.0),
      titleFontSize: r.font(15.9),
      valueFontSize: r.font(24.0),
      unitFontSize: r.font(12.0),
      subtitleFontSize: r.font(12.0),
      sparklineHeight: (r.height * 0.05).clamp(36.0, 48.0),
      iconSize: 18.0,
    );
  }
}

/// Pure presentation calculator for Vitals screen charts, wave curves, and scrubbers.
class VitalsCardCalculator {
  VitalsCardCalculator._();

  /// Calculates the scrub index and value given an X touch coordinate and total width.
  static int computeScrubIndex({
    required double localX,
    required double totalWidth,
    required int itemCount,
  }) {
    if (totalWidth <= 0 || itemCount <= 1) return 0;
    final clampedX = localX.clamp(0.0, totalWidth);
    final fraction = clampedX / totalWidth;
    final index = (fraction * (itemCount - 1)).round();
    return index.clamp(0, itemCount - 1);
  }

  /// Calculates the X position on canvas for an index in an item list.
  static double computePointX({
    required int index,
    required int totalCount,
    required double width,
  }) {
    if (totalCount <= 1) return width / 2;
    return (index / (totalCount - 1)) * width;
  }

  /// Normalizes a list of values to canvas Y coordinates with top and bottom padding.
  static List<Offset> computeNormalizedPoints({
    required List<double> values,
    required Size size,
    double topPadding = 12.0,
    double bottomPadding = 12.0,
  }) {
    if (values.isEmpty) return const [];
    if (values.length == 1) {
      return [Offset(size.width / 2, size.height / 2)];
    }

    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);
    final usableHeight = size.height - topPadding - bottomPadding;

    final List<Offset> points = [];
    for (int i = 0; i < values.length; i++) {
      final x = (i / (values.length - 1)) * size.width;
      final normalized = (values[i] - minVal) / range;
      // Invert Y: high value at top
      final y = size.height - bottomPadding - (normalized * usableHeight);
      points.add(Offset(x, y));
    }
    return points;
  }
}
