import 'package:flutter/material.dart';

import '../../../core/constants/app_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../painters/figma_loader_painter.dart';

/// Standalone animated circular loader widget matching Figma design specifications.
class FigmaCircularLoader extends StatefulWidget {
  final double size;
  final Color trackColor;
  final Color indicatorColor;
  final double strokeWidth;
  final Duration duration;

  const FigmaCircularLoader({
    super.key,
    this.size = 56.0,
    this.trackColor = AppColors.loaderTrack,
    this.indicatorColor = AppColors.white,
    this.strokeWidth = 5.5,
    this.duration = AppDurations.loaderSpin,
  });

  @override
  State<FigmaCircularLoader> createState() => _FigmaCircularLoaderState();
}

class _FigmaCircularLoaderState extends State<FigmaCircularLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: RotationTransition(
          turns: _controller,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: FigmaLoaderPainter(
              trackColor: widget.trackColor,
              indicatorColor: widget.indicatorColor,
              strokeWidth: widget.strokeWidth,
            ),
          ),
        ),
      ),
    );
  }
}
