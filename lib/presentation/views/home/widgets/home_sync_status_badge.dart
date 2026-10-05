import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/sync/health_sync_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../data/repositories/band_repository.dart';
import '../../../../data/repositories/wellness_repository.dart';
import '../../../blocs/band/band_bloc.dart';
import '../../../blocs/band/band_event.dart';
import '../../../blocs/band/band_state.dart';
import '../../../blocs/vitals/vitals_bloc.dart';
import '../../../blocs/vitals/vitals_event.dart';
import '../../../blocs/wellness/wellness_bloc.dart';
import '../../../blocs/wellness/wellness_event.dart';

/// Professional wearable synchronization status badge (referencing WHOOP & Garmin Connect).
///
/// Displays real-time band connectivity and sync status:
/// - Rotating spinner and live status text during active sync
/// - Relative timestamp ("Synced just now", "Synced 2m ago") when fresh
/// - Quick tap-to-sync or tap-to-reconnect action
///
/// Adheres strictly to zero-setState architecture using [ValueListenableBuilder].
class HomeSyncStatusBadge extends StatelessWidget {
  const HomeSyncStatusBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final syncMgr = context.read<HealthSyncManager>();

    return BlocBuilder<BandBloc, BandState>(
      builder: (context, bandState) {
        final isConnected = bandState.isConnected;
        final isConnecting = bandState.isConnecting;
        final hasBoundDevice = bandState.isBound;

        return ValueListenableBuilder<HealthSyncSnapshot>(
          valueListenable: syncMgr.snapshot,
          builder: (context, snapshot, _) {
            final isSyncing = snapshot.isSyncing;
            final isError = snapshot.hasError;

            // Determine badge appearance
            final Color badgeBg;
            final Color textColor;
            final Color iconColor;
            final String badgeText;
            final Widget leadingIcon;

            if (isSyncing) {
              badgeBg = AppColors.primary.withValues(alpha: 0.12);
              textColor = AppColors.primary;
              iconColor = AppColors.primary;
              badgeText = snapshot.statusMessage.isNotEmpty
                  ? snapshot.statusMessage
                  : 'Syncing with band...';
              leadingIcon = SizedBox(
                width: 14.0,
                height: 14.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                ),
              );
            } else if (isError) {
              badgeBg = AppColors.systemRed.withValues(alpha: 0.12);
              textColor = AppColors.systemRed;
              iconColor = AppColors.systemRed;
              badgeText = 'Sync error · Tap to retry';
              leadingIcon = Icon(
                Icons.error_outline_rounded,
                size: 14.0,
                color: iconColor,
              );
            } else if (isConnected) {
              badgeBg = AppColors.greenMetric.withValues(alpha: 0.10);
              textColor = context.isDark ? AppColors.white : AppColors.textPrimary;
              iconColor = AppColors.greenMetric;
              final syncTime = snapshot.formattedSyncTime;
              badgeText = 'Connected · $syncTime';
              leadingIcon = Container(
                width: 7.0,
                height: 7.0,
                decoration: const BoxDecoration(
                  color: AppColors.greenMetric,
                  shape: BoxShape.circle,
                ),
              );
            } else if (isConnecting) {
              badgeBg = AppColors.orangeMetric.withValues(alpha: 0.12);
              textColor = AppColors.orangeMetric;
              iconColor = AppColors.orangeMetric;
              badgeText = 'Connecting to band...';
              leadingIcon = SizedBox(
                width: 14.0,
                height: 14.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                ),
              );
            } else if (hasBoundDevice) {
              badgeBg = (context.isDark ? AppColors.midnightSurface : AppColors.surfaceVariant)
                  .withValues(alpha: 0.7);
              textColor = context.textSecondary;
              iconColor = context.textSecondary;
              badgeText = 'Band disconnected · Tap to connect';
              leadingIcon = Icon(
                Icons.bluetooth_disabled_rounded,
                size: 14.0,
                color: iconColor,
              );
            } else {
              badgeBg = (context.isDark ? AppColors.midnightSurface : AppColors.surfaceVariant)
                  .withValues(alpha: 0.7);
              textColor = context.textSecondary;
              iconColor = context.textSecondary;
              badgeText = 'No band paired · Tap to setup';
              leadingIcon = Icon(
                Icons.watch_outlined,
                size: 14.0,
                color: iconColor,
              );
            }

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isSyncing
                    ? null
                    : () async {
                        if (!isConnected && hasBoundDevice) {
                          context.read<BandBloc>().add(AutoReconnectBandEvent());
                        } else if (isConnected) {
                          final bandRepo = context.read<BandRepository>();
                          final wellnessRepo = context.read<WellnessRepository>();
                          final wellnessBloc = context.read<WellnessBloc>();
                          final vitalsBloc = context.read<VitalsBloc>();

                          await syncMgr.performManualSync(
                            bandRepo: bandRepo,
                            wellnessRepo: wellnessRepo,
                            force: true,
                          );

                          wellnessBloc.add(const LoadWellnessDataEvent());
                          vitalsBloc.add(LoadVitalsEvent());
                        }
                      },
                borderRadius: BorderRadius.circular(20.0),
                child: Ink(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 5.0,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: isSyncing
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : (isConnected
                              ? AppColors.greenMetric.withValues(alpha: 0.25)
                              : Colors.transparent),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      leadingIcon,
                      const SizedBox(width: 6.0),
                      Text(
                        badgeText,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: r.font(11.5),
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          letterSpacing: 0.1,
                        ),
                      ),
                      if (isConnected && !isSyncing) ...[
                        const SizedBox(width: 6.0),
                        Icon(
                          Icons.refresh_rounded,
                          size: 13.0,
                          color: textColor.withValues(alpha: 0.6),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
