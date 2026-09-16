import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// A reusable horizontal dotted divider with customizable dash width, gap, and color.
class DottedDivider extends StatelessWidget {
  final double height;
  final double thickness;
  final double dashWidth;
  final double dashSpace;
  final Color color;

  const DottedDivider({
    super.key,
    this.height = 1.0,
    this.thickness = 1.0,
    this.dashWidth = 3.0,
    this.dashSpace = 3.0,
    this.color = AppColors.systemCardBorder,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size(double.infinity, height),
        painter: _DottedDividerPainter(
          color: color,
          thickness: thickness,
          dashWidth: dashWidth,
          dashSpace: dashSpace,
        ),
      ),
    );
  }
}

class _DottedDividerPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final double dashWidth;
  final double dashSpace;

  const _DottedDividerPainter({
    required this.color,
    required this.thickness,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke;

    final y = size.height / 2;
    double currentX = 0.0;
    while (currentX < size.width) {
      final nextX = (currentX + dashWidth).clamp(0.0, size.width);
      canvas.drawLine(Offset(currentX, y), Offset(nextX, y), paint);
      currentX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DottedDividerPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.thickness != thickness ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace;
  }
}
