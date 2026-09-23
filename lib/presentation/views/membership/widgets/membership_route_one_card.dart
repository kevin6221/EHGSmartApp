import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../widgets/common/app_button.dart';

/// "Route one: Free with anything you wear" card on the Membership screen.
class MembershipRouteOneCard extends StatelessWidget {
  final VoidCallback? onShopTap;
  final VoidCallback? onScanTap;

  const MembershipRouteOneCard({
    super.key,
    this.onShopTap,
    this.onScanTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: context.isDark ? context.cardBackground : null,
        gradient: context.isDark ? null : AppGradients.membershipCard,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: context.isDark
              ? context.cardBorder
              : AppColors.primary.withValues(alpha: 0.40),
          width: 1.0,
        ),
        boxShadow: context.isDark
            ? []
            : [
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
                    color: context.textPrimary,
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
              color: context.textSecondary,
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
                  onPressed: onShopTap ??
                      () async {
                        final Uri url =
                            Uri.parse('https://www.ehgsmartwellness.com/');
                        try {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Could not open https://www.ehgsmartwellness.com/',
                                ),
                              ),
                            );
                          }
                        }
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
                  onPressed: onScanTap ??
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Starting tag scanner...'),
                          ),
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
}
