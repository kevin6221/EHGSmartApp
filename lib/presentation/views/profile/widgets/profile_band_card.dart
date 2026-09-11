import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/user_profile_model.dart';
import '../../../widgets/common/app_card.dart';

/// Card showing connected Smart Band details (model, ID, battery) and unpair action.
class ProfileBandCard extends StatelessWidget {
  final UserProfileModel data;
  final VoidCallback? onForgetBand;

  const ProfileBandCard({super.key, required this.data, this.onForgetBand});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
          blurRadius: 14,
          offset: const Offset(0, 3),
        ),
      ],
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: AppSvgIcon(
                    AppIcons.band,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.bandModel,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(data.bandId, style: AppTypography.bodySmall),
                      const SizedBox(width: 8),
                      const Text(
                        '|',
                        style: TextStyle(color: AppColors.border),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.battery_5_bar_rounded,
                        size: 14,
                        color: AppColors.greenMetric,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        data.bandBatteryDays,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onForgetBand,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              side: const BorderSide(color: AppColors.primary, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Forgot this band',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
