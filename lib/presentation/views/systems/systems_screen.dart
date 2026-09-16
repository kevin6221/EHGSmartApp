import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/dotted_divider.dart';
import '../../widgets/common/screen_header.dart';

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
  late final ValueNotifier<bool> _isRecoverExpandedNotifier;

  @override
  void initState() {
    super.initState();
    _routineNameController = TextEditingController();
    _selectedDurationNotifier = ValueNotifier<int>(14);
    _selectedMovementsNotifier = ValueNotifier<Set<String>>({'Yga'});
    _selectedWellnessNotifier = ValueNotifier<Set<String>>({'Mobile Flow'});
    _isRecoverExpandedNotifier = ValueNotifier<bool>(true);
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
    _isRecoverExpandedNotifier.dispose();
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
                  // 1. Top Header Row (Title & User Avatar)
                  _buildHeaderRow(r),

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
                  SizedBox(height: 27),

                  // 3. Four Systems Cards
                  _buildMoveCard(r),
                  SizedBox(height: 16),

                  _buildRecoverCard(r),
                  SizedBox(height: 16),

                  _buildMindCard(r),
                  SizedBox(height: 16),

                  _buildFuelCard(r),
                  SizedBox(height: (screenHeight * 0.026).clamp(20.0, 28.0)),

                  // 4. Journeys in Progress Section
                  _buildJourneysSection(r, screenHeight),
                  SizedBox(height: (screenHeight * 0.026).clamp(20.0, 28.0)),

                  // 5. Your Programmes Section
                  _buildProgrammesSection(r, screenHeight),
                  SizedBox(height: (screenHeight * 0.026).clamp(20.0, 28.0)),

                  // 6. Build Your Own Routine Section
                  _buildBuildYourOwnSection(r, screenHeight),
                  SizedBox(height: (screenHeight * 0.025).clamp(18.0, 24.0)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 1. Header Row
  // ===========================================================================
  Widget _buildHeaderRow(Responsive r) {
    final avatarDim = (r.width * 0.11).clamp(38.0, 44.0);
    final dotDim = (avatarDim * 0.25).clamp(9.0, 11.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            'Four systems, one wardrobe',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.white,
              fontSize: r.font(20.0),
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12.0),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
          behavior: HitTestBehavior.opaque,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: avatarDim,
                height: avatarDim,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2.0),
                  image: const DecorationImage(
                    image: AssetImage(AppConstants.avatar),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: dotDim,
                  height: dotDim,
                  decoration: BoxDecoration(
                    color: AppColors.greenMetric,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 2. Four Systems Cards
  // ===========================================================================
  Widget _buildMoveCard(Responsive r) {
    return _buildSystemCardTemplate(
      icon: AppIcons.runningManIcon,
      title: 'Move',
      subtitle: 'Strength, running, movement goals',
      r: r,
    );
  }

  Widget _buildRecoverCard(Responsive r) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isRecoverExpandedNotifier,
      builder: (context, isExpanded, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: AppGradients.recoverCard,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: AppColors.systemCardBorder, width: 1.0),
            boxShadow: [
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
              // Header Row
              GestureDetector(
                onTap: () => _isRecoverExpandedNotifier.value = !isExpanded,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    children: [
                      Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: AppSvgIcon(
                            AppIcons.recoverPerson,
                            size: 24.0,
                            color: AppColors.primary,
                          ),
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
                                    color: AppColors.secondary,
                                  ),
                                ),
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
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'Mobility, sleep, soft tissue',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: r.font(12.0),
                                fontWeight: FontWeight.w400,
                                color: AppColors.tertiary,
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.0),
                  child: DottedDivider(
                    color: AppColors.tertiary,
                    dashWidth: 3.0,
                    dashSpace: 3.0,
                    thickness: 0.5,
                  ),
                ),
                const SizedBox(height: 4.0),

                // 3 Action Items
                _buildActionItemRow(title: 'Full mobility flow · 20 min', r: r),
                _buildActionItemRow(
                  title: 'Foam roll: calves & hamstrings · 8 min',
                  r: r,
                ),
                _buildActionItemRow(title: 'Sleep wind-down · 12 min', r: r),
                const SizedBox(height: 4.0),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.0),
                  child: DottedDivider(
                    color: AppColors.tertiary,
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
                      color: AppColors.tertiary,
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

  Widget _buildActionItemRow({required String title, required Responsive r}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: r.font(10.0),
                fontWeight: FontWeight.w400,
                color: AppColors.secondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: Text(
              'START',
              style: GoogleFonts.plusJakartaSans(
                fontSize: r.font(12.0),
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMindCard(Responsive r) {
    return _buildSystemCardTemplate(
      icon: AppIcons.mindBreath,
      title: 'Mind',
      subtitle: 'Breath, mood, meditation',
      r: r,
    );
  }

  Widget _buildFuelCard(Responsive r) {
    return _buildSystemCardTemplate(
      icon: AppIcons.singleDrop,
      title: 'Fuel',
      subtitle: 'Hydration, food, habits',
      r: r,
    );
  }

  Widget _buildSystemCardTemplate({
    required String icon,
    required String title,
    required String subtitle,
    required Responsive r,
  }) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.02),
            blurRadius: 8.0,
            offset: const Offset(0.0, 2.0),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: AppColors.systemCardBgLight,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.systemCardBorder, width: 1.0),
            ),
            child: Center(
              child: AppSvgIcon(icon, size: 24.0, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(14.0),
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(12.0),
                    fontWeight: FontWeight.w400,
                    color: AppColors.tertiary,
                  ),
                ),
              ],
            ),
          ),
          const AppSvgIcon(
            AppIcons.chevronRight,
            color: AppColors.primary,
            size: 20.0,
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 3. Journeys in progress Section
  // ===========================================================================
  Widget _buildJourneysSection(Responsive r, double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Journeys in progress',
          style: GoogleFonts.plusJakartaSans(
            fontSize: r.font(14.0),
            fontWeight: FontWeight.w700,
            color: AppColors.secondary,
          ),
        ),
        SizedBox(height: 14),

        _buildJourneyCard(
          title: 'Morning Energy',
          progressText: '9/21 days',
          progressFraction: 9.0 / 21.0,
          gearText: 'Tank Top · Resistance Band · Smart Band',
          r: r,
        ),
        SizedBox(height: (screenHeight * 0.012).clamp(10.0, 14.0)),

        _buildJourneyCard(
          title: 'Better Sleep',
          progressText: '3/14 days',
          progressFraction: 3.0 / 14.0,
          gearText: 'Boxy Piping Tee · Eye Mask · Smart Band',
          r: r,
        ),
      ],
    );
  }

  Widget _buildJourneyCard({
    required String title,
    required String progressText,
    required double progressFraction,
    required String gearText,
    required Responsive r,
  }) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(12.0),
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
              Text(
                progressText,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(12.0),
                  fontWeight: FontWeight.w600,
                  color: AppColors.cyanLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(3.0),
            child: SizedBox(
              height: 2.0,
              child: LinearProgressIndicator(
                value: progressFraction,
                backgroundColor: AppColors.divider,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.cyanLight,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            gearText,
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(10.0),
              fontWeight: FontWeight.w400,
              color: AppColors.tertiary,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 4. Your Programmes Section
  // ===========================================================================
  Widget _buildProgrammesSection(Responsive r, double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your programmes',
              style: GoogleFonts.plusJakartaSans(
                fontSize: r.font(14.0),
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
            Text(
              '2 UNLOCKED',
              style: GoogleFonts.plusJakartaSans(
                fontSize: r.font(10.0),
                fontWeight: FontWeight.w600,
                color: AppColors.tertiary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        _buildProgrammeCard(
          title: '30–Day Pilates',
          sessionsCount: '0/4 sessions',
          category: 'Pilates',
          sourcePiece: 'From your High Rise Flared Yoga Pants',
          kcalRemaining: '371 kcal to go',
          progressFraction: 0.15,
          r: r,
        ),
        SizedBox(height: 16),

        _buildProgrammeCard(
          title: 'Lower Body Challenge',
          sessionsCount: '0/4 sessions',
          category: 'Strength',
          sourcePiece: 'From your High Rise Flared Yoga Pants',
          kcalRemaining: '1,055 kcal to go',
          progressFraction: 0.08,
          r: r,
        ),
      ],
    );
  }

  Widget _buildProgrammeCard({
    required String title,
    required String sessionsCount,
    required String category,
    required String sourcePiece,
    required String kcalRemaining,
    required double progressFraction,
    required Responsive r,
  }) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.systemCardBorder, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: r.font(12.0),
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 6.0),
                  Text(
                    sessionsCount,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: r.font(10.0),
                      fontWeight: FontWeight.w400,
                      color: AppColors.tertiary,
                    ),
                  ),
                ],
              ),
              Text(
                category,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(10.0),
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          ClipRRect(
            borderRadius: BorderRadius.circular(3.0),
            child: SizedBox(
              height: 2,
              child: LinearProgressIndicator(
                value: progressFraction,
                backgroundColor: AppColors.divider,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.cyanLight,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  sourcePiece,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(10.0),
                    fontWeight: FontWeight.w400,
                    color: AppColors.tertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                kcalRemaining,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(10.0),
                  fontWeight: FontWeight.w600,
                  color: AppColors.orangeMetric,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 5. Build your own Section
  // ===========================================================================
  Widget _buildBuildYourOwnSection(Responsive r, double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Build your own',
          style: GoogleFonts.plusJakartaSans(
            fontSize: r.font(14.0),
            fontWeight: FontWeight.w600,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          'Plan a routine that fits your week. The band still decides when to hold you back on a recovery day.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: r.font(10.0),
            fontWeight: FontWeight.w500,
            color: AppColors.tertiary,
            height: 1.4,
          ),
        ),
        SizedBox(height: (screenHeight * 0.016).clamp(12.0, 16.0)),

        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: AppColors.border, width: 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Routine Name
              Text(
                'Routine Name',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(12.0),
                  fontWeight: FontWeight.w400,
                  color: AppColors.tertiary,
                ),
              ),
              const SizedBox(height: 8.0),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _routineNameController,
                builder: (context, nameValue, _) {
                  final bool isTextEntered = nameValue.text.trim().isNotEmpty;

                  return TextFormField(
                    controller: _routineNameController,
                    style: GoogleFonts.plusJakartaSans(
                      color: isTextEntered
                          ? AppColors.primary
                          : AppColors.secondary,
                      fontSize: r.font(14.0),
                      fontWeight: isTextEntered
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    cursorColor: AppColors.primary,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.routineInputFill,
                      hintText: 'Enter here...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        color: AppColors.tertiary,
                        fontSize: r.font(13.0),
                        fontWeight: FontWeight.w400,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: isTextEntered
                              ? AppColors.primary
                              : AppColors.routineInputBorder,
                          width: 0.8,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.0,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: isTextEntered
                              ? AppColors.primary
                              : AppColors.routineInputBorder,
                          width: 0.8,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16.0),

              // Run it for duration selector
              Text(
                'Run it for',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(12.0),
                  fontWeight: FontWeight.w400,
                  color: AppColors.tertiary,
                ),
              ),
              const SizedBox(height: 10.0),
              ValueListenableBuilder<int>(
                valueListenable: _selectedDurationNotifier,
                builder: (context, selectedDays, _) {
                  final durations = [7, 14, 21, 30];
                  return Row(
                    children: durations.map((days) {
                      final isSelected = selectedDays == days;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3.0),
                          child: GestureDetector(
                            onTap: () => _selectedDurationNotifier.value = days,
                            behavior: HitTestBehavior.opaque,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.routineInputFill,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.routineInputBorder,
                                  width: 1.0,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '${days}d',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: r.font(12.5),
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.white
                                        : AppColors.tertiary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 16.0),

              // Add movement
              Text(
                'Add movement',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(12.0),
                  fontWeight: FontWeight.w600,
                  color: AppColors.tertiary,
                ),
              ),
              const SizedBox(height: 12.0),
              ValueListenableBuilder<Set<String>>(
                valueListenable: _selectedMovementsNotifier,
                builder: (context, selected, _) {
                  final row1 = ['Run', 'Wlk', 'Cyc', 'Str', 'Hlt'];
                  final row2 = ['Row', 'Swm', 'Yga', 'Pil', 'Mob'];

                  return Column(
                    children: [
                      Row(
                        children: row1.map((item) {
                          final isChecked = selected.contains(item);
                          return Expanded(
                            child: _buildCheckboxChip(
                              label: item,
                              isChecked: isChecked,
                              onTap: () => _toggleMovement(item),
                              r: r,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12.0),
                      Row(
                        children: row2.map((item) {
                          final isChecked = selected.contains(item);
                          return Expanded(
                            child: _buildCheckboxChip(
                              label: item,
                              isChecked: isChecked,
                              onTap: () => _toggleMovement(item),
                              r: r,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16.0),

              // Add wellness
              Text(
                'Add wellness',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(12.0),
                  fontWeight: FontWeight.w600,
                  color: AppColors.tertiary,
                ),
              ),
              const SizedBox(height: 12.0),
              ValueListenableBuilder<Set<String>>(
                valueListenable: _selectedWellnessNotifier,
                builder: (context, selected, _) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 8,
                            child: _buildCheckboxChip(
                              label: 'Mobile Flow',
                              isChecked: selected.contains('Mobile Flow'),
                              onTap: () => _toggleWellness('Mobile Flow'),
                              r: r,
                            ),
                          ),
                          Expanded(
                            flex: 7,
                            child: _buildCheckboxChip(
                              label: 'Foam roll',
                              isChecked: selected.contains('Foam roll'),
                              onTap: () => _toggleWellness('Foam roll'),
                              r: r,
                            ),
                          ),
                          Expanded(
                            flex: 6,
                            child: _buildCheckboxChip(
                              label: 'Sleep wind',
                              isChecked: selected.contains('Sleep wind'),
                              onTap: () => _toggleWellness('Sleep wind'),
                              r: r,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      Row(
                        children: [
                          Expanded(
                            flex: 8,
                            child: _buildCheckboxChip(
                              label: 'Box breathing',
                              isChecked: selected.contains('Box breathing'),
                              onTap: () => _toggleWellness('Box breathing'),
                              r: r,
                            ),
                          ),
                          Expanded(
                            flex: 7,
                            child: _buildCheckboxChip(
                              label: 'Meditation',
                              isChecked: selected.contains('Meditation'),
                              onTap: () => _toggleWellness('Meditation'),
                              r: r,
                            ),
                          ),
                          const Spacer(flex: 6),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16.0),

              ValueListenableBuilder<List<Map<String, String>>>(
                valueListenable: _activeRoutineNotifier,
                builder: (context, routineItems, _) {
                  if (routineItems.isEmpty) {
                    return const SizedBox(height: 8.0);
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16.0),
                      // Dotted divider
                      const DottedDivider(
                        color: AppColors.divider,
                        dashWidth: 3.0,
                        dashSpace: 3.0,
                        thickness: 1.0,
                      ),
                      const SizedBox(height: 20.0),

                      // Your routine Box
                      Text(
                        'Your routine',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(12.0),
                          fontWeight: FontWeight.w400,
                          color: AppColors.tertiary,
                        ),
                      ),
                      const SizedBox(height: 12.0),

                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 0.5,
                          ),
                        ),
                        child: Column(
                          children: routineItems.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            final isLast = index == routineItems.length - 1;

                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 12.0,
                                  ),
                                  child: Row(
                                    children: [
                                      // Blue bullet dot
                                      Container(
                                        width: 5.0,
                                        height: 5.0,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Expanded(
                                        child: Text(
                                          item['title'] ?? '',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: r.font(12.5),
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        item['duration'] ?? '',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: r.font(12.0),
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.secondary,
                                        ),
                                      ),
                                      const SizedBox(width: 10.0),
                                      GestureDetector(
                                        onTap: () => _removeRoutineItem(index),
                                        behavior: HitTestBehavior.opaque,
                                        child: const AppSvgIcon(
                                          AppIcons.redCross,
                                          color: AppColors.systemRed,
                                          size: 16.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isLast)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: Divider(
                                      height: 1.0,
                                      thickness: 0.8,
                                      color: AppColors.tertiary.withValues(
                                        alpha: 0.35,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 18.0),
                    ],
                  );
                },
              ),

              // Save routine AppButton
              AppButton(
                text: 'Save routine',
                useGradient: true,
                showArrow: false,
                onPressed: () {},
                height: 46.0,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static const Map<String, Map<String, String>> _movementItemsConfig = {
    'Run': {'title': 'Running', 'duration': '30 min.'},
    'Wlk': {'title': 'Walking', 'duration': '30 min.'},
    'Cyc': {'title': 'Cycling', 'duration': '45 min.'},
    'Str': {'title': 'Strength', 'duration': '45 min.'},
    'Hlt': {'title': 'HIIT', 'duration': '30 min.'},
    'Row': {'title': 'Rowing', 'duration': '20 min.'},
    'Swm': {'title': 'Swimming', 'duration': '45 min.'},
    'Yga': {'title': 'Yoga', 'duration': '45 min.'},
    'Pil': {'title': 'Pilates', 'duration': '40 min.'},
    'Mob': {'title': 'Mobility', 'duration': '20 min.'},
  };

  static const Map<String, Map<String, String>> _wellnessItemsConfig = {
    'Mobile Flow': {'title': 'Mobility flow', 'duration': '30 min.'},
    'Foam roll': {'title': 'Foam roll', 'duration': '15 min.'},
    'Sleep wind': {'title': 'Sleep wind-down', 'duration': '15 min.'},
    'Box breathing': {'title': 'Box breathing', 'duration': '10 min.'},
    'Meditation': {'title': 'Meditation', 'duration': '15 min.'},
  };

  void _toggleMovement(String key) {
    final movementSet = Set<String>.from(_selectedMovementsNotifier.value);
    final routineList = List<Map<String, String>>.from(
      _activeRoutineNotifier.value,
    );

    if (movementSet.contains(key)) {
      movementSet.remove(key);
      routineList.removeWhere(
        (item) => item['key'] == key && item['type'] == 'movement',
      );
    } else {
      movementSet.add(key);
      final config =
          _movementItemsConfig[key] ?? {'title': key, 'duration': '30 min.'};
      routineList.add({
        'key': key,
        'title': config['title']!,
        'duration': config['duration']!,
        'type': 'movement',
      });
    }

    _selectedMovementsNotifier.value = movementSet;
    _activeRoutineNotifier.value = routineList;
  }

  void _toggleWellness(String key) {
    final wellnessSet = Set<String>.from(_selectedWellnessNotifier.value);
    final routineList = List<Map<String, String>>.from(
      _activeRoutineNotifier.value,
    );

    if (wellnessSet.contains(key)) {
      wellnessSet.remove(key);
      routineList.removeWhere(
        (item) => item['key'] == key && item['type'] == 'wellness',
      );
    } else {
      wellnessSet.add(key);
      final config =
          _wellnessItemsConfig[key] ?? {'title': key, 'duration': '15 min.'};
      routineList.add({
        'key': key,
        'title': config['title']!,
        'duration': config['duration']!,
        'type': 'wellness',
      });
    }

    _selectedWellnessNotifier.value = wellnessSet;
    _activeRoutineNotifier.value = routineList;
  }

  void _removeRoutineItem(int index) {
    final routineList = List<Map<String, String>>.from(
      _activeRoutineNotifier.value,
    );
    if (index < 0 || index >= routineList.length) return;

    final removed = routineList.removeAt(index);
    final key = removed['key'];
    final type = removed['type'];

    if (type == 'movement' && key != null) {
      final movementSet = Set<String>.from(_selectedMovementsNotifier.value);
      movementSet.remove(key);
      _selectedMovementsNotifier.value = movementSet;
    } else if (type == 'wellness' && key != null) {
      final wellnessSet = Set<String>.from(_selectedWellnessNotifier.value);
      wellnessSet.remove(key);
      _selectedWellnessNotifier.value = wellnessSet;
    }

    _activeRoutineNotifier.value = routineList;
  }

  Widget _buildCheckboxChip({
    required String label,
    required bool isChecked,
    required VoidCallback onTap,
    required Responsive r,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16.0,
            height: 16.0,
            decoration: BoxDecoration(
              color: isChecked ? AppColors.primary : AppColors.white,
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(
                color: isChecked ? AppColors.primary : AppColors.textGray400,
                width: 1.2,
              ),
            ),
            child: isChecked
                ? const AppSvgIcon(
                    AppIcons.check,
                    size: 12.0,
                    color: AppColors.white,
                  )
                : null,
          ),
          const SizedBox(width: 6.0),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: r.font(12.0),
                fontWeight: FontWeight.w400,
                color: AppColors.tertiary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
