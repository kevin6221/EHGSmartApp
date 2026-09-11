import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
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
/// Pixel-perfect match to Figma node 118:917 / 121:2016 with senior-level architecture and zero setState.
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
      duration: const Duration(milliseconds: 1000),
    );
    _chartAnim = CurvedAnimation(
      parent: _chartAnimController,
      curve: Curves.easeOutCubic,
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
              // 1. Sky Header Gradient Background (Figma Rectangle 127: height 310)
              const SkyHeaderBackground(height: 310.0),

              // 2. Main Scrollable Dashboard Content
              SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    r.horizontalPadding,
                    12.0,
                    r.horizontalPadding,
                    r.hp(0.12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Date & Greeting + User Avatar with Online Indicator
                      const HomeHeaderGreeting(),
                      const SizedBox(height: 16.0),

                      // Wellness Score Banner Card
                      HomeWellnessScoreCard(score: data.wellnessScore),
                      const SizedBox(height: 16.0),

                      // Mode Selector Tabs (Recover / Steady / Push)
                      HomeModeSelector(
                        currentMode: data.activeMode,
                        onModeChanged: (mode) {
                          context.read<WellnessBloc>().add(
                                ChangeWellnessModeEvent(mode),
                              );
                        },
                      ),
                      const SizedBox(height: 16.0),

                      // "Your day so far" Chart Section (No Card Wrapper)
                      HomeDayWaveSection(
                        points: data.dayChartPoints,
                        animation: _chartAnim,
                      ),
                      const SizedBox(height: 16.0),

                      // Quick-Glance Vitals Carousel (Heart Rate & Sleep)
                      HomeVitalsSummaryRow(
                        heartRate: data.currentHeartRate,
                        weeklyHeartRate: data.weeklyHeartRate,
                        sleepHours: data.sleepHours,
                      ),
                      const SizedBox(height: 16.0),

                      // Readiness Detail Section Card
                      HomeReadinessCard(data: data),
                      const SizedBox(height: 16.0),

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
                      const SizedBox(height: 16.0),

                      // Energy Burned Card
                      HomeEnergyCard(
                        energyBurned: data.energyBurned,
                        activeMins: data.activeMins,
                        goalMins: data.goalMins,
                        weeklyEnergy: data.weeklyEnergy,
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
