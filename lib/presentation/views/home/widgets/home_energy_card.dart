import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/charts/capsule_bar_chart.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/common/card_section_header.dart';

/// Card showing energy burned, active minutes, and weekly capsule bar chart.
/// Pixel-perfect implementation matching Figma node 118:917 specs.
class HomeEnergyCard extends StatelessWidget {
  final int energyBurned;
  final int activeMins;
  final int goalMins;
  final List<double> weeklyEnergy;
  final VoidCallback? onStartSession;
  final VoidCallback? onTap;

  const HomeEnergyCard({
    super.key,
    required this.energyBurned,
    required this.activeMins,
    required this.goalMins,
    required this.weeklyEnergy,
    this.onStartSession,
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
          CardSectionHeader(
            title: 'Energy burned',
            iconSvg: AppIcons.train,
            iconColor: const Color(0xFF0EA5E9),
            iconSize: 18.0,
            titleFontSize: 15.0,
            actionText: 'Start a session',
            actionFontSize: 12.0,
            onActionTap: onStartSession,
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
                          '$energyBurned',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22.0,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          ' kcal',
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
                      'Active $activeMins / $goalMins',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF4B5563),
                        fontWeight: FontWeight.w500,
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
                  values: weeklyEnergy,
                  activeGradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF00F2FE),
                      Color(0xFF4FACFE),
                    ],
                  ),
                  trackColor: const Color(0xFFE0F7FA),
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
