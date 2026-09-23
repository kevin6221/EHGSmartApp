import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';

/// Section displaying earnings status for user's verified apparel pieces.
class RewardsPiecesSection extends StatelessWidget {
  final Responsive r;

  const RewardsPiecesSection({super.key, required this.r});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your pieces are earning',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(14.0),
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 14.0),
          _buildPieceEarningItem(
            context: context,
            r: r,
            title: 'High Rise Flared Yoga Pants',
            tier: 'BRONZE',
            progress: 0.60,
            subtitle: '47 wears · 3 to Silver',
          ),
          const SizedBox(height: 12.0),
          _buildPieceEarningItem(
            context: context,
            r: r,
            title: 'Heavyweight Tank Top',
            tier: 'BRONZE',
            progress: 0.60,
            subtitle: '22 wears · 28 to Silver',
          ),
        ],
      ),
    );
  }

  Widget _buildPieceEarningItem({
    required BuildContext context,
    required Responsive r,
    required String title,
    required String tier,
    required double progress,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: context.cardBorder, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.2 : 0.03),
            offset: const Offset(0, 4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(12.0),
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                tier,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(10.0),
                  fontWeight: FontWeight.w600,
                  color: AppColors.cyanLight,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: context.isDark ? AppColors.midnightBorder : AppColors.surfaceVariant,
            color: AppColors.cyanLight,
            minHeight: 2.0,
            borderRadius: BorderRadius.circular(3.0),
          ),
          const SizedBox(height: 8.0),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(10.0),
              fontWeight: FontWeight.w400,
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
