import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../widgets/common/app_button.dart';

/// Pixel-perfect implementation of Figma node 82:3063 (Welcome Screen 1 / Onboarding).
class WelcomeScreen1 extends StatelessWidget {
  const WelcomeScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;
    final horizontalPad = (screenWidth * 0.0427).clamp(16.0, 24.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        extendBody: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background photo filling 100% edge-to-edge without letterboxing
            Image.asset(
              AppConstants.welcomeBg,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              alignment: const Alignment(0.0, -0.1),
            ),

            // Top subtle gradient overlay for status bar clarity
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: media.padding.top + 50,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Bottom dark gradient overlay (Figma: smooth linear gradient to dark for high contrast)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: screenHeight * 0.50,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.30),
                      Colors.black.withValues(alpha: 0.50),
                      Colors.black.withValues(alpha: 0.50),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.35, 0.70, 1.0],
                  ),
                ),
              ),
            ),

            // Text and CTA button positioned at bottom
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPad,
                  vertical: (screenHeight * 0.02).clamp(12.0, 24.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Figma 82:3095: Plus Jakarta Sans Bold 30px, line-height 40px, -0.39 tracking, center aligned
                    Text(
                      'Understand Your Health.\nElevate Your Wellness.',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: (screenWidth * 0.08).clamp(24.0, 30.0),
                        fontWeight: FontWeight.w700,
                        height: 40.0 / 30.0,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 25),

                    // Next button matching Figma 82:3097
                    AppButton(
                      text: 'Next',
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AppRoutes.welcome2),
                    ),

                    const SizedBox(height: 8.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
