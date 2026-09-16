import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';

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
    this.stops = const [0.0, 0.75],
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
            colors: const [AppColors.primarySky, AppColors.background],
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
/// Responsive and dynamically sized according to device form factor.
class ScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showAvatar;
  final String avatarAsset;
  final bool showOnlineIndicator;
  final Widget? trailing;
  final VoidCallback? onAvatarTap;
  final bool showBackButton;
  final VoidCallback? onBackTap;

  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showAvatar = true,
    this.avatarAsset = AppConstants.avatar,
    this.showOnlineIndicator = false,
    this.trailing,
    this.onAvatarTap,
    this.showBackButton = false,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final avatarDim = (r.width * 0.115).clamp(38.0, 48.0);
    final dotDim = (avatarDim * 0.25).clamp(9.0, 12.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showBackButton)
          GestureDetector(
            onTap: onBackTap ?? () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: Icon(
                Icons.arrow_back_ios_new_outlined,
                color: AppColors.white,
                size: 20.0,
              ),
            ),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (subtitle != null) ...[
                Text(
                  subtitle!,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.white.withValues(alpha: 0.9),
                    fontSize: r.font(13.0),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4.0),
              ],
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.white,
                  fontSize: r.font(26.0),
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
            onTap: onAvatarTap ??
                () {
                  if (ModalRoute.of(context)?.settings.name !=
                      AppRoutes.profile) {
                    Navigator.pushNamed(context, AppRoutes.profile);
                  }
                },
            behavior: HitTestBehavior.opaque,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: avatarDim,
                  height: avatarDim,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                       image: AssetImage(avatarAsset),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (showOnlineIndicator)
                  Positioned(
                    right: 0,
                    bottom: 1,
                    child: Container(
                      width: dotDim,
                      height: dotDim,
                      decoration: BoxDecoration(
                        color: AppColors.greenMetric,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2.0),
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
