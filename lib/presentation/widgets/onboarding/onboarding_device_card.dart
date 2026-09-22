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
  final String? batteryDays;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool showRadio;
  final int? rssi;

  const OnboardingDeviceCard({
    super.key,
    this.deviceName = 'EHG Smart Band',
    this.deviceId = 'EH-9F2C',
    this.batteryDays,
    this.onTap,
    this.isSelected = false,
    this.showRadio = false,
    this.rssi,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final badgeDim = (r.width * 0.095).clamp(32.0, 42.0);
    final badgeIconDim = (badgeDim * 0.5).clamp(16.0, 20.0);
    final verticalPad = (r.height * 0.016).clamp(10.0, 14.0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: verticalPad),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryLight.withValues(alpha: 0.45)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Band badge icon
            Container(
              width: badgeDim,
              height: badgeDim,
              decoration: BoxDecoration(
                gradient: isSelected ? AppGradients.primary : null,
                color: isSelected ? null : AppColors.borderLight,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: AppSvgIcon(
                AppIcons.band,
                size: badgeIconDim,
                color: isSelected ? AppColors.white : AppColors.tertiary,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3.0),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          deviceId,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      if (rssi != null) ...[
                        const SizedBox(width: 6.0),
                        Text(
                          '•',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.0,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        Icon(
                          Icons.signal_cellular_alt_rounded,
                          size: 14.0,
                          color: rssi! > -70
                              ? AppColors.deviceConnectedGreen
                              : AppColors.tertiary,
                        ),
                      ],
                      if (batteryDays != null) ...[
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
                          batteryDays!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (showRadio) ...[
              const SizedBox(width: 10.0),
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 22.0,
                color: isSelected ? AppColors.primary : AppColors.divider,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
