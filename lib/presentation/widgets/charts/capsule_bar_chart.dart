import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

/// Capsule bar chart displaying weekly metrics with pill-shaped progress bars.
/// Matches Figma specs with customizable height, width, gradient, and track colors.
class CapsuleBarChart extends StatelessWidget {
  final List<double> values; // 0.0 to 1.0
  final Color activeColor;
  final Gradient? activeGradient;
  final Color? trackColor;
  final double height;
  final double barWidth;
  final List<String> days;

  const CapsuleBarChart({
    super.key,
    required this.values,
    this.activeColor = AppColors.hydration,
    this.activeGradient,
    this.trackColor,
    this.height = 56.0,
    this.barWidth = 8.9,
    this.days = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTrackColor =
        trackColor ?? activeColor.withValues(alpha: 0.12);

    return RepaintBoundary(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(values.length, (index) {
          final fraction = values[index].clamp(0.0, 1.0);
          final day = index < days.length ? days[index] : '';
          final fillHeight = (height * fraction).clamp(barWidth, height);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Capsule Track and Fill
              Container(
                width: barWidth,
                height: height,
                decoration: BoxDecoration(
                  color: effectiveTrackColor,
                  borderRadius: BorderRadius.circular(barWidth / 2),
                ),
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: barWidth,
                  height: fillHeight,
                  decoration: BoxDecoration(
                    color: activeGradient == null ? activeColor : null,
                    gradient: activeGradient,
                    borderRadius: BorderRadius.circular(barWidth / 2),
                  ),
                ),
              ),
              const SizedBox(height: 6.0),

              // Weekday Label
              Text(
                day,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.0,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
