import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../common/app_button.dart';

/// Scenario types for band permissions and hardware readiness dialog.
enum BandPermissionDialogType {
  /// Permission denied initially (can request again via system prompt).
  denied,

  /// Permission permanently denied (requires opening App Settings).
  permanentlyDenied,

  /// Device Bluetooth radio is powered off.
  bluetoothOff,

  /// Android Location services (GPS) is disabled.
  locationOff,

  /// Bluetooth pairing / encryption key mismatch (requires forgetting device in OS Bluetooth settings).
  pairingMismatch,
}

/// A premium modal sheet informing the user about permissions and hardware requirements
/// to connect to the EHG Smart Band, strictly aligned with Figma typography and brand styling.
class BandPermissionDialog extends StatelessWidget {
  final BandPermissionDialogType type;
  final VoidCallback onAction;
  final VoidCallback? onCancel;

  const BandPermissionDialog({
    super.key,
    required this.type,
    required this.onAction,
    this.onCancel,
  });

  /// Displays the permission dialog as a modal bottom sheet.
  static Future<T?> show<T>(
    BuildContext context, {
    required BandPermissionDialogType type,
    required VoidCallback onAction,
    VoidCallback? onCancel,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      barrierColor: AppColors.black.withValues(alpha: 0.5),
      builder: (ctx) => BandPermissionDialog(
        type: type,
        onAction: () {
          Navigator.of(ctx).pop();
          onAction();
        },
        onCancel: () {
          Navigator.of(ctx).pop();
          onCancel?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    final IconData iconData;
    final Color iconColor;
    final Color iconBgColor;
    final String title;
    final String description;
    final String actionButtonText;

    switch (type) {
      case BandPermissionDialogType.pairingMismatch:
        iconData = Icons.link_off_rounded;
        iconColor = AppColors.systemRed;
        iconBgColor = AppColors.systemRed.withValues(alpha: 0.12);
        title = 'Pairing Info Mismatch';
        description = Platform.isIOS
            ? 'The stored pairing key on your iPhone no longer matches the band.\n\nPlease open iPhone Settings > Bluetooth, tap the (i) icon next to this device, tap "Forget This Device", and then connect again.'
            : 'Bluetooth pairing info does not match. Please unpair the band in Bluetooth Settings and connect again.';
        actionButtonText = 'Open Settings';
        break;

      case BandPermissionDialogType.permanentlyDenied:
        iconData = Icons.settings_suggest_rounded;
        iconColor = AppColors.primary;
        iconBgColor = AppColors.primaryLight;
        title = 'Permission Required';
        description =
            'Nearby Devices / Bluetooth permission is permanently denied. Please open App Settings and grant Nearby Devices permission to find your band.';
        actionButtonText = 'Open Settings';
        break;

      case BandPermissionDialogType.denied:
        iconData = Icons.bluetooth_searching_rounded;
        iconColor = AppColors.primary;
        iconBgColor = AppColors.primaryLight;
        title = 'Bluetooth Permission Needed';
        description =
            'EHG Smart App needs Bluetooth permission to scan and connect with your smart band for real-time vitals and wellness tracking.';
        actionButtonText = 'Allow Permission';
        break;

      case BandPermissionDialogType.bluetoothOff:
        iconData = Icons.bluetooth_disabled_rounded;
        iconColor = AppColors.primary;
        iconBgColor = AppColors.primaryLight;
        title = 'Bluetooth is Turned Off';
        description =
            'Bluetooth is disabled on your device. Turn it on from your Control Center (swipe down from top right) or open Settings to find your band.';
        actionButtonText = 'Open Settings';
        break;

      case BandPermissionDialogType.locationOff:
        iconData = Icons.location_off_rounded;
        iconColor = AppColors.primary;
        iconBgColor = AppColors.primaryLight;
        title = 'Location Services Needed';
        description =
            'Android requires Location Services (GPS) to be active for discovering nearby Bluetooth Low Energy devices. Please enable Location.';
        actionButtonText = 'Enable Location';
        break;
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, bottomInset > 0 ? bottomInset + 12 : 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.tertiary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Icon Container
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                iconData,
                color: iconColor,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          if (type == BandPermissionDialogType.bluetoothOff) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.swipe_down_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      Platform.isIOS
                          ? 'Swipe down from top right to open Control Center and tap Bluetooth.'
                          : 'Swipe down notification bar and tap Bluetooth to enable.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (type == BandPermissionDialogType.pairingMismatch) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Follow these steps:',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Platform.isIOS
                        ? '1. Open iPhone Settings > Bluetooth\n2. Find your band under MY DEVICES\n3. Tap (i) icon > "Forget This Device"\n4. Return here and tap connect again'
                        : '1. Open phone Settings > Bluetooth\n2. Tap the paired band and tap "Unpair"\n3. Return here and tap connect again',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Action Button
          AppButton(
            text: actionButtonText,
            showArrow: false,
            onPressed: onAction,
          ),
          const SizedBox(height: 12),

          // Secondary Cancel Button
          TextButton(
            onPressed: onCancel ?? () => Navigator.of(context).pop(),
            child: Text(
              'Not Now',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
