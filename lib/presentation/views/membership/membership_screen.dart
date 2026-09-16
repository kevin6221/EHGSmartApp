import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../widgets/common/screen_header.dart';
import 'widgets/membership_benefits_section.dart';
import 'widgets/membership_route_one_card.dart';
import 'widgets/membership_route_two_card.dart';

/// EHG Membership screen (Figma Node 133:774).
/// Modular architecture with zero setState.
class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  // ValueNotifier for the feature tabs (0: "Free forever", 1: "What membership adds").
  // STRICTLY ZERO setState() per project architecture rules.
  final ValueNotifier<int> _selectedTabNotifier = ValueNotifier<int>(0);

  @override
  void dispose() {
    _selectedTabNotifier.dispose();
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
          // Sky header gradient background fading smoothly to white
          SkyHeaderBackground(
            height: screenHeight * 0.30,
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
                r.hp(0.06),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top Header Row & Divider
                  const ScreenHeader(
                    title: 'EHG Membership',
                    titleFontSize: 20.0,
                    showAvatar: true,
                    showOnlineIndicator: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 14.0, bottom: 20.0),
                    child: Container(height: 1.0, color: AppColors.background),
                  ),

                  // 2. Headline & Subtitle
                  Text(
                    'Your numbers are free.\nAlways.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: r.font(24.0),
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: (screenHeight * 0.012).clamp(8.0, 14.0)),
                  Text(
                    'You paid for the band, so your data is yours. Membership is the coaching on top — and there are two ways to get it.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: r.font(16.0),
                      fontWeight: FontWeight.w400,
                      color: AppColors.tertiary,
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: (screenHeight * 0.024).clamp(16.0, 22.0)),

                  // 3. Route one Card
                  const MembershipRouteOneCard(),
                  SizedBox(height: (screenHeight * 0.018).clamp(14.0, 18.0)),

                  // 4. Route two Card
                  const MembershipRouteTwoCard(),
                  SizedBox(height: (screenHeight * 0.030).clamp(22.0, 28.0)),

                  // 5. Benefits Comparison & Features Section
                  MembershipBenefitsSection(
                    selectedTabNotifier: _selectedTabNotifier,
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
