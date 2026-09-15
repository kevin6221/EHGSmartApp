/// Precomputed layout specifications for metric cards (Hydration & Energy).
class MetricCardDimensions {
  final double chartHeight;
  final double barWidth;
  final double verticalSpacing;

  const MetricCardDimensions({
    required this.chartHeight,
    required this.barWidth,
    required this.verticalSpacing,
  });

  /// Computes responsive dimensions from screen dimensions.
  factory MetricCardDimensions.compute({
    required double screenWidth,
    required double screenHeight,
  }) {
    return MetricCardDimensions(
      chartHeight: (screenHeight * 0.07).clamp(48.0, 64.0),
      barWidth: (screenWidth * 0.024).clamp(7.5, 10.0),
      verticalSpacing: (screenHeight * 0.016).clamp(10.0, 16.0),
    );
  }
}
