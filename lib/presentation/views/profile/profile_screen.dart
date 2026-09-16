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
import '../../widgets/common/screen_header.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import 'widgets/profile_account_card.dart';
import 'widgets/profile_appearance_card.dart';
import 'widgets/profile_band_card.dart';
import 'widgets/profile_data_privacy_section.dart';
import 'widgets/profile_membership_banner.dart';
import 'widgets/profile_notifications_card.dart';
import 'widgets/profile_picker_sheets.dart';
import 'widgets/profile_rewards_card.dart';

/// User profile and application settings screen (Figma Node 75:2756).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _usernameController;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _usernameController = TextEditingController(text: 'John');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

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
    final media = MediaQuery.of(context);
    final screenHeight = media.size.height;

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final data = state.data;
        if (data == null) {
          return const Center(child: CircularProgressIndicator());
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
                        title: 'Profile',
                        showBackButton: false,
                        showAvatar: true,
                        showOnlineIndicator: true,
                      ),
                      SizedBox(
                        height: (screenHeight * 0.020).clamp(16.0, 20.0),
                      ),

                      // 2. "Keep your rewards safe" Card (Figma Node 75:2775)
                      ProfileRewardsCard(
                        emailController: _emailController,
                        onCreateAccount: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'One-time link sent to your email!',
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        height: (screenHeight * 0.022).clamp(16.0, 20.0),
                      ),

                      // 3. Profile Details Section (Figma Node 75:2928)
                      Text(
                        'Profile',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(14.0),
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      ProfileAccountCard(
                        usernameController: _usernameController,
                        age: data.age,
                        weight: data.weight,
                        onAgeTap: () {
                          showAgePickerSheet(
                            context,
                            initialAge: data.age,
                            onConfirmed: (newAge) {
                              context.read<ProfileBloc>().add(
                                UpdateAgeEvent(newAge),
                              );
                            },
                          );
                        },
                        onWeightTap: () {
                          showWeightPickerSheet(
                            context,
                            initialWeight: data.weight,
                            unitSystem: data.unitSystem,
                            onConfirmed: (newWeight) {
                              context.read<ProfileBloc>().add(
                                UpdateWeightEvent(newWeight),
                              );
                            },
                          );
                        },
                      ),
                      SizedBox(
                        height: (screenHeight * 0.022).clamp(16.0, 20.0),
                      ),

                      // 4. Appearance Section (Figma Nodes 75:2952 & 75:2966)
                      Text(
                        'Appearance',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(14.0),
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      ProfileAppearanceCard(
                        appearance: data.appearance,
                        unitSystem: data.unitSystem,
                        onAppearanceChanged: (theme) {
                          context.read<ProfileBloc>().add(
                            UpdateAppearanceEvent(theme),
                          );
                        },
                        onUnitSystemChanged: (unit) {
                          context.read<ProfileBloc>().add(
                            UpdateUnitSystemEvent(unit),
                          );
                        },
                      ),
                      SizedBox(
                        height: (screenHeight * 0.022).clamp(16.0, 20.0),
                      ),

                      // 5. Notifications Section with CupertinoSwitch (Figma Nodes 82:2984, 82:2977, 82:3002)
                      ProfileNotificationsCard(
                        data: data,
                        onToggleNotification: (key, value) {
                          context.read<ProfileBloc>().add(
                            ToggleNotificationEvent(key, value),
                          );
                        },
                      ),
                      SizedBox(
                        height: (screenHeight * 0.022).clamp(16.0, 20.0),
                      ),

                      // 6. Band Section (Figma Node 82:3003)
                      Text(
                        'Band',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(14.0),
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      ProfileBandCard(data: data, onForgetBand: () {}),
                      SizedBox(
                        height: (screenHeight * 0.022).clamp(16.0, 20.0),
                      ),

                      // 7. Health Tracking Membership Banner Card (Figma Node 82:3028)
                      ProfileMembershipBanner(
                        onSeeMembership: () {
                          Navigator.of(context).pushNamed(AppRoutes.membership);
                        },
                      ),
                      SizedBox(
                        height: (screenHeight * 0.022).clamp(16.0, 20.0),
                      ),

                      // 8. Data & Privacy + Disclaimer (Figma Node 82:3035)
                      const ProfileDataPrivacySection(),
                      // const SizedBox(height: 12.0),
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
}
