import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

/// Centralized SnackBar manager for the EHG Smart App.
/// Aligns with QWatch Pro hardware notification standards and the Figma Brand System.
class AppSnackbar {
  AppSnackbar._();

  /// Displays the QWatch Pro aligned alert when user does not wear the smart device properly.
  /// Used during heart rate and vital optical PPG measurements.
  static void showWearDeviceProperly(
    BuildContext context, {
    String message = 'Please wear smart device properly',
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message: message,
      icon: Icons.watch_off_outlined,
      backgroundColor: AppColors.systemRed,
      duration: duration,
    );
  }

  /// Displays an informational or success snackbar.
  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      icon: Icons.check_circle_outline_rounded,
      backgroundColor: AppColors.qwatchNormalGreen,
      duration: duration,
    );
  }

  /// Displays a warning snackbar.
  static void showWarning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      icon: Icons.warning_amber_rounded,
      backgroundColor: AppColors.qwatchWakeSleep,
      duration: duration,
    );
  }

  /// Displays an error snackbar.
  static void showError(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message: message,
      icon: Icons.error_outline_rounded,
      backgroundColor: AppColors.systemRed,
      duration: duration,
    );
  }

  /// Generic centralized method for showing floating, themed snackbars across the app.
  static void show(
    BuildContext context, {
    required String message,
    IconData? icon,
    Color? backgroundColor,
    Color foregroundColor = AppColors.white,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    // Tactile haptic feedback for user awareness
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: foregroundColor, size: 22),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.plusJakartaSans(
                  color: foregroundColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: -0.1,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        action: action,
      ),
    );
  }
}
