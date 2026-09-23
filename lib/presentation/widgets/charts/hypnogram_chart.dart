import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../../data/models/vitals_model.dart';
import '../painters/hypnogram_painter.dart';

/// Clean UI widget displaying the sleep hypnogram stages, timeline, and interactive interval tooltip.
class HypnogramChart extends StatefulWidget {
  final List<SleepInterval> intervals;

  const HypnogramChart({super.key, required this.intervals});

  @override
  State<HypnogramChart> createState() => _HypnogramChartState();
}

class _HypnogramChartState extends State<HypnogramChart> {
  final ValueNotifier<int> _selectedIndexNotifier = ValueNotifier<int>(3);

  @override
  void didUpdateWidget(covariant HypnogramChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.intervals != widget.intervals) {
      _selectedIndexNotifier.value = _selectedIndexNotifier.value.clamp(
        0,
        widget.intervals.isEmpty ? 0 : widget.intervals.length - 1,
      );
    }
  }

  @override
  void dispose() {
    _selectedIndexNotifier.dispose();
    super.dispose();
  }

  void _onTapChart(double localX, double width) {
    if (widget.intervals.isEmpty || width <= 0) return;
    final fraction = (localX / width).clamp(0.0, 1.0);

    for (int i = 0; i < widget.intervals.length; i++) {
      final it = widget.intervals[i];
      if (fraction >= it.startOffset &&
          fraction <= (it.startOffset + it.widthFraction)) {
        if (_selectedIndexNotifier.value != i) {
          _selectedIndexNotifier.value = i;
        }
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final chartHeight = (r.height * 0.165).clamp(120.0, 160.0);
    final yAxisWidth = (r.width * 0.12).clamp(40.0, 56.0);
    final legendSpacing = (r.height * 0.021).clamp(14.0, 22.0);

    return Column(
      children: [
        // 1. Legend row (Figma Node 73:1323-1332)
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _LegendItem(color: AppColors.hypnogramDeep, label: 'Deep'),
            _LegendItem(color: AppColors.hypnogramLight, label: 'Light'),
            _LegendItem(color: AppColors.hypnogramRem, label: 'REM'),
            _LegendItem(color: AppColors.hypnogramAwake, label: 'Awake'),
          ],
        ),
        SizedBox(height: legendSpacing),

        // 2. Hypnogram display with Y-axis labels and interactive tooltip
        LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final chartAreaWidth = totalWidth - yAxisWidth;

            return SizedBox(
              height: chartHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Row(
                    children: [
                      // Y-axis Phase labels
                      SizedBox(
                        width: yAxisWidth,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Deep',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.0,
                                color: AppColors.tertiary,
                              ),
                            ),
                            Text(
                              'REM',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.0,
                                color: AppColors.tertiary,
                              ),
                            ),
                            Text(
                              'Light',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.0,
                                color: AppColors.tertiary,
                              ),
                            ),
                            Text(
                              'Awake',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.0,
                                color: AppColors.tertiary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Chart Area (Interactive on tap or scrub)
                      Expanded(
                        child: GestureDetector(
                          onTapDown: (details) => _onTapChart(
                            details.localPosition.dx,
                            chartAreaWidth,
                          ),
                          onHorizontalDragUpdate: (details) => _onTapChart(
                            details.localPosition.dx,
                            chartAreaWidth,
                          ),
                          behavior: HitTestBehavior.opaque,
                          child: RepaintBoundary(
                            child: CustomPaint(
                              size: Size(chartAreaWidth, chartHeight),
                              painter: HypnogramPainter(
                                intervals: widget.intervals,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Empty State Message or Floating Tooltip Popup overlay
                  if (widget.intervals.isEmpty)
                    Positioned.fill(
                      left: yAxisWidth,
                      child: Center(
                        child: Text(
                          'No sleep recorded yet',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                            color: AppColors.tertiary,
                          ),
                        ),
                      ),
                    ),
                  if (widget.intervals.isNotEmpty)
                    ValueListenableBuilder<int>(
                      valueListenable: _selectedIndexNotifier,
                      builder: (context, selectedIndex, _) {
                        final selectedInterval = widget.intervals.isNotEmpty &&
                                selectedIndex < widget.intervals.length
                            ? widget.intervals[selectedIndex]
                            : null;

                        final String phaseName = selectedInterval != null
                            ? switch (selectedInterval.phase) {
                                SleepPhase.deep => 'Deep Sleep',
                                SleepPhase.rem => 'REM Sleep',
                                SleepPhase.light => 'Light Sleep',
                                SleepPhase.awake => 'Awake',
                              }
                            : 'Deep Sleep';

                        final double tooltipLeft;
                        if (selectedInterval != null) {
                          final centerFraction = selectedInterval.startOffset +
                              (selectedInterval.widthFraction / 2);
                          final rawX =
                              yAxisWidth + (centerFraction * chartAreaWidth);
                          tooltipLeft = (rawX - 60.0)
                              .clamp(yAxisWidth, totalWidth - 125.0);
                        } else {
                          tooltipLeft = totalWidth - 140.0;
                        }

                        return Positioned(
                          top: 0,
                          left: tooltipLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 6.0,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.chartDarkBg,
                              borderRadius: BorderRadius.circular(6.0),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.black.withValues(alpha: 0.15),
                                  blurRadius: 8.0,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  phaseName,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.white,
                                    fontSize: 9.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2.0),
                                Text(
                                  selectedInterval?.timeRangeText ?? '11:15 pm → 01:30 am (2h 15m)',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.white70,
                                    fontSize: 8.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16.0,
          height: 16.0,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6.0),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textSecondary,
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
