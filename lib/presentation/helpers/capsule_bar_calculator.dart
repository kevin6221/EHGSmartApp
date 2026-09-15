/// Precomputed fill heights for the 3-tier capsule bar layers.
class CapsuleBarTiers {
  final double fillHeight;
  final double tier2Height; // Middle (65%)
  final double tier3Height; // Base (35%)

  const CapsuleBarTiers({
    required this.fillHeight,
    required this.tier2Height,
    required this.tier3Height,
  });
}

/// Pure presentation calculator for CapsuleBarChart bars and tiers.
class CapsuleBarCalculator {
  CapsuleBarCalculator._();

  /// Computes all tier heights for a capsule bar given value fraction (0.0 - 1.0),
  /// available height, and bar width.
  static CapsuleBarTiers computeTiers({
    required double rawValue,
    required double totalHeight,
    required double barWidth,
  }) {
    final fraction = rawValue.clamp(0.0, 1.0);
    final fillHeight = (totalHeight * fraction).clamp(barWidth, totalHeight);
    final tier2Height = (fillHeight * 0.65).clamp(barWidth * 0.7, fillHeight);
    final tier3Height = (fillHeight * 0.35).clamp(barWidth * 0.5, fillHeight);

    return CapsuleBarTiers(
      fillHeight: fillHeight,
      tier2Height: tier2Height,
      tier3Height: tier3Height,
    );
  }
}
