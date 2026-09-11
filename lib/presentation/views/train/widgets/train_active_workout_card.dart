import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/workout_model.dart';
import '../../../widgets/common/app_card.dart';

/// Card presenting the active selected workout session, parameters, and action button.
class TrainActiveWorkoutCard extends StatelessWidget {
  final WorkoutModel data;
  final VoidCallback? onStartWorkout;

  const TrainActiveWorkoutCard({
    super.key,
    required this.data,
    this.onStartWorkout,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.05),
          blurRadius: 18,
          offset: const Offset(0, 4),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with Icon, Title, and Start Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: AppSvgIcon(
                        AppIcons.runner,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    data.title,
                    style: AppTypography.titleLarge.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              // Play button
              GestureDetector(
                onTap: onStartWorkout,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: AppSvgIcon(
                      AppIcons.play,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Details grey inner card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: [
                _buildWorkoutDetailRow(
                  icon: const Icon(
                    Icons.track_changes_rounded,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                  text: data.zoneInfo,
                ),
                const SizedBox(height: 14),
                _buildWorkoutDetailRow(
                  icon: const AppSvgIcon(
                    AppIcons.band,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                  text: data.metricsSummary,
                ),
                const SizedBox(height: 14),
                _buildWorkoutDetailRow(
                  icon: const Icon(
                    Icons.layers_outlined,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                  text: data.outfitRecommendation,
                ),
                const SizedBox(height: 14),
                _buildWorkoutDetailRow(
                  icon: const AppSvgIcon(
                    AppIcons.train,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                  text:
                      '≈ ${data.estimatedKcalPerMin} kcal/min at ${data.selectedWeightKg}kg',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutDetailRow({required Widget icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        icon,
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
