import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../../data/models/wellness_data_model.dart';
import '../../../data/models/workout_model.dart';
import '../../../data/repositories/wellness_repository.dart';
import '../../blocs/wellness/wellness_bloc.dart';
import '../../widgets/common/screen_header.dart';
import 'widgets/systems_build_routine_section.dart';
import 'widgets/systems_journeys_section.dart';
import 'widgets/systems_programmes_section.dart';
import 'widgets/systems_saved_routines_section.dart';
import 'widgets/systems_system_card.dart';

/// Systems screen matching Figma Node 143:2187 ("Four systems, one wardrobe").
/// Strictly adheres to zero setState() policy using ValueNotifiers for reactive local state.
class SystemsScreen extends StatefulWidget {
  final WellnessMode? initialMode;
  final String? initialExpandedSection;
  final bool isTab;

  const SystemsScreen({
    super.key,
    this.initialMode,
    this.initialExpandedSection,
    this.isTab = false,
  });

  @override
  State<SystemsScreen> createState() => _SystemsScreenState();
}

class _SystemsScreenState extends State<SystemsScreen> {
  final _routineFormKey = GlobalKey<FormState>();
  late final TextEditingController _routineNameController;
  late final ValueNotifier<int> _selectedDurationNotifier;
  late final ValueNotifier<Set<String>> _selectedMovementsNotifier;
  late final ValueNotifier<Set<String>> _selectedWellnessNotifier;
  late final ValueNotifier<List<Map<String, String>>> _activeRoutineNotifier;
  late final ValueNotifier<String?> _expandedSystemNotifier;
  late final ValueNotifier<List<UserRoutine>> _savedRoutinesNotifier;

  @override
  void initState() {
    super.initState();
    _routineNameController = TextEditingController();
    _selectedDurationNotifier = ValueNotifier<int>(14);
    _selectedMovementsNotifier = ValueNotifier<Set<String>>({'Yga'});
    _selectedWellnessNotifier = ValueNotifier<Set<String>>({'Mobile Flow'});
    _savedRoutinesNotifier = ValueNotifier<List<UserRoutine>>([]);

    final String initialSection = widget.initialExpandedSection ??
        switch (widget.initialMode) {
          WellnessMode.recover => 'recover',
          WellnessMode.steady => 'move',
          WellnessMode.push => 'move',
          null => 'recover',
        };
    _expandedSystemNotifier = ValueNotifier<String?>(initialSection);
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      try {
        final wellnessRepo = context.read<WellnessRepository>();
        final savedRoutine = await wellnessRepo.getLatestActiveUserRoutine();
        final allRoutines = await wellnessRepo.getUserRoutines();

        if (mounted) {
          _savedRoutinesNotifier.value = allRoutines;
        }

        if (savedRoutine != null && mounted) {
          _routineNameController.text = savedRoutine.routineName;
          _selectedDurationNotifier.value = savedRoutine.durationDays;

          final movementsList =
              (jsonDecode(savedRoutine.movementsJson) as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toSet();
          if (movementsList != null && movementsList.isNotEmpty) {
            _selectedMovementsNotifier.value = movementsList;
          }

          final wellnessList =
              (jsonDecode(savedRoutine.wellnessJson) as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toSet();
          if (wellnessList != null && wellnessList.isNotEmpty) {
            _selectedWellnessNotifier.value = wellnessList;
          }

          final rawItems =
              jsonDecode(savedRoutine.routineItemsJson) as List<dynamic>?;
          if (rawItems != null && rawItems.isNotEmpty) {
            final parsedItems = rawItems
                .map((e) => Map<String, String>.from(e as Map))
                .toList();
            _activeRoutineNotifier.value = parsedItems;
          }
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _routineNameController.dispose();
    _selectedDurationNotifier.dispose();
    _selectedMovementsNotifier.dispose();
    _selectedWellnessNotifier.dispose();
    _expandedSystemNotifier.dispose();
    _activeRoutineNotifier.dispose();
    _savedRoutinesNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final media = MediaQuery.sizeOf(context);
    final screenHeight = media.height;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  ScreenHeader(
                    title: 'Four systems, one wardrobe',
                    titleFontSize: 20.0,
                    showAvatar: true,
                    showBackButton: !widget.isTab,
                    showOnlineIndicator: false,
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
                      color: context.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 27.0),

                  // 3. Four Systems Cards
                  () {
                    final activeMode = widget.initialMode ??
                        context.watch<WellnessBloc>().state.data?.activeMode ??
                        WellnessMode.recover;

                    final bool isMoveLeading = activeMode == WellnessMode.steady ||
                        activeMode == WellnessMode.push;
                    final bool isRecoverLeading =
                        activeMode == WellnessMode.recover;

                    final List<SystemExerciseItem> moveExercises =
                        switch (activeMode) {
                      WellnessMode.steady => const [
                          SystemExerciseItem(
                            title: 'Brisk outdoor walk · 30 min',
                            workoutType: WorkoutType.walk,
                          ),
                          SystemExerciseItem(
                            title: 'Steady Zone 2 aerobic walk · 45 min',
                            workoutType: WorkoutType.walk,
                          ),
                          SystemExerciseItem(
                            title: 'Movement goal · 8,000 steps',
                            workoutType: WorkoutType.walk,
                          ),
                        ],
                      WellnessMode.push => const [
                          SystemExerciseItem(
                            title: 'Full body strength session · 45 min',
                            workoutType: WorkoutType.strength,
                          ),
                          SystemExerciseItem(
                            title: 'HIIT intervals & sprint · 30 min',
                            workoutType: WorkoutType.hit,
                          ),
                          SystemExerciseItem(
                            title: 'Tempo run intervals · 35 min',
                            workoutType: WorkoutType.run,
                          ),
                        ],
                      WellnessMode.recover => const [
                          SystemExerciseItem(
                            title: 'Active recovery walk · 25 min',
                            workoutType: WorkoutType.walk,
                          ),
                          SystemExerciseItem(
                            title: 'Light movement goal · 5,000 steps',
                            workoutType: WorkoutType.walk,
                          ),
                          SystemExerciseItem(
                            title: 'Low-intensity mobility pace · 20 min',
                            workoutType: WorkoutType.mobility,
                          ),
                        ],
                    };

                    final String moveSubtitle = switch (activeMode) {
                      WellnessMode.steady =>
                        'Aerobic walks, steady pacing, movement goals',
                      WellnessMode.push =>
                        'High intensity, strength, power burn',
                      WellnessMode.recover =>
                        'Light recovery, foundational movement',
                    };

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SystemsCardTemplate(
                          icon: AppIcons.runningManIcon,
                          title: 'Move',
                          subtitle: moveSubtitle,
                          sectionKey: 'move',
                          expandedSystemNotifier: _expandedSystemNotifier,
                          leadsToday: isMoveLeading,
                          exercises: moveExercises,
                          r: r,
                        ),
                        const SizedBox(height: 16.0),
                        SystemsRecoverCard(
                          expandedSystemNotifier: _expandedSystemNotifier,
                          leadsToday: isRecoverLeading,
                          r: r,
                        ),
                      ],
                    );
                  }(),
                  const SizedBox(height: 16.0),

                  SystemsMindCard(
                    expandedSystemNotifier: _expandedSystemNotifier,
                    r: r,
                  ),
                  const SizedBox(height: 16.0),

                  SystemsFuelCard(
                    expandedSystemNotifier: _expandedSystemNotifier,
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
                    formKey: _routineFormKey,
                    routineNameController: _routineNameController,
                    selectedDurationNotifier: _selectedDurationNotifier,
                    selectedMovementsNotifier: _selectedMovementsNotifier,
                    selectedWellnessNotifier: _selectedWellnessNotifier,
                    activeRoutineNotifier: _activeRoutineNotifier,
                    r: r,
                    onSaveRoutine: _saveRoutine,
                  ),
                  SizedBox(height: (screenHeight * 0.026).clamp(20.0, 28.0)),

                  // 7. Saved Routines Section (displays newly saved routines below the builder)
                  SystemsSavedRoutinesSection(
                    savedRoutinesNotifier: _savedRoutinesNotifier,
                    r: r,
                    onDeleteRoutine: _deleteRoutine,
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

  Future<void> _saveRoutine() async {
    // Form Validation: Routine Name is mandatory
    if (_routineFormKey.currentState?.validate() != true) {
      HapticFeedback.vibrate();
      return;
    }

    final routineName = _routineNameController.text.trim();
    final duration = _selectedDurationNotifier.value;
    final movements = _selectedMovementsNotifier.value;
    final wellness = _selectedWellnessNotifier.value;
    final items = _activeRoutineNotifier.value;

    final wellnessRepo = context.read<WellnessRepository>();

    await wellnessRepo.saveUserRoutine(
      routineName: routineName,
      durationDays: duration,
      movements: movements,
      wellness: wellness,
      routineItems: items,
    );

    // Haptic feedback & effect
    HapticFeedback.mediumImpact();

    if (mounted) {
      // Reload routines list to immediately render below the builder
      final updatedRoutines = await wellnessRepo.getUserRoutines();
      if (!mounted) return;
      _savedRoutinesNotifier.value = updatedRoutines;

      // Reset text field
      _routineNameController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
          content: Text(
            'Routine "$routineName" saved to your health profile!',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
  }

  Future<void> _deleteRoutine(UserRoutine routine) async {
    final wellnessRepo = context.read<WellnessRepository>();
    await wellnessRepo.deleteUserRoutine(routine.id);

    HapticFeedback.selectionClick();

    if (mounted) {
      final updatedRoutines = await wellnessRepo.getUserRoutines();
      if (!mounted) return;
      _savedRoutinesNotifier.value = updatedRoutines;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Routine "${routine.routineName}" removed'),
        ),
      );
    }
  }
}
