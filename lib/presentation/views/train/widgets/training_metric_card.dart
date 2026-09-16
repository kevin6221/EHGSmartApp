import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';

/// Reusable metric card (e.g. Heart Rate, Calories) for active workout session.
class TrainingMetricCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;
  final String unit;

  const TrainingMetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final media = MediaQuery.sizeOf(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: (media.height * 0.016).clamp(11.0, 15.0),
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowNavy.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              AppSvgIcon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.secondary,
                    fontSize: r.font(12),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: (media.height * 0.010).clamp(6.0, 10.0)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.secondary,
                  fontSize: r.font(18),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.secondary,
                  fontSize: r.font(12),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
