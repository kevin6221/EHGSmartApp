import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../../data/models/hydration_record_model.dart';
import '../../../data/models/wellness_data_model.dart';
import '../../../data/repositories/wellness_repository.dart';
import '../../blocs/wellness/wellness_bloc.dart';
import '../../blocs/wellness/wellness_event.dart';
import '../../blocs/wellness/wellness_state.dart';
import '../../widgets/charts/capsule_bar_chart.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/detail_screen_app_bar.dart';
import '../../widgets/common/screen_header.dart';

/// Full-screen Hydration Detail screen adhering to the EHG design system.
///
/// Features interactive quick-logging (+250ml, +500ml, +750ml, -250ml, -500ml, custom free-type),
/// 7-day interactive consistency overview, personalized target breakdown, and coaching insights.
class HydrationDetailScreen extends StatefulWidget {
  const HydrationDetailScreen({super.key});

  @override
  State<HydrationDetailScreen> createState() => _HydrationDetailScreenState();
}

class _HydrationDetailScreenState extends State<HydrationDetailScreen> {
  late final ValueNotifier<int> _selectedDayNotifier;

  @override
  void initState() {
    super.initState();
    _selectedDayNotifier = ValueNotifier<int>((DateTime.now().weekday - 1).clamp(0, 6));
  }

  @override
  void dispose() {
    _selectedDayNotifier.dispose();
    super.dispose();
  }

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
                  statusColor: AppColors.primary,
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

                            // Quick Log Buttons Card (with 250, 500, 750, 1000, Custom)
                            _buildQuickLogCard(
                              context: context,
                              r: r,
                              currentMl: currentMl,
                            ),
                            SizedBox(height: itemSpacing),

                            // Weekly Consistency Card (Interactive Day Inspector)
                            _buildWeeklyConsistencyCard(
                              context: context,
                              r: r,
                              weeklyHydration: weeklyHydration,
                              currentMl: currentMl,
                              goalMl: goalMl,
                            ),
                            SizedBox(height: itemSpacing),

                            // Logged Hydration Entries Card (Inspect & Remove individual entries)
                            _buildLoggedEntriesCard(
                              context: context,
                              r: r,
                              wellness: wellness,
                              goalMl: goalMl,
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
                          color: AppColors.primary.withValues(alpha: 0.25),
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
                  color: context.isDark ? AppColors.midnightBackground : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  pct >= 100 ? 'Goal Reached' : '$pct% of Goal',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(11.0),
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
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
                  color: AppColors.primary,
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
              backgroundColor: AppColors.hydrationTrack,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
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
    required int currentMl,
  }) {
    final quickOptions = [
      {'label': '250 mL', 'amount': 250},
      {'label': '500 mL', 'amount': 500},
      {'label': '750 mL', 'amount': 750},
      {'label': '1000 mL', 'amount': 1000},
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
                'Quick Log',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(15.0),
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
              const Icon(
                Icons.water_drop_rounded,
                size: 20.0,
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 6.0),
          Text(
            'Select a preset volume or enter custom mL to record your fluid intake',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(12.0),
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 16.0),

          // Options: 250 mL, 500 mL, 750 mL, 1000 mL, and Custom
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              ...quickOptions.map((opt) {
                final amount = opt['amount'] as int;
                final label = opt['label'] as String;
                return InkWell(
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
                        backgroundColor: AppColors.primary,
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
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? AppColors.midnightBackground
                          : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(14.0),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add, size: 14.0, color: AppColors.primary),
                        const SizedBox(width: 4.0),
                        Text(
                          label,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: r.font(13.0),
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              // Custom Button
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => CustomHydrationSheet(currentMl: currentMl),
                  );
                },
                borderRadius: BorderRadius.circular(14.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: context.isDark
                        ? AppColors.midnightSurface
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(14.0),
                    border: Border.all(
                      color: AppColors.primary,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.edit_outlined, size: 14.0, color: AppColors.primary),
                      const SizedBox(width: 4.0),
                      Text(
                        'Custom',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(13.0),
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  DateTime _getDateForDayIndex(int dayIdx) {
    final now = DateTime.now();
    final currentWeekday = now.weekday; // 1 = Mon, 7 = Sun
    final monday = now.subtract(Duration(days: currentWeekday - 1));
    return DateTime(monday.year, monday.month, monday.day).add(Duration(days: dayIdx));
  }

  Widget _buildLoggedEntriesCard({
    required BuildContext context,
    required Responsive r,
    required WellnessDataModel? wellness,
    required int goalMl,
  }) {
    const fullDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return AppCard(
      padding: EdgeInsets.all(r.isSmall ? 14.0 : 18.0),
      borderRadius: BorderRadius.circular(22.0),
      border: Border.all(color: AppColors.borderLight, width: 0.8),
      child: ValueListenableBuilder<int>(
        valueListenable: _selectedDayNotifier,
        builder: (context, selectedIdx, _) {
          final int todayIdx = (DateTime.now().weekday - 1).clamp(0, 6);
          final bool isToday = selectedIdx == todayIdx;
          final String dayTitle = fullDays[selectedIdx];
          final selectedDate = _getDateForDayIndex(selectedIdx);

          if (isToday) {
            final entries = wellness?.hydrationRecords ?? const [];
            return _buildEntriesListContent(
              context: context,
              r: r,
              dayTitle: '$dayTitle (Today)',
              selectedDate: selectedDate,
              entries: entries,
              isToday: true,
            );
          }

          return FutureBuilder<List<HydrationRecord>>(
            future: context.read<WellnessRepository>().getHydrationEntriesForDate(selectedDate),
            builder: (context, snapshot) {
              final entries = snapshot.data ?? const [];
              return _buildEntriesListContent(
                context: context,
                r: r,
                dayTitle: dayTitle,
                selectedDate: selectedDate,
                entries: entries,
                isToday: false,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEntriesListContent({
    required BuildContext context,
    required Responsive r,
    required String dayTitle,
    required DateTime selectedDate,
    required List<HydrationRecord> entries,
    required bool isToday,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isToday ? "Today's Hydration" : "$dayTitle's Hydration",
              style: GoogleFonts.plusJakartaSans(
                fontSize: r.font(15.0),
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                '${entries.length} ${entries.length == 1 ? 'entry' : 'entries'}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(11.0),
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6.0),
        Text(
          'Individual fluid intake entries. Tap Remove to delete any entry.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: r.font(12.0),
            color: context.textSecondary,
          ),
        ),
        const SizedBox(height: 14.0),

        if (entries.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: context.isDark ? AppColors.midnightBackground : AppColors.surface,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: context.cardBorder, width: 0.8),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.water_drop_outlined,
                  size: 32.0,
                  color: context.textSecondary.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'No hydration logged for this day',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(13.0),
                    fontWeight: FontWeight.w500,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: entries.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8.0),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: context.isDark ? AppColors.midnightBackground : AppColors.surface,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(color: context.cardBorder, width: 0.8),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Icon(
                        Icons.water_drop_rounded,
                        size: 16.0,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${entry.amountMl} mL',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: r.font(15.0),
                              fontWeight: FontWeight.w700,
                              color: context.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            entry.timeFormatted,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: r.font(11.0),
                              fontWeight: FontWeight.w500,
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        context.read<WellnessBloc>().add(
                          RemoveHydrationEntryEvent(entry.id, date: selectedDate),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Removed ${entry.amountMl} mL entry',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: AppColors.scoreDownRed.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: AppColors.scoreDownRed.withValues(alpha: 0.30),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.delete_outline_rounded,
                              size: 14.0,
                              color: AppColors.scoreDownRed,
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              'Remove',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: r.font(12.0),
                                fontWeight: FontWeight.w600,
                                color: AppColors.scoreDownRed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildWeeklyConsistencyCard({
    required BuildContext context,
    required Responsive r,
    required List<double> weeklyHydration,
    required int currentMl,
    required int goalMl,
  }) {
    const fullDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return AppCard(
      padding: EdgeInsets.all(r.isSmall ? 14.0 : 18.0),
      borderRadius: BorderRadius.circular(22.0),
      border: Border.all(color: AppColors.borderLight, width: 0.8),
      child: ValueListenableBuilder<int>(
        valueListenable: _selectedDayNotifier,
        builder: (context, selectedIdx, _) {
          final int todayIdx = (DateTime.now().weekday - 1).clamp(0, 6);
          final bool isToday = selectedIdx == todayIdx;
          final int dayVolume = isToday
              ? currentMl
              : (weeklyHydration[selectedIdx] * goalMl).round();
          final double dayRatio = isToday
              ? (currentMl / goalMl)
              : weeklyHydration[selectedIdx];
          final int dayPct = (dayRatio * 100).round();
          final String dayTitle = fullDays[selectedIdx];

          return Column(
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
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18.0),

              // Interactive Capsule Bar Chart
              CapsuleBarChart(
                values: weeklyHydration,
                activeColor: AppColors.primary,
                middleColor: AppColors.hydrationMiddle,
                lightColor: AppColors.hydrationLight,
                trackColor: AppColors.hydrationTrack,
                selectedIndex: selectedIdx,
                onBarTap: (index) {
                  _selectedDayNotifier.value = index;
                },
              ),
              const SizedBox(height: 16.0),

              // Selected Day Inspection Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: context.isDark
                      ? AppColors.midnightBackground
                      : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.20),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isToday ? '$dayTitle (Today)' : dayTitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: r.font(13.0),
                            fontWeight: FontWeight.w700,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          'Tap any day bar to view recorded intake',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: r.font(10.0),
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$dayVolume mL',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: r.font(15.0),
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          '$dayPct% of daily target',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: r.font(11.0),
                            fontWeight: FontWeight.w500,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
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
                  color: context.isDark
                      ? AppColors.midnightBackground
                      : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const AppSvgIcon(
                  AppIcons.waterGlass,
                  color: AppColors.primary,
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

/// Modal bottom sheet allowing the user to free-type any custom mL amount.
class CustomHydrationSheet extends StatelessWidget {
  final int currentMl;

  const CustomHydrationSheet({super.key, required this.currentMl});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final isDark = context.isDark;
    final controller = TextEditingController();
    final errorNotifier = ValueNotifier<String?>(null);

    return Container(
      padding: EdgeInsets.fromLTRB(20.0, 16.0, 20.0, MediaQuery.of(context).viewInsets.bottom + 24.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightSurface : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: context.cardBorder,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Enter Custom Amount',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(18.0),
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20.0),
                onPressed: () => Navigator.of(context).pop(),
                color: context.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          Text(
            'Current intake: $currentMl mL. Enter the amount to add:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(12.0),
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 16.0),
          ValueListenableBuilder<String?>(
            valueListenable: errorNotifier,
            builder: (context, errorText, _) {
              return TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                onChanged: (_) {
                  if (errorNotifier.value != null) {
                    errorNotifier.value = null;
                  }
                },
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(20.0),
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. 350',
                  errorText: errorText,
                  suffixText: 'mL',
                  suffixStyle: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(15.0),
                    fontWeight: FontWeight.w600,
                    color: context.textSecondary,
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.midnightBackground : AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: context.cardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: context.cardBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20.0),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final text = controller.text.trim();
                final val = int.tryParse(text);
                if (val == null || val <= 0) {
                  errorNotifier.value = 'Please enter a valid positive amount (e.g. 350)';
                  return;
                }
                context.read<WellnessBloc>().add(AddHydrationEvent(val));
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Added $val mL of water',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                elevation: 0,
              ),
              child: Text(
                'Add',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(15.0),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
