import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../blocs/vitals/vitals_bloc.dart';
import '../../blocs/vitals/vitals_state.dart';
import '../../widgets/charts/capsule_bar_chart.dart';
import '../../widgets/charts/sparkline_chart.dart';
import '../../widgets/common/screen_header.dart';
import 'widgets/vitals_chart_metric_tile.dart';
import 'widgets/vitals_heart_rate_card.dart';
import 'widgets/vitals_sleep_summary_card.dart';
import 'widgets/vitals_stress_card.dart';
import 'widgets/vitals_twin_trend_cards.dart';

/// Vitals dashboard screen displaying sleep, heart metrics, stress, oxygen, and trend vitals.
class VitalsScreen extends StatelessWidget {
  const VitalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return BlocBuilder<VitalsBloc, VitalsState>(
      builder: (context, state) {
        final data = state.data;
        if (data == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              // Top Sky Gradient
              SkyHeaderBackground(height: r.hp(0.32), stops: const [0.0, 0.85]),

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
                      const ScreenHeader(title: 'Vitals'),
                      SizedBox(height: r.hp(0.02)),

                      // 1. Last night Sleep Summary Card
                      VitalsSleepSummaryCard(
                        totalSleep: data.totalSleep,
                        sleepWindow: data.sleepWindow,
                        sleepIntervals: data.sleepIntervals,
                      ),
                      SizedBox(height: r.hp(0.02)),

                      // 2. Heart Rate Card
                      VitalsHeartRateCard(
                        currentHeartRate: data.currentHeartRate,
                        weeklyHeartRate: data.weeklyHeartRate,
                      ),
                      SizedBox(height: r.hp(0.02)),

                      // 3. Stress Card
                      VitalsStressCard(
                        stressScore: data.stressScore,
                        stressStatus: data.stressStatus,
                        stressTimeline: data.stressTimeline,
                      ),
                      SizedBox(height: r.hp(0.02)),

                      // 4. Heart Rate Variability (HRV)
                      VitalsChartMetricTile(
                        svgIcon: AppIcons.vitals,
                        iconColor: AppColors.primary,
                        title: 'Heart Rate Variability',
                        value: '${data.hrvMs}',
                        unit: 'ms',
                        status: 'Below your usual',
                        chart: SparklineChart(
                          values: data.weeklyHrv,
                          lineColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 5. Resting Heart Rate
                      VitalsChartMetricTile(
                        svgIcon: AppIcons.vitals,
                        iconColor: AppColors.orangeMetric,
                        title: 'Resting Heart Rate',
                        value: '${data.restingHr}',
                        unit: 'bpm',
                        status: 'Above your usual',
                        chart: SparklineChart(
                          values: data.weeklyRestingHr,
                          lineColor: AppColors.orangeMetric,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 6. Blood Oxygen
                      VitalsChartMetricTile(
                        svgIcon: AppIcons.water,
                        iconColor: AppColors.greenMetric,
                        title: 'Blood oxygen',
                        value: '${data.bloodOxygen}',
                        unit: '%',
                        status: 'In your range',
                        showWeekdays: false,
                        chart: CapsuleBarChart(
                          values: data.weeklyOxygen,
                          activeColor: AppColors.greenMetric,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 7. Breathing Rate
                      VitalsChartMetricTile(
                        iconData: Icons.spa_rounded,
                        iconColor: AppColors.primaryCyan,
                        title: 'Breathing rate',
                        value: '${data.breathingRate}',
                        unit: '/min.',
                        status: 'Above your usual',
                        chart: SparklineChart(
                          values: data.weeklyBreathing,
                          lineColor: AppColors.primaryCyan,
                          height: 38,
                        ),
                      ),
                      SizedBox(height: r.hp(0.02)),

                      // 8. Bottom Twin Trend Cards (Blood Pressure & Skin Temp)
                      VitalsTwinTrendCards(
                        bloodPressure: data.bloodPressure,
                        skinTempDiff: data.skinTempDiff,
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
