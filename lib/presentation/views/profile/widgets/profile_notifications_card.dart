import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/user_profile_model.dart';
import '../../../widgets/common/app_card.dart';

/// Card showing notification toggle switches for plan reminders, hydration, and sleep.
class ProfileNotificationsCard extends StatelessWidget {
  final UserProfileModel data;
  final void Function(String key, bool value) onToggleNotification;

  const ProfileNotificationsCard({
    super.key,
    required this.data,
    required this.onToggleNotification,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
          blurRadius: 14,
          offset: const Offset(0, 3),
        ),
      ],
      child: Column(
        children: [
          _buildSwitchTile(
            title: 'Daily plan reminder',
            value: data.dailyPlanReminder,
            onChanged: (v) => onToggleNotification('dailyPlan', v),
          ),
          _buildSwitchTile(
            title: 'Hydration nudges',
            value: data.hydrationNudges,
            onChanged: (v) => onToggleNotification('hydration', v),
          ),
          _buildSwitchTile(
            title: 'Journey days',
            value: data.journeyDays,
            onChanged: (v) => onToggleNotification('journey', v),
          ),
          _buildSwitchTile(
            title: 'Sleep wind-down',
            value: data.sleepWindDown,
            onChanged: (v) => onToggleNotification('sleep', v),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
