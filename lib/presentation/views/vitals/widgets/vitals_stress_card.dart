import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_animations.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/engine/recommendation_engine.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../helpers/vitals_card_calculator.dart';
import '../../../widgets/painters/stress_chart_painter.dart';
import 'vitals_interpretation_section.dart';

/// Card showing current stress status, interactive timeline area chart, and scrubbed score indicator bubble.
///
/// Expandable to reveal "What it is", "Your reading", and "Do this" actionable guidance matching Figma Node 119:1442.
class VitalsStressCard extends StatefulWidget {
  final int stressScore;
  final String stressStatus;
  final List<double> stressTimeline;
  final VoidCallback? onTap;
  final ValueNotifier<bool>? isExpandedNotifier;
  final VoidCallback? onExpandChanged;
  final String? whatItIs;
  final String? yourReading;
  final String? doThis;

  const VitalsStressCard({
    super.key,
    required this.stressScore,
    required this.stressStatus,
    required this.stressTimeline,
    this.onTap,
    this.isExpandedNotifier,
    this.onExpandChanged,
    this.whatItIs,
    this.yourReading,
    this.doThis,
  });

  @override
  State<VitalsStressCard> createState() => _VitalsStressCardState();
}

class _VitalsStressCardState extends State<VitalsStressCard>
    with SingleTickerProviderStateMixin {
  late final ValueNotifier<int> _activeScrubIndexNotifier;
  late final ValueNotifier<bool> _expandedNotifier;
  bool _internalNotifierAllocated = false;
  late final AnimationController _animController;
  late final Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    final int todayIdx = (DateTime.now().weekday - 1).clamp(0, 6);
    final maxIdx = widget.stressTimeline.isEmpty ? 6 : widget.stressTimeline.length - 1;
    _activeScrubIndexNotifier = ValueNotifier<int>(todayIdx.clamp(0, maxIdx));

    if (widget.isExpandedNotifier != null) {
      _expandedNotifier = widget.isExpandedNotifier!;
    } else {
      _expandedNotifier = ValueNotifier<bool>(false);
      _internalNotifierAllocated = true;
    }

    _animController = AnimationController(
      duration: AppDurations.cardExpand,
      vsync: this,
    );
    _heightFactor = CurvedAnimation(
      parent: _animController,
      curve: Curves.fastOutSlowIn,
    );
    if (_expandedNotifier.value) {
      _animController.value = 1.0;
    }
    _expandedNotifier.addListener(_handleNotifierChange);
  }

  void _handleNotifierChange() {
    if (_expandedNotifier.value) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  @override
  void didUpdateWidget(covariant VitalsStressCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.stressTimeline, widget.stressTimeline) ||
        oldWidget.stressScore != widget.stressScore) {
      final int todayIdx = (DateTime.now().weekday - 1).clamp(0, 6);
      final maxIdx = widget.stressTimeline.isEmpty ? 6 : widget.stressTimeline.length - 1;
      _activeScrubIndexNotifier.value = todayIdx.clamp(0, maxIdx);
    }

    if (widget.isExpandedNotifier != null &&
        widget.isExpandedNotifier != _expandedNotifier) {
      _expandedNotifier.removeListener(_handleNotifierChange);
      if (_internalNotifierAllocated) {
        _expandedNotifier.dispose();
        _internalNotifierAllocated = false;
      }
      _expandedNotifier = widget.isExpandedNotifier!;
      _expandedNotifier.addListener(_handleNotifierChange);
      if (_expandedNotifier.value) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _activeScrubIndexNotifier.dispose();
    _expandedNotifier.removeListener(_handleNotifierChange);
    _animController.dispose();
    if (_internalNotifierAllocated) {
      _expandedNotifier.dispose();
    }
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

  void _toggleExpanded() {
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      _expandedNotifier.value = !_expandedNotifier.value;
      widget.onExpandChanged?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final dims = VitalsCardDimensions.fromResponsive(r);
    final chartHeight = (r.height * 0.12).clamp(80.0, 110.0);

    final rec = (widget.whatItIs != null && widget.yourReading != null && widget.doThis != null)
        ? MetricRecommendation(
            status: widget.stressStatus,
            whatItIs: widget.whatItIs!,
            yourReading: widget.yourReading!,
            doThis: widget.doThis!,
          )
        : RecommendationEngine.getStressRecommendation(
            widget.stressScore,
            widget.stressTimeline,
          );

    return AnimatedBuilder(
      animation: _heightFactor,
      builder: (context, _) {
        final progress = _heightFactor.value;
        final isClosed = _animController.isDismissed && !_expandedNotifier.value;

        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: context.cardBackground,
            borderRadius: BorderRadius.circular(dims.cardRadius),
            boxShadow: context.isDark
                ? []
                : [
                    BoxShadow(
                      color: AppColors.shadowNavy.withValues(alpha: 0.04),
                      blurRadius: 16.0,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Stack(
            children: [
              // 1. Collapsed subtle border layer
              if (progress < 1.0)
                Positioned.fill(
                  child: Opacity(
                    opacity: (1.0 - progress).clamp(0.0, 1.0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(dims.cardRadius),
                        border: Border.all(
                          color: context.cardBorder,
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),

              // 2. Figma Node 119:1442 Expanded Gradient & Primary Blue Border
              if (progress > 0.0)
                Positioned.fill(
                  child: Opacity(
                    opacity: progress.clamp(0.0, 1.0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(dims.cardRadius),
                        gradient: context.isDark
                            ? null
                            : AppGradients.vitalsExpandedCard,
                        color: context.isDark ? context.cardBackground : null,
                        border: Border.all(
                          color: AppColors.primary,
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),

              // 3. Card Content & Tap Handler
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _toggleExpanded,
                  borderRadius: BorderRadius.circular(dims.cardRadius),
                  child: Padding(
                    padding: EdgeInsets.all(dims.cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header (Icon + Title on Left, Status Pill on Right)
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
                                    color: context.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: AppColors.cyanAccent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Text(
                                widget.stressStatus.isNotEmpty
                                    ? widget.stressStatus
                                    : (rec.status.isNotEmpty ? rec.status : 'Normal'),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: r.font(12.0),
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.cyanAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: dims.itemSpacing),

                        // Interactive Timeline Chart with Scrubber and Floating Score Bubble
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final chartWidth = constraints.maxWidth;
                            const bubbleWidth = 44.0;
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
                                    final totalSlots = widget.stressTimeline.length >= 7 ? 7 : (widget.stressTimeline.length > 1 ? widget.stressTimeline.length : 1);
                                    final safeActiveIdx = activeIndex.clamp(0, totalSlots - 1);
                                    final double activeX = totalSlots > 1 ? (safeActiveIdx / (totalSlots - 1)) * chartWidth : chartWidth * 0.5;

                                    final currentScore = safeActiveIdx < widget.stressTimeline.length
                                        ? widget.stressTimeline[safeActiveIdx].round()
                                        : widget.stressScore;
                                    final double normalized = (currentScore / 100.0).clamp(0.0, 1.0);
                                    final double activeY = chartHeight - (normalized * chartHeight * 0.85) - 6.0;

                                    final bubbleLeft = (activeX - bubbleWidth / 2).clamp(
                                      0.0,
                                      chartWidth - bubbleWidth,
                                    );
                                    final bubbleTop = (activeY - bubbleHeight - 6.0).clamp(0.0, chartHeight - bubbleHeight);

                                    return Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        if (widget.stressTimeline.any((v) => v > 0))
                                          RepaintBoundary(
                                            child: CustomPaint(
                                              size: Size(chartWidth, chartHeight),
                                              painter: StressChartPainter(
                                                values: widget.stressTimeline,
                                                activeIndex: activeIndex,
                                                lineColor: AppColors.cyanAccent,
                                              ),
                                            ),
                                          ),

                                        if (!widget.stressTimeline.any((v) => v > 0))
                                          Center(
                                            child: Text(
                                              'No stress records yet',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.w500,
                                                color: context.textSecondary,
                                              ),
                                            ),
                                          ),

                                        // Floating Callout Bubble with Score
                                        if (widget.stressTimeline.any((v) => v > 0))
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

                        // Smooth Expanded Content (Figma Node 119:1442)
                        if (!isClosed)
                          ClipRect(
                            child: Align(
                              alignment: Alignment.topCenter,
                              heightFactor: progress,
                              child: VitalsInterpretationSection(
                                whatItIs: rec.whatItIs,
                                yourReading: rec.yourReading,
                                doThis: rec.doThis,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
