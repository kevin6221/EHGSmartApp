import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../blocs/training/training_bloc.dart';
import '../../blocs/training/training_event.dart';
import '../../blocs/training/training_state.dart';
import '../../widgets/common/screen_header.dart';
import '../../widgets/common/section_header.dart';
import 'widgets/train_active_workout_card.dart';
import 'widgets/train_category_selector.dart';
import 'widgets/train_recent_session_card.dart';
import 'widgets/train_weight_selector.dart';

/// Training and workout dashboard screen.
class TrainScreen extends StatelessWidget {
  const TrainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final media = MediaQuery.of(context);
    final screenHeight = media.size.height;

    return BlocBuilder<TrainingBloc, TrainingState>(
      builder: (context, state) {
        final data = state.data;
        if (data == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              // Header Sky Gradient
              SkyHeaderBackground(
                height: screenHeight * 0.3,
                stops: const [0.0, 0.85],
              ),

              SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    r.horizontalPadding,
                    r.verticalPadding,
                    r.horizontalPadding,
                    r.hp(0.12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      const ScreenHeader(title: 'Train'),
                      SizedBox(height: screenHeight * 0.022),

                      // Workout Categories Pill Card
                      TrainCategorySelector(
                        currentCategory: data.selectedCategory,
                        onCategorySelected: (type) {
                          context.read<TrainingBloc>().add(
                            SelectWorkoutCategoryEvent(type),
                          );
                        },
                      ),
                      SizedBox(height: screenHeight * 0.024),

                      // Active Workout Card
                      TrainActiveWorkoutCard(data: data),
                      SizedBox(height: screenHeight * 0.026),

                      // Calorie Maths Section
                      const SectionHeader(
                        title: 'Calorie maths',
                        padding: EdgeInsets.zero,
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      TrainWeightSelector(
                        currentWeight: data.selectedWeightKg,
                        onWeightSelected: (weight) {
                          context.read<TrainingBloc>().add(
                            SelectWeightEvent(weight),
                          );
                        },
                      ),
                      SizedBox(height: screenHeight * 0.026),

                      // Recent Sessions Section
                      const SectionHeader(
                        title: 'Recent sessions',
                        padding: EdgeInsets.zero,
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      TrainRecentSessionCard(
                        sessionTitle: data.recentSessionTitle,
                        duration: data.recentSessionDuration,
                        peakHr: data.recentPeakHr,
                        avgHr: data.recentAvgHr,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
