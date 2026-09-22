import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../blocs/band/band_bloc.dart';
import '../../blocs/band/band_event.dart';
import '../../blocs/band/band_state.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../blocs/profile/profile_state.dart';
import '../../blocs/wellness/wellness_bloc.dart';
import '../../blocs/wellness/wellness_event.dart';
import '../../blocs/wellness/wellness_state.dart';
import '../../widgets/common/screen_header.dart';
import 'widgets/home_day_wave_section.dart';
import 'widgets/home_energy_card.dart';
import 'widgets/home_header_greeting.dart';
import 'widgets/home_hydration_card.dart';
import 'widgets/home_mode_selector.dart';
import 'widgets/home_readiness_card.dart';
import 'widgets/home_vitals_summary_row.dart';
import 'widgets/home_wellness_score_card.dart';

/// Main Dashboard Home Screen displaying wellness score, daily waves, vitals, readiness, and habits.
/// Fully dynamic responsive layout adhering to senior developer architecture and zero setState.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _chartAnimController;
  late final Animation<double> _chartAnim;

  @override
  void initState() {
    super.initState();
    _chartAnimController = AnimationController(
      vsync: this,
      duration: AppDurations.chartDraw,
    );
    _chartAnim = CurvedAnimation(
      parent: _chartAnimController,
      curve: AppCurves.chartEase,
    );
    _chartAnimController.forward();
  }

  @override
  void dispose() {
    _chartAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final itemSpacing = (r.height * 0.018).clamp(12.0, 20.0);

    return BlocBuilder<WellnessBloc, WellnessState>(
      builder: (context, state) {
        final data = state.data;
        if (data == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              SkyHeaderBackground(height: r.hp(0.36)),

              // 2. Main Scrollable Dashboard Content
              SafeArea(
                bottom: false,
                child: RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  onRefresh: () async {
                    context.read<BandBloc>().add(SyncVitalsEvent());
                    context.read<BandBloc>().add(StartLiveHeartRateEvent());
                    await Future.delayed(const Duration(milliseconds: 1200));
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.fromLTRB(
                      r.horizontalPadding,
                      r.verticalPadding,
                      r.horizontalPadding,
                      r.hp(0.12),
                    ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BlocBuilder<ProfileBloc, ProfileState>(
                        builder: (context, profileState) {
                          final userName = profileState.data?.username;
                          return HomeHeaderGreeting(
                            userName: (userName != null && userName.isNotEmpty)
                                ? userName
                                : 'there',
                          );
                        },
                      ),
                      SizedBox(height: itemSpacing),

                      // Wellness Score Banner Card
                      HomeWellnessScoreCard(
                        score: data.wellnessScore,
                        moveScore: data.moveScore,
                        recoverScore: data.recoverScore,
                        mindScore: data.mindScore,
                        fuelScore: data.fuelScore,
                        scoreChange: '${data.scoreDiff.abs()}',
                        isNegativeChange: data.scoreDiff < 0,
                      ),
                      SizedBox(height: itemSpacing),

                      // Mode Selector Tabs (Recover / Steady / Push)
                      HomeModeSelector(
                        currentMode: data.activeMode,
                        onModeChanged: (mode) {
                          context.read<WellnessBloc>().add(
                            ChangeWellnessModeEvent(mode),
                          );
                        },
                      ),
                      SizedBox(height: itemSpacing),

                      // "Your day so far" Chart Section (No Card Wrapper)
                      HomeDayWaveSection(
                        points: data.dayChartPoints,
                        animation: _chartAnim,
                      ),
                      // SizedBox(height: itemSpacing),

                      // Quick-Glance Vitals Carousel (Heart Rate & Sleep)
                      BlocBuilder<BandBloc, BandState>(
                        buildWhen: (prev, curr) => prev.liveHeartRate != curr.liveHeartRate,
                        builder: (context, bandState) {
                          final hr = bandState.liveHeartRate > 0
                              ? bandState.liveHeartRate
                              : data.currentHeartRate;
                          return HomeVitalsSummaryRow(
                            heartRate: hr,
                            weeklyHeartRate: data.weeklyHeartRate,
                            sleepHours: data.sleepHours,
                          );
                        },
                      ),
                      SizedBox(height: itemSpacing),

                      // Readiness Detail Section Card
                      HomeReadinessCard(data: data),
                      SizedBox(height: itemSpacing),

                      // Hydration Card
                      HomeHydrationCard(
                        currentMl: data.hydrationCurrent,
                        goalMl: data.hydrationGoal,
                        weeklyHydration: data.weeklyHydration,
                        onAddMl: () {
                          context.read<WellnessBloc>().add(
                            const AddHydrationEvent(250),
                          );
                        },
                      ),
                      SizedBox(height: itemSpacing),

                      // Energy Burned Card
                      HomeEnergyCard(
                        energyBurned: data.energyBurned,
                        activeMins: data.activeMins,
                        goalMins: data.goalMins,
                        weeklyEnergy: data.weeklyEnergy,
                      ),
                      SizedBox(height: itemSpacing),
                    ],
                  ),
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
