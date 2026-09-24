import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../../data/models/journal_entry_model.dart';
import '../../../data/repositories/wellness_repository.dart';
import '../../widgets/common/screen_header.dart';
import 'widgets/journal_check_in_card.dart';
import 'widgets/journal_pattern_banner.dart';
import 'widgets/journal_recent_entries_card.dart';

/// Journal screen matching Figma Node 143:2654.
/// Refactored to modular architecture with zero setState.
class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  late final ValueNotifier<int> _selectedEnergyNotifier;
  late final ValueNotifier<String> _selectedWordNotifier;
  late final TextEditingController _journalTextController;
  late final ValueNotifier<List<JournalEntryModel>> _entriesNotifier;

  @override
  void initState() {
    super.initState();
    _selectedEnergyNotifier = ValueNotifier<int>(2);
    _selectedWordNotifier = ValueNotifier<String>('Calm');
    _journalTextController = TextEditingController();
    _entriesNotifier = ValueNotifier<List<JournalEntryModel>>([]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _entriesNotifier.value =
            context.read<WellnessRepository>().journalEntries;
      }
    });
  }

  @override
  void dispose() {
    _selectedEnergyNotifier.dispose();
    _selectedWordNotifier.dispose();
    _journalTextController.dispose();
    _entriesNotifier.dispose();
    super.dispose();
  }

  String _computePatternText(List<JournalEntryModel> entries) {
    if (entries.isEmpty) {
      return "Log your daily check-in to unlock your physiological recovery pattern.";
    }
    if (entries.length < 2) {
      return "Logged 1 check-in. Continue logging to uncover how sleep correlates with daily energy.";
    }
    final highEnergyEntries = entries.where((e) => e.energyLevel >= 3).toList();
    final lowEnergyEntries = entries.where((e) => e.energyLevel < 3).toList();

    if (highEnergyEntries.isNotEmpty && lowEnergyEntries.isNotEmpty) {
      final avgHighSleep = highEnergyEntries.fold(0.0, (s, e) => s + e.sleepHours) /
          highEnergyEntries.length;
      final avgLowSleep = lowEnergyEntries.fold(0.0, (s, e) => s + e.sleepHours) /
          lowEnergyEntries.length;
      if (avgHighSleep > 0 && avgLowSleep > 0) {
        return "Your energy averages higher after ${avgHighSleep.toStringAsFixed(1)}h sleep compared to ${avgLowSleep.toStringAsFixed(1)}h on lower energy days. Across ${entries.length} entries, sleep is your strongest lever.";
      }
    }
    return "Your energy averages ${entries.first.energyLevel}/4 with '${entries.first.moodWord}'. Consistent logging reveals key levers for your daily readiness.";
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          const SkyHeaderBackground(height: 250),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 110.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Top Header Row & Divider
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      r.horizontalPadding,
                      10.0,
                      r.horizontalPadding,
                      0,
                    ),
                    child: Column(
                      children: [
                        const ScreenHeader(
                          title: 'Journal',
                          titleFontSize: 24.0,
                          showAvatar: true,
                          showOnlineIndicator: true,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0, bottom: 20.0),
                          child: Container(
                            height: 1.0,
                            color: AppColors.white.withValues(alpha: 0.35),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. Tonight's check-in Section Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.horizontalPadding),
                    child: Text(
                      "Tonight's check-in",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(14.0),
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // 3. Interactive Check-in Card
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.horizontalPadding),
                    child: JournalCheckInCard(
                      energyNotifier: _selectedEnergyNotifier,
                      wordNotifier: _selectedWordNotifier,
                      textController: _journalTextController,
                      onSave: () async {
                        final energy = _selectedEnergyNotifier.value;
                        final word = _selectedWordNotifier.value;
                        final note = _journalTextController.text.trim();

                        await context.read<WellnessRepository>().saveJournalEntry(
                              energyLevel: energy,
                              moodWord: word,
                              note: note.isNotEmpty
                                  ? note
                                  : 'Evening wellness check-in completed.',
                            );

                        _journalTextController.clear();
                        if (context.mounted) {
                          _entriesNotifier.value = context
                              .read<WellnessRepository>()
                              .journalEntries;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Journal entry saved! +120 points'),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  // 4. Pattern the Band Found Banner
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.horizontalPadding),
                    child: ValueListenableBuilder<List<JournalEntryModel>>(
                      valueListenable: _entriesNotifier,
                      builder: (context, entries, _) {
                        return JournalPatternBanner(
                          patternText: _computePatternText(entries),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 4.0),

                  // 5. Recent Entries Section
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: r.horizontalPadding,
                      vertical: 16.0,
                    ),
                    child: Text(
                      "Recent entries",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(14.0),
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.horizontalPadding),
                    child: ValueListenableBuilder<List<JournalEntryModel>>(
                      valueListenable: _entriesNotifier,
                      builder: (context, entries, _) {
                        if (entries.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: context.cardBackground,
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(color: context.cardBorder),
                            ),
                            child: Center(
                              child: Text(
                                "No entries yet. Complete tonight's check-in above!",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: r.font(12.0),
                                  fontWeight: FontWeight.w500,
                                  color: context.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }

                        const monthNames = [
                          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                        ];

                        return Column(
                          children: entries.take(5).map((entry) {
                            final dateStr =
                                '${entry.date.day} ${monthNames[(entry.date.month - 1).clamp(0, 11)]} · ${entry.moodWord}';
                            final energyStr =
                                '${entry.sleepHours > 0 ? "${entry.sleepHours.toStringAsFixed(1)}h · " : ""}energy ${entry.energyLevel}/4';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: JournalRecentEntriesCard(
                                dateText: dateStr,
                                energyText: energyStr,
                                noteText: entry.note,
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

