import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../data/models/workout_model.dart';
import '../../../widgets/common/app_card.dart';
import 'train_weight_selector.dart';

/// Card presenting the active selected workout session, parameters, action button,
/// and integrated Calorie maths weight selector matching Figma Node 75:2580.
class TrainActiveWorkoutCard extends StatelessWidget {
  final WorkoutModel data;
  final VoidCallback? onStartWorkout;
  final ValueChanged<int>? onWeightSelected;

  const TrainActiveWorkoutCard({
    super.key,
    required this.data,
    this.onStartWorkout,
    this.onWeightSelected,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final runnerBoxDim = (r.width * 0.10).clamp(36.0, 42.0);
    final playBtnDim = (r.width * 0.086).clamp(30.0, 36.0);

    return AppCard(
      padding: EdgeInsets.all(r.isSmall ? 14.0 : 16.0),
      borderRadius: BorderRadius.circular(12.0),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowNavy.withValues(alpha: 0.03),
          blurRadius: 8.0,
          offset: const Offset(0, 4),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header row: Runner Icon + Title on Left, Play Button on Right (Figma Node 75:2581-2603)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
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
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        data.title,
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
              ),
              const SizedBox(width: 10.0),

              // Radial Gradient Play button
              GestureDetector(
                onTap: onStartWorkout,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: playBtnDim,
                  height: playBtnDim,
                  decoration: const BoxDecoration(
                    gradient: AppColors.trainPlayGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: AppSvgIcon(
                      AppIcons.playButton,
                      color: AppColors.white,
                      size: 14.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // 2. Details Box with 4 Parameter Rows (Figma Node 75:2604)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            decoration: BoxDecoration(
              color: AppColors.workoutCardBg,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.10),
                width: 1.0,
              ),
            ),
            child: Column(
              children: [
                _buildDetailRow(
                  icon: const AppSvgIcon(
                    AppIcons.targetDart,
                    size: 18.0,
                    color: AppColors.secondary,
                  ),
                  text: data.zoneInfo,
                  r: r,
                ),
                const SizedBox(height: 14.0),
                _buildDetailRow(
                  icon: const AppSvgIcon(
                    AppIcons.watchDevice,
                    size: 18.0,
                    color: AppColors.secondary,
                  ),
                  text: data.metricsSummary,
                  r: r,
                ),
                const SizedBox(height: 14.0),
                _buildDetailRow(
                  icon: const AppSvgIcon(
                    AppIcons.layersFolded,
                    size: 18.0,
                    color: AppColors.secondary,
                  ),
                  text: data.outfitRecommendation,
                  r: r,
                ),
                const SizedBox(height: 14.0),
                _buildDetailRow(
                  icon: const AppSvgIcon(
                    AppIcons.trainFlame,
                    size: 18.0,
                    color: AppColors.secondary,
                  ),
                  text:
                      '≈ ${data.estimatedKcalPerMin} kcal/min at ${data.selectedWeightKg}kg',
                  r: r,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),

          // 3. Integrated Calorie maths Section (Figma Node 75:2646)
          Text(
            'Calorie maths',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(16.0),
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 12.0),

          // 4. Weight Selector Pills (Figma Node 75:2658)
          if (onWeightSelected != null)
            TrainWeightSelector(
              currentWeight: data.selectedWeightKg,
              onWeightSelected: onWeightSelected!,
            )
          else
            TrainWeightSelector(
              currentWeight: data.selectedWeightKg,
              onWeightSelected: (_) {},
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required Widget icon,
    required String text,
    required Responsive r,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1.0),
          child: SizedBox(
            width: 18.0,
            height: 18.0,
            child: Center(child: icon),
          ),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.tertiary,
              fontWeight: FontWeight.w400,
              fontSize: r.font(14.0),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
