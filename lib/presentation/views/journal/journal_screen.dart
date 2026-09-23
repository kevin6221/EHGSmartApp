import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
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

  @override
  void initState() {
    super.initState();
    _selectedEnergyNotifier = ValueNotifier<int>(2);
    _selectedWordNotifier = ValueNotifier<String>('Clam');
    _journalTextController = TextEditingController();
  }

  @override
  void dispose() {
    _selectedEnergyNotifier.dispose();
    _selectedWordNotifier.dispose();
    _journalTextController.dispose();
    super.dispose();
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
                      onSave: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Journal entry saved! +120 points')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  // 4. Pattern the Band Found Banner
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.horizontalPadding),
                    child: const JournalPatternBanner(),
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
                    child: const JournalRecentEntriesCard(),
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
