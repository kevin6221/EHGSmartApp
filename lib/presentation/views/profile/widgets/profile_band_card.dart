import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../data/models/user_profile_model.dart';
import '../../../../data/repositories/band_repository.dart';
import '../../../blocs/band/band_bloc.dart';
import '../../../blocs/band/band_event.dart';
import '../../../blocs/band/band_state.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_card.dart';

/// Card showing connected Smart Band details and bind/unbind actions (matching QWatch Pro).
class ProfileBandCard extends StatelessWidget {
  final UserProfileModel data;
  final VoidCallback? onForgetBand;

  const ProfileBandCard({super.key, required this.data, this.onForgetBand});

  void _showUnbindConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        title: Text(
          'Unbind Device',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: 18.0,
            color: context.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to unbind your smart band? This will disconnect the device, remove Bluetooth pairing, and clear locally cached vitals.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.0,
            color: context.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w500,
                color: context.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.systemRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
            onPressed: () {
              context.read<BandBloc>().add(UnbindBandEvent());
              onForgetBand?.call();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Device unbound successfully.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Text(
              'Unbind',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return BlocBuilder<BandBloc, BandState>(
      builder: (context, bandState) {
        final isBound = bandState.isBound;
        final isConnected = bandState.isConnected;
        final isConnecting = bandState.isConnecting;

        if (!isBound) {
          return AppCard(
            padding: const EdgeInsets.all(16.0),
            borderRadius: BorderRadius.circular(12.0),
            border: const Border.fromBorderSide(BorderSide.none),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowNavy.withValues(alpha: 0.03),
                blurRadius: 8.0,
                offset: const Offset(0, 4),
              ),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36.0,
                      height: 36.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: context.isDark ? AppColors.midnightSurface : AppColors.surfaceVariant,
                        shape: BoxShape.circle,
                      ),
                      child: const AppSvgIcon(
                        AppIcons.watchDevice,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No Band Paired',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: r.font(16.0),
                              fontWeight: FontWeight.w600,
                              color: context.textPrimary,
                            ),
                          ),
                          Text(
                            'Pair your band to track 24/7 vitals & sleep',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: r.font(12.0),
                              fontWeight: FontWeight.w400,
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                AppButton(
                  text: 'Pair EHG Smart Band',
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.onboarding2);
                  },
                  borderRadius: BorderRadius.circular(8.0),
                  height: 44.0,
                ),
              ],
            ),
          );
        }

        final deviceName = bandState.connectedDevice?.name ??
            bandState.boundDevice?.name ??
            'EHG Smart Band';
        final deviceId = bandState.connectedDevice != null
            ? (bandState.connectedDevice!.macAddress.isNotEmpty
                ? bandState.connectedDevice!.macAddress
                : bandState.connectedDevice!.id)
            : (bandState.boundDevice?.mac.isNotEmpty == true
                ? bandState.boundDevice!.mac
                : (bandState.boundDevice?.id ?? ''));

        final repoBattery =
            context.read<BandRepository>().currentBattery.percentage;
        final effectiveBattery = bandState.battery.percentage > 0
            ? bandState.battery.percentage
            : (repoBattery > 0 ? repoBattery : null);
        final batteryText = isConnected && effectiveBattery != null
            ? '$effectiveBattery%'
            : (isConnected ? '--%' : 'Disconnected');

        return AppCard(
          padding: const EdgeInsets.all(15.0),
          borderRadius: BorderRadius.circular(12.0),
          border: const Border.fromBorderSide(BorderSide.none),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowNavy.withValues(alpha: 0.03),
              blurRadius: 8.0,
              offset: const Offset(0, 4),
            ),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Device Info Row (Radial Badge + Name + ID + Battery/Status)
              Row(
                children: [
                  Container(
                    width: 34.0,
                    height: 34.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: isConnected
                          ? AppGradients.profileBadgeRadial
                          : null,
                      color: isConnected ? null : (context.isDark ? AppColors.midnightSurface : AppColors.surfaceVariant),
                      shape: BoxShape.circle,
                    ),
                    child: AppSvgIcon(
                      AppIcons.watchDevice,
                      color: isConnected ? AppColors.white : context.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                deviceName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: r.font(16.0),
                                  fontWeight: FontWeight.w600,
                                  color: context.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6.0,
                                vertical: 2.0,
                              ),
                              decoration: BoxDecoration(
                                color: isConnected
                                    ? AppColors.greenMetric.withValues(alpha: 0.12)
                                    : (isConnecting
                                        ? AppColors.orangeMetric.withValues(alpha: 0.12)
                                        : AppColors.textMuted.withValues(alpha: 0.12)),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: Text(
                                isConnected
                                    ? 'Connected'
                                    : (isConnecting ? 'Connecting...' : 'Disconnected'),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: r.font(10.0),
                                  fontWeight: FontWeight.w600,
                                  color: isConnected
                                      ? AppColors.greenMetric
                                      : (isConnecting
                                          ? AppColors.orangeMetric
                                          : context.textSecondary),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2.0),
                        Row(
                          children: [
                            if (deviceId.isNotEmpty) ...[
                              Expanded(
                                child: Text(
                                  deviceId,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: r.font(12.0),
                                    fontWeight: FontWeight.w400,
                                    color: context.textSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Container(
                                width: 0.5,
                                height: 10.0,
                                color: context.cardBorder,
                              ),
                              const SizedBox(width: 8.0),
                            ],
                            if (isConnected) ...[
                              RotatedBox(
                                quarterTurns: 1,
                                child: const Icon(
                                  Icons.battery_5_bar_rounded,
                                  size: 16.0,
                                  color: AppColors.greenMetric,
                                ),
                              ),
                              const SizedBox(width: 4.0),
                            ],
                            Text(
                              batteryText,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: r.font(12.0),
                                fontWeight: FontWeight.w400,
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // 2. Action Buttons (Matching QWatch Pro: Find Band / Reconnect + Unbind)
              Row(
                children: [
                  if (isConnected)
                    Expanded(
                      child: AppButton.outlined(
                        text: 'Find band',
                        onPressed: () {
                          context.read<BandBloc>().add(FindBandEvent());
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Vibrating band...'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        showArrow: false,
                        borderRadius: BorderRadius.circular(8.0),
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        fontSize: r.font(14.0),
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else
                    Expanded(
                      child: AppButton(
                        text: isConnecting ? 'Connecting...' : 'Reconnect',
                        onPressed: isConnecting
                            ? null
                            : () {
                                context.read<BandBloc>().add(ReconnectBandEvent());
                              },
                        showArrow: false,
                        borderRadius: BorderRadius.circular(8.0),
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        fontSize: r.font(14.0),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: AppButton.outlined(
                      text: 'Unbind',
                      onPressed: () => _showUnbindConfirmation(context),
                      showArrow: false,
                      borderRadius: BorderRadius.circular(8.0),
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      fontSize: r.font(14.0),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
