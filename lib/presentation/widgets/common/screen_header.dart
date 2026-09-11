import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

/// Decorative sky header gradient background used across all major tabs.
class SkyHeaderBackground extends StatelessWidget {
  final double height;
  final Alignment begin;
  final Alignment end;
  final List<double>? stops;

  const SkyHeaderBackground({
    super.key,
    required this.height,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
    this.stops = const [0.0, 0.85],
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: const [Color(0xFF5A9FE6), Color(0xFFF8FAFC)],
            begin: begin,
            end: end,
            stops: stops,
          ),
        ),
      ),
    );
  }
}

/// Unified top screen header with title, optional date/subtitle, and user profile avatar.
class ScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showAvatar;
  final String avatarAsset;
  final bool showOnlineIndicator;
  final Widget? trailing;
  final VoidCallback? onAvatarTap;

  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showAvatar = true,
    this.avatarAsset = AppConstants.avatar,
    this.showOnlineIndicator = false,
    this.trailing,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (subtitle != null) ...[
                Text(
                  subtitle!,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4.0),
              ],
              Text(
                title,
                style: GoogleFonts.funnelDisplay(
                  color: Colors.white,
                  fontSize: 26.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (trailing != null)
          trailing!
        else if (showAvatar)
          GestureDetector(
            onTap: onAvatarTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44.0,
                  height: 44.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.0),
                    image: DecorationImage(
                      image: AssetImage(avatarAsset),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (showOnlineIndicator)
                  Positioned(
                    right: 0,
                    bottom: 2,
                    child: Container(
                      width: 11.0,
                      height: 11.0,
                      decoration: BoxDecoration(
                        color: AppColors.greenMetric,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.0),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
