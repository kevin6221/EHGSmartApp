import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../data/models/user_profile_model.dart';
import '../../../widgets/common/app_switch.dart';

/// Section showing notification toggle switches (Figma Nodes 82:2984, 82:2977, 82:3002).
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
    final r = context.responsive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Top Divider (Figma Line 20, sw=0.5)
        const Divider(
          height: 1.0,
          thickness: 0.5,
          color: AppColors.profileDivider,
        ),
        const SizedBox(height: 16.0),

        // 2. Section Header
        Text(
          'Notifications',
          style: GoogleFonts.plusJakartaSans(
            fontSize: r.font(14.0),
            fontWeight: FontWeight.w600,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 15.0),

        // 3. Four Notification Switch Rows (Figma Nodes 82:2983-3000)
        _buildSwitchRow(
          title: 'Daily plan reminder',
          value: data.dailyPlanReminder,
          onChanged: (v) => onToggleNotification('dailyPlan', v),
          fontSize: r.font(14.0),
        ),
        _buildSwitchRow(
          title: 'Hydration nudges',
          value: data.hydrationNudges,
          onChanged: (v) => onToggleNotification('hydration', v),
          fontSize: r.font(14.0),
        ),
        _buildSwitchRow(
          title: 'Journey days',
          value: data.journeyDays,
          onChanged: (v) => onToggleNotification('journey', v),
          fontSize: r.font(14.0),
        ),
        _buildSwitchRow(
          title: 'Sleep wind-down',
          value: data.sleepWindDown,
          onChanged: (v) => onToggleNotification('sleep', v),
          fontSize: r.font(14.0),
        ),
        const SizedBox(height: 12.0),

        // 4. Bottom Divider (Figma Line 21, sw=0.5)
        const Divider(
          height: 1.0,
          thickness: 0.5,
          color: AppColors.profileDivider,
        ),
      ],
    );
  }

  Widget _buildSwitchRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required double fontSize,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.secondary,
                fontWeight: FontWeight.w400,
                fontSize: fontSize,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8.0),
          // Exact ~30x16 Figma Switch Proportions (Figma Nodes 82:2985 - 82:3000)
          AppSwitch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
