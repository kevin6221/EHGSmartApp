import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

/// Precomputed layout specifications for the floating navigation bar dimensions.
class NavBarDimensions {
  final double navHeight;
  final double indicatorDim;
  final double activeIconSize;
  final double inactiveIconSize;

  const NavBarDimensions({
    required this.navHeight,
    required this.indicatorDim,
    required this.activeIconSize,
    required this.inactiveIconSize,
  });

  /// Computes responsive dimensions given total screen height.
  factory NavBarDimensions.compute(double screenHeight) {
    final navHeight = (screenHeight * 0.075).clamp(58.0, 68.0);
    final indicatorDim = (navHeight * 0.62).clamp(38.0, 42.0);
    final activeIconSize = (navHeight * 0.32).clamp(19.0, 22.0);
    final inactiveIconSize = (navHeight * 0.30).clamp(18.0, 21.0);

    return NavBarDimensions(
      navHeight: navHeight,
      indicatorDim: indicatorDim,
      activeIconSize: activeIconSize,
      inactiveIconSize: inactiveIconSize,
    );
  }
}

/// Specifications for the active sliding bubble geometry and squash & stretch physics.
class NavBarBubbleSpec {
  final double left;
  final double top;
  final double width;
  final double height;
  final double borderRadius;

  const NavBarBubbleSpec({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.borderRadius,
  });
}

/// Specifications for cross-fading icon transitions inside the active bubble.
class ActiveIconMorphSpec {
  final double fromOpacity;
  final double fromScale;
  final double toOpacity;
  final double toScale;

  const ActiveIconMorphSpec({
    required this.fromOpacity,
    required this.fromScale,
    required this.toOpacity,
    required this.toScale,
  });
}

/// Pure calculation helper for CustomBottomNavBar layout, physics, and animations.
/// Encapsulates all math outside of widget build methods.
class NavBarCalculator {
  NavBarCalculator._();

  /// Computes each tab track width.
  static double computeTabWidth(double totalWidth, int tabCount) {
    if (tabCount <= 0) return totalWidth;
    return totalWidth / tabCount;
  }

  /// Linearly interpolates the bubble position between previous and target tab indices.
  static double computeCurrentPosition({
    required double fromPosition,
    required double targetPosition,
    required double progress,
  }) {
    return lerpDouble(fromPosition, targetPosition, progress) ?? targetPosition;
  }

  /// Calculates the morphing bubble layout with liquid squash & stretch physics.
  static NavBarBubbleSpec computeBubbleSpec({
    required double currentPos,
    required double fromPosition,
    required double targetPosition,
    required double progress,
    required double tabWidth,
    required double indicatorDim,
    required double navHeight,
  }) {
    final distance = (targetPosition - fromPosition).abs();
    final stretchFactor = math.sin(progress * math.pi);
    final maxStretch = (distance * 8.0).clamp(0.0, indicatorDim * 0.35);

    final bubbleWidth = indicatorDim + (stretchFactor * maxStretch);
    final bubbleHeight = indicatorDim - (stretchFactor * maxStretch * 0.15);

    final bubbleCenter = (currentPos * tabWidth) + (tabWidth / 2.0);
    final indicatorLeft = bubbleCenter - (bubbleWidth / 2.0);
    final indicatorTop = (navHeight - bubbleHeight) / 2.0;

    return NavBarBubbleSpec(
      left: indicatorLeft,
      top: indicatorTop,
      width: bubbleWidth,
      height: bubbleHeight,
      borderRadius: indicatorDim / 2.0,
    );
  }

  /// Calculates the opacity of an inactive tab icon and label based on distance to the bubble.
  static double computeInactiveOpacity({
    required double currentPos,
    required int tabIndex,
  }) {
    final dist = (currentPos - tabIndex).abs();
    final coverage = (1.0 - dist * 1.5).clamp(0.0, 1.0);
    return (1.0 - coverage).clamp(0.0, 1.0);
  }

  /// Computes opacity and scale for morphing between active icons.
  static ActiveIconMorphSpec computeActiveIconMorph(double progress) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    return ActiveIconMorphSpec(
      fromOpacity: (1.0 - clampedProgress).clamp(0.0, 1.0),
      fromScale: 0.85 + 0.15 * (1.0 - clampedProgress),
      toOpacity: clampedProgress,
      toScale: 0.85 + 0.15 * clampedProgress,
    );
  }
}
