import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../blocs/training/training_bloc.dart';
import '../../blocs/training/training_event.dart';
import '../../blocs/training/training_state.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

/// Pixel-perfect recording view matching Figma Node 128:554.
/// Strictly enforces Zero setState policy via ValueNotifier.
class TrainingSessionScreen extends StatefulWidget {
  const TrainingSessionScreen({super.key});

  @override
  State<TrainingSessionScreen> createState() => _TrainingSessionScreenState();
}

class _TrainingSessionScreenState extends State<TrainingSessionScreen> {
  Timer? _ticker;
  late final ValueNotifier<int> _selectedZoneNotifier;

  @override
  void initState() {
    super.initState();
    _selectedZoneNotifier = ValueNotifier<int>(1);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) context.read<TrainingBloc>().add(const TickWorkoutEvent());
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _selectedZoneNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return BlocBuilder<TrainingBloc, TrainingState>(
      builder: (context, state) {
        if (state.data == null) return const SizedBox.shrink();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              const _RecordingBackground(),
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        r.horizontalPadding,
                        (screenHeight * 0.012).clamp(8.0, 12.0),
                        r.horizontalPadding,
                        0,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Recording · Mobility',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.white,
                            fontSize: r.font(24),
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          r.horizontalPadding,
                          (screenHeight * 0.018).clamp(12.0, 16.0),
                          r.horizontalPadding,
                          r.hp(0.14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _TimerCard(elapsedSeconds: state.elapsedSeconds),
                            SizedBox(
                              height: (screenHeight * 0.020).clamp(12.0, 16.0),
                            ),
                            IntrinsicHeight(
                              child: Row(
                                children: [
                                  const Expanded(
                                    child: _MetricCard(
                                      icon: AppIcons.heartPulse,
                                      label: 'Heart Rate',
                                      color: AppColors.primary,
                                      value: '72',
                                      unit: 'bpm',
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: _MetricCard(
                                      icon: AppIcons.trainFlame,
                                      color: AppColors.mindPillar,
                                      label: 'Calories',
                                      value: '${19 + state.elapsedSeconds ~/ 60}',
                                      unit: 'kcal',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: (screenHeight * 0.028).clamp(18.0, 24.0),
                            ),
                            Text(
                              'Zone',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.secondary,
                                fontSize: r.font(18),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(
                              height: (screenHeight * 0.014).clamp(8.0, 12.0),
                            ),
                            _ZoneCard(
                              selectedZoneNotifier: _selectedZoneNotifier,
                            ),
                            SizedBox(
                              height: (screenHeight * 0.018).clamp(10.0, 16.0),
                            ),
                            ValueListenableBuilder<int>(
                              valueListenable: _selectedZoneNotifier,
                              builder: (context, selectedZone, _) {
                                return Text(
                                  _zoneDescription(selectedZone),
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.tertiary,
                                    fontSize: r.font(13.5),
                                    height: 1.45,
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: (screenHeight * 0.032).clamp(20.0, 28.0),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              child: AppButton(
                                text: 'Finish session',
                                onPressed: () {
                                  context.read<TrainingBloc>().add(
                                    const FinishWorkoutEvent(),
                                  );
                                  Navigator.of(context).pushReplacementNamed(
                                    AppRoutes.membership,
                                  );
                                },
                                useGradient: true,
                                borderRadius: BorderRadius.circular(12),
                                fontSize: r.font(16),
                                fontWeight: FontWeight.w700,
                                hasShadow: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: CustomBottomNavBar(
                  activeIndex: 2,
                  onTabSelected: (_) => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _zoneDescription(int zone) {
    const descriptions = [
      'Aerobic and sustainable. This is the range that builds an engine without costing you tomorrow.',
      'Controlled and comfortable. This is the range that builds endurance without costing you tomorrow.',
      'Steady and focused. This is the range that improves your fitness while staying sustainable.',
      'Challenging and strong. Use this range for short efforts with enough recovery between them.',
      'High intensity. Keep this range brief and return to an easier zone when you need to recover.',
    ];
    return descriptions[zone - 1];
  }
}

class _RecordingBackground extends StatelessWidget {
  const _RecordingBackground();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: screenHeight * 0.35,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryGradientStart,
              AppColors.background.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerCard extends StatelessWidget {
  final int elapsedSeconds;
  const _TimerCard({required this.elapsedSeconds});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final media = MediaQuery.sizeOf(context);
    final totalSeconds = 16080 + elapsedSeconds;
    final duration = Duration(seconds: totalSeconds);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final timer = '$hours : $minutes : $seconds';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: (media.width * 0.06).clamp(18.0, 24.0),
        vertical: (media.height * 0.022).clamp(14.0, 20.0),
      ),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        gradient: AppGradients.timerCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary,
          width: 0.5,
        ),
      ),
      child: Text(
        timer,
        style: GoogleFonts.plusJakartaSans(
          color: AppColors.primary,
          fontSize: r.font(30),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;
  final String unit;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final media = MediaQuery.sizeOf(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: (media.height * 0.016).clamp(11.0, 15.0),
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowNavy.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              AppSvgIcon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.secondary,
                    fontSize: r.font(12),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: (media.height * 0.010).clamp(6.0, 10.0)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.secondary,
                  fontSize: r.font(18),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.secondary,
                  fontSize: r.font(12),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ZoneCard extends StatelessWidget {
  final ValueNotifier<int> selectedZoneNotifier;

  const _ZoneCard({required this.selectedZoneNotifier});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final media = MediaQuery.sizeOf(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: (media.height * 0.014).clamp(10.0, 14.0),
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowNavy.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ValueListenableBuilder<int>(
        valueListenable: selectedZoneNotifier,
        builder: (context, selectedZone, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Zone $selectedZone · ${_zoneName(selectedZone)}',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.primary,
                  fontSize: r.font(12.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: (media.height * 0.010).clamp(6.0, 10.0)),
              Row(
                children: List.generate(5, (index) {
                  final zone = index + 1;
                  final isSelected = zone == selectedZone;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => selectedZoneNotifier.value = zone,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        margin: EdgeInsets.only(right: zone == 5 ? 0 : 5),
                        padding: EdgeInsets.symmetric(
                          vertical: (media.height * 0.009).clamp(6.0, 9.0),
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Z$zone',
                          style: GoogleFonts.plusJakartaSans(
                            color: isSelected
                                ? AppColors.white
                                : AppColors.primary,
                            fontSize: r.font(12.5),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _zoneName(int zone) {
    const names = ['Easy', 'Steady', 'Moderate', 'Hard', 'Peak'];
    return names[zone - 1];
  }
}
