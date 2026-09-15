import 'package:flutter/material.dart';

/// Custom painter for rendering the sine wave with circular bead marker matching Figma Vector 248-251.
class TrendWavePainter extends CustomPainter {
  final Color waveColor;
  final bool isUpTrend;

  const TrendWavePainter({
    required this.waveColor,
    this.isUpTrend = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Faint soft shadow wave offset slightly downward
    final shadowPaint = Paint()
      ..color = waveColor.withValues(alpha: 0.18)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final shadowPath = Path();
    if (isUpTrend) {
      // S-curve rising towards top-right
      shadowPath.moveTo(0, h * 0.72 + 3);
      shadowPath.cubicTo(w * 0.20, h * 0.40 + 3, w * 0.35, h * 0.95 + 3, w * 0.55, h * 0.55 + 3);
      shadowPath.cubicTo(w * 0.75, h * 0.25 + 3, w * 0.85, h * 0.70 + 3, w - 5, h * 0.22 + 3);
    } else {
      // S-curve dipping and rising towards right
      shadowPath.moveTo(0, h * 0.45 + 3);
      shadowPath.cubicTo(w * 0.15, h * 0.30 + 3, w * 0.30, h * 0.95 + 3, w * 0.55, h * 0.70 + 3);
      shadowPath.cubicTo(w * 0.75, h * 0.50 + 3, w * 0.85, h * 0.60 + 3, w - 5, h * 0.25 + 3);
    }
    canvas.drawPath(shadowPath, shadowPaint);

    // Main wave line
    final linePaint = Paint()
      ..color = waveColor
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final linePath = Path();
    final Offset endPoint;

    if (isUpTrend) {
      linePath.moveTo(0, h * 0.72);
      linePath.cubicTo(w * 0.20, h * 0.40, w * 0.35, h * 0.95, w * 0.55, h * 0.55);
      linePath.cubicTo(w * 0.75, h * 0.25, w * 0.85, h * 0.70, w - 5, h * 0.22);
      endPoint = Offset(w - 5, h * 0.22);
    } else {
      linePath.moveTo(0, h * 0.45);
      linePath.cubicTo(w * 0.15, h * 0.30, w * 0.30, h * 0.95, w * 0.55, h * 0.70);
      linePath.cubicTo(w * 0.75, h * 0.50, w * 0.85, h * 0.60, w - 5, h * 0.25);
      endPoint = Offset(w - 5, h * 0.25);
    }
    canvas.drawPath(linePath, linePaint);

    // Open circular bead at the end of the wave (matching Figma Ellipse 208 & 209)
    final beadFillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(endPoint, 4.0, beadFillPaint);

    final beadStrokePaint = Paint()
      ..color = waveColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(endPoint, 4.0, beadStrokePaint);
  }

  @override
  bool shouldRepaint(covariant TrendWavePainter oldDelegate) {
    return oldDelegate.waveColor != waveColor ||
        oldDelegate.isUpTrend != isUpTrend;
  }
}
