import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';

/// Section displaying unlocked programmes on the Systems screen.
class SystemsProgrammesSection extends StatelessWidget {
  final Responsive r;

  const SystemsProgrammesSection({
    super.key,
    required this.r,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your programmes',
              style: GoogleFonts.plusJakartaSans(
                fontSize: r.font(14.0),
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
            Text(
              '2 UNLOCKED',
              style: GoogleFonts.plusJakartaSans(
                fontSize: r.font(10.0),
                fontWeight: FontWeight.w600,
                color: AppColors.tertiary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        _buildProgrammeCard(
          title: '30–Day Pilates',
          sessionsCount: '0/4 sessions',
          category: 'Pilates',
          sourcePiece: 'From your High Rise Flared Yoga Pants',
          kcalRemaining: '371 kcal to go',
          progressFraction: 0.15,
          r: r,
        ),
        const SizedBox(height: 16.0),
        _buildProgrammeCard(
          title: 'Lower Body Challenge',
          sessionsCount: '0/4 sessions',
          category: 'Strength',
          sourcePiece: 'From your High Rise Flared Yoga Pants',
          kcalRemaining: '1,055 kcal to go',
          progressFraction: 0.08,
          r: r,
        ),
      ],
    );
  }

  Widget _buildProgrammeCard({
    required String title,
    required String sessionsCount,
    required String category,
    required String sourcePiece,
    required String kcalRemaining,
    required double progressFraction,
    required Responsive r,
  }) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.systemCardBorder, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(12.0),
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    Text(
                      sessionsCount,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(10.0),
                        fontWeight: FontWeight.w400,
                        color: AppColors.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                category,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(10.0),
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          LinearProgressIndicator(
            value: progressFraction,
            minHeight: 2.0,
            borderRadius: BorderRadius.circular(3.0),
            backgroundColor: AppColors.divider,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.cyanLight,
            ),
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  sourcePiece,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(10.0),
                    fontWeight: FontWeight.w400,
                    color: AppColors.tertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                kcalRemaining,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(10.0),
                  fontWeight: FontWeight.w400,
                  color: AppColors.tertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
