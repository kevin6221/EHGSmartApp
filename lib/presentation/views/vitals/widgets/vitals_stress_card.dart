import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../helpers/vitals_card_calculator.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/painters/stress_chart_painter.dart';

/// Card showing current stress status, interactive timeline area chart, and scrubbed score indicator bubble.
///
/// Matches Figma Node 71:1042 pixel-perfectly with cyan theme and interactive scrubbing.
class VitalsStressCard extends StatefulWidget {
  final int stressScore;
  final String stressStatus;
  final List<double> stressTimeline;
  final VoidCallback? onTap;

  const VitalsStressCard({
    super.key,
    required this.stressScore,
    required this.stressStatus,
    required this.stressTimeline,
    this.onTap,
  });

  @override
  State<VitalsStressCard> createState() => _VitalsStressCardState();
}

class _VitalsStressCardState extends State<VitalsStressCard> {
  late final ValueNotifier<int> _activeScrubIndexNotifier;

  @override
  void initState() {
    super.initState();
    // Default scrubber index to the highest or representative point (index ~8-10 of timeline)
    _activeScrubIndexNotifier = ValueNotifier<int>(
      widget.stressTimeline.length > 9
          ? 9
          : (widget.stressTimeline.length - 1),
    );
  }

  @override
  void didUpdateWidget(covariant VitalsStressCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stressTimeline != widget.stressTimeline) {
      _activeScrubIndexNotifier.value = _activeScrubIndexNotifier.value.clamp(
        0,
        widget.stressTimeline.isEmpty ? 0 : widget.stressTimeline.length - 1,
      );
    }
  }

  @override
  void dispose() {
    _activeScrubIndexNotifier.dispose();
    super.dispose();
  }

  void _handleScrub(double localX, double width) {
    if (widget.stressTimeline.isEmpty) return;
    final index = VitalsCardCalculator.computeScrubIndex(
      localX: localX,
      totalWidth: width,
      itemCount: widget.stressTimeline.length,
    );
    if (index != _activeScrubIndexNotifier.value) {
      _activeScrubIndexNotifier.value = index;
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final dims = VitalsCardDimensions.fromResponsive(r);
    final chartHeight = (r.height * 0.12).clamp(80.0, 110.0);

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
          // 1. Header (Icon + Title on Left, Status Pill on Right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const AppSvgIcon(
                    AppIcons.stressVital,
                    size: 18.0,
                    color: AppColors.cyanAccent,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    'Stress',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: dims.titleFontSize,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(7.0),
                ),
                child: Text(
                  widget.stressScore > 0 ? widget.stressStatus.toUpperCase() : '--',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                    fontSize: r.font(12.0),
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: dims.itemSpacing),

          // 2. Interactive Area Chart with Scrubber and Floating Callout Bubble
          LayoutBuilder(
            builder: (context, constraints) {
              final chartWidth = constraints.maxWidth;
              final points = VitalsCardCalculator.computeNormalizedPoints(
                values: widget.stressTimeline,
                size: Size(chartWidth, chartHeight),
                topPadding: 16.0,
                bottomPadding: 16.0,
              );

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
                          : Offset(chartWidth * 0.75, chartHeight * 0.3);

                      final currentScore = widget.stressTimeline.isNotEmpty
                          ? widget.stressTimeline[safeIndex].round()
                          : widget.stressScore;

                      final bubbleLeft = (activePt.dx - bubbleWidth / 2).clamp(
                        0.0,
                        chartWidth - bubbleWidth,
                      );
                      final bubbleTop = (activePt.dy - bubbleHeight - 8.0).clamp(
                        0.0,
                        chartHeight - bubbleHeight,
                      );

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Area Chart with Guidelines and Line
                          RepaintBoundary(
                            child: CustomPaint(
                              size: Size(chartWidth, chartHeight),
                              painter: StressChartPainter(
                                values: widget.stressTimeline,
                                activeIndex: activeIndex,
                                lineColor: AppColors.cyanAccent,
                                showGuidelines: true,
                              ),
                            ),
                          ),

                          if (widget.stressTimeline.length < 2)
                            Center(
                              child: Text(
                                'No stress records yet',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.tertiary,
                                ),
                              ),
                            ),

                          // Floating Callout Bubble with Score
                          if (widget.stressTimeline.length >= 2 && currentScore > 0)
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
                                    color: AppColors.cyanAccent.withValues(alpha: 0.4),
                                    width: 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.shadowNavy.withValues(alpha: 0.08),
                                      blurRadius: 8.0,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '$currentScore',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: r.font(16.0),
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
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
        ],
      ),
    );
  }
}
