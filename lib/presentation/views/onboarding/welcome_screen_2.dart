import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/onboarding/rotating_orbit_graphic.dart';

/// Pixel-perfect implementation of Figma node 3:815 (Welcome Screen 2 / Onboarding).
class WelcomeScreen2 extends StatelessWidget {
  const WelcomeScreen2({super.key});

  void _navigateToDashboard(BuildContext context) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRoutes.dashboard, (route) => false);
  }

  void _navigateToOnboarding(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.onboarding1);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          left: false,
          right: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPad = (screenWidth * 0.05).clamp(16.0, 24.0);
              final availableHeight = constraints.maxHeight;
              final orbitDim = screenWidth > 500.0 ? 440.0 : screenWidth;

              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: availableHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: (availableHeight * 0.015).clamp(8.0, 16.0),
                      ),
                      child: Column(
                        children: [
                          const Spacer(flex: 2),

                          // Animated rotating orbit with stationary centered EHG logo (Full screen width, zero side spacing)
                          SizedBox(
                            width: screenWidth,
                            height: orbitDim,
                            child: Center(
                              child: RotatingOrbitGraphic(dimension: orbitDim),
                            ),
                          ),

                          const Spacer(flex: 2),

                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPad,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Welcome Title (Figma Brand Guide Node 2:575: Funnel Display Bold)
                                Text(
                                  'Welcome to EHG!',
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
                                  'Your everyday wellness, made simple. ALL your health data tracked and explained in one app, so you always know where you stand.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: (screenWidth * 0.042).clamp(
                                      13.5,
                                      16.0,
                                    ),
                                    fontWeight: FontWeight.w400,
                                    height: 25.6 / 16.0,
                                    letterSpacing: 0.0,
                                    color: AppColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height: (availableHeight * 0.06).clamp(
                                    20.0,
                                    45.0,
                                  ),
                                ),
                                AppButton(
                                  text: 'Get Started',
                                  onPressed: () =>
                                      _navigateToOnboarding(context),
                                ),

                                const SizedBox(height: 24.0),
                                GestureDetector(
                                  onTap: () => _navigateToDashboard(context),
                                  behavior: HitTestBehavior.opaque,
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      text: 'Already have an account? ',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: AppColors.textSecondary,
                                        fontSize: (screenWidth * 0.037).clamp(
                                          12.5,
                                          14.0,
                                        ),
                                        fontWeight: FontWeight.w500,
                                        height: 20.0 / 14.0,
                                        letterSpacing: -0.084,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Sign In.',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: (screenWidth * 0.037)
                                                .clamp(12.5, 14.0),
                                            height: 20.0 / 14.0,
                                            letterSpacing: -0.084,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8.0),
                        ],
                      ),
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
