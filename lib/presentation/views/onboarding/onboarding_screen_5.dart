import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/security/secure_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../blocs/onboarding/onboarding_cubit.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../blocs/profile/profile_event.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/onboarding/onboarding_progress_bar.dart';

class OnboardingScreen5 extends StatefulWidget {
  const OnboardingScreen5({super.key});

  @override
  State<OnboardingScreen5> createState() => _OnboardingScreen5State();
}

class _OnboardingScreen5State extends State<OnboardingScreen5> {
  late final ValueNotifier<String> _selectedPlan;

  @override
  void initState() {
    super.initState();
    _selectedPlan = ValueNotifier<String>('');
  }

  @override
  void dispose() {
    _selectedPlan.dispose();
    super.dispose();
  }

  void _onPlanSelected(String plan) async {
    _selectedPlan.value = plan;
    try {
      final cubit = context.read<OnboardingCubit>();
      cubit.setSelectedPlan(plan);
      final enteredName = cubit.state.userName.trim();
      final enteredAge = cubit.state.userAge;
      final secureStorage = SecureStorageService();
      if (enteredName.isNotEmpty) {
        await secureStorage.saveUserName(enteredName);
        if (mounted) {
          context.read<ProfileBloc>().add(UpdateUsernameEvent(enteredName));
        }
      }
      if (enteredAge > 0) {
        await secureStorage.saveUserAge(enteredAge);
        if (mounted) {
          context.read<ProfileBloc>().add(UpdateAgeEvent(enteredAge));
        }
      }
      await secureStorage.setOnboardingCompleted(true);
    } catch (_) {}

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.dashboard,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final screenWidth = r.width;

    // Retrieve user name from cubit for personalized greeting
    String userName = 'John';
    try {
      final cubit = context.read<OnboardingCubit>();
      if (cubit.state.userName.trim().isNotEmpty) {
        userName = cubit.state.userName.trim().split(' ').first;
      }
    } catch (_) {}

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bottomInset = MediaQuery.of(context).padding.bottom;
              final bottomSpacing = bottomInset > 0 ? 16.0 : 24.0;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Dynamic Top Progress Bar (Step 5 of 5)
                      const OnboardingProgressBar(
                        padding: EdgeInsets.only(top: 12.0, bottom: 8.0),
                      ),

                      SizedBox(
                        height: (constraints.maxHeight * 0.090).clamp(
                          16.0,
                          40.0,
                        ),
                      ),
                      Text(
                        'How do you want to use EHG, $userName?',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: (screenWidth * 0.08).clamp(24.0, 30.0),
                          fontWeight: FontWeight.w700,
                          height: 38.0 / 30.0,
                          letterSpacing: -0.39,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16.0),

                      Text(
                        'You can change this at any time. Nothing is locked away permanently.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: (screenWidth * 0.042).clamp(14.0, 16.0),
                          fontWeight: FontWeight.w400,
                          height: 25.6 / 16.0,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: (r.height * 0.026).clamp(16.0, 26.0)),

                      _PlanCard(
                        title: 'Health Tracking',
                        price: 'FREE',
                        iconAsset: AppIcons.heartStar,
                        description: 'Your band, your numbers, and what they mean. No subscription, No account.',
                        features: const [
                          _FeatureItem(
                            text: 'Every vital: sleep stages, HRV, blood oxygen, stress, breathing rate',
                            textColor: AppColors.textSecondary,
                            iconAsset: AppIcons.blackStar,
                          ),
                          _FeatureItem(
                            text: 'Plain-English interpretation of each number, against your own baseline',
                            textColor: AppColors.textSecondary,
                            iconAsset: AppIcons.blackStar,
                          ),
                          _FeatureItem(
                            text: '11 sports modes with live heart rate and zones',
                            textColor: AppColors.textSecondary,
                            iconAsset: AppIcons.blackStar,
                          ),
                          _FeatureItem(
                            text:
                                'GPS route tracking for runs, walks and rides',
                            textColor: AppColors.textSecondary,
                            iconAsset: AppIcons.blackStar,
                          ),
                          _FeatureItem(
                            text: 'Steps, calories and daily activity',
                            textColor: AppColors.textSecondary,
                            iconAsset: AppIcons.blackStar,
                          ),
                        ],
                        buttonText: 'Start tracking',
                        isFilled: false,
                        onTap: () => _onPlanSelected('free'),
                      ),

                      SizedBox(height: (r.height * 0.02).clamp(14.0, 22.0)),

                      // 5. Card 2: Connected Wellness (Figma Node 120:1809 - Filled Gradient Background, Blue Stars)
                      _PlanCard(
                        title: 'Connected Wellness',
                        price: '£4.99/mo',
                        iconAsset: AppIcons.diamond,
                        description: 'The full system — your band, your clothing and your app working as one. Free for 90 days with any EHG purchase.',
                        features: const [
                          _FeatureItem(
                            text: 'Everything in Health Tracking, plus:',
                            textColor: AppColors.textSecondary,
                            iconAsset: AppIcons.blackStar,
                          ),
                          _FeatureItem(
                            text: 'Scan any EHG piece to unlock its programmes',
                            textColor: AppColors.textPrimary,
                            iconAsset: AppIcons.blueStar,
                          ),
                          _FeatureItem(
                            text: 'Guided journeys — Morning Energy, Better Sleep, Stress Reset',
                            textColor: AppColors.textPrimary,
                            iconAsset: AppIcons.blueStar,
                          ),
                          _FeatureItem(
                            text: 'The outfit engine: your wardrobe matched to each morning’s readiness',
                            textColor: AppColors.textPrimary,
                            iconAsset: AppIcons.blueStar,
                          ),
                          _FeatureItem(
                            text: 'Wellness Points, tiers and rewards you can spend',
                            textColor: AppColors.textPrimary,
                            iconAsset: AppIcons.blueStar,
                          ),
                          _FeatureItem(
                            text: 'Journal patterns cross-referenced against your band data',
                            textColor: AppColors.textPrimary,
                            iconAsset: AppIcons.blueStar,
                          ),
                          _FeatureItem(
                            text: 'The EHG community',
                            textColor: AppColors.textPrimary,
                            iconAsset: AppIcons.blueStar,
                          ),
                        ],
                        buttonText: 'Explore the full system',
                        isFilled: true,
                        onTap: () => _onPlanSelected('premium'),
                      ),

                      const SizedBox(height: 15.0),

                      // 6. Bottom Disclaimer Text (Figma Node 120:1800: 10/400 #4B5563, Left-aligned)
                      Text(
                        'Either way your vitals are free and always will be. You paid for the band — your data is yours.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.0,
                          fontWeight: FontWeight.w400,
                          height: 16.0 / 10.0,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.left,
                      ),

                      SizedBox(height: bottomSpacing),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FeatureItem {
  final String text;
  final Color textColor;
  final String iconAsset;

  const _FeatureItem({
    required this.text,
    required this.textColor,
    required this.iconAsset,
  });
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String iconAsset;
  final String description;
  final List<_FeatureItem> features;
  final String buttonText;
  final bool isFilled;
  final VoidCallback onTap;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.iconAsset,
    required this.description,
    required this.features,
    required this.buttonText,
    required this.isFilled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        // One is filled gradient background, one is pure white background per Figma
        color: isFilled ? null : AppColors.white,
        gradient: isFilled ? AppGradients.onboardingCard : null,
        border: Border.all(color: AppColors.primary, width: 0.5),
        boxShadow: isFilled
            ? [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.03),
                  blurRadius: 8.0,
                  offset: const Offset(0.0, 4.0),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.fromLTRB(14.0, 14.0, 14.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Circle Avatar + Title + Price
          Row(
            children: [
              // 32x32 Radial Gradient Circle Avatar (Figma Node 120:1805 / 120:1813)
              Container(
                width: 32.0,
                height: 32.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: Alignment(-0.22, -0.39),
                    radius: 0.8,
                    colors: [AppColors.cyanActive, AppColors.primary],
                  ),
                ),
                alignment: Alignment.center,
                child: AppSvgIcon(
                  iconAsset,
                  size: 16.0,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(width: 10.0),
              // Plan Title (Figma: 16/600 #1F2937)
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    height: 22.0 / 16.0,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              // Plan Price (Figma: 14/800 #3E83C8)
              Text(
                price,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w800,
                  height: 22.0 / 14.0,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8.0),

          // Plan Description (Figma: 13/400 #4B5563)
          Text(
            description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.0,
              fontWeight: FontWeight.w400,
              height: 19.0 / 13.0,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 14.0),

          // Divider (Figma Line 10/11: #4B5563 with 30% opacity)
          Container(
            height: 1.0,
            color: AppColors.tertiary.withValues(alpha: 0.30),
          ),

          const SizedBox(height: 14.0),

          // Feature Items List with SVG stars (Black Star / Blue Star)
          ...features.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20.0,
                    height: 20.0,
                    alignment: Alignment.center,
                    child: AppSvgIcon(item.iconAsset, size: 20.0),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      item.text,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                        height: 19.0 / 12.0,
                        color: item.textColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 8.0),

          // Action Button
          if (isFilled)
            // Premium: gradient filled button (Figma: primary gradient, 12 radius, dynamic height, SVG arrow)
            AppButton(
              text: buttonText,
              onPressed: onTap,
              height: (context.responsive.height * 0.058).clamp(44.0, 52.0),
              borderRadius: BorderRadius.circular(12.0),
              trailingSvg: AppIcons.arrowForward,
            )
          else
            // Free: outlined white button (Figma: white fill, 8 radius, dynamic height, #3E83C8 0.5 border)
            GestureDetector(
              onTap: onTap,
              child: Container(
                height: (context.responsive.height * 0.048).clamp(38.0, 44.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: AppColors.primary, width: 0.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  buttonText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
