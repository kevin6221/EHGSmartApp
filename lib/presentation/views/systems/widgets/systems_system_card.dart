import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../data/models/workout_model.dart';
import '../../../blocs/training/training_bloc.dart';
import '../../../blocs/training/training_event.dart';
import '../../../blocs/wellness/wellness_bloc.dart';
import '../../../widgets/common/dotted_divider.dart';
import '../../details/hydration_detail_screen.dart';
import '../../train/training_session_screen.dart';
import 'mind_meditation_session_sheet.dart';

/// Model representing an actionable exercise item inside a system card.
class SystemExerciseItem {
  final String title;
  final WorkoutType workoutType;
  final String? subtitle;

  const SystemExerciseItem({
    required this.title,
    required this.workoutType,
    this.subtitle,
  });
}

/// Single responsibility card component for the four systems (Move, Recover, Mind, Fuel).
class SystemsCardTemplate extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String sectionKey;
  final ValueNotifier<String?> expandedSystemNotifier;
  final List<String> details;
  final List<SystemExerciseItem>? exercises;
  final bool leadsToday;
  final Responsive r;

  const SystemsCardTemplate({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.sectionKey,
    required this.expandedSystemNotifier,
    this.details = const [],
    this.exercises,
    this.leadsToday = false,
    required this.r,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: expandedSystemNotifier,
      builder: (context, expandedSection, _) {
        final isExpanded = expandedSection == sectionKey;
        return _buildCard(
          context: context,
          isExpanded: isExpanded,
          onTap: _toggleExpansion,
        );
      },
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isExpanded
            ? (context.isDark ? AppColors.midnightSurface : null)
            : context.cardBackground,
        gradient: isExpanded
            ? (context.isDark ? null : AppGradients.recoverCard)
            : null,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: context.cardBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.02),
            blurRadius: 8.0,
            offset: const Offset(0.0, 2.0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                children: [
                  Container(
                    width: 40.0,
                    height: 40.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? AppColors.midnightBackground
                          : AppColors.systemCardBgLight,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: context.cardBorder,
                        width: 1.0,
                      ),
                    ),
                    child: AppSvgIcon(
                      icon,
                      size: 24.0,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(title, style: _titleStyle(context)),
                            if (leadsToday) ...[
                              const SizedBox(width: 8.0),
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 3.0,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.cyanLight,
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Text(
                                  'Leads today',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: r.font(10.0),
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4.0),
                        Text(subtitle, style: _subtitleStyle(context)),
                      ],
                    ),
                  ),
                  RotatedBox(
                    quarterTurns: isExpanded ? 1 : 0,
                    child: const AppSvgIcon(
                      AppIcons.chevronRight,
                      color: AppColors.primary,
                      size: 20.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: DottedDivider(
                color: context.cardBorder,
                dashWidth: 3.0,
                dashSpace: 3.0,
                thickness: 0.5,
              ),
            ),
            if (exercises != null && exercises!.isNotEmpty)
              ...exercises!.map(
                (exercise) => _buildExerciseActionRow(
                  context: context,
                  title: exercise.title,
                  r: r,
                  onStart: () {
                    final titlePrefix = exercise.title.split('·').first.trim();
                    context.read<TrainingBloc>().add(
                          SelectWorkoutCategoryEvent(
                            exercise.workoutType,
                            customTitle: titlePrefix.isNotEmpty ? titlePrefix : exercise.title,
                          ),
                        );
                    context.read<TrainingBloc>().add(const StartWorkoutEvent());
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TrainingSessionScreen(),
                      ),
                    );
                  },
                ),
              )
            else
              ...details.map(
                (detail) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 8.0,
                  ),
                  child: Text(detail, style: _detailStyle(context)),
                ),
              ),
            const SizedBox(height: 4.0),
          ],
        ],
      ),
    );
  }

  void _toggleExpansion() {
    expandedSystemNotifier.value = sectionKey;
  }

  static Widget _buildExerciseActionRow({
    required BuildContext context,
    required String title,
    required Responsive r,
    required VoidCallback onStart,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: r.font(12.0),
                fontWeight: FontWeight.w400,
                color: context.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onStart,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Text(
                'START',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(11.0),
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _titleStyle(BuildContext context) => GoogleFonts.plusJakartaSans(
    fontSize: r.font(14.0),
    fontWeight: FontWeight.w600,
    color: context.textPrimary,
  );

  TextStyle _subtitleStyle(BuildContext context) => GoogleFonts.plusJakartaSans(
    fontSize: r.font(12.0),
    fontWeight: FontWeight.w400,
    color: context.textSecondary,
  );

  TextStyle _detailStyle(BuildContext context) => GoogleFonts.plusJakartaSans(
    fontSize: r.font(10.0),
    fontWeight: FontWeight.w400,
    color: context.textPrimary,
  );
}

/// Expandable Recover system card with interactive lead status and sub-action items.
class SystemsRecoverCard extends StatelessWidget {
  final ValueNotifier<String?> expandedSystemNotifier;
  final bool leadsToday;
  final Responsive r;

  const SystemsRecoverCard({
    super.key,
    required this.expandedSystemNotifier,
    this.leadsToday = true,
    required this.r,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: expandedSystemNotifier,
      builder: (context, expandedSection, _) {
        final isExpanded = expandedSection == 'recover';
        return Container(
          decoration: BoxDecoration(
            color: isExpanded
                ? (context.isDark ? AppColors.midnightSurface : null)
                : context.cardBackground,
            gradient: isExpanded
                ? (context.isDark ? null : AppGradients.recoverCard)
                : null,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: context.isDark ? context.cardBorder : AppColors.systemCardBorder,
              width: 1.0,
            ),
            boxShadow: context.isDark
                ? []
                : [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.04),
                      blurRadius: 10.0,
                      offset: const Offset(0.0, 3.0),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => expandedSystemNotifier.value = 'recover',
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    children: [
                      Container(
                        width: 40.0,
                        height: 40.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: context.isDark ? AppColors.midnightBackground : AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const AppSvgIcon(
                          AppIcons.recoverPerson,
                          size: 24.0,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Recover',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: r.font(14.0),
                                    fontWeight: FontWeight.w600,
                                    color: context.textPrimary,
                                  ),
                                ),
                                if (leadsToday) ...[
                                  const SizedBox(width: 8.0),
                                  Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 3.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.cyanLight,
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: Text(
                                      'Leads today',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: r.font(10.0),
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'Mobility, sleep, soft tissue',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: r.font(12.0),
                                fontWeight: FontWeight.w400,
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RotatedBox(
                        quarterTurns: isExpanded ? 1 : 0,
                        child: const AppSvgIcon(
                          AppIcons.chevronRight,
                          color: AppColors.primary,
                          size: 20.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isExpanded) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: DottedDivider(
                    color: context.cardBorder,
                    dashWidth: 3.0,
                    dashSpace: 3.0,
                    thickness: 0.5,
                  ),
                ),
                const SizedBox(height: 4.0),
                _buildActionItemRow(
                  context: context,
                  title: 'Full mobility flow · 20 min',
                  r: r,
                  onStart: () => _startSession(context, WorkoutType.mobility, customTitle: 'Full mobility flow'),
                ),
                _buildActionItemRow(
                  context: context,
                  title: 'Foam roll: calves & hamstrings · 8 min',
                  r: r,
                  onStart: () => _startSession(context, WorkoutType.mobility, customTitle: 'Foam roll: calves & hamstrings'),
                ),
                _buildActionItemRow(
                  context: context,
                  title: 'Sleep wind-down · 12 min',
                  r: r,
                  onStart: () => _startSession(context, WorkoutType.breathing, customTitle: 'Sleep wind-down'),
                ),
                const SizedBox(height: 4.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: DottedDivider(
                    color: context.cardBorder,
                    dashWidth: 3.0,
                    dashSpace: 3.0,
                    thickness: 0.5,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14.0, 8.0, 14.0, 12.0),
                  child: Text(
                    'Your gear: Boxy Piping T-Shirt · Foam Roller · Massage Ball',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: r.font(10.0),
                      fontWeight: FontWeight.w500,
                      color: context.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  static void _startSession(BuildContext context, WorkoutType type, {String? customTitle}) {
    context.read<TrainingBloc>().add(SelectWorkoutCategoryEvent(type, customTitle: customTitle));
    context.read<TrainingBloc>().add(const StartWorkoutEvent());
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const TrainingSessionScreen(),
      ),
    );
  }

  static Widget _buildActionItemRow({
    required BuildContext context,
    required String title,
    required Responsive r,
    required VoidCallback onStart,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: r.font(12.0),
                fontWeight: FontWeight.w400,
                color: context.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onStart,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Text(
                'START',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(11.0),
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Expandable Mind system card with interactive countdown timers for each practice.
class SystemsMindCard extends StatelessWidget {
  final ValueNotifier<String?> expandedSystemNotifier;
  final bool leadsToday;
  final Responsive r;

  const SystemsMindCard({
    super.key,
    required this.expandedSystemNotifier,
    this.leadsToday = false,
    required this.r,
  });

  void _openCountdown(BuildContext context, String title, int seconds) {
    final wellnessBloc = context.read<WellnessBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MindMeditationSessionSheet(
        title: title,
        totalSeconds: seconds,
        wellnessBloc: wellnessBloc,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: expandedSystemNotifier,
      builder: (context, expandedSection, _) {
        final isExpanded = expandedSection == 'mind';
        return Container(
          decoration: BoxDecoration(
            color: isExpanded
                ? (context.isDark ? AppColors.midnightSurface : null)
                : context.cardBackground,
            gradient: isExpanded
                ? (context.isDark ? null : AppGradients.recoverCard)
                : null,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: context.isDark ? context.cardBorder : AppColors.systemCardBorder,
              width: 1.0,
            ),
            boxShadow: context.isDark
                ? []
                : [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.04),
                      blurRadius: 10.0,
                      offset: const Offset(0.0, 3.0),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => expandedSystemNotifier.value = isExpanded ? null : 'mind',
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    children: [
                      Container(
                        width: 40.0,
                        height: 40.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: context.isDark ? AppColors.midnightBackground : AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const AppSvgIcon(
                          AppIcons.mindBreath,
                          size: 24.0,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Mind',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: r.font(14.0),
                                    fontWeight: FontWeight.w600,
                                    color: context.textPrimary,
                                  ),
                                ),
                                if (leadsToday) ...[
                                  const SizedBox(width: 8.0),
                                  Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 3.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.cyanLight,
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: Text(
                                      'Leads today',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: r.font(10.0),
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'Breath, mood, meditation',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: r.font(12.0),
                                fontWeight: FontWeight.w400,
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RotatedBox(
                        quarterTurns: isExpanded ? 1 : 0,
                        child: const AppSvgIcon(
                          AppIcons.chevronRight,
                          color: AppColors.primary,
                          size: 20.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isExpanded) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: DottedDivider(
                    color: context.cardBorder,
                    dashWidth: 3.0,
                    dashSpace: 3.0,
                    thickness: 0.5,
                  ),
                ),
                const SizedBox(height: 4.0),
                SystemsFuelCard._buildActionItemRow(
                  context: context,
                  title: 'Guided meditation · 10 min',
                  r: r,
                  onStart: () => _openCountdown(context, 'Guided meditation', 600),
                ),
                SystemsFuelCard._buildActionItemRow(
                  context: context,
                  title: 'Breathwork reset · 5 min',
                  r: r,
                  onStart: () => _openCountdown(context, 'Breathwork reset', 300),
                ),
                SystemsFuelCard._buildActionItemRow(
                  context: context,
                  title: 'Mindful check-in · 3 min',
                  r: r,
                  onStart: () => _openCountdown(context, 'Mindful check-in', 180),
                ),
                const SizedBox(height: 4.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: DottedDivider(
                    color: context.cardBorder,
                    dashWidth: 3.0,
                    dashSpace: 3.0,
                    thickness: 0.5,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14.0, 8.0, 14.0, 12.0),
                  child: Text(
                    'Your gear: Breath Sensor · EHG Mind Band',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: r.font(10.0),
                      fontWeight: FontWeight.w500,
                      color: context.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Expandable Fuel system card with interactive lead status and actionable hydration items.
class SystemsFuelCard extends StatelessWidget {
  final ValueNotifier<String?> expandedSystemNotifier;
  final bool leadsToday;
  final Responsive r;

  const SystemsFuelCard({
    super.key,
    required this.expandedSystemNotifier,
    this.leadsToday = false,
    required this.r,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: expandedSystemNotifier,
      builder: (context, expandedSection, _) {
        final isExpanded = expandedSection == 'fuel';
        return Container(
          decoration: BoxDecoration(
            color: isExpanded
                ? (context.isDark ? AppColors.midnightSurface : null)
                : context.cardBackground,
            gradient: isExpanded
                ? (context.isDark ? null : AppGradients.recoverCard)
                : null,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: context.isDark ? context.cardBorder : AppColors.systemCardBorder,
              width: 1.0,
            ),
            boxShadow: context.isDark
                ? []
                : [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.04),
                      blurRadius: 10.0,
                      offset: const Offset(0.0, 3.0),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => expandedSystemNotifier.value = isExpanded ? null : 'fuel',
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    children: [
                      Container(
                        width: 40.0,
                        height: 40.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: context.isDark ? AppColors.midnightBackground : AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const AppSvgIcon(
                          AppIcons.singleDrop,
                          size: 24.0,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Fuel',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: r.font(14.0),
                                    fontWeight: FontWeight.w600,
                                    color: context.textPrimary,
                                  ),
                                ),
                                if (leadsToday) ...[
                                  const SizedBox(width: 8.0),
                                  Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 3.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.cyanLight,
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: Text(
                                      'Leads today',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: r.font(10.0),
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'Hydration, food, habits',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: r.font(12.0),
                                fontWeight: FontWeight.w400,
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RotatedBox(
                        quarterTurns: isExpanded ? 1 : 0,
                        child: const AppSvgIcon(
                          AppIcons.chevronRight,
                          color: AppColors.primary,
                          size: 20.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isExpanded) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: DottedDivider(
                    color: context.cardBorder,
                    dashWidth: 3.0,
                    dashSpace: 3.0,
                    thickness: 0.5,
                  ),
                ),
                const SizedBox(height: 4.0),
                _buildActionItemRow(
                  context: context,
                  title: 'Record your water daily intake',
                  r: r,
                  onStart: () => _openHydrationDetail(context),
                ),
                const SizedBox(height: 4.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: DottedDivider(
                    color: context.cardBorder,
                    dashWidth: 3.0,
                    dashSpace: 3.0,
                    thickness: 0.5,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14.0, 8.0, 14.0, 12.0),
                  child: Text(
                    'Your gear: Insulated Smart Bottle · EHG Smart Band',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: r.font(10.0),
                      fontWeight: FontWeight.w500,
                      color: context.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  static void _openHydrationDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const HydrationDetailScreen(),
      ),
    );
  }

  static Widget _buildActionItemRow({
    required BuildContext context,
    required String title,
    required Responsive r,
    required VoidCallback onStart,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: r.font(12.0),
                fontWeight: FontWeight.w400,
                color: context.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onStart,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Text(
                'START',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(11.0),
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
