import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../widgets/common/app_card.dart';

/// Card showing statistics from the most recent training session.
/// Exact match to Figma Node 75:2661 with gradient capsules and crisp typography.
class TrainRecentSessionCard extends StatelessWidget {
  final String sessionTitle;
  final String duration;
  final int peakHr;
  final int avgHr;
  final VoidCallback? onTap;

  const TrainRecentSessionCard({
    super.key,
    required this.sessionTitle,
    required this.duration,
    required this.peakHr,
    required this.avgHr,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final runnerBoxDim = (r.width * 0.10).clamp(36.0, 42.0);

    return AppCard(
      padding: EdgeInsets.all(r.isSmall ? 12.0 : 16.0),
      borderRadius: BorderRadius.circular(12.0),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowNavy.withValues(alpha: 0.03),
          blurRadius: 8.0,
          offset: const Offset(0, 4),
        ),
      ],
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Row (Runner Icon + Title)
          Row(
            children: [
              Container(
                width: runnerBoxDim,
                height: runnerBoxDim,
                decoration: BoxDecoration(
                  color: AppColors.trainRunnerBg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.30),
                    width: 0.3,
                  ),
                ),
                child: const Center(
                  child: AppSvgIcon(
                    AppIcons.runningManIcon,
                    color: AppColors.primary,
                    size: 24.0,
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Text(
                  sessionTitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(14.0),
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 7.0,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.trainStatTimeGradient,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: AppColors.trainStatTimeBorder,
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        duration,
                        style: GoogleFonts.poppins(
                          fontSize: r.font(10.0),
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Time',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(10.0),
                          fontWeight: FontWeight.w600,
                          color: AppColors.tertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8.0),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 6.0,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.trainStatPeakGradient,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: AppColors.trainStatPeakBorder,
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$peakHr',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(10.0),
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Peak',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(10.0),
                          fontWeight: FontWeight.w600,
                          color: AppColors.tertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8.0),

              // Avg Capsule (Figma Group 1376157570)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 6.0,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.trainStatAvgGradient,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: AppColors.trainStatAvgBorder,
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${avgHr}bpm',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(10.0),
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Avg.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(10.0),
                          fontWeight: FontWeight.w600,
                          color: AppColors.tertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
