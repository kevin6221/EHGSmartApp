import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';

import 'package:flutter_svg/flutter_svg.dart';

import '../../widgets/common/app_button.dart';
import '../../widgets/onboarding/onboarding_progress_bar.dart';

/// Onboarding Screen 1 matching Figma node 10:2408.
/// Introduces "Wellness That Understands You" with 3 cascading metric cards.
class OnboardingScreen1 extends StatelessWidget {
  const OnboardingScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final screenWidth = r.width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bottomInset = MediaQuery.of(context).padding.bottom;
              final bottomSpacing = bottomInset > 0
                  ? (constraints.maxHeight * 0.07).clamp(32.0, 54.0)
                  : 24.0;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. Dynamic Top 6-capsule Progress Bar
                          // In Figma: status bar is 44pt, progress bar starts at 56pt (44 + 12 = 56).
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
                            'Wellness That Understands You.',
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
                            "EHG turns your body's signals into simple, personalized guidance for every day.",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: (screenWidth * 0.042).clamp(14.0, 16.0),
                              fontWeight: FontWeight.w400,
                              height: 25.6 / 16.0,
                              letterSpacing: 0.0,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const Spacer(),

                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: SvgPicture.asset(
                              AppIcons.onboardingFirstCard,
                              fit: BoxFit.contain,
                            ),
                          ),

                          const Spacer(),

                          AppButton(
                            text: 'Next',
                            trailingSvg: AppIcons.arrowForward,
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.onboarding2,
                              );
                            },
                          ),

                          SizedBox(height: bottomSpacing),
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
