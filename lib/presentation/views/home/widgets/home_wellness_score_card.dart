import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/charts/wellness_doughnut_chart.dart';

import '../../../../core/constants/app_animations.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../helpers/wellness_card_calculator.dart';

/// Card showing the overall wellness score with trend indicator, activity tags,
/// and interactive full detailed expanded view matching Figma node 60:289 (Home >> Expanded).
/// Fully dynamic layout using responsive scaling and zero memory leaks.
class HomeWellnessScoreCard extends StatefulWidget {
  final int score;
  final int moveScore;
  final int recoverScore;
  final int mindScore;
  final int fuelScore;
  final String scoreChange;
  final bool isNegativeChange;
  final ValueNotifier<bool>? isExpandedNotifier;
  final VoidCallback? onTap;

  const HomeWellnessScoreCard({
    super.key,
    required this.score,
    this.moveScore = 36,
    this.recoverScore = 73,
    this.mindScore = 30,
    this.fuelScore = 31,
    this.scoreChange = '3',
    this.isNegativeChange = false,
    this.isExpandedNotifier,
    this.onTap,
  });

  @override
  State<HomeWellnessScoreCard> createState() => _HomeWellnessScoreCardState();
}

class _HomeWellnessScoreCardState extends State<HomeWellnessScoreCard> {
  ValueNotifier<bool>? _internalNotifier;

  ValueNotifier<bool> get _effectiveNotifier =>
      widget.isExpandedNotifier ??
      (_internalNotifier ??= ValueNotifier<bool>(false));

  @override
  void initState() {
    super.initState();
    if (widget.isExpandedNotifier == null) {
      _internalNotifier = ValueNotifier<bool>(false);
    }
  }

  @override
  void didUpdateWidget(covariant HomeWellnessScoreCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpandedNotifier != oldWidget.isExpandedNotifier) {
      if (widget.isExpandedNotifier == null && _internalNotifier == null) {
        _internalNotifier = ValueNotifier<bool>(
          oldWidget.isExpandedNotifier?.value ?? false,
        );
      } else if (widget.isExpandedNotifier != null &&
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

  void _handleTap() {
    final notifier = _effectiveNotifier;
    notifier.value = !notifier.value;
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final dims = WellnessCardDimensions.compute(
      screenWidth: r.width,
      screenHeight: r.height,
    );

    return ValueListenableBuilder<bool>(
      valueListenable: _effectiveNotifier,
      builder: (context, isExpanded, _) {
        return GestureDetector(
          onTap: _handleTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: AppDurations.cardExpand,
            curve: AppCurves.cardExpand,
            padding: EdgeInsets.all(r.isSmall ? 12.0 : 16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22.0),
              color: context.cardBackground,
              gradient: context.isDark ? null : AppGradients.wellnessCard,
              border: Border.all(
                color: context.isDark ? context.cardBorder : AppColors.primary,
                width: 0.5,
              ),
              boxShadow: context.isDark
                  ? []
                  : [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.03),
                        blurRadius: 8.0,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: isExpanded
                ? _buildExpandedView(context, r, dims)
                : _buildCollapsedView(context, r, dims),
          ),
        );
      },
    );
  }

  // --- 1. Collapsed View ---
  Widget _buildCollapsedView(
    BuildContext context,
    Responsive r,
    WellnessCardDimensions dims,
  ) {
    return Row(
      children: [
        Container(
          width: dims.badgeDim,
          height: dims.badgeDim,
          decoration: BoxDecoration(
            color: context.isDark ? AppColors.midnightBackground : AppColors.white,
            borderRadius: BorderRadius.circular(dims.badgeDim * 0.22),
            border: Border.all(
              color: AppColors.primary,
              width: 0.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.score > 0 ? '${widget.score}' : '--',
            style: GoogleFonts.plusJakartaSans(
              fontSize: dims.badgeFontSize,
              fontWeight: FontWeight.w700,
              color: context.isDark ? AppColors.white : AppColors.primary,
              height: 1.0,
            ),
          ),
        ),
        SizedBox(width: dims.detailsGap),

        // Details column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Wellness Score',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: r.font(16.0),
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                  if (widget.score > 0) ...[
                    const SizedBox(width: 6.0),
                    Icon(
                      widget.isNegativeChange
                          ? Icons.arrow_downward_outlined
                          : Icons.arrow_upward_outlined,
                      size: 10.0,
                      color: widget.isNegativeChange
                          ? AppColors.scoreDownRed
                          : AppColors.primary,
                    ),
                    Text(
                      widget.scoreChange,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(12.0),
                        fontWeight: FontWeight.w500,
                        color: widget.isNegativeChange
                            ? AppColors.scoreDownRed
                            : AppColors.primary,
                      ),
                    ),
                  ],
                  const SizedBox(width: 4.0),
                  Text(
                    'from yesterday',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: r.font(10.0),
                      fontWeight: FontWeight.w500,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),

              // Bottom Row: Move & Recover pills + Chevron
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AppSvgIcon(
                          AppIcons.runningMan,
                          size: 15.0,
                          color: AppColors.cyanAccent,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          'Move',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: r.font(12.0),
                            fontWeight: FontWeight.w500,
                            color: context.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Container(
                          width: 4.0,
                          height: 4.0,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.chartDotMuted,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        const AppSvgIcon(
                          AppIcons.heartPlus,
                          size: 15.0,
                        ),
                        const SizedBox(width: 4.0),
                        Flexible(
                          child: Text(
                            'Recover',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: r.font(12.0),
                              fontWeight: FontWeight.w500,
                              color: context.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const RotatedBox(
                    quarterTurns: 1,
                    child: Icon(
                      Icons.arrow_forward_ios_outlined,
                      size: 16.0,
                      color: AppColors.primarySkyAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- 2. Expanded Detail View (Figma Node 60:289) ---
  Widget _buildExpandedView(
    BuildContext context,
    Responsive r,
    WellnessCardDimensions dims,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top section: Concentric Rings on left, 2x2 Pillar Legend on right, Chevron up
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Concentric Rings Graphic with Center Score & Status
            SizedBox(
              width: dims.ringsDim,
              height: dims.ringsDim,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  WellnessDoughnutChart(
                    recoverScore: widget.recoverScore,
                    fuelScore: widget.fuelScore,
                    mindScore: widget.mindScore,
                    moveScore: widget.moveScore,
                    size: dims.ringsDim,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.score > 0 ? '${widget.score}' : '--',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: dims.ringsFontSize,
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 3.0),
                      Text(
                        widget.score > 0
                            ? (widget.score >= 75
                                ? 'Optimal'
                                : widget.score >= 50
                                    ? 'Steady'
                                    : 'Push')
                            : 'No Data',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(12.5),
                          fontWeight: FontWeight.w500,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: (r.width * 0.04).clamp(12.0, 18.0)),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Column 1: Move & Mind
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLegendItem(
                          context: context,
                          color: AppColors.movePillar,
                          label: 'Move',
                          score: widget.moveScore,
                          r: r,
                        ),
                        const SizedBox(height: 14.0),
                        _buildLegendItem(
                          context: context,
                          color: AppColors.mindPillar,
                          label: 'Mind',
                          score: widget.mindScore,
                          r: r,
                        ),
                      ],
                    ),
                  ),

                  // Column 2: Recover & Fuel
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLegendItem(
                          context: context,
                          color: AppColors.recoverPillar,
                          label: 'Recover',
                          score: widget.recoverScore,
                          r: r,
                        ),
                        const SizedBox(height: 14.0),
                        _buildLegendItem(
                          context: context,
                          color: AppColors.fuelPillar,
                          label: 'Fuel',
                          score: widget.fuelScore,
                          r: r,
                        ),
                      ],
                    ),
                  ),

                  // Upward chevron indicator
                  const Padding(
                    padding: EdgeInsets.only(left: 4.0),
                    child: Icon(
                      Icons.keyboard_arrow_up_rounded,
                      size: 24.0,
                      color: AppColors.primarySkyAccent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 22.0),

        // 4 Pillar Breakdown Rows (Figma 60:289)
        _buildPillarRow(
          context: context,
          score: widget.moveScore,
          scoreColor: AppColors.movePillar,
          title: 'Move',
          fraction: WellnessCardCalculator.computeFraction(widget.moveScore),
          insight: 'Movement is your weakest pillar today.',
          r: r,
        ),
        const SizedBox(height: 16.0),
        _buildPillarRow(
          context: context,
          score: widget.recoverScore,
          scoreColor: AppColors.recoverPillar,
          title: 'Recover',
          fraction: WellnessCardCalculator.computeFraction(widget.recoverScore),
          insight: 'Short sleep is holding this down.',
          r: r,
        ),
        const SizedBox(height: 16.0),
        _buildPillarRow(
          context: context,
          score: widget.mindScore,
          scoreColor: AppColors.mindPillar,
          title: 'Mind',
          fraction: WellnessCardCalculator.computeFraction(widget.mindScore),
          insight: 'Stress load is elevated. Five minutes of breathing moves this.',
          r: r,
        ),
        const SizedBox(height: 16.0),
        _buildPillarRow(
          context: context,
          score: widget.fuelScore,
          scoreColor: AppColors.fuelPillar,
          title: 'Fuel',
          fraction: WellnessCardCalculator.computeFraction(widget.fuelScore),
          insight: 'Hydration is the quickest win available to you.',
          r: r,
        ),
        const SizedBox(height: 20.0),

        // Footer explanation note (Figma 60:289)
        Text(
          'Your Wellness Score is the average of the four systems, recalculated as the day goes on. Drink water, finish a session or log a breathing exercise and watch it move.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: r.font(11.0),
            fontWeight: FontWeight.w400,
            color: context.textSecondary,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required BuildContext context,
    required Color color,
    required String label,
    required int score,
    required Responsive r,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7.0,
              height: 7.0,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6.0),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: r.font(13.0),
                fontWeight: FontWeight.w500,
                color: context.textPrimary,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 13.0, top: 2.0),
          child: Text(
            '$score',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(15.0),
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPillarRow({
    required BuildContext context,
    required int score,
    required Color scoreColor,
    required String title,
    required double fraction,
    required String insight,
    required Responsive r,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$score',
              style: GoogleFonts.plusJakartaSans(
                fontSize: r.font(18.0),
                fontWeight: FontWeight.w700,
                color: scoreColor,
              ),
            ),
            const SizedBox(width: 8.0),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: r.font(15.0),
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6.0),
        ClipRRect(
          borderRadius: BorderRadius.circular(2.0),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 3.5,
            backgroundColor: scoreColor.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
          ),
        ),
        const SizedBox(height: 6.0),
        Text(
          insight,
          style: GoogleFonts.plusJakartaSans(
            fontSize: r.font(12.0),
            fontWeight: FontWeight.w400,
            color: context.textSecondary,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
