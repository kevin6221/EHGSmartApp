/// Precomputed layout specifications for HomeVitalsSummaryRow.
class VitalsRowDimensions {
  final double cardWidth;
  final double cardHeight;
  final double chartWidth;
  final double cardGap;
  final double sleepBarWidth;

  const VitalsRowDimensions({
    required this.cardWidth,
    required this.cardHeight,
    required this.chartWidth,
    required this.cardGap,
    required this.sleepBarWidth,
  });

  /// Computes responsive dimensions from screen dimensions.
  factory VitalsRowDimensions.compute({
    required double screenWidth,
    required double screenHeight,
  }) {
    final cardWidth = (screenWidth * 0.72).clamp(240.0, 310.0);
    final cardHeight = (screenHeight * 0.135).clamp(105.0, 130.0);
    final chartWidth = (cardWidth * 0.38).clamp(85.0, 115.0);
    final cardGap = (screenWidth * 0.03).clamp(8.0, 14.0);
    final sleepBarWidth = (chartWidth / 12.0).clamp(6.0, 9.0);

    return VitalsRowDimensions(
      cardWidth: cardWidth,
      cardHeight: cardHeight,
      chartWidth: chartWidth,
      cardGap: cardGap,
      sleepBarWidth: sleepBarWidth,
    );
  }
}
