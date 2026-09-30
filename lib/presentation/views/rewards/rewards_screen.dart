import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/screen_header.dart';

/// Rewards screen for v1 featuring a placeholder matching the EHG design system.
/// The full rewards engine (points, tiers, redeem codes) will be enabled in future updates.
class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    final headerHeight = (r.height * 0.32).clamp(240.0, 300.0);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          SkyHeaderBackground(height: headerHeight),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 110.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Screen Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.horizontalPadding),
                    child: const ScreenHeader(
                      title: 'Rewards',
                      showAvatar: true,
                      showBackButton: true,
                      showOnlineIndicator: false,
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  // 2. Coming Soon Placeholder Card
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.horizontalPadding),
                    child: AppCard(
                      padding: const EdgeInsets.all(24.0),
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: context.cardBorder,
                        width: 1.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 12.0),
                          // Glowing Emblem Container
                          Container(
                            width: 64.0,
                            height: 64.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const RadialGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.secondary,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.35),
                                  blurRadius: 16.0,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const AppSvgIcon(
                              AppIcons.diamond,
                              size: 28.0,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 20.0),

                          // Pill Tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 5.0,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20.0),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.25),
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              'COMING SOON',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: r.font(11.0),
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14.0),

                          // Title
                          Text(
                            'Unlock full experience',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: r.font(20.0),
                              fontWeight: FontWeight.w700,
                              color: context.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 10.0),

                          // Subtitle explanation
                          Text(
                            'The EHG Rewards ecosystem, tier progression, member benefits, and exclusive piece redemptions are coming in our next release.\n\nContinue tracking your vitals and logging daily sessions to build your wellness streak.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: r.font(13.5),
                              fontWeight: FontWeight.w400,
                              color: context.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24.0),

                          // Preview features checklist
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: context.isDark
                                  ? AppColors.midnightBackground.withValues(alpha: 0.5)
                                  : AppColors.systemCardBgLight,
                              borderRadius: BorderRadius.circular(14.0),
                              border: Border.all(
                                color: context.cardBorder,
                                width: 0.8,
                              ),
                            ),
                            child: Column(
                              children: [
                                _buildFeatureRow(
                                  context: context,
                                  r: r,
                                  icon: AppIcons.check,
                                  text: 'Automatic milestone tracking from verified band data',
                                ),
                                const SizedBox(height: 12.0),
                                _buildFeatureRow(
                                  context: context,
                                  r: r,
                                  icon: AppIcons.check,
                                  text: 'Exclusive tier unlocks and seasonal wardrobe pieces',
                                ),
                                const SizedBox(height: 12.0),
                                _buildFeatureRow(
                                  context: context,
                                  r: r,
                                  icon: AppIcons.check,
                                  text: 'Direct checkout discounts applied to your store account',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16.0),
                        ],
                      ),
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

  Widget _buildFeatureRow({
    required BuildContext context,
    required Responsive r,
    required String icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20.0,
          height: 20.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.greenMetric.withValues(alpha: 0.15),
          ),
          alignment: Alignment.center,
          child: const AppSvgIcon(
            AppIcons.check,
            size: 11.0,
            color: AppColors.greenMetric,
          ),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: r.font(12.5),
              fontWeight: FontWeight.w500,
              color: context.textPrimary,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
