import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_colors.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        ),
        child: Row(
          children: [
            // Band badge icon
            Container(
              width: 36.0,
              height: 36.0,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const AppSvgIcon(
                AppIcons.band,
                size: 18.0,
                color: Colors.white,
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
                          color: Color(0xFFCBD5E1),
                          fontSize: 12.0,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      const Icon(
                        Icons.battery_5_bar_rounded,
                        size: 14.0,
                        color: Color(0xFF10B981),
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
