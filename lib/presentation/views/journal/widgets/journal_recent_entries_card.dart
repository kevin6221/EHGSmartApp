import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../data/models/journal_entry_model.dart';

/// Detailed recent entry card for the Journal screen.
/// Visually highlights sleep duration, energy level, mood, and reflection note,
/// with delete functionality.
class JournalRecentEntriesCard extends StatelessWidget {
  final JournalEntryModel entry;
  final VoidCallback? onDelete;

  const JournalRecentEntriesCard({
    super.key,
    required this.entry,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    final dateFormatted = DateFormat('d MMM yyyy').format(entry.date);

    return Container(
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: context.isDark ? AppColors.midnightBorder : context.cardBorder,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.02),
            blurRadius: 8.0,
            offset: const Offset(0.0, 2.0),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Date and Delete Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateFormatted,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(11.5),
                  fontWeight: FontWeight.w600,
                  color: context.textSecondary,
                ),
              ),
              if (onDelete != null)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onDelete!();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: const AppSvgIcon(
                      AppIcons.deleteIcon,
                      size: 16.0,
                      color: AppColors.systemRed,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10.0),

          // Detailed Breakdown Badges: Sleep, Energy, and Mood
          Wrap(
            spacing: 6.0,
            runSpacing: 6.0,
            children: [
              if (entry.sleepHours > 0)
                _buildBadge(
                  icon: AppIcons.sleepZ,
                  label: '${entry.sleepHours.toStringAsFixed(1)}h Sleep',
                  color: AppColors.cyanLight,
                  bgColor: AppColors.cyanLight.withValues(alpha: 0.12),
                  r: r,
                ),
              _buildBadge(
                icon: AppIcons.energyBurn,
                label: 'Energy ${entry.energyLevel}/4',
                color: AppColors.primary,
                bgColor: AppColors.primary.withValues(alpha: 0.12),
                r: r,
              ),
              if (entry.moodWord.isNotEmpty)
                _buildBadge(
                  icon: AppIcons.mindBreath,
                  label: entry.moodWord,
                  color: AppColors.primary,
                  bgColor: AppColors.primaryLight,
                  r: r,
                ),
            ],
          ),
          const SizedBox(height: 12.0),

          // User reflection note
          Text(
            entry.note,
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(12.5),
              fontWeight: FontWeight.w500,
              color: context.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required String icon,
    required String label,
    required Color color,
    required Color bgColor,
    required Responsive r,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSvgIcon(
            icon,
            size: 11.0,
            color: color,
          ),
          const SizedBox(width: 5.0),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(10.5),
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
