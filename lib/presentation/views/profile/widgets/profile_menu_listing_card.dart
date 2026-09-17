import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../widgets/common/app_card.dart';

/// Data model representing a feature menu item in the profile screen.
class _ProfileMenuItem {
  final String title;
  final String subtitle;
  final String? svgPath;
  final IconData? iconData;
  final String route;

  const _ProfileMenuItem({
    required this.title,
    required this.subtitle,
    this.svgPath,
    this.iconData,
    required this.route,
  });
}

/// Menu listing card on the Profile screen hosting Train, Systems, Rewards,
/// and Notifications options with smooth chevron navigation.
class ProfileMenuListingCard extends StatelessWidget {
  const ProfileMenuListingCard({super.key});

  static const List<_ProfileMenuItem> _menuItems = [
    _ProfileMenuItem(
      title: 'Train',
      subtitle: 'Workouts, training sessions & performance',
      svgPath: AppIcons.burnGrey,
      route: AppRoutes.train,
    ),
    _ProfileMenuItem(
      title: 'Systems',
      subtitle: 'Four systems, routines & journeys',
      svgPath: AppIcons.systems,
      route: AppRoutes.systems,
    ),
    _ProfileMenuItem(
      title: 'Rewards',
      subtitle: 'Unlocked pieces, badges & milestones',
      svgPath: AppIcons.rewards,
      route: AppRoutes.rewards,
    ),
    _ProfileMenuItem(
      title: 'Notifications',
      subtitle: 'Plan reminders, hydration & alerts',
      iconData: Icons.notifications_none_rounded,
      route: AppRoutes.notifications,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      borderRadius: BorderRadius.circular(16.0),
      border: Border.all(color: AppColors.border, width: 0.8),
      boxShadow: [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.02),
          blurRadius: 8.0,
          offset: const Offset(0.0, 2.0),
        ),
      ],
      child: Column(
        children: List.generate(
          _menuItems.length,
          (index) {
            final item = _menuItems[index];
            final isLast = index == _menuItems.length - 1;

            return Column(
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pushNamed(item.route);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 12.0,
                    ),
                    child: Row(
                      children: [
                        // Circular leading icon container
                        Container(
                          width: 40.0,
                          height: 40.0,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.systemCardBgLight,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.systemCardBorder,
                              width: 1.0,
                            ),
                          ),
                          child: item.svgPath != null
                              ? AppSvgIcon(
                                  item.svgPath!,
                                  size: 22.0,
                                  color: AppColors.primary,
                                )
                              : Icon(
                                  item.iconData,
                                  size: 22.0,
                                  color: AppColors.primary,
                                ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: r.font(14.0),
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondary,
                                ),
                              ),
                              const SizedBox(height: 2.0),
                              Text(
                                item.subtitle,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: r.font(11.5),
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.tertiary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        const AppSvgIcon(
                          AppIcons.chevronRight,
                          color: AppColors.primary,
                          size: 18.0,
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isLast)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14.0),
                    child: Divider(
                      height: 1.0,
                      thickness: 0.5,
                      color: AppColors.profileDivider,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
