import 'package:ehgsmartapp/presentation/widgets/common/app_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../widgets/common/screen_header.dart';

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
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const SkyHeaderBackground(height: 250),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(
                bottom: 110.0,
              ), // Floating nav bar clearance
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(r),
                  const SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      "Tonight's check-in",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(14.0),
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _buildCheckInCard(
                      r,
                      _selectedEnergyNotifier,
                      _selectedWordNotifier,
                      _journalTextController,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _buildPatternBanner(r),
                  ),
                  const SizedBox(height: 4.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 16,
                    ),
                    child: Text(
                      "Recent entries",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(14.0),
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _buildRecentEntriesCard(r),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Responsive r) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Journal',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(24.0),
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                  height: 1.2,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                behavior: HitTestBehavior.opaque,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    const CircleAvatar(
                      radius: 20.0,
                      backgroundImage: AssetImage(AppConstants.avatar),
                      backgroundColor: Colors.transparent,
                    ),
                    Container(
                      width: 12.0,
                      height: 12.0,
                      decoration: BoxDecoration(
                        color: AppColors.greenMetric,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2.0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
    );
  }

  Widget _buildCheckInCard(
    Responsive r,
    ValueNotifier<int> energyNotifier,
    ValueNotifier<String> wordNotifier,
    TextEditingController textController,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "How was your energy today?",
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(12.0),
              fontWeight: FontWeight.w400,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 10.0),
          ValueListenableBuilder<int>(
            valueListenable: energyNotifier,
            builder: (context, selectedEnergy, _) {
              return Row(
                children: List.generate(4, (index) {
                  final energyLevel = index + 1;
                  final isSelected = selectedEnergy == energyLevel;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => energyNotifier.value = energyLevel,
                      child: Container(
                        margin: EdgeInsets.only(right: index < 3 ? 10.0 : 0.0),
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.routineInputFill,
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.routineInputBorder,
                            width: 1.0,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$energyLevel',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: r.font(14.0),
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.white
                                : AppColors.secondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 20.0),
          Text(
            "Which word fits?",
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(12.0),
              fontWeight: FontWeight.w400,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 12.0),
          ValueListenableBuilder<String>(
            valueListenable: wordNotifier,
            builder: (context, selectedWord, _) {
              final words = ['Clear', 'Clam', 'Flat', 'Wired', 'Heavy'];
              return Wrap(
                spacing: 8.0,
                runSpacing: 10.0,
                children: words.map((word) {
                  final isSelected = selectedWord == word;
                  return GestureDetector(
                    onTap: () => wordNotifier.value = word,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 10.0,
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
                      child: Text(
                        word,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(12.0),
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? AppColors.white
                              : AppColors.tertiary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 20.0),
          Text(
            "What stressed you, and what helped?",
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(12.0),
              fontWeight: FontWeight.w400,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 8.0),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: textController,
            builder: (context, nameValue, _) {
              final bool isTextEntered = nameValue.text.trim().isNotEmpty;

              return TextFormField(
                controller: textController,
                maxLines: 4,
                style: GoogleFonts.plusJakartaSans(
                  color: isTextEntered
                      ? AppColors.primary
                      : AppColors.secondary,
                  fontSize: r.font(14.0),
                  fontWeight: isTextEntered ? FontWeight.w600 : FontWeight.w400,
                ),
                cursorColor: AppColors.primary,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.routineInputFill,
                  contentPadding: const EdgeInsets.all(16.0),
                  hintText: 'Enter here...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(14.0),
                    fontWeight: FontWeight.w400,
                    color: AppColors.tertiary,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: isTextEntered
                          ? AppColors.primary
                          : AppColors.routineInputBorder,
                      width: 0.8,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.0,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
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
          AppButton(
            text: 'Save entry · +120',
            onPressed: () {},
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
            useGradient: true,
            borderRadius: BorderRadius.circular(8.0),
            fontSize: r.font(14.0),
            fontWeight: FontWeight.w600,
            hasShadow: false,
          ),
        ],
      ),
    );
  }

  Widget _buildPatternBanner(Responsive r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Pattern the band found",
          style: GoogleFonts.plusJakartaSans(
            fontSize: r.font(14.0),
            fontWeight: FontWeight.w600,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 16.0),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: AppGradients.journalPatternBanner,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 3.0,
                height: 48.0,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  "Your energy averages 4.5 after 7h+ sleep, and 2.7 when you sleep less. Across 5 entries, sleep is your strongest lever.",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(14.0),
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentEntriesCard(Responsive r) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.divider),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "23 Jul · Calm",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(10.0),
                  fontWeight: FontWeight.w500,
                  color: AppColors.tertiary,
                ),
              ),
              Text(
                "8.0h · energy 4/5",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: r.font(10.0),
                  fontWeight: FontWeight.w500,
                  color: AppColors.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Text(
            "Long stretch session, slept deep.",
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(12.0),
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
