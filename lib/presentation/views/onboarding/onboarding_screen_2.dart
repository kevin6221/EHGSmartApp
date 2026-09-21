import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../../data/models/band_device_model.dart';
import '../../blocs/band/band_bloc.dart';
import '../../blocs/band/band_event.dart';
import '../../blocs/band/band_state.dart';
import '../../blocs/onboarding/onboarding_cubit.dart';
import '../../widgets/band/band_permission_dialog.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/figma_circular_loader.dart';
import '../../widgets/onboarding/onboarding_device_card.dart';
import '../../widgets/onboarding/onboarding_progress_bar.dart';
import '../../widgets/onboarding/onboarding_radar_graphic.dart';

/// Onboarding Screen 2 matching Figma nodes 14:2600 (Radar Scanner) and 16:2978 (Device Found).
///
/// Both states are part of Step 2 ("Connect your band"):
/// 1. Initial State: Radar scanner searching for nearby band via [BandBloc].
/// 2. Found State: Paired device card and band preview once the band is discovered.
///
/// Tapping "Connect" connects to the band and advances to Onboarding Screen 3 (Node 16:4201).
class OnboardingScreen2 extends StatefulWidget {
  final bool initialBandFound;

  const OnboardingScreen2({super.key, this.initialBandFound = false});

  @override
  State<OnboardingScreen2> createState() => _OnboardingScreen2State();
}

class _OnboardingScreen2State extends State<OnboardingScreen2>
    with WidgetsBindingObserver {
  bool _hasNavigated = false;
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.resumed && mounted) {
      context.read<BandBloc>().add(CheckBandPermissionsEvent());
      if (_isDialogShowing) {
        Navigator.of(context, rootNavigator: true).maybePop();
        _isDialogShowing = false;
      }
    }
  }

  void _onFindBandPressed(BuildContext context) {
    context.read<BandBloc>().add(const StartBandScanEvent());
  }

  void _onConnectPressed(BuildContext context, DiscoveredBandDevice device) {
    context.read<BandBloc>().add(ConnectBandEvent(device));
  }

  void _showPermissionModal(
    BuildContext context,
    BandPermissionDialogType type,
    VoidCallback action,
  ) {
    if (_isDialogShowing || !mounted) return;
    _isDialogShowing = true;
    BandPermissionDialog.show(
      context,
      type: type,
      onAction: action,
    ).then((_) {
      _isDialogShowing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final screenWidth = r.width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final radarDimension = (screenWidth * 0.72).clamp(240.0, 280.0);
              final bandDimension = (screenWidth * 0.65).clamp(200.0, 260.0);
              final bottomInset = MediaQuery.of(context).padding.bottom;
              final bottomSpacing = bottomInset > 0 ? 14.0 : 20.0;

              return BlocConsumer<BandBloc, BandState>(
                listenWhen: (previous, current) {
                  final becameConnected = !previous.isConnected && current.isConnected;
                  final newError = previous.errorMessage != current.errorMessage && current.errorMessage != null;
                  return (becameConnected && !_hasNavigated) || newError;
                },
                listener: (context, state) {
                  if (state.isConnected) {
                    if (_hasNavigated) return;
                    _hasNavigated = true;
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.deviceConnectedGreen,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        duration: const Duration(milliseconds: 2000),
                        content: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.white,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Band is successfully connected!',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppColors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                    Future.delayed(const Duration(milliseconds: 900), () {
                      if (context.mounted) {
                        context.read<OnboardingCubit>().setBandFound(true);
                        Navigator.pushNamed(context, AppRoutes.onboarding3);
                      }
                    });
                  } else if (state.errorMessage != null) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    final bloc = context.read<BandBloc>();

                    if (state.isPermanentlyDenied ||
                        (state.errorMessage?.contains('Settings') ?? false)) {
                      _showPermissionModal(
                        context,
                        BandPermissionDialogType.permanentlyDenied,
                        () => bloc.add(OpenAppSettingsEvent()),
                      );
                    } else if (!state.isBluetoothEnabled ||
                        (state.errorMessage?.contains('turned OFF') ?? false)) {
                      _showPermissionModal(
                        context,
                        BandPermissionDialogType.bluetoothOff,
                        () => bloc.add(EnableBluetoothEvent()),
                      );
                    } else if (!state.isLocationEnabled ||
                        (state.errorMessage?.contains('Location') ?? false)) {
                      _showPermissionModal(
                        context,
                        BandPermissionDialogType.locationOff,
                        () => bloc.add(OpenLocationSettingsEvent()),
                      );
                    } else if (state.permissionDetails?.status == BandPermissionStatus.denied ||
                        (state.errorMessage?.contains('permission') ?? false)) {
                      _showPermissionModal(
                        context,
                        BandPermissionDialogType.denied,
                        () => bloc.add(RequestBandPermissionsEvent()),
                      );
                    } else {
                      // Generic network or timeout error
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.systemRed,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          duration: const Duration(seconds: 4),
                          content: Text(
                            state.errorMessage!,
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }
                  }
                },
                builder: (context, state) {
                  final bool isFound = state.discoveredDevices.isNotEmpty || state.isConnected;
                  final DiscoveredBandDevice? targetDevice =
                      state.discoveredDevices.isNotEmpty ? state.discoveredDevices.first : null;

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 1. Top 6-capsule Progress Bar (Step 2 active)
                              const OnboardingProgressBar(
                                padding: EdgeInsets.only(
                                  top: 12.0,
                                  bottom: 8.0,
                                ),
                              ),

                              SizedBox(
                                height: (constraints.maxHeight * 0.090).clamp(
                                  16.0,
                                  40.0,
                                ),
                              ),

                              Text(
                                'Connect your band',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: (screenWidth * 0.08).clamp(
                                    24.0,
                                    30.0,
                                  ),
                                  fontWeight: FontWeight.w700,
                                  height: 38.0 / 30.0,
                                  letterSpacing: -0.39,
                                  color: AppColors.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 16.0),

                              Text(
                                'Make sure your EHG Smart Band is charged and nearby. If it is currently paired to another app, unpair it there first.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: (screenWidth * 0.042).clamp(
                                    14.0,
                                    16.0,
                                  ),
                                  fontWeight: FontWeight.w400,
                                  height: 25.6 / 16.0,
                                  letterSpacing: 0.0,
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const Spacer(),

                              // 3. Center Graphic & Device Card (Transitions smoothly between Radar and Band Found)
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 350),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                child: !isFound
                                    ? Column(
                                        key: const ValueKey('radar_section'),
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16.0,
                                            ),
                                            child: Center(
                                              child: OnboardingRadarGraphic(
                                                dimension: radarDimension,
                                                isScanning: state.isScanning,
                                              ),
                                            ),
                                          ),
                                          AnimatedSwitcher(
                                            duration: const Duration(milliseconds: 250),
                                            child: state.isScanning
                                                ? Container(
                                                    key: const ValueKey('scanning_status_pill'),
                                                    margin: const EdgeInsets.only(top: 4.0),
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 16.0,
                                                      vertical: 8.0,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primaryLight,
                                                      borderRadius: BorderRadius.circular(24.0),
                                                      border: Border.all(
                                                        color: AppColors.primary.withValues(alpha: 0.18),
                                                        width: 1.0,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        const FigmaCircularLoader(
                                                          size: 14.0,
                                                          strokeWidth: 2.0,
                                                          indicatorColor: AppColors.primary,
                                                          trackColor: AppColors.transparent,
                                                        ),
                                                        const SizedBox(width: 8.0),
                                                        Text(
                                                          'Scanning for nearby EHG Band...',
                                                          style: GoogleFonts.plusJakartaSans(
                                                            fontSize: 12.0,
                                                            fontWeight: FontWeight.w600,
                                                            color: AppColors.primary,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : const SizedBox.shrink(key: ValueKey('idle_spacer')),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        key: const ValueKey('band_found_card'),
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Center(
                                            child: Image.asset(
                                              AppConstants.onboardingBand,
                                              width: bandDimension,
                                              height: bandDimension,
                                              fit: BoxFit.contain,
                                              cacheWidth: (bandDimension * 2.5).toInt(),
                                            ),
                                          ),
                                          const SizedBox(height: 16.0),
                                          OnboardingDeviceCard(
                                            deviceName: targetDevice?.name ?? 'EHG Smart Band',
                                            deviceId: (targetDevice != null && targetDevice.mac.isNotEmpty)
                                                ? targetDevice.mac
                                                : (targetDevice?.id ?? 'Connected'),
                                          ),
                                        ],
                                      ),
                              ),

                              const Spacer(),

                              // 4. Action Button (Find My band -> Connect)
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: !isFound
                                    ? AppButton(
                                        key: const ValueKey('find_band_button'),
                                        text: state.isScanning
                                            ? 'Searching for band...'
                                            : (state.discoveredDevices.isEmpty
                                                ? 'Find My band'
                                                : 'Scan Again'),
                                        isLoading: state.isScanning,
                                        trailingSvg: state.isScanning ? null : AppIcons.searchIcon,
                                        onPressed: state.isScanning ? null : () => _onFindBandPressed(context),
                                      )
                                    : AppButton(
                                        key: const ValueKey('connect_button'),
                                        text: state.isConnecting
                                            ? 'Connecting...'
                                            : (state.isConnected ? 'Connected' : 'Connect'),
                                        isLoading: state.isConnecting,
                                        trailingSvg: state.isConnecting ? null : AppIcons.connectIcon,
                                        onPressed: (state.isConnecting || targetDevice == null || state.isConnected)
                                            ? null
                                            : () => _onConnectPressed(context, targetDevice),
                                      ),
                              ),

                              const SizedBox(height: 16.0),

                              // 5. Status / Privacy Footer
                              Text(
                                !isFound
                                    ? (state.isScanning
                                        ? 'Bluetooth   •   Scanning nearby...'
                                        : 'Bluetooth   •   Ready to search')
                                    : 'Your data stays on your phone',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w400,
                                  height: 19.2 / 12.0,
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: bottomSpacing),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
