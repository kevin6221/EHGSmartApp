import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/charts/capsule_bar_chart.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/common/card_section_header.dart';

/// Card showing daily hydration progress and weekly capsule bar chart.
/// Pixel-perfect implementation matching Figma node 118:917 specs.
class HomeHydrationCard extends StatelessWidget {
  final int currentMl;
  final int goalMl;
  final List<double> weeklyHydration;
  final VoidCallback? onAddMl;
  final VoidCallback? onTap;

  const HomeHydrationCard({
    super.key,
    required this.currentMl,
    required this.goalMl,
    required this.weeklyHydration,
    this.onAddMl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16.0),
      borderRadius: BorderRadius.circular(22.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 8.0,
          offset: const Offset(0, 4),
        ),
      ],
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const CardSectionHeader(
            title: 'Hydration',
            iconSvg: AppIcons.water,
            iconColor: Color(0xFF0072CE),
            iconSize: 18.0,
            titleFontSize: 15.0,
            actionText: 'Today',
            actionFontSize: 12.0,
          ),
          const SizedBox(height: 14.0),

          // Body: Metric on left, 7-day capsule bar chart on right
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$currentMl',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22.0,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          ' / $goalMl ml',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'On Track',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                flex: 5,
                child: CapsuleBarChart(
                  values: weeklyHydration,
                  activeColor: const Color(0xFF0072CE),
                  trackColor: const Color(0xFFE2F0FD),
                  height: 56.0,
                  barWidth: 8.9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
