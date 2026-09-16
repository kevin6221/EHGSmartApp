import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/screen_header.dart';

/// EHG Membership screen (Figma Node 133:774).
/// Displays membership routes, subscription options, and feature breakdowns.
class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  // ValueNotifier for the feature tabs (0: "Free forever", 1: "What membership adds").
  // STRICTLY ZERO setState() per project architecture rules.
  final ValueNotifier<int> _selectedTabNotifier = ValueNotifier<int>(0);

  static const List<String> _freeForeverFeatures = [
    'Every vital: sleep stages, HRV, blood oxygen, stress, breathing rate',
    'The plain-English reading of each number, against your own baseline',
    'All 11 sports modes, live sessions and calorie tracking',
    'Steps, hydration, readiness score',
    'Your own journal entries and routines you build yourself',
  ];

  static const List<String> _membershipFeatures = [
    'Tailored workout & recovery programmes adapted to your vitals',
    'Smart outfit engine recommendations based on weather & strain',
    'Double reward points on all tracked sessions and milestones',
    'Advanced biomarker trend forecasting and recovery insights',
    'Priority access to new kit drops and wellness coaching',
  ];

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
                  // 1. Top Header Row: Back button, Title, Online Avatar
                  _buildHeaderRow(context, r),

                  // Subtle divider under top bar matching Figma
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
                  _buildRouteOneCard(context, r, screenHeight),
                  SizedBox(height: (screenHeight * 0.018).clamp(14.0, 18.0)),

                  // 4. Route two Card
                  _buildRouteTwoCard(context, r, screenHeight),
                  SizedBox(height: (screenHeight * 0.030).clamp(22.0, 28.0)),

                  // 5. Benefits Tab Bar ("Free forever" & "What membership adds")
                  _buildTabBar(r),
                  SizedBox(height: (screenHeight * 0.020).clamp(14.0, 18.0)),

                  // 6. Feature Bullets List
                  ValueListenableBuilder<int>(
                    valueListenable: _selectedTabNotifier,
                    builder: (context, activeTab, _) {
                      final features = activeTab == 0
                          ? _freeForeverFeatures
                          : _membershipFeatures;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: features
                            .map((feature) => _buildFeatureItem(feature, r))
                            .toList(),
                      );
                    },
                  ),
                  SizedBox(height: (screenHeight * 0.012)),
                  Divider(color: AppColors.profileDivider, height: 0.5),
                  SizedBox(height: (screenHeight * 0.024).clamp(18.0, 24.0)),
                  // 7. Footer Disclaimer
                  Text(
                    'Points never expire. Cancelling never touches your vitals, your history or your own routines.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: r.font(10.0),
                      fontWeight: FontWeight.w400,
                      color: AppColors.tertiary,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context, Responsive r) {
    final avatarDim = (r.width * 0.11).clamp(38.0, 44.0);
    final dotDim = (avatarDim * 0.25).clamp(9.0, 11.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'EHG Membership',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.white,
                fontSize: r.font(20.0),
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
          behavior: HitTestBehavior.opaque,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: avatarDim,
                height: avatarDim,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(AppConstants.avatar),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 1,
                child: Container(
                  width: dotDim,
                  height: dotDim,
                  decoration: BoxDecoration(
                    color: AppColors.greenMetric,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRouteOneCard(
    BuildContext context,
    Responsive r,
    double screenHeight,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: AppGradients.membershipCard,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.40),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowNavy.withValues(alpha: 0.04),
            blurRadius: 10.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route one tag
          Text(
            'Route one',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(10.0),
              fontWeight: FontWeight.w700,
              color: AppColors.primarySky,
            ),
          ),
          const SizedBox(height: 6.0),

          // Title & Most member badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Free with anything you wear',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(16.0),
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 5.0,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.mindPillar,
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Text(
                  'Most member',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(10.0),
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),

          // Description
          Text(
            'Any EHG piece — a tee, leggings, a Wellness Kit — carries 90 days of membership in its tag. Scan it and everything opens. Buy again and the clock resets.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(13.0),
              fontWeight: FontWeight.w400,
              color: AppColors.tertiary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16.0),

          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Shop the collection',
                  showArrow: false,
                  useGradient: true,
                  hasShadow: false,
                  height: (screenHeight * 0.050).clamp(40.0, 44.0),
                  borderRadius: BorderRadius.circular(10.0),
                  fontSize: r.font(13.0),
                  fontWeight: FontWeight.w600,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opening collection shop...'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: AppButton.outlined(
                  text: 'Scan',
                  showArrow: false,
                  height: (screenHeight * 0.050).clamp(40.0, 44.0),
                  borderRadius: BorderRadius.circular(10.0),
                  fontSize: r.font(13.0),
                  fontWeight: FontWeight.w600,
                  textColor: AppColors.primarySky,
                  border: Border.all(color: AppColors.primarySky, width: 1.0),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Starting tag scanner...')),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteTwoCard(
    BuildContext context,
    Responsive r,
    double screenHeight,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route two tag
          Text(
            'Route two',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(10.0),
              fontWeight: FontWeight.w700,
              color: AppColors.primarySky,
            ),
          ),
          const SizedBox(height: 6.0),

          // Price row
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '£4.99 ',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(16.0),
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
                TextSpan(
                  text: '/ month · or £39 a year',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(13.5),
                    fontWeight: FontWeight.w400,
                    color: AppColors.tertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),

          // Description
          Text(
            'No clothes needed. Cancel in one tap, whenever. Band owners get the first three months free.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(13.0),
              fontWeight: FontWeight.w400,
              color: AppColors.tertiary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16.0),

          // Full-width button: Start 3 months free
          AppButton.outlined(
            text: 'Start 3 months free',
            showArrow: false,
            height: (screenHeight * 0.050).clamp(40.0, 44.0),
            borderRadius: BorderRadius.circular(10.0),
            fontSize: r.font(14.0),
            fontWeight: FontWeight.w600,
            textColor: AppColors.primarySky,
            border: Border.all(color: AppColors.primarySky, width: 1.0),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(Responsive r) {
    return ValueListenableBuilder<int>(
      valueListenable: _selectedTabNotifier,
      builder: (context, activeIndex, _) {
        return Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 1.0),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectedTabNotifier.value = 0,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: activeIndex == 0
                              ? AppColors.primarySky
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Free forever',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(14.0),
                        fontWeight: activeIndex == 0
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: activeIndex == 0
                            ? AppColors.primarySky
                            : AppColors.tertiary,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectedTabNotifier.value = 1,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: activeIndex == 1
                              ? AppColors.primarySky
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'What membership adds',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: r.font(14.0),
                        fontWeight: activeIndex == 1
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: activeIndex == 1
                            ? AppColors.primarySky
                            : AppColors.tertiary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem(String text, Responsive r) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: AppSvgIcon(
              AppIcons.blackStar,
              size: 16.0,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: r.font(12.0),
                fontWeight: FontWeight.w400,
                color: AppColors.secondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
