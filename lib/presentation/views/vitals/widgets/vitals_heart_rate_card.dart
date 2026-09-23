import 'package:flutter/foundation.dart';
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
    // Default scrubber index to the recorded day or last non-zero day
    final foundIndex = widget.weeklyHeartRate.lastIndexOf(
      widget.currentHeartRate.toDouble(),
    );
    final firstValidIndex = widget.weeklyHeartRate.indexWhere((v) => v > 0);

    _activeScrubIndexNotifier = ValueNotifier<int>(
      foundIndex != -1
          ? foundIndex
          : (firstValidIndex != -1
              ? firstValidIndex
              : (widget.weeklyHeartRate.length > 1
                  ? widget.weeklyHeartRate.length - 1
                  : 0)),
    );
  }

  @override
  void didUpdateWidget(covariant VitalsHeartRateCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.weeklyHeartRate, widget.weeklyHeartRate) ||
        oldWidget.currentHeartRate != widget.currentHeartRate) {
      final maxIdx = widget.weeklyHeartRate.isEmpty ? 0 : widget.weeklyHeartRate.length - 1;
      final foundIndex = widget.weeklyHeartRate.lastIndexOf(
        widget.currentHeartRate.toDouble(),
      );
      final firstValidIndex = widget.weeklyHeartRate.indexWhere((v) => v > 0);

      if (foundIndex != -1) {
        _activeScrubIndexNotifier.value = foundIndex;
      } else if (firstValidIndex != -1) {
        _activeScrubIndexNotifier.value = firstValidIndex;
      } else {
        _activeScrubIndexNotifier.value = _activeScrubIndexNotifier.value.clamp(0, maxIdx);
      }
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
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
              ValueListenableBuilder<int>(
                valueListenable: _activeScrubIndexNotifier,
                builder: (context, activeIndex, _) {
                  final displayRate = activeIndex < widget.weeklyHeartRate.length
                      ? widget.weeklyHeartRate[activeIndex].round()
                      : 0;

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
              final List<double> validValues = widget.weeklyHeartRate.where((v) => v > 0).toList();
              final double maxVal = validValues.isNotEmpty
                  ? validValues.reduce((a, b) => a > b ? a : b)
                  : (widget.currentHeartRate > 0 ? widget.currentHeartRate.toDouble() : 100.0);
              const double topPadding = 6.0;
              const double bottomPadding = 6.0;
              final double usableHeight = chartHeight - topPadding - bottomPadding;

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
                      final totalSlots = widget.weeklyHeartRate.length >= 7 ? 7 : (widget.weeklyHeartRate.length > 1 ? widget.weeklyHeartRate.length : 1);
                      final safeActiveIdx = activeIndex.clamp(0, totalSlots - 1);
                      final double activeX = totalSlots > 1 ? (safeActiveIdx / (totalSlots - 1)) * chartWidth : chartWidth * 0.5;

                      final currentBpm = safeActiveIdx < widget.weeklyHeartRate.length
                          ? widget.weeklyHeartRate[safeActiveIdx].round()
                          : 0;
                      final double val = currentBpm > 0 ? currentBpm.toDouble() : 0.0;
                      final double normalized = maxVal > 0 ? (val / maxVal).clamp(0.0, 1.0) : 0.0;
                      final double activeY = chartHeight - bottomPadding - (normalized * usableHeight);

                      final bubbleLeft = (activeX - bubbleWidth / 2).clamp(
                        0.0,
                        chartWidth - bubbleWidth,
                      );
                      final bubbleTop = (activeY - bubbleHeight - 8.0).clamp(0.0, chartHeight - bubbleHeight);

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Area Chart with Scrubber and Line
                          if (widget.weeklyHeartRate.any((v) => v > 0))
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
                            )
                          else
                            Center(
                              child: Text(
                                'No heart rate history yet',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w500,
                                  color: context.textSecondary,
                                ),
                              ),
                            ),

                          // Floating Callout Bubble with Heart Rate Value
                          if (widget.weeklyHeartRate.any((v) => v > 0) && currentBpm > 0)
                            Positioned(
                              left: bubbleLeft,
                              top: bubbleTop,
                              child: Container(
                                width: bubbleWidth,
                                height: bubbleHeight,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: context.cardBackground,
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
                          isSelected ? AppColors.primary : context.textSecondary,
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
