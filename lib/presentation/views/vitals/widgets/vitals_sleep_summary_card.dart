import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_animations.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/engine/recommendation_engine.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../data/models/vitals_model.dart';
import '../../../helpers/vitals_card_calculator.dart';
import '../../../helpers/vitals_history_calculator.dart';
import '../../../widgets/charts/hypnogram_chart.dart';
import 'vitals_interpretation_section.dart';

/// Card showing the user's previous night sleep summary and hypnogram chart.
///
/// Expandable to reveal "What it is", "Your reading", and "Do this" actionable guidance matching Figma Node 119:1442.
class VitalsSleepSummaryCard extends StatefulWidget {
  final String? title;
  final String totalSleep;
  final String sleepWindow;
  final List<SleepInterval> sleepIntervals;
  final VoidCallback? onTap;
  final ValueNotifier<bool>? isExpandedNotifier;
  final VoidCallback? onExpandChanged;
  final String? whatItIs;
  final String? yourReading;
  final String? doThis;
  final bool isLoading;

  const VitalsSleepSummaryCard({
    super.key,
    this.title,
    required this.totalSleep,
    required this.sleepWindow,
    required this.sleepIntervals,
    this.onTap,
    this.isExpandedNotifier,
    this.onExpandChanged,
    this.whatItIs,
    this.yourReading,
    this.doThis,
    this.isLoading = false,
  });

  @override
  State<VitalsSleepSummaryCard> createState() => _VitalsSleepSummaryCardState();
}

class _VitalsSleepSummaryCardState extends State<VitalsSleepSummaryCard>
    with SingleTickerProviderStateMixin {
  late final ValueNotifier<bool> _expandedNotifier;
  bool _internalNotifierAllocated = false;
  late final AnimationController _animController;
  late final Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
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
  void didUpdateWidget(covariant VitalsSleepSummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
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
    _expandedNotifier.removeListener(_handleNotifierChange);
    _animController.dispose();
    if (_internalNotifierAllocated) {
      _expandedNotifier.dispose();
    }
    super.dispose();
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
    final iconBoxDim = (r.width * 0.082).clamp(28.0, 36.0);
    final iconSize = (iconBoxDim * 0.5).clamp(14.0, 18.0);

    // Reconcile and calculate effective total sleep, sleep window, and hypnogram intervals
    String effectiveTotalSleep = widget.totalSleep;
    String effectiveSleepWindow = widget.sleepWindow;
    List<SleepInterval> effectiveIntervals = widget.sleepIntervals;

    if (widget.isLoading && (effectiveTotalSleep == '--' || effectiveTotalSleep.trim().isEmpty)) {
      effectiveTotalSleep = 'Syncing...';
      effectiveSleepWindow = 'Retrieving sleep data...';
    }

    if (effectiveTotalSleep == '--' ||
        effectiveTotalSleep.trim().isEmpty ||
        effectiveTotalSleep == '0 mins.' ||
        effectiveTotalSleep == '0 min' ||
        effectiveTotalSleep == '0 hrs. 0 mins.') {
      effectiveTotalSleep = '--';
      if (effectiveIntervals.isEmpty) {
        effectiveSleepWindow = 'No sleep recorded';
      }
    }

    // 1. If totalSleep is missing or '--', but intervals exist, compute from intervals
    if ((effectiveTotalSleep == '--' || effectiveTotalSleep.trim().isEmpty) &&
        effectiveIntervals.isNotEmpty) {
      int parsedMins = 0;
      for (final inv in effectiveIntervals) {
        final text = inv.timeRangeText;
        if (text != null) {
          final match = RegExp(r'\((\d+)h\s*(\d+)m\)').firstMatch(text);
          if (match != null) {
            final h = int.tryParse(match.group(1) ?? '') ?? 0;
            final m = int.tryParse(match.group(2) ?? '') ?? 0;
            parsedMins += (h * 60 + m);
          }
        }
      }
      if (parsedMins > 0) {
        final h = parsedMins ~/ 60;
        final m = parsedMins % 60;
        effectiveTotalSleep = h > 0 ? '$h hrs. $m mins.' : '$m mins.';
      }
    }

    // 2. If intervals are empty, but totalSleep is present and not '--', auto-generate hypnogram
    final totalMins = SleepIntervalGenerator.parseMinutesFromText(effectiveTotalSleep);
    if (effectiveIntervals.isEmpty && totalMins > 0) {
      final now = DateTime.now();
      final wakeTime = DateTime(now.year, now.month, now.day, 7, 0);
      final sleepStart = wakeTime.subtract(Duration(minutes: totalMins));
      effectiveIntervals = SleepIntervalGenerator.generate(
        totalMinutes: totalMins,
        wakeTime: wakeTime,
      );
      if (effectiveSleepWindow.isEmpty ||
          effectiveSleepWindow == 'No sleep recorded' ||
          effectiveSleepWindow.toLowerCase().contains('no sleep')) {
        final startFmt = DateFormat('hh:mm a').format(sleepStart).toLowerCase();
        final endFmt = DateFormat('hh:mm a').format(wakeTime).toLowerCase();
        effectiveSleepWindow = '$startFmt - $endFmt';
      }
    }

    final rec = (widget.whatItIs != null && widget.yourReading != null && widget.doThis != null)
        ? MetricRecommendation(
            status: '',
            whatItIs: widget.whatItIs!,
            yourReading: widget.yourReading!,
            doThis: widget.doThis!,
          )
        : RecommendationEngine.getSleepRecommendation(
            effectiveTotalSleep,
            effectiveIntervals,
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
                        Row(
                          children: [
                            Container(
                              width: iconBoxDim,
                              height: iconBoxDim,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppGradients.vitalsSleepIcon,
                              ),
                              child: AppSvgIcon(
                                AppIcons.sleepZ,
                                color: AppColors.white,
                                size: iconSize,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                widget.title ?? 'Last night Sleep Summary',
                                style: AppTypography.titleMedium.copyWith(
                                  color: context.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: r.font(16),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                effectiveTotalSleep,
                                style: AppTypography.displayMedium.copyWith(
                                  color: context.textPrimary,
                                  fontSize: r.font(18),
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                effectiveSleepWindow,
                                style: AppTypography.bodySmall.copyWith(
                                  color: context.textSecondary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: r.font(14),
                                ),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        HypnogramChart(intervals: effectiveIntervals),

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
