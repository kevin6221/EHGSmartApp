/// Pure helper for touch scrubbing calculations on WaveChart.
class WaveChartCalculator {
  WaveChartCalculator._();

  /// Calculates the selected point index from a touch or drag X-coordinate.
  static int? calculateScrubIndex({
    required double localX,
    required double totalWidth,
    required int pointCount,
  }) {
    if (pointCount <= 0 || totalWidth <= 0.0) return null;
    final double fraction = (localX / totalWidth).clamp(0.0, 1.0);
    final int index = (fraction * (pointCount - 1)).round();
    return index.clamp(0, pointCount - 1);
  }
}
