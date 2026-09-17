import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../blocs/navigation/navigation_bloc.dart';
import '../../blocs/navigation/navigation_event.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../blocs/profile/profile_event.dart';
import '../../blocs/profile/profile_state.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_switch.dart';
import '../../widgets/common/screen_header.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

/// Dedicated notification settings screen opened from Profile screen.
class ProfileNotificationsScreen extends StatefulWidget {
  const ProfileNotificationsScreen({super.key});

  @override
  State<ProfileNotificationsScreen> createState() =>
      _ProfileNotificationsScreenState();
}

class _ProfileNotificationsScreenState
    extends State<ProfileNotificationsScreen> {
  bool _isNavigating = false;

  void _onBottomNavTabSelected(int index) {
    if (_isNavigating) return;
    _isNavigating = true;

    context.read<NavigationBloc>().add(TabChangedEvent(index));

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).popUntil(
        (route) =>
            route.settings.name == AppRoutes.dashboard || route.isFirst,
      );
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final media = MediaQuery.sizeOf(context);
    final screenHeight = media.height;

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final data = state.data;
        if (data == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          extendBody: true,
          body: Stack(
            children: [
              SkyHeaderBackground(
                height: screenHeight * 0.30,
                stops: const [0.0, 0.85],
              ),
              SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    r.horizontalPadding,
                    r.verticalPadding,
                    r.horizontalPadding,
                    r.hp(0.12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ScreenHeader(
                        title: 'Notifications',
                        showBackButton: true,
                        showAvatar: false,
                      ),
                      SizedBox(
                        height: (screenHeight * 0.020).clamp(16.0, 20.0),
                      ),
                      Text(
                        'Customize your wellness alerts, reminders, and performance updates.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(14.0),
                          fontWeight: FontWeight.w400,
                          color: AppColors.secondary,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      AppCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
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
                          children: [
                            _buildNotificationTile(
                              title: 'Daily plan reminder',
                              subtitle:
                                  'Morning nudge for your customized daily schedule',
                              value: data.dailyPlanReminder,
                              onChanged: (v) {
                                context.read<ProfileBloc>().add(
                                      ToggleNotificationEvent('dailyPlan', v),
                                    );
                              },
                              r: r,
                            ),
                            const Divider(
                              color: AppColors.profileDivider,
                              height: 20.0,
                              thickness: 0.5,
                            ),
                            _buildNotificationTile(
                              title: 'Hydration nudges',
                              subtitle:
                                  'Periodic reminders to log your water intake',
                              value: data.hydrationNudges,
                              onChanged: (v) {
                                context.read<ProfileBloc>().add(
                                      ToggleNotificationEvent('hydration', v),
                                    );
                              },
                              r: r,
                            ),
                            const Divider(
                              color: AppColors.profileDivider,
                              height: 20.0,
                              thickness: 0.5,
                            ),
                            _buildNotificationTile(
                              title: 'Journey days',
                              subtitle:
                                  'Progress milestone alerts and journey completion',
                              value: data.journeyDays,
                              onChanged: (v) {
                                context.read<ProfileBloc>().add(
                                      ToggleNotificationEvent('journey', v),
                                    );
                              },
                              r: r,
                            ),
                            const Divider(
                              color: AppColors.profileDivider,
                              height: 20.0,
                              thickness: 0.5,
                            ),
                            _buildNotificationTile(
                              title: 'Sleep wind-down',
                              subtitle:
                                  'Evening alerts to prepare for optimal restorative rest',
                              value: data.sleepWindDown,
                              onChanged: (v) {
                                context.read<ProfileBloc>().add(
                                      ToggleNotificationEvent('sleep', v),
                                    );
                              },
                              r: r,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: CustomBottomNavBar(
            activeIndex: -1,
            onTabSelected: _onBottomNavTabSelected,
          ),
        );
      },
    );
  }

  Widget _buildNotificationTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Responsive r,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(14.0),
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: r.font(11.5),
                    fontWeight: FontWeight.w400,
                    color: AppColors.tertiary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12.0),
          AppSwitch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
