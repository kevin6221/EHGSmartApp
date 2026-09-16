import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../widgets/common/screen_header.dart';
import 'widgets/systems_build_routine_section.dart';
import 'widgets/systems_journeys_section.dart';
import 'widgets/systems_programmes_section.dart';
import 'widgets/systems_system_card.dart';

/// Systems screen matching Figma Node 143:2187 ("Four systems, one wardrobe").
/// Strictly adheres to zero setState() policy using ValueNotifiers for reactive local state.
class SystemsScreen extends StatefulWidget {
  const SystemsScreen({super.key});

  @override
  State<SystemsScreen> createState() => _SystemsScreenState();
}

class _SystemsScreenState extends State<SystemsScreen> {
  late final TextEditingController _routineNameController;
  late final ValueNotifier<int> _selectedDurationNotifier;
  late final ValueNotifier<Set<String>> _selectedMovementsNotifier;
  late final ValueNotifier<Set<String>> _selectedWellnessNotifier;
  late final ValueNotifier<List<Map<String, String>>> _activeRoutineNotifier;
  late final ValueNotifier<String?> _expandedSystemNotifier;

  @override
  void initState() {
    super.initState();
    _routineNameController = TextEditingController();
    _selectedDurationNotifier = ValueNotifier<int>(14);
    _selectedMovementsNotifier = ValueNotifier<Set<String>>({'Yga'});
    _selectedWellnessNotifier = ValueNotifier<Set<String>>({'Mobile Flow'});
    _expandedSystemNotifier = ValueNotifier<String?>('recover');
    _activeRoutineNotifier = ValueNotifier<List<Map<String, String>>>([
      {
        'key': 'Mobile Flow',
        'title': 'Mobility flow',
        'duration': '30 min.',
        'type': 'wellness',
      },
      {
        'key': 'Yga',
        'title': 'Yoga',
        'duration': '45 min.',
        'type': 'movement',
      },
    ]);
  }

  @override
  void dispose() {
    _routineNameController.dispose();
    _selectedDurationNotifier.dispose();
    _selectedMovementsNotifier.dispose();
    _selectedWellnessNotifier.dispose();
    _expandedSystemNotifier.dispose();
    _activeRoutineNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final media = MediaQuery.sizeOf(context);
    final screenHeight = media.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Sky header gradient background
          SkyHeaderBackground(
            height: screenHeight * 0.36,
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
                110.0, // Space for floating bottom navigation bar
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Unified Top Header Row (Title & User Avatar)
                  const ScreenHeader(
                    title: 'Four systems, one wardrobe',
                    titleFontSize: 20.0,
                    showAvatar: true,
                    showOnlineIndicator: true,
                  ),

                  // Subtle divider under top bar matching Figma
                  Padding(
                    padding: const EdgeInsets.only(top: 14.0, bottom: 16.0),
                    child: Container(
                      height: 1.0,
                      color: AppColors.white.withValues(alpha: 0.35),
                    ),
                  ),

                  // 2. Subtitle copy
                  Text(
                    'Everything you own sits in a system. The band decides which one leads today.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: r.font(16.0),
                      fontWeight: FontWeight.w400,
                      color: AppColors.tertiary,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 27.0),

                  // 3. Four Systems Cards
                  SystemsCardTemplate(
                    icon: AppIcons.runningManIcon,
                    title: 'Move',
                    subtitle: 'Strength, running, movement goals',
                    sectionKey: 'move',
                    expandedSystemNotifier: _expandedSystemNotifier,
                    details: const [
                      'Strength session · 45 min',
                      'Run intervals · 30 min',
                      'Movement goal · 8,000 steps',
                    ],
                    r: r,
                  ),
                  const SizedBox(height: 16.0),

                  SystemsRecoverCard(
                    expandedSystemNotifier: _expandedSystemNotifier,
                    r: r,
                  ),
                  const SizedBox(height: 16.0),

                  SystemsCardTemplate(
                    icon: AppIcons.mindBreath,
                    title: 'Mind',
                    subtitle: 'Breath, mood, meditation',
                    sectionKey: 'mind',
                    expandedSystemNotifier: _expandedSystemNotifier,
                    details: const [
                      'Guided meditation · 10 min',
                      'Breathwork reset · 5 min',
                      'Check in with your mood',
                    ],
                    r: r,
                  ),
                  const SizedBox(height: 16.0),

                  SystemsCardTemplate(
                    icon: AppIcons.singleDrop,
                    title: 'Fuel',
                    subtitle: 'Hydration, food, habits',
                    sectionKey: 'fuel',
                    expandedSystemNotifier: _expandedSystemNotifier,
                    details: const [
                      'Drink water · 250 ml',
                      'Plan your next meal',
                      'Log today’s fuel habits',
                    ],
                    r: r,
                  ),
                  SizedBox(height: (screenHeight * 0.026).clamp(20.0, 28.0)),

                  // 4. Journeys in Progress Section
                  SystemsJourneysSection(r: r, screenHeight: screenHeight),
                  SizedBox(height: (screenHeight * 0.026).clamp(20.0, 28.0)),

                  // 5. Your Programmes Section
                  SystemsProgrammesSection(r: r),
                  SizedBox(height: (screenHeight * 0.026).clamp(20.0, 28.0)),

                  // 6. Build Your Own Routine Section
                  SystemsBuildRoutineSection(
                    routineNameController: _routineNameController,
                    selectedDurationNotifier: _selectedDurationNotifier,
                    selectedMovementsNotifier: _selectedMovementsNotifier,
                    selectedWellnessNotifier: _selectedWellnessNotifier,
                    activeRoutineNotifier: _activeRoutineNotifier,
                    r: r,
                  ),
                  SizedBox(height: (screenHeight * 0.025).clamp(18.0, 24.0)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
