import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../helpers/vitals_card_calculator.dart';
import '../../../widgets/charts/sparkline_chart.dart';
import '../../../widgets/common/app_card.dart';

/// Card showing current heart rate, 7-day trend chart, and interactive weekday feedback.
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
  final ValueNotifier<int?> _hoveredIndexNotifier = ValueNotifier<int?>(null);

  static const List<String> _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void dispose() {
    _hoveredIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final dims = VitalsCardDimensions.fromResponsive(r);
    final sparklineHeight = (r.height * 0.085).clamp(60.0, 85.0);

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
              ValueListenableBuilder<int?>(
                valueListenable: _hoveredIndexNotifier,
                builder: (context, hoveredIndex, _) {
                  final displayRate = hoveredIndex != null &&
                          hoveredIndex < widget.weeklyHeartRate.length
                      ? widget.weeklyHeartRate[hoveredIndex].round()
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

          // 2. Interactive Sparkline Chart
          LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onHorizontalDragUpdate: (details) {
                  final index = VitalsCardCalculator.computeScrubIndex(
                    localX: details.localPosition.dx,
                    totalWidth: constraints.maxWidth,
                    itemCount: widget.weeklyHeartRate.length,
                  );
                  if (index != _hoveredIndexNotifier.value) {
                    _hoveredIndexNotifier.value = index;
                  }
                },
                onHorizontalDragEnd: (_) => _hoveredIndexNotifier.value = null,
                onTapDown: (details) {
                  final index = VitalsCardCalculator.computeScrubIndex(
                    localX: details.localPosition.dx,
                    totalWidth: constraints.maxWidth,
                    itemCount: widget.weeklyHeartRate.length,
                  );
                  _hoveredIndexNotifier.value = index;
                },
                onTapUp: (_) => _hoveredIndexNotifier.value = null,
                behavior: HitTestBehavior.opaque,
                child: SparklineChart(
                  values: widget.weeklyHeartRate,
                  lineColor: AppColors.primary,
                  height: sparklineHeight,
                  width: double.infinity,
                  strokeWidth: 2.5,
                  showFill: true,
                ),
              );
            },
          ),
          const SizedBox(height: 8.0),

          // 3. Weekday Labels
          ValueListenableBuilder<int?>(
            valueListenable: _hoveredIndexNotifier,
            builder: (context, hoveredIndex, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_weekdays.length, (i) {
                  final isSelected = hoveredIndex == i;
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
