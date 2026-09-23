import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../data/repositories/band_repository.dart';
import '../../data/repositories/wellness_repository.dart';
import '../security/secure_storage_service.dart';
import 'health_sync_policy.dart';

enum HealthSyncStatus { idle, syncing, completed, error }

/// Production-grade manager controlling all health data synchronizations.
///
/// Prevents concurrent BLE calls, eliminates duplicate polling, guarantees single source of truth,
/// and enforces the 5-minute Heart Rate refresh policy.
class HealthSyncManager {
  final SecureStorageService _secureStorage;

  DateTime? _lastHealthSyncAt;
  DateTime? _lastHeartRateSyncAt;
  DateTime? _lastTrainingSyncAt;
  HealthSyncStatus _status = HealthSyncStatus.idle;
  String? _lastError;

  Future<bool>? _ongoingSync;

  static const String _keyLastHealthSync = 'sync_last_health_sync_at';
  static const String _keyLastHrSync = 'sync_last_hr_sync_at';

  HealthSyncManager({SecureStorageService? secureStorage})
      : _secureStorage = secureStorage ?? SecureStorageService() {
    _loadStoredTimestamps();
  }

  DateTime? get lastHealthSyncAt => _lastHealthSyncAt;
  DateTime? get lastHeartRateSyncAt => _lastHeartRateSyncAt;
  DateTime? get lastTrainingSyncAt => _lastTrainingSyncAt;
  HealthSyncStatus get status => _status;
  bool get isSyncing => _status == HealthSyncStatus.syncing;
  String? get lastError => _lastError;

  Future<void> _loadStoredTimestamps() async {
    try {
      final healthIso = await _secureStorage.read(_keyLastHealthSync);
      if (healthIso != null && healthIso.isNotEmpty) {
        _lastHealthSyncAt = DateTime.tryParse(healthIso);
      }
      final hrIso = await _secureStorage.read(_keyLastHrSync);
      if (hrIso != null && hrIso.isNotEmpty) {
        _lastHeartRateSyncAt = DateTime.tryParse(hrIso);
      }
    } catch (_) {}
  }

  Future<void> _recordHealthSyncSuccess() async {
    final now = DateTime.now();
    _lastHealthSyncAt = now;
    _lastHeartRateSyncAt = now;
    _status = HealthSyncStatus.completed;
    _lastError = null;
    await _secureStorage.write(_keyLastHealthSync, now.toIso8601String()).catchError((_) {});
    await _secureStorage.write(_keyLastHrSync, now.toIso8601String()).catchError((_) {});
  }

  Future<void> _recordHeartRateSyncSuccess() async {
    final now = DateTime.now();
    _lastHeartRateSyncAt = now;
    await _secureStorage.write(_keyLastHrSync, now.toIso8601String()).catchError((_) {});
  }

  /// Triggers a cold-start synchronization if policy determines it is due and a band is connected.
  Future<bool> performColdStartSync({
    required BandRepository bandRepo,
    required WellnessRepository wellnessRepo,
  }) async {
    if (!HealthSyncPolicy.shouldColdStartSync(_lastHealthSyncAt)) {
      debugPrint('ℹ️ [SYNC MGR] Cold start sync skipped: data is already fresh ($_lastHealthSyncAt).');
      return true;
    }
    return performManualSync(
      bandRepo: bandRepo,
      wellnessRepo: wellnessRepo,
      isColdStart: true,
    );
  }

  /// Performs a controlled, deduplicated synchronization of health data from the band.
  Future<bool> performManualSync({
    required BandRepository bandRepo,
    required WellnessRepository wellnessRepo,
    bool isColdStart = false,
  }) async {
    // If a sync is already running, deduplicate and await existing Future
    if (_ongoingSync != null) {
      debugPrint('ℹ️ [SYNC MGR] Sync already in flight, joining ongoing operation...');
      return _ongoingSync!;
    }

    _status = HealthSyncStatus.syncing;
    _ongoingSync = () async {
      try {
        debugPrint('🔄 [SYNC MGR] Starting controlled sync (coldStart=$isColdStart)...');
        final vitals = await bandRepo.syncFullHealthData();
        wellnessRepo.updateFromBandVitals(vitals);
        await _recordHealthSyncSuccess();
        debugPrint('✅ [SYNC MGR] Sync completed successfully at $_lastHealthSyncAt');
        return true;
      } catch (e) {
        _status = HealthSyncStatus.error;
        _lastError = e.toString();
        debugPrint('⚠️ [SYNC MGR] Sync failed: $e');
        return false;
      } finally {
        _status = HealthSyncStatus.idle;
        _ongoingSync = null;
      }
    }();

    return _ongoingSync!;
  }

  /// Checks if Heart Rate on Home or Vitals is due for refresh according to the 5-minute policy.
  ///
  /// If due, triggers an on-demand Heart Rate sample from the band and updates local storage.
  /// If NOT due, uses the stored value and skips BLE transmission entirely.
  Future<bool> syncHeartRateIfDue({
    required BandRepository bandRepo,
    required WellnessRepository wellnessRepo,
  }) async {
    if (!HealthSyncPolicy.shouldRefreshHeartRate(_lastHeartRateSyncAt)) {
      debugPrint('⏱️ [SYNC MGR] HR sync skipped by 5-min policy (last sync: $_lastHeartRateSyncAt)');
      return true;
    }

    if (_ongoingSync != null) {
      return _ongoingSync!;
    }

    debugPrint('💓 [SYNC MGR] 5-minute interval elapsed. Performing controlled HR refresh...');
    _status = HealthSyncStatus.syncing;
    _ongoingSync = () async {
      try {
        final hr = await bandRepo.fetchLatestHeartRateSample();
        if (hr != null && hr > 0) {
          wellnessRepo.updateHeartRate(hr);
          await _recordHeartRateSyncSuccess();
        }
        return true;
      } catch (e) {
        debugPrint('⚠️ [SYNC MGR] HR refresh failed: $e');
        return false;
      } finally {
        _status = HealthSyncStatus.idle;
        _ongoingSync = null;
      }
    }();

    return _ongoingSync!;
  }

  void recordTrainingSessionSync() {
    _lastTrainingSyncAt = DateTime.now();
  }
}
