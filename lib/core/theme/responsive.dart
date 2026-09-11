import 'package:flutter/material.dart';

/// Comprehensive responsive sizing utility for phone and tablet form factors across Android & iOS.
class Responsive {
  final BuildContext context;
  late final MediaQueryData _media;

  Responsive(this.context) {
    _media = MediaQuery.of(context);
  }

  double get width => _media.size.width;
  double get height => _media.size.height;
  double get topPadding => _media.padding.top;
  double get bottomPadding => _media.padding.bottom;
  double get viewInsetsBottom => _media.viewInsets.bottom;

  bool get isSmall => width < 360;
  bool get isMedium => width >= 360 && width < 420;
  bool get isLarge => width >= 420 && width < 600;
  bool get isTablet => width >= 600;

  /// Proportional horizontal padding (5% on phones, up to 10% on tablets/foldables)
  double get horizontalPadding {
    if (isTablet) return width * 0.15;
    if (isSmall) return 14.0;
    return (width * 0.05).clamp(16.0, 24.0);
  }

  /// Proportional vertical padding
  double get verticalPadding => (height * 0.015).clamp(10.0, 20.0);

  /// Safe scaled width fraction
  double wp(double percent) => (width * percent).clamp(0.0, width);

  /// Safe scaled height fraction
  double hp(double percent) => (height * percent).clamp(0.0, height);

  /// Clamped font scaling that respects user accessibility while preventing layout overflow
  double font(double size) {
    final scale = _media.textScaler.scale(size) / size;
    final clampedScale = scale.clamp(0.85, 1.25);
    return size * clampedScale;
  }
}

extension ResponsiveExtension on BuildContext {
  Responsive get responsive => Responsive(this);
}
