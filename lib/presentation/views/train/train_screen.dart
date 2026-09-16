import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../../core/routes/app_routes.dart';
import '../../blocs/training/training_bloc.dart';
import '../../blocs/training/training_event.dart';
import '../../blocs/training/training_state.dart';
import '../../widgets/common/screen_header.dart';
import 'widgets/train_active_workout_card.dart';
import 'widgets/train_category_selector.dart';
import 'widgets/train_recent_session_card.dart';

/// Training and workout dashboard screen matching Figma Node 75:2261.
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
              // Header Sky Gradient (Figma Rectangle 127)
              SkyHeaderBackground(
                height: screenHeight * 0.32,
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
                      // 1. Header Row with Online Avatar Indicator (Figma Node 75:2268-2271)
                      const ScreenHeader(
                        title: 'Train',
                        showAvatar: true,
                        showOnlineIndicator: true,
                      ),
                      SizedBox(
                        height: (screenHeight * 0.020).clamp(16.0, 20.0),
                      ),

                      // 2. Workout Categories Card (Figma Node 75:2570)
                      TrainCategorySelector(
                        currentCategory: data.selectedCategory,
                        onCategorySelected: (type) {
                          context.read<TrainingBloc>().add(
                            SelectWorkoutCategoryEvent(type),
                          );
                        },
                      ),
                      SizedBox(
                        height: (screenHeight * 0.022).clamp(16.0, 22.0),
                      ),

                      // 3. Active Workout Card with Integrated Calorie maths (Figma Node 75:2580)
                      TrainActiveWorkoutCard(
                        data: data,
                        onStartWorkout: () {
                          context.read<TrainingBloc>().add(
                            const StartWorkoutEvent(),
                          );
                          Navigator.of(context)
                              .pushNamed(AppRoutes.trainingSession);
                        },
                        onWeightSelected: (weight) {
                          context.read<TrainingBloc>().add(
                            SelectWeightEvent(weight),
                          );
                        },
                      ),
                      SizedBox(
                        height: (screenHeight * 0.024).clamp(18.0, 24.0),
                      ),

                      // 4. Recent Sessions Section Header (Figma Node 75:2659)
                      Text(
                        'Recent sessions',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(16.0),
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                      SizedBox(
                        height: (screenHeight * 0.014).clamp(10.0, 14.0),
                      ),

                      // 5. Recent Session Statistics Card (Figma Node 75:2661)
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
