import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../widgets/common/screen_header.dart';

/// Top header greeting on the Dashboard Home screen displaying date, username, and user avatar.
/// Reuses the unified ScreenHeader component for clean code and architectural consistency.
class HomeHeaderGreeting extends StatelessWidget {
  final String? dateText;
  final String userName;
  final String avatarPath;
  final bool isOnline;
  final VoidCallback? onAvatarTap;

  const HomeHeaderGreeting({
    super.key,
    this.dateText,
    this.userName = 'there',
    this.avatarPath = AppConstants.avatar,
    this.isOnline = true,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveDate =
        dateText ?? DateFormat('EEE, MMM d').format(DateTime.now());
    return ScreenHeader(
      title: 'Hello $userName!',
      subtitle: effectiveDate,
      avatarAsset: avatarPath,
      showAvatar: true,
      showOnlineIndicator: isOnline,
      onAvatarTap: onAvatarTap,
    );
  }
}
