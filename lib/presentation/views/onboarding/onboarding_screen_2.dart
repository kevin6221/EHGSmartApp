import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../blocs/onboarding/onboarding_cubit.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/onboarding/onboarding_device_card.dart';
import '../../widgets/onboarding/onboarding_progress_bar.dart';
import '../../widgets/onboarding/onboarding_radar_graphic.dart';

/// Onboarding Screen 2 matching Figma nodes 14:2600 (Radar Scanner) and 16:2978 (Device Found).
///
/// Both states are part of Step 2 ("Connect your band"):
/// 1. Initial State: Radar scanner searching for nearby band.
/// 2. Found State: Paired device card and band preview once "Find My band" is clicked.
///
/// The top [OnboardingProgressBar] remains stably at Step 2 throughout both states.
/// Tapping "Connect" advances to Onboarding Screen 3 (Node 16:4201).
class OnboardingScreen2 extends StatefulWidget {
  final bool initialBandFound;

  const OnboardingScreen2({super.key, this.initialBandFound = false});

  @override
  State<OnboardingScreen2> createState() => _OnboardingScreen2State();
}

class _OnboardingScreen2State extends State<OnboardingScreen2> {
  late final ValueNotifier<bool> _isBandFound;

  @override
  void initState() {
    super.initState();
    _isBandFound = ValueNotifier<bool>(widget.initialBandFound);
  }

  @override
  void dispose() {
    _isBandFound.dispose();
    super.dispose();
  }

  void _onFindBandPressed() {
    _isBandFound.value = true;
    try {
      context.read<OnboardingCubit>().setBandFound(true);
    } catch (_) {}
  }

  void _onConnectPressed() {
    Navigator.pushNamed(context, AppRoutes.onboarding3);
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final screenWidth = r.width;

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
              final radarDimension = (screenWidth * 0.72).clamp(240.0, 280.0);
              final bandDimension = (screenWidth * 0.65).clamp(200.0, 260.0);
              final bottomInset = MediaQuery.of(context).padding.bottom;
              final bottomSpacing = bottomInset > 0 ? 14.0 : 20.0;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _isBandFound,
                      builder: (context, isBandFound, _) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 1. Top 6-capsule Progress Bar (Step 2 active)
                              const OnboardingProgressBar(
                                padding: EdgeInsets.only(
                                  top: 12.0,
                                  bottom: 8.0,
                                ),
                              ),

                              SizedBox(
                                height: (constraints.maxHeight * 0.090).clamp(
                                  16.0,
                                  40.0,
                                ),
                              ),

                              Text(
                                'Connect your band',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: (screenWidth * 0.08).clamp(
                                    24.0,
                                    30.0,
                                  ),
                                  fontWeight: FontWeight.w700,
                                  height: 38.0 / 30.0,
                                  letterSpacing: -0.39,
                                  color: AppColors.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 16.0),

                              Text(
                                'Make sure your EHG Smart Band is charged and nearby. If it is currently paired to another app, unpair it there first.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: (screenWidth * 0.042).clamp(
                                    14.0,
                                    16.0,
                                  ),
                                  fontWeight: FontWeight.w400,
                                  height: 25.6 / 16.0,
                                  letterSpacing: 0.0,
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const Spacer(),

                              // 3. Center Graphic & Device Card (Transitions smoothly between Radar and Band Found)
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 350),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                child: !isBandFound
                                    ? Padding(
                                        key: const ValueKey('radar_graphic'),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16.0,
                                        ),
                                        child: Center(
                                          child: OnboardingRadarGraphic(
                                            dimension: radarDimension,
                                          ),
                                        ),
                                      )
                                    : Column(
                                        key: const ValueKey('band_found_card'),
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Center(
                                            child: Image.asset(
                                              AppConstants.onboardingBand,
                                              width: bandDimension,
                                              height: bandDimension,
                                              fit: BoxFit.contain,
                                              cacheWidth: (bandDimension * 2.5)
                                                  .toInt(),
                                            ),
                                          ),
                                          const SizedBox(height: 16.0),
                                          const OnboardingDeviceCard(),
                                        ],
                                      ),
                              ),

                              const Spacer(),

                              // 4. Action Button (Find My band -> Connect)
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: !isBandFound
                                    ? AppButton(
                                        key: const ValueKey('find_band_button'),
                                        text: 'Find My band',
                                        trailingIcon: const Icon(
                                          Icons.search_rounded,
                                          color: AppColors.white,
                                          size: 20,
                                        ),
                                        onPressed: _onFindBandPressed,
                                      )
                                    : AppButton(
                                        key: const ValueKey('connect_button'),
                                        text: 'Connect',
                                        trailingIcon: const Icon(
                                          Icons.arrow_forward_rounded,
                                          color: AppColors.white,
                                          size: 20,
                                        ),
                                        onPressed: _onConnectPressed,
                                      ),
                              ),

                              const SizedBox(height: 16.0),

                              // 5. Status / Privacy Footer
                              Text(
                                !isBandFound
                                    ? 'Bluetooth   •   Ready'
                                    : 'Your data stays on your phone',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w400,
                                  height: 19.2 / 12.0,
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: bottomSpacing),
                            ],
                          ),
                        );
                      },
                    ),
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
