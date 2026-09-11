import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../blocs/profile/profile_event.dart';
import '../../blocs/profile/profile_state.dart';
import '../../widgets/common/screen_header.dart';
import '../../widgets/common/section_header.dart';
import 'widgets/profile_account_card.dart';
import 'widgets/profile_appearance_card.dart';
import 'widgets/profile_band_card.dart';
import 'widgets/profile_data_privacy_section.dart';
import 'widgets/profile_membership_banner.dart';
import 'widgets/profile_notifications_card.dart';
import 'widgets/profile_rewards_card.dart';

/// User profile and application settings screen.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: 'You@lorem.com');
    _usernameController = TextEditingController(text: 'John');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
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
          body: Stack(
            children: [
              // Sky header gradient
              SkyHeaderBackground(
                height: screenHeight * 0.3,
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
                      // Header Row
                      const ScreenHeader(title: 'Profile'),
                      SizedBox(height: screenHeight * 0.022),

                      // 1. "Keep your rewards safe" Card
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
                      SizedBox(height: screenHeight * 0.024),

                      // 2. Profile Details Section
                      const SectionHeader(
                        title: 'Profile',
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 12),
                      ProfileAccountCard(
                        usernameController: _usernameController,
                        age: data.age,
                        weight: data.weight,
                      ),
                      SizedBox(height: screenHeight * 0.024),

                      // 3. Appearance Section
                      const SectionHeader(
                        title: 'Appearance',
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 12),
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
                      SizedBox(height: screenHeight * 0.024),

                      // 4. Notifications Section
                      const SectionHeader(
                        title: 'Notifications',
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 12),
                      ProfileNotificationsCard(
                        data: data,
                        onToggleNotification: (key, value) {
                          context.read<ProfileBloc>().add(
                            ToggleNotificationEvent(key, value),
                          );
                        },
                      ),
                      SizedBox(height: screenHeight * 0.024),

                      // 5. Band Section
                      const SectionHeader(
                        title: 'Band',
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 12),
                      ProfileBandCard(data: data, onForgetBand: () {}),
                      SizedBox(height: screenHeight * 0.024),

                      // 6. Health Tracking Membership Banner Card
                      const ProfileMembershipBanner(),
                      SizedBox(height: screenHeight * 0.024),

                      // 7. Data & Privacy + Disclaimer
                      const ProfileDataPrivacySection(),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
