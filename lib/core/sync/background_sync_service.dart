import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../data/repositories/band_repository.dart';
import '../../data/repositories/wellness_repository.dart';
import 'health_sync_manager.dart';
import 'health_sync_policy.dart';

/// Service orchestrating background and lifecycle synchronization.
///
/// Implements Android WorkManager and iOS BGAppRefreshTask triggers via platform
/// channels, respecting [HealthSyncPolicy] to prevent BLE connection thrashing.
class BackgroundSyncService {
  static const MethodChannel _backgroundChannel =
      MethodChannel('com.ehg.smartapp/background_sync');

  final HealthSyncManager syncManager;
  final BandRepository bandRepository;
  final WellnessRepository wellnessRepository;

  bool _isInitialized = false;

  BackgroundSyncService({
    required this.syncManager,
    required this.bandRepository,
    required this.wellnessRepository,
  });

  /// Initializes background sync handler and schedules native background tasks.
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // Listen for background trigger from native WorkManager / BGAppRefreshTask
    _backgroundChannel.setMethodCallHandler(_handleNativeBackgroundCall);

    // Register periodic background sync tasks with the OS
    await scheduleNativePeriodicSync();
  }

  /// Handles incoming calls from native background workers (WorkManager / BGTask).
  Future<dynamic> _handleNativeBackgroundCall(MethodCall call) async {
    switch (call.method) {
      case 'onPeriodicBackgroundSync':
        debugPrint('🔔 [BG SYNC] Received periodic background sync trigger from OS.');
        final success = await performBackgroundSync();
        return success;
      default:
        return null;
    }
  }

  /// Requests the native layer (WorkManager / BGAppRefreshTask) to register periodic background sync.
  Future<bool> scheduleNativePeriodicSync() async {
    try {
      final result = await _backgroundChannel.invokeMethod<bool>(
        'schedulePeriodicSync',
        {
          'intervalMinutes': HealthSyncPolicy.backgroundSyncInterval.inMinutes,
        },
      );
      debugPrint('📅 [BG SYNC] Native periodic sync scheduled: $result');
      return result ?? false;
    } on MissingPluginException {
      debugPrint('ℹ️ [BG SYNC] Background channel not registered on this platform.');
      return false;
    } catch (e) {
      debugPrint('⚠️ [BG SYNC] Failed to schedule native periodic sync: $e');
      return false;
    }
  }

  /// Executes background synchronization if allowed by [HealthSyncPolicy].
  Future<bool> performBackgroundSync() async {
    final lastSync = syncManager.lastHealthSyncAt;
    if (!HealthSyncPolicy.shouldBackgroundSync(lastSync)) {
      debugPrint('ℹ️ [BG SYNC] Background sync skipped by policy: data is fresh (last sync: $lastSync).');
      return true;
    }

    // Check if band is connected or can auto-reconnect
    final isConnected = bandRepository.isConnected;
    if (!isConnected) {
      debugPrint('ℹ️ [BG SYNC] Band not connected; attempting reconnect for background sync...');
      final reconnected = await bandRepository.reconnect();
      if (!reconnected) {
        debugPrint('⚠️ [BG SYNC] Cannot perform background sync: band unreachable.');
        return false;
      }
    }

    debugPrint('🔄 [BG SYNC] Performing background health synchronization...');
    return syncManager.performManualSync(
      bandRepo: bandRepository,
      wellnessRepo: wellnessRepository,
      isColdStart: false,
    );
  }
}
