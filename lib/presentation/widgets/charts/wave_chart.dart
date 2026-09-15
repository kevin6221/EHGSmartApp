import 'package:flutter/material.dart';

import '../../../data/models/wellness_data_model.dart';
import '../../helpers/wave_chart_calculator.dart';
import '../painters/wave_chart_painter.dart';

/// Clean UI widget that displays the interactive daytime wellness wave chart.
/// Supports horizontal dragging and tapping to scrub and inspect scores at different times.
/// Managed lifecycle with zero memory leaks and pure calculation delegation.
class WaveChart extends StatefulWidget {
  final List<DayChartPoint> points;
  final double animationProgress;
  final ValueNotifier<int?>? activePointNotifier;

  const WaveChart({
    super.key,
    required this.points,
    this.animationProgress = 1.0,
    this.activePointNotifier,
  });

  @override
  State<WaveChart> createState() => _WaveChartState();
}

class _WaveChartState extends State<WaveChart> {
  ValueNotifier<int?>? _internalNotifier;

  ValueNotifier<int?> get _effectiveNotifier =>
      widget.activePointNotifier ??
      (_internalNotifier ??= ValueNotifier<int?>(null));

  @override
  void initState() {
    super.initState();
    if (widget.activePointNotifier == null) {
      _internalNotifier = ValueNotifier<int?>(null);
    }
  }

  @override
  void didUpdateWidget(covariant WaveChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activePointNotifier != oldWidget.activePointNotifier) {
      if (widget.activePointNotifier == null && _internalNotifier == null) {
        _internalNotifier = ValueNotifier<int?>(
          oldWidget.activePointNotifier?.value,
        );
      } else if (widget.activePointNotifier != null &&
          _internalNotifier != null) {
        _internalNotifier!.dispose();
        _internalNotifier = null;
      }
    }
  }

  @override
  void dispose() {
    _internalNotifier?.dispose();
    super.dispose();
  }

  void _updateScrubPosition(Offset localPosition, double totalWidth) {
    final index = WaveChartCalculator.calculateScrubIndex(
      localX: localPosition.dx,
      totalWidth: totalWidth,
      pointCount: widget.points.length,
    );
    if (index != null) {
      _effectiveNotifier.value = index;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2.2,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) =>
                _updateScrubPosition(details.localPosition, width),
            onHorizontalDragStart: (details) =>
                _updateScrubPosition(details.localPosition, width),
            onHorizontalDragUpdate: (details) =>
                _updateScrubPosition(details.localPosition, width),
            child: ValueListenableBuilder<int?>(
              valueListenable: _effectiveNotifier,
              builder: (context, activeIndex, _) {
                return RepaintBoundary(
                  child: CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: WaveChartPainter(
                      points: widget.points,
                      progress: widget.animationProgress,
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
