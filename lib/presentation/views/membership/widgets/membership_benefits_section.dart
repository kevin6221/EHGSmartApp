import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';

/// Benefits comparison tabs, checklist, and disclaimer for the Membership screen.
/// Uses ValueNotifier - strictly zero setState.
class MembershipBenefitsSection extends StatelessWidget {
  final ValueNotifier<int> selectedTabNotifier;

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

  const MembershipBenefitsSection({
    super.key,
    required this.selectedTabNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab Bar
        ValueListenableBuilder<int>(
          valueListenable: selectedTabNotifier,
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
                      onTap: () => selectedTabNotifier.value = 0,
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
                      onTap: () => selectedTabNotifier.value = 1,
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
        ),
        SizedBox(height: (screenHeight * 0.020).clamp(14.0, 18.0)),

        // Feature Bullets List
        ValueListenableBuilder<int>(
          valueListenable: selectedTabNotifier,
          builder: (context, activeTab, _) {
            final features =
                activeTab == 0 ? _freeForeverFeatures : _membershipFeatures;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: features
                  .map((feature) => _buildFeatureItem(feature, r))
                  .toList(),
            );
          },
        ),
        SizedBox(height: screenHeight * 0.012),
        const Divider(color: AppColors.profileDivider, height: 0.5),
        SizedBox(height: (screenHeight * 0.024).clamp(18.0, 24.0)),

        // Footer Disclaimer
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
    );
  }

  Widget _buildFeatureItem(String text, Responsive r) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2.0),
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
