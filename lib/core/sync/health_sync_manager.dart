import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../data/repositories/band_repository.dart';
import '../../data/repositories/wellness_repository.dart';
import '../security/secure_storage_service.dart';
import 'health_sync_policy.dart';

enum HealthSyncStatus { idle, syncing, completed, error }

/// Production-grade sync manager for wearable health data.
///
/// **Manual-only architecture** — data is refreshed exclusively via:
///   1. Cold-start sync on app launch (if stale / day changed).
///   2. User-initiated pull-to-refresh on Home or Vitals screens.
///
/// Per-vital freshness thresholds (matching QWatch Pro):
///   • Heart Rate      — 5 min
///   • HRV / SpO₂      — 1 hr
///   • Stress           — 30 min
///   • Blood Pressure   — 2 hr
///
/// No periodic Timer, no automatic background polling.
class HealthSyncManager {
  final SecureStorageService _secureStorage;

  // ── Timestamps per vital type ──────────────────────────────────────────
  DateTime? _lastFullSyncAt;
  DateTime? _lastHeartRateSyncAt;
  DateTime? _lastHrvSyncAt;
  DateTime? _lastSpO2SyncAt;
  DateTime? _lastStressSyncAt;
  DateTime? _lastBloodPressureSyncAt;

  HealthSyncStatus _status = HealthSyncStatus.idle;
  String? _lastError;

  Future<bool>? _ongoingSync;

  // Secure storage keys
  static const String _keyLastFullSync = 'sync_last_health_sync_at';
  static const String _keyLastHrSync = 'sync_last_hr_sync_at';
  static const String _keyLastHrvSync = 'sync_last_hrv_sync_at';
  static const String _keyLastSpO2Sync = 'sync_last_spo2_sync_at';
  static const String _keyLastStressSync = 'sync_last_stress_sync_at';
  static const String _keyLastBpSync = 'sync_last_bp_sync_at';

  HealthSyncManager({SecureStorageService? secureStorage})
      : _secureStorage = secureStorage ?? SecureStorageService() {
    _loadStoredTimestamps();
  }

  // ── Public getters ─────────────────────────────────────────────────────
  DateTime? get lastHealthSyncAt => _lastFullSyncAt;
  DateTime? get lastHeartRateSyncAt => _lastHeartRateSyncAt;
  HealthSyncStatus get status => _status;
  bool get isSyncing => _status == HealthSyncStatus.syncing;
  String? get lastError => _lastError;

  // ── Timestamp persistence ──────────────────────────────────────────────

  Future<void> _loadStoredTimestamps() async {
    try {
      _lastFullSyncAt = await _readTimestamp(_keyLastFullSync);
      _lastHeartRateSyncAt = await _readTimestamp(_keyLastHrSync);
      _lastHrvSyncAt = await _readTimestamp(_keyLastHrvSync);
      _lastSpO2SyncAt = await _readTimestamp(_keyLastSpO2Sync);
      _lastStressSyncAt = await _readTimestamp(_keyLastStressSync);
      _lastBloodPressureSyncAt = await _readTimestamp(_keyLastBpSync);
    } catch (_) {}
  }

  Future<DateTime?> _readTimestamp(String key) async {
    final iso = await _secureStorage.read(key);
    if (iso != null && iso.isNotEmpty) return DateTime.tryParse(iso);
    return null;
  }

  Future<void> _saveTimestamp(String key, DateTime ts) async {
    await _secureStorage.write(key, ts.toIso8601String()).catchError((_) {});
  }

  Future<void> _recordFullSyncSuccess() async {
    final now = DateTime.now();
    _lastFullSyncAt = now;
    _lastHeartRateSyncAt = now;
    _lastHrvSyncAt = now;
    _lastSpO2SyncAt = now;
    _lastStressSyncAt = now;
    _lastBloodPressureSyncAt = now;
    _status = HealthSyncStatus.completed;
    _lastError = null;

    await Future.wait([
      _saveTimestamp(_keyLastFullSync, now),
      _saveTimestamp(_keyLastHrSync, now),
      _saveTimestamp(_keyLastHrvSync, now),
      _saveTimestamp(_keyLastSpO2Sync, now),
      _saveTimestamp(_keyLastStressSync, now),
      _saveTimestamp(_keyLastBpSync, now),
    ]);
  }

  // ── Cold-start sync ────────────────────────────────────────────────────

  /// Triggers a cold-start synchronization if policy determines it is due.
  Future<bool> performColdStartSync({
    required BandRepository bandRepo,
    required WellnessRepository wellnessRepo,
  }) async {
    if (!HealthSyncPolicy.shouldColdStartSync(_lastFullSyncAt)) {
      debugPrint(
          'ℹ️ [SYNC MGR] Cold start sync skipped: data is already fresh ($_lastFullSyncAt).');
      return true;
    }
    return performManualSync(
      bandRepo: bandRepo,
      wellnessRepo: wellnessRepo,
      isColdStart: true,
    );
  }

  // ── Manual pull-to-refresh sync ────────────────────────────────────────

  /// Performs a controlled, deduplicated synchronization of health data.
  ///
  /// Called **only** by user pull-to-refresh or cold start — never automatically.
  /// Fetches full health data from the band, updates the WellnessRepository,
  /// reloads weekly DB data, and records per-vital timestamps.
  Future<bool> performManualSync({
    required BandRepository bandRepo,
    required WellnessRepository wellnessRepo,
    bool isColdStart = false,
  }) async {
    // Deduplicate concurrent sync requests
    if (_ongoingSync != null) {
      debugPrint(
          'ℹ️ [SYNC MGR] Sync already in flight, joining ongoing operation...');
      return _ongoingSync!;
    }

    _status = HealthSyncStatus.syncing;
    _ongoingSync = () async {
      try {
        debugPrint(
            '🔄 [SYNC MGR] Starting manual sync (coldStart=$isColdStart)...');

        // Log which vitals are actually stale (useful for debugging)
        _logStaleness();

        final vitals = await bandRepo.syncFullHealthData();
        wellnessRepo.updateFromBandVitals(vitals);
        await wellnessRepo.reloadWeeklyDataFromDatabase();
        await _recordFullSyncSuccess();

        debugPrint(
            '✅ [SYNC MGR] Manual sync completed successfully at $_lastFullSyncAt');
        return true;
      } catch (e) {
        _status = HealthSyncStatus.error;
        _lastError = e.toString();
        debugPrint('⚠️ [SYNC MGR] Manual sync failed: $e');
        return false;
      } finally {
        _status = HealthSyncStatus.idle;
        _ongoingSync = null;
      }
    }();

    return _ongoingSync!;
  }

  // ── On-demand HR sample (used for cold start only) ─────────────────────

  /// Fetches latest HR sample if stale per 5-minute policy.
  ///
  /// Only called by cold-start; **NOT** on a periodic timer.
  Future<bool> syncHeartRateIfDue({
    required BandRepository bandRepo,
    required WellnessRepository wellnessRepo,
  }) async {
    if (!HealthSyncPolicy.shouldRefreshHeartRate(_lastHeartRateSyncAt)) {
      debugPrint(
          '⏱️ [SYNC MGR] HR sync skipped by 5-min policy (last: $_lastHeartRateSyncAt)');
      return true;
    }

    if (_ongoingSync != null) return _ongoingSync!;

    debugPrint(
        '💓 [SYNC MGR] HR stale — performing controlled HR refresh...');
    _status = HealthSyncStatus.syncing;
    _ongoingSync = () async {
      try {
        final hr = await bandRepo.fetchLatestHeartRateSample();
        if (hr != null && hr > 0) {
          wellnessRepo.updateHeartRate(hr);
          final now = DateTime.now();
          _lastHeartRateSyncAt = now;
          await _saveTimestamp(_keyLastHrSync, now);
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

  // ── Past days backfill ─────────────────────────────────────────────────

  /// Sequentially synchronizes past days (1 up to count, max 6) to backfill Drift SQLite.
  Future<void> syncPastDays({
    required BandRepository bandRepo,
    int count = 6,
  }) async {
    for (int day = 1; day <= count; day++) {
      try {
        await bandRepo.syncHistoricalDay(day);
      } catch (e) {
        debugPrint('⚠️ [SYNC MGR] syncPastDays failed for day $day: $e');
      }
    }
  }

  // ── Debug helper ───────────────────────────────────────────────────────

  void _logStaleness() {
    final staleHr = HealthSyncPolicy.shouldRefreshHeartRate(_lastHeartRateSyncAt);
    final staleHrv = HealthSyncPolicy.shouldRefreshHrv(_lastHrvSyncAt);
    final staleSpo2 = HealthSyncPolicy.shouldRefreshBloodOxygen(_lastSpO2SyncAt);
    final staleStress = HealthSyncPolicy.shouldRefreshStress(_lastStressSyncAt);
    final staleBp = HealthSyncPolicy.shouldRefreshBloodPressure(_lastBloodPressureSyncAt);
    debugPrint(
      '📊 [SYNC MGR] Staleness → HR:$staleHr | HRV:$staleHrv | SpO2:$staleSpo2 | Stress:$staleStress | BP:$staleBp',
    );
  }
}
