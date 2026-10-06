import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/user_profile_model.dart';
import '../../blocs/band/band_bloc.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../blocs/training/training_bloc.dart';
import '../../blocs/training/training_event.dart';
import '../../blocs/training/training_state.dart';
import '../../widgets/common/screen_header.dart';
import 'widgets/train_active_workout_card.dart';
import 'widgets/train_category_selector.dart';
import 'widgets/train_recent_session_card.dart';
import '../details/workout_session_detail_screen.dart';

/// Training and workout dashboard screen matching Figma Node 75:2261.
class TrainScreen extends StatelessWidget {
  final bool isTab;
  const TrainScreen({super.key, this.isTab = false});

  void _confirmDeleteSession(BuildContext context, WorkoutSession session) {
    final r = context.responsive;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: context.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(color: context.cardBorder, width: 0.8),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.systemRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.systemRed,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Delete Session',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(16),
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to remove this ${session.title} session? This will remove it from your workout history.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: r.font(13),
            color: context.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: context.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.systemRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              context.read<TrainingBloc>().add(
                    DeleteWorkoutSessionEvent(session.id),
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${session.title} session removed'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text(
              'Delete',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final media = MediaQuery.of(context);
    final screenHeight = media.size.height;
    final unitSystem =
        context.watch<ProfileBloc>().state.data?.unitSystem ??
            UnitSystem.metric;
    final bandState = context.watch<BandBloc>().state;

    return BlocBuilder<TrainingBloc, TrainingState>(
      builder: (context, state) {
        final data = state.data;
        if (data == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final liveHr = state.liveHeartRate > 0
            ? state.liveHeartRate
            : (bandState.liveHeartRate > 0
                ? bandState.liveHeartRate
                : bandState.latestHeartRate);

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                      ScreenHeader(
                        title: 'Train',
                        showAvatar: true,
                        showBackButton: !isTab,
                        showOnlineIndicator: false,
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
                        unitSystem: unitSystem,
                        liveHeartRate: liveHr > 0 ? liveHr : null,
                        onStartWorkout: () async {
                          context.read<TrainingBloc>().add(
                            const StartWorkoutEvent(),
                          );
                          await Navigator.of(context)
                              .pushNamed(AppRoutes.trainingSession);
                          if (context.mounted) {
                            context.read<TrainingBloc>().add(const LoadTrainingDataEvent());
                          }
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent sessions',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: r.font(16.0),
                              fontWeight: FontWeight.w600,
                              color: context.textPrimary,
                            ),
                          ),
                          if (state.recentSessions.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 3.0,
                              ),
                              decoration: BoxDecoration(
                                color: context.isDark
                                    ? AppColors.primary.withValues(alpha: 0.15)
                                    : AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Text(
                                '${state.recentSessions.length} completed',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: r.font(11.0),
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(
                        height: (screenHeight * 0.014).clamp(10.0, 14.0),
                      ),

                      // 5. Dynamic Recent Sessions Cards (Figma Node 75:2661)
                      if (state.recentSessions.isEmpty)
                        TrainRecentSessionCard(
                          sessionTitle: data.recentSessionTitle,
                          duration: data.recentSessionDuration,
                          peakHr: data.recentPeakHr,
                          avgHr: data.recentAvgHr,
                          burnedCalories: 1,
                          startTime: DateTime.now().subtract(const Duration(minutes: 50)),
                          onTap: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (_) => WorkoutSessionDetailScreen(
                                  title: data.recentSessionTitle,
                                  durationSeconds: 14,
                                  avgHeartRate: data.recentAvgHr,
                                  peakHeartRate: data.recentPeakHr,
                                  burnedCalories: 1,
                                  category: 'walk',
                                  startTime: DateTime.now().subtract(const Duration(minutes: 50)),
                                ),
                              ),
                            );
                          },
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.recentSessions.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final session = state.recentSessions[index];
                            return TrainRecentSessionCard.fromSession(
                              session: session,
                              onTap: () {
                                Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (_) => WorkoutSessionDetailScreen(
                                      session: session,
                                    ),
                                  ),
                                );
                              },
                              onDelete: () => _confirmDeleteSession(context, session),
                            );
                          },
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
