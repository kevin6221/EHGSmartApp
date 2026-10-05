import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../widgets/common/app_card.dart';

/// Card showing statistics from a completed training session.
/// Exact match to Figma Node 75:2661 with dynamic multi-workout history support.
class TrainRecentSessionCard extends StatelessWidget {
  final String sessionTitle;
  final String duration;
  final int peakHr;
  final int avgHr;
  final int burnedCalories;
  final DateTime? startTime;
  final String? category;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TrainRecentSessionCard({
    super.key,
    required this.sessionTitle,
    required this.duration,
    required this.peakHr,
    required this.avgHr,
    this.burnedCalories = 0,
    this.startTime,
    this.category,
    this.onTap,
    this.onDelete,
  });

  /// Factory constructor to render directly from SQLite-persisted [WorkoutSession].
  factory TrainRecentSessionCard.fromSession({
    Key? key,
    required WorkoutSession session,
    VoidCallback? onTap,
    VoidCallback? onDelete,
  }) {
    final h = session.durationSeconds ~/ 3600;
    final m = (session.durationSeconds % 3600) ~/ 60;
    final s = session.durationSeconds % 60;
    final dur = '${h.toString().padLeft(2, '0')}hr ${m.toString().padLeft(2, '0')}min ${s.toString().padLeft(2, '0')}sec';

    return TrainRecentSessionCard(
      key: key,
      sessionTitle: session.title,
      duration: dur,
      peakHr: session.peakHeartRate,
      avgHr: session.avgHeartRate,
      burnedCalories: session.burnedCalories,
      startTime: session.startTime,
      category: session.category,
      onTap: onTap,
      onDelete: onDelete,
    );
  }

  String _formatSessionSubtitle(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDay = DateTime(dt.year, dt.month, dt.day);
    final timeStr = DateFormat('h:mm a').format(dt);

    String dayPrefix;
    if (sessionDay == today) {
      dayPrefix = 'Today';
    } else if (sessionDay == today.subtract(const Duration(days: 1))) {
      dayPrefix = 'Yesterday';
    } else {
      dayPrefix = DateFormat('MMM d').format(dt);
    }

    if (burnedCalories > 0 && peakHr > 0) {
      return '$dayPrefix · $timeStr · Peak ${peakHr}bpm';
    }
    return '$dayPrefix · $timeStr';
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final runnerBoxDim = (r.width * 0.10).clamp(36.0, 42.0);

    final hasValidSession = (peakHr > 0 || avgHr > 0 || burnedCalories > 0) &&
        duration != '--' &&
        duration != '00hr 00min 00sec' &&
        duration != '00hr 00min 01sec';

    final displayTitle = hasValidSession ? sessionTitle : 'No recent sessions';
    final displayDuration = hasValidSession ? duration : '--';
    final displayPeak = hasValidSession && peakHr > 0 ? '$peakHr' : '--';
    final displayAvg = hasValidSession && avgHr > 0 ? '${avgHr}bpm' : '--';

    final bool showCaloriesInCapsule = burnedCalories > 0;
    final String displayMetric2 = hasValidSession
        ? (showCaloriesInCapsule ? '${burnedCalories}kcal' : displayPeak)
        : '--';
    final String labelMetric2 = hasValidSession
        ? (showCaloriesInCapsule ? 'Energy' : 'Peak')
        : 'Peak';

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
          // 1. Header Row (Runner Icon + Title + Status)
          Row(
            children: [
              Container(
                width: runnerBoxDim,
                height: runnerBoxDim,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.trainRunnerBg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.30),
                    width: 0.3,
                  ),
                ),
                child: _buildSessionIcon(),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayTitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(14.0),
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hasValidSession && startTime != null) ...[
                      const SizedBox(height: 2.0),
                      Text(
                        _formatSessionSubtitle(startTime!),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(11.0),
                          fontWeight: FontWeight.w500,
                          color: context.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (hasValidSession) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7.0,
                    vertical: 3.0,
                  ),
                  decoration: BoxDecoration(
                    color: context.isDark
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 11,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'Completed',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(9.5),
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onDelete != null) ...[
                  const SizedBox(width: 6.0),
                  GestureDetector(
                    onTap: onDelete,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: AppColors.systemRed.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 15,
                        color: AppColors.systemRed,
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
          const SizedBox(height: 14.0),

          // 2. Metrics Capsules Row (Time | Energy/Peak | Avg)
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 7.0,
                  ),
                  decoration: BoxDecoration(
                    color: context.isDark ? context.inputFill : null,
                    gradient: context.isDark ? null : AppGradients.trainStatTime,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: context.isDark
                          ? context.cardBorder
                          : AppColors.trainStatTimeBorder,
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayDuration,
                        style: GoogleFonts.poppins(
                          fontSize: r.font(10.0),
                          fontWeight: FontWeight.w700,
                          color: context.isDark
                              ? context.textPrimary
                              : AppColors.black,
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
                          color: context.textSecondary,
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
                    color: context.isDark ? context.inputFill : null,
                    gradient: context.isDark ? null : AppGradients.trainStatPeak,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: context.isDark
                          ? context.cardBorder
                          : AppColors.trainStatPeakBorder,
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayMetric2,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(10.0),
                          fontWeight: FontWeight.w700,
                          color: context.isDark
                              ? context.textPrimary
                              : AppColors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        labelMetric2,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(10.0),
                          fontWeight: FontWeight.w600,
                          color: context.textSecondary,
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
                    color: context.isDark ? context.inputFill : null,
                    gradient: context.isDark ? null : AppGradients.trainStatAvg,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: context.isDark
                          ? context.cardBorder
                          : AppColors.trainStatAvgBorder,
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayAvg,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(10.0),
                          fontWeight: FontWeight.w700,
                          color: context.isDark
                              ? context.textPrimary
                              : AppColors.black,
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
                          color: context.textSecondary,
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

  Widget _buildSessionIcon() {
    final lower = (category ?? sessionTitle).toLowerCase();
    if (lower.contains('walk')) {
      return const Icon(
        Icons.directions_walk_rounded,
        color: AppColors.primary,
        size: 24.0,
      );
    } else if (lower.contains('bik') || lower.contains('cycl')) {
      return const Icon(
        Icons.directions_bike_rounded,
        color: AppColors.primary,
        size: 24.0,
      );
    } else if (lower.contains('strength')) {
      return const Icon(
        Icons.fitness_center_rounded,
        color: AppColors.primary,
        size: 22.0,
      );
    } else if (lower.contains('hiit') || lower.contains('hit')) {
      return const AppSvgIcon(
        AppIcons.trainFlame,
        color: AppColors.primary,
        size: 22.0,
      );
    }
    return const AppSvgIcon(
      AppIcons.runningManIcon,
      color: AppColors.primary,
      size: 24.0,
    );
  }
}
