import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../painters/sparkline_painter.dart';

/// Lightweight UI widget that displays a sparkline trend chart.
class SparklineChart extends StatelessWidget {
  final List<double> values;
  final Color lineColor;
  final bool showFill;
  final double height;
  final double width;
  final double strokeWidth;

  const SparklineChart({
    super.key,
    required this.values,
    this.lineColor = AppColors.primary,
    this.showFill = true,
    this.height = 40,
    this.width = 110,
    this.strokeWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(width, height),
        painter: SparklinePainter(
          values: values,
          lineColor: lineColor,
          showFill: showFill,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}
