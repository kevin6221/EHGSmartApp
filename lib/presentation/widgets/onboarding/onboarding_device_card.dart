import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';

/// Device info card showing paired band name, identifier, and battery duration,
/// matching Figma node 16:2978.
class OnboardingDeviceCard extends StatelessWidget {
  final String deviceName;
  final String deviceId;
  final String batteryDays;
  final VoidCallback? onTap;

  const OnboardingDeviceCard({
    super.key,
    this.deviceName = 'EHG Smart Band',
    this.deviceId = 'EH-9F2C',
    this.batteryDays = '4 days',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final badgeDim = (r.width * 0.095).clamp(32.0, 42.0);
    final badgeIconDim = (badgeDim * 0.5).clamp(16.0, 20.0);
    final verticalPad = (r.height * 0.016).clamp(10.0, 16.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: verticalPad),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: AppColors.divider, width: 1.0),
        ),
        child: Row(
          children: [
            // Band badge icon
            Container(
              width: badgeDim,
              height: badgeDim,
              decoration: const BoxDecoration(
                gradient: AppGradients.primary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: AppSvgIcon(
                AppIcons.band,
                size: badgeIconDim,
                color: AppColors.white,
              ),
            ),
            const SizedBox(width: 12.0),

            // Details Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    deviceName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      Text(
                        deviceId,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      const Text(
                        '|',
                        style: TextStyle(
                          color: AppColors.deviceTrackBorder,
                          fontSize: 12.0,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      const Icon(
                        Icons.battery_5_bar_rounded,
                        size: 14.0,
                        color: AppColors.deviceConnectedGreen,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        batteryDays,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
