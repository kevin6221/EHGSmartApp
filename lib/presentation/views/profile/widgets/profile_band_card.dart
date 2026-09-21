import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../data/models/user_profile_model.dart';
import '../../../blocs/band/band_bloc.dart';
import '../../../blocs/band/band_event.dart';
import '../../../blocs/band/band_state.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_card.dart';

/// Card showing connected Smart Band details and unpair action (Figma Node 82:3003).
class ProfileBandCard extends StatelessWidget {
  final UserProfileModel data;
  final VoidCallback? onForgetBand;

  const ProfileBandCard({super.key, required this.data, this.onForgetBand});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return BlocBuilder<BandBloc, BandState>(
      builder: (context, bandState) {
        final isConnected = bandState.isConnected;
        final deviceName = bandState.connectedDevice?.name ?? data.bandModel;
        final deviceId = bandState.connectedDevice != null
            ? (bandState.connectedDevice!.macAddress.isNotEmpty
                ? bandState.connectedDevice!.macAddress
                : bandState.connectedDevice!.id)
            : data.bandId;
        final batteryText = isConnected
            ? '${bandState.battery.percentage}%'
            : data.bandBatteryDays;

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
              // 1. Device Info Row (Radial Badge + Name + ID + Battery)
              Row(
                children: [
                  Container(
                    width: 32.0,
                    height: 32.0,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      gradient: AppGradients.profileBadgeRadial,
                      shape: BoxShape.circle,
                    ),
                    child: const AppSvgIcon(
                      AppIcons.watchDevice,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          deviceName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: r.font(16.0),
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Text(
                              deviceId,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: r.font(12.0),
                                fontWeight: FontWeight.w400,
                                color: AppColors.tertiary,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Container(
                              width: 0.5,
                              height: 10.0,
                              color: AppColors.borderLight,
                            ),
                            const SizedBox(width: 8.0),
                            RotatedBox(
                              quarterTurns: 1,
                              child: Icon(
                                isConnected
                                    ? Icons.battery_5_bar_rounded
                                    : Icons.battery_unknown_rounded,
                                size: 18.0,
                                color: isConnected
                                    ? AppColors.greenMetric
                                    : AppColors.tertiary,
                              ),
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              batteryText,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: r.font(12.0),
                                fontWeight: FontWeight.w400,
                                color: AppColors.tertiary,
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

              // 2. Action Button (Forgot this Band vs Pair Band)
              if (isConnected)
                AppButton.outlined(
                  text: 'Forgot this band',
                  onPressed: () {
                    context.read<BandBloc>().add(DisconnectBandEvent());
                    onForgetBand?.call();
                  },
                  showArrow: false,
                  borderRadius: BorderRadius.circular(8.0),
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  fontSize: r.font(16.0),
                  fontWeight: FontWeight.w500,
                )
              else
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
      },
    );
  }
}
