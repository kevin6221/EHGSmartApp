import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../helpers/vitals_card_calculator.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/painters/heart_rate_chart_painter.dart';

/// Card showing current heart rate, interactive spline area chart, and scrubbed score indicator bubble.
///
/// Matches Figma Node 73:1418 pixel-perfectly with interactive scrubbing matching the Stress card.
class VitalsHeartRateCard extends StatefulWidget {
  final int currentHeartRate;
  final List<double> weeklyHeartRate;
  final VoidCallback? onTap;

  const VitalsHeartRateCard({
    super.key,
    required this.currentHeartRate,
    required this.weeklyHeartRate,
    this.onTap,
  });

  @override
  State<VitalsHeartRateCard> createState() => _VitalsHeartRateCardState();
}

class _VitalsHeartRateCardState extends State<VitalsHeartRateCard> {
  late final ValueNotifier<int> _activeScrubIndexNotifier;

  static const List<String> _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void initState() {
    super.initState();
    // Default scrubber index to the point matching currentHeartRate (72 bpm), or representative point
    final foundIndex = widget.weeklyHeartRate.lastIndexOf(
      widget.currentHeartRate.toDouble(),
    );
    _activeScrubIndexNotifier = ValueNotifier<int>(
      foundIndex != -1
          ? foundIndex
          : (widget.weeklyHeartRate.length > 1
              ? widget.weeklyHeartRate.length - 1
              : 0),
    );
  }

  @override
  void didUpdateWidget(covariant VitalsHeartRateCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weeklyHeartRate != widget.weeklyHeartRate) {
      _activeScrubIndexNotifier.value = _activeScrubIndexNotifier.value.clamp(
        0,
        widget.weeklyHeartRate.isEmpty ? 0 : widget.weeklyHeartRate.length - 1,
      );
    }
  }

  @override
  void dispose() {
    _activeScrubIndexNotifier.dispose();
    super.dispose();
  }

  void _handleScrub(double localX, double width) {
    if (widget.weeklyHeartRate.isEmpty) return;
    final index = VitalsCardCalculator.computeScrubIndex(
      localX: localX,
      totalWidth: width,
      itemCount: widget.weeklyHeartRate.length,
    );
    if (index != _activeScrubIndexNotifier.value) {
      _activeScrubIndexNotifier.value = index;
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final dims = VitalsCardDimensions.fromResponsive(r);
    final chartHeight = (r.height * 0.085).clamp(65.0, 85.0);

    return AppCard(
      padding: EdgeInsets.all(dims.cardPadding),
      borderRadius: BorderRadius.circular(dims.cardRadius),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowNavy.withValues(alpha: 0.04),
          blurRadius: 16.0,
          offset: const Offset(0, 4),
        ),
      ],
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header (Heart Icon + Title on Left, Value bpm on Right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const AppSvgIcon(
                    AppIcons.heartPulse,
                    size: 18.0,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    'Heart Rate',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: dims.titleFontSize,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              ValueListenableBuilder<int>(
                valueListenable: _activeScrubIndexNotifier,
                builder: (context, activeIndex, _) {
                  final displayRate = activeIndex < widget.weeklyHeartRate.length
                      ? widget.weeklyHeartRate[activeIndex].round()
                      : widget.currentHeartRate;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$displayRate',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: dims.valueFontSize,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        'bpm',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(14.0),
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          SizedBox(height: dims.itemSpacing),

          // 2. Interactive Area Chart with Scrubber and Floating Callout Bubble
          LayoutBuilder(
            builder: (context, constraints) {
              final chartWidth = constraints.maxWidth;
              final double minVal = widget.weeklyHeartRate.isNotEmpty
                  ? widget.weeklyHeartRate.reduce((a, b) => a < b ? a : b)
                  : 0.0;
              final double maxVal = widget.weeklyHeartRate.isNotEmpty
                  ? widget.weeklyHeartRate.reduce((a, b) => a > b ? a : b)
                  : 1.0;
              final double range =
                  (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);
              const double topPadding = 6.0;
              const double bottomPadding = 6.0;
              final double usableHeight =
                  chartHeight - topPadding - bottomPadding;

              final List<Offset> points = [];
              for (int i = 0; i < widget.weeklyHeartRate.length; i++) {
                final double x = (i / (widget.weeklyHeartRate.length - 1)) *
                    chartWidth;
                final double normalized =
                    (widget.weeklyHeartRate[i] - minVal) / range;
                final double y =
                    chartHeight - bottomPadding - (normalized * usableHeight);
                points.add(Offset(x, y));
              }

              const bubbleWidth = 48.0;
              const bubbleHeight = 32.0;

              return GestureDetector(
                onHorizontalDragDown: (details) =>
                    _handleScrub(details.localPosition.dx, chartWidth),
                onHorizontalDragUpdate: (details) =>
                    _handleScrub(details.localPosition.dx, chartWidth),
                onTapDown: (details) =>
                    _handleScrub(details.localPosition.dx, chartWidth),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: chartWidth,
                  height: chartHeight,
                  child: ValueListenableBuilder<int>(
                    valueListenable: _activeScrubIndexNotifier,
                    builder: (context, activeIndex, _) {
                      final safeIndex = activeIndex.clamp(
                        0,
                        points.isNotEmpty ? points.length - 1 : 0,
                      );
                      final activePt = points.isNotEmpty
                          ? points[safeIndex]
                          : Offset(chartWidth * 0.5, chartHeight * 0.5);

                      final currentBpm = widget.weeklyHeartRate.isNotEmpty &&
                              safeIndex < widget.weeklyHeartRate.length
                          ? widget.weeklyHeartRate[safeIndex].round()
                          : widget.currentHeartRate;

                      final bubbleLeft = (activePt.dx - bubbleWidth / 2).clamp(
                        0.0,
                        chartWidth - bubbleWidth,
                      );
                      final bubbleTop = activePt.dy - bubbleHeight - 8.0;

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Area Chart with Scrubber and Line
                          RepaintBoundary(
                            child: CustomPaint(
                              size: Size(chartWidth, chartHeight),
                              painter: HeartRateChartPainter(
                                values: widget.weeklyHeartRate,
                                activeIndex: activeIndex,
                                lineColor: AppColors.primary,
                                strokeWidth: 2.5,
                                showFill: true,
                              ),
                            ),
                          ),

                          // Floating Callout Bubble with Heart Rate Value
                          Positioned(
                            left: bubbleLeft,
                            top: bubbleTop,
                            child: Container(
                              width: bubbleWidth,
                              height: bubbleHeight,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.35),
                                  width: 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.shadowNavy
                                        .withValues(alpha: 0.08),
                                    blurRadius: 8.0,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                '$currentBpm',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: r.font(15.0),
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8.0),

          // 3. Weekday Labels
          ValueListenableBuilder<int>(
            valueListenable: _activeScrubIndexNotifier,
            builder: (context, activeIndex, _) {
              final int activeWeekdayIndex = widget.weeklyHeartRate.length > 1
                  ? (activeIndex /
                          (widget.weeklyHeartRate.length - 1) *
                          (_weekdays.length - 1))
                      .round()
                  : activeIndex;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_weekdays.length, (i) {
                  final isSelected = activeWeekdayIndex == i;
                  return Text(
                    _weekdays[i],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.0,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w400,
                      color:
                          isSelected ? AppColors.primary : AppColors.tertiary,
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}
