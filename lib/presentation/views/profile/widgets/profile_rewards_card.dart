import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_card.dart';

/// Card prompting user to link email and secure their rewards.
class ProfileRewardsCard extends StatelessWidget {
  final TextEditingController emailController;
  final VoidCallback onCreateAccount;

  const ProfileRewardsCard({
    super.key,
    required this.emailController,
    required this.onCreateAccount,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.energy,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: AppSvgIcon(
                    AppIcons.shield,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Keep your rewards safe',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Email input
          TextField(
            controller: emailController,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Create account button
          AppButton(
            text: 'Create account',
            height: 48,
            borderRadius: BorderRadius.circular(14),
            trailingSvg: AppIcons.arrowForward,
            hasShadow: false,
            onPressed: onCreateAccount,
          ),
          const SizedBox(height: 8),
          Text(
            'No password. We send a one-time link.',
            style: AppTypography.bodySmall.copyWith(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
