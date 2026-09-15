import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../helpers/capsule_bar_calculator.dart';

/// Capsule bar chart displaying weekly metrics with pill-shaped progress bars.
/// Matches Figma specs with tri-tier tonal segments, customizable height, width, and colors.
class CapsuleBarChart extends StatelessWidget {
  final List<double> values; // 0.0 to 1.0
  final Color activeColor;
  final Color? middleColor;
  final Color? lightColor;
  final Gradient? activeGradient;
  final Color? trackColor;
  final double height;
  final double barWidth;
  final List<String> days;
  final bool showTrack;

  const CapsuleBarChart({
    super.key,
    required this.values,
    this.activeColor = AppColors.hydration,
    this.middleColor,
    this.lightColor,
    this.activeGradient,
    this.trackColor,
    this.height = 56.0,
    this.barWidth = 8.9,
    this.days = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
    this.showTrack = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMiddleColor =
        middleColor ?? activeColor.withValues(alpha: 0.55);
    final effectiveLightColor =
        lightColor ?? activeColor.withValues(alpha: 0.22);
    final effectiveTrackColor =
        trackColor ?? activeColor.withValues(alpha: 0.12);

    return RepaintBoundary(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(values.length, (index) {
          final tiers = CapsuleBarCalculator.computeTiers(
            rawValue: values[index],
            totalHeight: height,
            barWidth: barWidth,
          );
          final day = index < days.length ? days[index] : '';

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Capsule Bar Container
              SizedBox(
                width: barWidth,
                height: height,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: showTrack
                      ? Container(
                          width: barWidth,
                          height: height,
                          decoration: BoxDecoration(
                            color: effectiveTrackColor,
                            borderRadius: BorderRadius.circular(barWidth / 2.0),
                          ),
                          alignment: Alignment.bottomCenter,
                          child: _buildBar(
                            tiers,
                            effectiveMiddleColor,
                            effectiveLightColor,
                          ),
                        )
                      : _buildBar(
                          tiers,
                          effectiveMiddleColor,
                          effectiveLightColor,
                        ),
                ),
              ),
              const SizedBox(height: 6.0),
              Text(
                day,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.0,
                  fontWeight: FontWeight.w500,
                  color: AppColors.tertiary,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildBar(
    CapsuleBarTiers tiers,
    Color effMiddleColor,
    Color effLightColor,
  ) {
    final radius = Radius.circular(barWidth / 2.0);
    final borderRadius = BorderRadius.all(radius);

    if (activeGradient != null) {
      return Container(
        width: barWidth,
        height: tiers.fillHeight,
        decoration: BoxDecoration(
          gradient: activeGradient,
          borderRadius: borderRadius,
        ),
      );
    }

    return SizedBox(
      width: barWidth,
      height: tiers.fillHeight,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Tier 1: Light (100% of fill height)
          Container(
            width: barWidth,
            height: tiers.fillHeight,
            decoration: BoxDecoration(
              color: effLightColor,
              borderRadius: borderRadius,
            ),
          ),
          // Tier 2: Middle (65% of fill height)
          Container(
            width: barWidth,
            height: tiers.tier2Height,
            decoration: BoxDecoration(
              color: effMiddleColor,
              borderRadius: borderRadius,
            ),
          ),
          // Tier 3: Base / Deep (35% of fill height)
          Container(
            width: barWidth,
            height: tiers.tier3Height,
            decoration: BoxDecoration(
              color: activeColor,
              borderRadius: borderRadius,
            ),
          ),
        ],
      ),
    );
  }
}
