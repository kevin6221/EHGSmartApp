import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../blocs/wellness/wellness_bloc.dart';
import '../../blocs/wellness/wellness_event.dart';
import '../../blocs/wellness/wellness_state.dart';
import '../../widgets/charts/capsule_bar_chart.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/detail_screen_app_bar.dart';
import '../../widgets/common/screen_header.dart';

/// Full-screen Hydration Detail screen adhering to the EHG design system.
///
/// Features interactive quick-logging (+250ml, +500ml, +750ml),
/// 7-day capsule consistency, personalized target breakdown, and coaching insights.
class HydrationDetailScreen extends StatelessWidget {
  const HydrationDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final itemSpacing = (r.height * 0.016).clamp(12.0, 18.0);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          SkyHeaderBackground(height: r.hp(0.30), stops: const [0.0, 0.85]),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Custom Navigation Bar
                const DetailScreenAppBar(
                  statusText: 'Fuel System',
                  statusColor: AppColors.tealMetric,
                ),

                // Main Scrollable Body
                Expanded(
                  child: BlocBuilder<WellnessBloc, WellnessState>(
                    builder: (context, state) {
                      final wellness = state.data;
                      final int currentMl = wellness?.hydrationCurrent ?? 0;
                      final int goalMl = (wellness?.hydrationGoal ?? 0) > 0
                          ? wellness!.hydrationGoal
                          : 2400;

                      final double progress = (currentMl / goalMl).clamp(0.0, 1.5);
                      final int remainingMl = (goalMl - currentMl).clamp(0, goalMl);

                      final List<double> weeklyHydration = (wellness?.weeklyHydration.length == 7)
                          ? wellness!.weeklyHydration
                          : const [0.4, 0.65, 0.8, 0.5, 0.9, 0.7, 0.55];

                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          r.horizontalPadding,
                          8.0,
                          r.horizontalPadding,
                          r.hp(0.10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title Header
                            Text(
                              'Hydration & Fluid Intake',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: r.font(26.0),
                                fontWeight: FontWeight.w700,
                                color: context.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'Cellular hydration, blood volume, and metabolic replenishment',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: r.font(13.0),
                                fontWeight: FontWeight.w400,
                                color: context.textSecondary,
                              ),
                            ),
                            SizedBox(height: itemSpacing),

                            // Hero Hydration Progress Card
                            _buildHeroCard(
                              context: context,
                              r: r,
                              currentMl: currentMl,
                              goalMl: goalMl,
                              progress: progress,
                              remainingMl: remainingMl,
                            ),
                            SizedBox(height: itemSpacing),

                            // Quick Log Buttons Card
                            _buildQuickLogCard(
                              context: context,
                              r: r,
                            ),
                            SizedBox(height: itemSpacing),

                            // Weekly Consistency Card
                            _buildWeeklyConsistencyCard(
                              context: context,
                              r: r,
                              weeklyHydration: weeklyHydration,
                            ),
                            SizedBox(height: itemSpacing),

                            // Physiological Coaching Insight Card
                            _buildHydrationInsightCard(
                              context: context,
                              r: r,
                              progress: progress,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard({
    required BuildContext context,
    required Responsive r,
    required int currentMl,
    required int goalMl,
    required double progress,
    required int remainingMl,
  }) {
    final int pct = (progress * 100).round();

    return AppCard(
      padding: EdgeInsets.all(r.isSmall ? 16.0 : 20.0),
      borderRadius: BorderRadius.circular(22.0),
      border: Border.all(color: AppColors.borderLight, width: 0.8),
      boxShadow: [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.04),
          blurRadius: 14.0,
          offset: const Offset(0, 4),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36.0,
                    height: 36.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppGradients.primary,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.tealMetric.withValues(alpha: 0.35),
                          blurRadius: 10.0,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const AppSvgIcon(
                      AppIcons.waterGlass,
                      color: AppColors.white,
                      size: 18.0,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Text(
                    'Daily Fluid Intake',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: r.font(15.0),
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.tealMetric.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  pct >= 100 ? 'Goal Reached' : '$pct% of Goal',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(11.0),
                    fontWeight: FontWeight.w700,
                    color: AppColors.tealMetric,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18.0),

          // Value and Goal
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$currentMl',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(40.0),
                  fontWeight: FontWeight.w700,
                  color: AppColors.tealMetric,
                  height: 1.0,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                '/ $goalMl mL',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(16.0),
                  fontWeight: FontWeight.w600,
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),

          // Linear Gradient Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6.0),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 10.0,
              backgroundColor: AppColors.tealMetric.withValues(alpha: 0.12),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.tealMetric),
            ),
          ),
          const SizedBox(height: 14.0),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                remainingMl > 0 ? '$remainingMl mL remaining today' : 'Daily hydration target fulfilled!',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(12.0),
                  fontWeight: FontWeight.w500,
                  color: context.textSecondary,
                ),
              ),
              Text(
                'Personalized: 35 mL/kg',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(11.0),
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLogCard({
    required BuildContext context,
    required Responsive r,
  }) {
    final increments = [
      {'label': '+250 mL', 'sub': 'Glass', 'amount': 250},
      {'label': '+500 mL', 'sub': 'Bottle', 'amount': 500},
      {'label': '+750 mL', 'sub': 'Flask', 'amount': 750},
    ];

    return AppCard(
      padding: EdgeInsets.all(r.isSmall ? 14.0 : 18.0),
      borderRadius: BorderRadius.circular(22.0),
      border: Border.all(color: AppColors.borderLight, width: 0.8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quick Log Water',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(15.0),
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
              const Icon(
                Icons.add_circle_outline_rounded,
                size: 20.0,
                color: AppColors.tealMetric,
              ),
            ],
          ),
          const SizedBox(height: 6.0),
          Text(
            'Tap any quantity below to add to your daily intake',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(12.0),
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 16.0),

          Row(
            children: increments.map((inc) {
              final amount = inc['amount'] as int;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        context.read<WellnessBloc>().add(AddHydrationEvent(amount));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Added $amount mL of water',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            backgroundColor: AppColors.tealMetric,
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(14.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        decoration: BoxDecoration(
                          color: AppColors.tealMetric.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14.0),
                          border: Border.all(
                            color: AppColors.tealMetric.withValues(alpha: 0.25),
                            width: 0.8,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              inc['label'] as String,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: r.font(14.0),
                                fontWeight: FontWeight.w700,
                                color: AppColors.tealMetric,
                              ),
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              inc['sub'] as String,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: r.font(11.0),
                                fontWeight: FontWeight.w500,
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyConsistencyCard({
    required BuildContext context,
    required Responsive r,
    required List<double> weeklyHydration,
  }) {
    return AppCard(
      padding: EdgeInsets.all(r.isSmall ? 14.0 : 18.0),
      borderRadius: BorderRadius.circular(22.0),
      border: Border.all(color: AppColors.borderLight, width: 0.8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Hydration Habit',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(15.0),
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
              Text(
                '7-Day Overview',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(12.0),
                  fontWeight: FontWeight.w600,
                  color: AppColors.tealMetric,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18.0),

          // Capsule Bar Chart
          CapsuleBarChart(
            values: weeklyHydration,
            activeColor: AppColors.tealMetric,
          ),
        ],
      ),
    );
  }

  Widget _buildHydrationInsightCard({
    required BuildContext context,
    required Responsive r,
    required double progress,
  }) {
    return AppCard(
      padding: EdgeInsets.all(r.isSmall ? 14.0 : 18.0),
      borderRadius: BorderRadius.circular(22.0),
      border: Border.all(color: AppColors.borderLight, width: 0.8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: AppColors.tealMetric.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const AppSvgIcon(
                  AppIcons.waterGlass,
                  color: AppColors.tealMetric,
                  size: 16.0,
                ),
              ),
              const SizedBox(width: 10.0),
              Text(
                'Hydration & Recovery Science',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(14.0),
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Text(
            progress >= 0.85
                ? 'Your fluid intake is keeping blood viscosity optimal. Proper plasma volume allows your heart to pump more blood per stroke, reducing cardiac workload and lowering resting heart rate.'
                : 'Staying hydrated enhances nutrient delivery to muscles and prevents spikes in autonomic stress. Aim to drink 500 mL between major meals.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(13.0),
              fontWeight: FontWeight.w400,
              color: context.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
