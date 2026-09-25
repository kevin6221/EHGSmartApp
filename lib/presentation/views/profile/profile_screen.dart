import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../data/repositories/band_repository.dart';
import '../../blocs/band/band_bloc.dart';
import '../../blocs/band/band_event.dart';
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
import 'widgets/profile_menu_listing_card.dart';
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
  String? _lastLoadedUsername;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _usernameController = TextEditingController();
    context.read<ProfileBloc>().add(LoadProfileEvent());
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

  Future<void> _shareExportFile(BuildContext context, {required bool isCsv}) async {
    try {
      final repo = context.read<BandRepository>();
      final tempDir = await getTemporaryDirectory();
      final now = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = isCsv ? 'ehg_health_export_$now.csv' : 'ehg_health_export_$now.json';
      final file = File('${tempDir.path}/$fileName');

      if (isCsv) {
        final csvData = await repo.exportHealthDataCsv();
        await file.writeAsString(csvData);
      } else {
        final jsonData = repo.exportHealthDataJson();
        await file.writeAsString(jsonData);
      }

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'EHG Smart Wellness Health Export',
          text: 'EHG Smart Band Health Data Export ($now)',
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  void _showExportDialog(BuildContext context) {
    final jsonStr = context.read<BandRepository>().exportHealthDataJson();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.cardBackground,
        title: Text(
          'Export Health Data',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: ctx.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export your complete health metrics, vitals history, and sleep stages. You can share as a CSV spreadsheet or JSON file.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.0,
                color: ctx.textSecondary,
              ),
            ),
            const SizedBox(height: 12.0),
            Container(
              constraints: const BoxConstraints(maxHeight: 140.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: ctx.cardBackground,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: SingleChildScrollView(
                child: Text(
                  jsonStr,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11.0,
                    color: ctx.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Close', style: TextStyle(color: ctx.textSecondary)),
          ),
          OutlinedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonStr));
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exported JSON copied to clipboard!')),
              );
            },
            child: const Text('Copy JSON'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _shareExportFile(context, isCsv: true);
            },
            child: const Text('Share CSV'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.cardBackground,
        title: Text(
          'Delete Everything?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: ctx.textPrimary,
          ),
        ),
        content: Text(
          'This will disconnect your EHG Smart Band and permanently clear all locally stored vitals and health history.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.0,
            color: ctx.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.systemRed,
            ),
            onPressed: () async {
              await context.read<BandRepository>().clearLocalData();
              if (context.mounted) {
                context.read<BandBloc>().add(UnbindBandEvent());
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All local health data cleared and band unbound.')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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

        if (_lastLoadedUsername == null) {
          _lastLoadedUsername = data.username;
          _usernameController.text = data.username;
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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

                      // 3. Features & Settings Listing (Train, Systems, Rewards, Notifications)
                      Text(
                        'More Features',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(14.0),
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      const ProfileMenuListingCard(),
                      SizedBox(
                        height: (screenHeight * 0.022).clamp(16.0, 20.0),
                      ),

                      // 4. Profile Details Section (Figma Node 75:2928)
                      Text(
                        'Profile',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(14.0),
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      ProfileAccountCard(
                        usernameController: _usernameController,
                        age: data.age,
                        weight: data.weight,
                        unitSystem: data.unitSystem,
                        onUsernameChanged: (newVal) {
                          final trimmed = newVal.trim();
                          if (trimmed.isNotEmpty && trimmed != data.username) {
                            _lastLoadedUsername = trimmed;
                            context.read<ProfileBloc>().add(
                              UpdateUsernameEvent(trimmed),
                            );
                          }
                        },
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
                          final initialWeight = data.unitSystem == UnitSystem.imperial
                              ? (data.weight * 2.20462).round()
                              : data.weight;
                          showWeightPickerSheet(
                            context,
                            initialWeight: initialWeight,
                            unitSystem: data.unitSystem,
                            onConfirmed: (newWeight) {
                              final savedWeight = data.unitSystem == UnitSystem.imperial
                                  ? (newWeight / 2.20462).round()
                                  : newWeight;
                              context.read<ProfileBloc>().add(
                                UpdateWeightEvent(savedWeight),
                              );
                            },
                          );
                        },
                      ),
                      SizedBox(
                        height: (screenHeight * 0.022).clamp(16.0, 20.0),
                      ),

                      // 5. Appearance Section (Figma Nodes 75:2952 & 75:2966)
                      Text(
                        'Appearance',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(14.0),
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
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

                      // 6. Band Section (Figma Node 82:3003)
                      Text(
                        'Band',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(14.0),
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
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
                      ProfileDataPrivacySection(
                        onExportData: () => _showExportDialog(context),
                        onDeleteData: () => _showDeleteConfirmation(context),
                      ),
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
