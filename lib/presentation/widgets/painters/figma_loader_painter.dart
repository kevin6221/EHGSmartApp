import 'package:flutter/material.dart';

/// Custom painter for the Figma-styled circular loader with a subtle track
/// and a prominent rounded-cap arc.
class FigmaLoaderPainter extends CustomPainter {
  final Color trackColor;
  final Color indicatorColor;
  final double strokeWidth;

  const FigmaLoaderPainter({
    this.trackColor = const Color(0x33FFFFFF),
    this.indicatorColor = Colors.white,
    this.strokeWidth = 5.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 1. Background full circle track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // 2. Rotating active arc with rounded stroke caps (Figma node 3:749)
    final arcPaint = Paint()
      ..color = indicatorColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Sweeps ~135 degrees (2.35 radians)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.57,
      2.35,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant FigmaLoaderPainter oldDelegate) =>
      oldDelegate.trackColor != trackColor ||
      oldDelegate.indicatorColor != indicatorColor ||
      oldDelegate.strokeWidth != strokeWidth;
}
