import 'package:flutter/material.dart';

import '../../../data/models/wellness_data_model.dart';
import '../painters/wave_chart_painter.dart';

/// Clean UI widget that displays the interactive daytime wellness wave chart.
/// Supports horizontal dragging and tapping to scrub and inspect scores at different times.
/// Zero setState architecture via ValueNotifier and ValueListenableBuilder.
class WaveChart extends StatelessWidget {
  final List<DayChartPoint> points;
  final double animationProgress;
  final ValueNotifier<int?>? activePointNotifier;

  WaveChart({
    super.key,
    required this.points,
    this.animationProgress = 1.0,
    this.activePointNotifier,
  }) : _internalActivePoint = activePointNotifier ?? ValueNotifier<int?>(null);

  final ValueNotifier<int?> _internalActivePoint;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2.2,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          void updateScrubPosition(Offset localPosition) {
            if (points.isEmpty) return;
            final double fraction = (localPosition.dx / width).clamp(0.0, 1.0);
            final int index = (fraction * (points.length - 1)).round();
            _internalActivePoint.value = index;
          }

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) => updateScrubPosition(details.localPosition),
            onHorizontalDragStart: (details) => updateScrubPosition(details.localPosition),
            onHorizontalDragUpdate: (details) => updateScrubPosition(details.localPosition),
            child: ValueListenableBuilder<int?>(
              valueListenable: _internalActivePoint,
              builder: (context, activeIndex, _) {
                return RepaintBoundary(
                  child: CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: WaveChartPainter(
                      points: points,
                      progress: animationProgress,
                      activePointIndex: activeIndex,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
