import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../data/repositories/band_repository.dart';
import '../../data/repositories/wellness_repository.dart';
import '../security/secure_storage_service.dart';
import 'health_sync_policy.dart';

enum HealthSyncStatus { idle, syncing, completed, error }

/// Detailed phase of the synchronization pipeline matching Garmin Connect / WHOOP architecture.
enum HealthSyncPhase {
  idle,
  connecting,
  handshake,
  syncingToday,
  backfillingHistory,
  calculatingScores,
  completed,
  error,
}

/// Immutable snapshot representing current synchronization progress and metadata.
class HealthSyncSnapshot {
  final HealthSyncPhase phase;
  final DateTime? lastSyncedAt;
  final String? lastError;
  final String statusMessage;

  const HealthSyncSnapshot({
    this.phase = HealthSyncPhase.idle,
    this.lastSyncedAt,
    this.lastError,
    this.statusMessage = '',
  });

  bool get isSyncing =>
      phase == HealthSyncPhase.connecting ||
      phase == HealthSyncPhase.handshake ||
      phase == HealthSyncPhase.syncingToday ||
      phase == HealthSyncPhase.backfillingHistory ||
      phase == HealthSyncPhase.calculatingScores;

  bool get isCompleted => phase == HealthSyncPhase.completed;
  bool get hasError => phase == HealthSyncPhase.error;

  String get formattedSyncTime {
    if (lastSyncedAt == null) return 'Never synced';
    final now = DateTime.now();
    final diff = now.difference(lastSyncedAt!);
    if (diff.inSeconds < 45) return 'Synced just now';
    if (diff.inMinutes < 60) return 'Synced ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Synced ${diff.inHours}h ago';
    return 'Synced ${DateFormat('MMM d, h:mm a').format(lastSyncedAt!)}';
  }

  HealthSyncSnapshot copyWith({
    HealthSyncPhase? phase,
    DateTime? lastSyncedAt,
    String? lastError,
    String? statusMessage,
    bool clearError = false,
  }) {
    return HealthSyncSnapshot(
      phase: phase ?? this.phase,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastError: clearError ? null : (lastError ?? this.lastError),
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}

/// Production-grade synchronization coordinator for wearable health data.
///
/// Implements a multi-stage sync pipeline (matching WHOOP, Garmin Connect, and QWatch Pro):
///   1. **Handshake Phase**: Verify BLE link, synchronize band RTC time, refresh battery & device info.
///   2. **Today (Day 0) Phase**: Fetch comprehensive vitals, steps, sleep, and PPG records from band.
///   3. **Historical Backfill Phase**: Backfill missing days (yesterday & day 2) to eliminate chart gaps.
///   4. **Persistence & Recalculate Phase**: Await Drift SQLite writes, compute rolling baseline, reload weekly arrays.
///   5. **Reactive Propagation**: Update all listening BLoCs and UI widgets reactively via [snapshot].
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
  Timer? _idleResetTimer;

  final ValueNotifier<HealthSyncSnapshot> _snapshotNotifier =
      ValueNotifier<HealthSyncSnapshot>(const HealthSyncSnapshot());

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

  /// Reactive listenable for UI widgets to observe sync progress without setState.
  ValueListenable<HealthSyncSnapshot> get snapshot => _snapshotNotifier;

  void _updateSnapshot({
    required HealthSyncPhase phase,
    String? statusMessage,
    String? lastError,
    bool clearError = false,
  }) {
    _snapshotNotifier.value = _snapshotNotifier.value.copyWith(
      phase: phase,
      statusMessage: statusMessage,
      lastError: lastError,
      clearError: clearError,
      lastSyncedAt: _lastFullSyncAt,
    );
  }

  // ── Timestamp persistence ──────────────────────────────────────────────

  Future<void> _loadStoredTimestamps() async {
    try {
      _lastFullSyncAt = await _readTimestamp(_keyLastFullSync);
      _lastHeartRateSyncAt = await _readTimestamp(_keyLastHrSync);
      _lastHrvSyncAt = await _readTimestamp(_keyLastHrvSync);
      _lastSpO2SyncAt = await _readTimestamp(_keyLastSpO2Sync);
      _lastStressSyncAt = await _readTimestamp(_keyLastStressSync);
      _lastBloodPressureSyncAt = await _readTimestamp(_keyLastBpSync);

      _snapshotNotifier.value = HealthSyncSnapshot(
        phase: HealthSyncPhase.idle,
        lastSyncedAt: _lastFullSyncAt,
      );
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

  // ── Cold-start & resume sync ───────────────────────────────────────────

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

  // ── Multi-stage synchronization pipeline ───────────────────────────────

  /// Performs a controlled, deduplicated synchronization of health data.
  ///
  /// Orchestrates all 5 stages of synchronization:
  /// 1. Connection check & Time Synchronization handshake
  /// 2. Day 0 (Today) complete health data fetch & SQLite persistence
  /// 3. Backfilling missing historical days (Day 1 / yesterday)
  /// 4. WellnessRepository metrics reload from SQLite
  /// 5. Recalibration of baseline scores & reactive UI notification
  Future<bool> performManualSync({
    required BandRepository bandRepo,
    required WellnessRepository wellnessRepo,
    bool isColdStart = false,
    bool force = false,
  }) async {
    // 1. Deduplicate concurrent sync requests
    if (_ongoingSync != null) {
      debugPrint(
          'ℹ️ [SYNC MGR] Sync already in flight, joining ongoing operation...');
      return _ongoingSync!;
    }

    // 2. Debounce if recently synced (< 5 seconds) and not forced
    if (!force && _lastFullSyncAt != null) {
      final elapsed = DateTime.now().difference(_lastFullSyncAt!);
      if (elapsed < const Duration(seconds: 5)) {
        debugPrint(
            'ℹ️ [SYNC MGR] Sync skipped: completed ${elapsed.inSeconds}s ago.');
        return true;
      }
    }

    _status = HealthSyncStatus.syncing;
    _idleResetTimer?.cancel();

    _ongoingSync = () async {
      try {
        debugPrint(
            '🔄 [SYNC MGR] Starting synchronized health pipeline (coldStart=$isColdStart, force=$force)...');
        _logStaleness();

        // ── Phase 1: Connection & Time Handshake ────────────────────────
        _updateSnapshot(
          phase: HealthSyncPhase.handshake,
          statusMessage: 'Syncing device time and battery...',
          clearError: true,
        );

        if (!bandRepo.isConnected && bandRepo.boundDevice != null) {
          _updateSnapshot(
            phase: HealthSyncPhase.connecting,
            statusMessage: 'Reconnecting to band...',
          );
          final reconnected = await bandRepo.reconnect();
          if (!reconnected && !bandRepo.isConnected) {
            throw Exception('Smart band is not connected. Please check Bluetooth.');
          }
        }

        // Send time sync to band RTC so timestamp records match phone clock
        try {
          await bandRepo.service.syncTime().timeout(
            const Duration(seconds: 3),
            onTimeout: () => false,
          );
        } catch (_) {}

        // ── Phase 2: Today (Day 0) Complete Sync ────────────────────────
        _updateSnapshot(
          phase: HealthSyncPhase.syncingToday,
          statusMessage: 'Reading health vitals from band...',
        );

        final vitals = await bandRepo.syncFullHealthData();

        // ── Phase 3: Historical Backfill (Yesterday / Day 1) ─────────────
        _updateSnapshot(
          phase: HealthSyncPhase.backfillingHistory,
          statusMessage: 'Syncing weekly trends...',
        );

        // Fetch yesterday's finalized records (dayIndex: 1) ONLY if band was paired before today.
        // For a brand new band out of the box, yesterday's flash memory contains factory QA test data.
        final devMac = await _secureStorage.getBondedDeviceMac() ?? 'default_band';
        final pairingDate = await _secureStorage.getDevicePairingDate(devMac);
        final todayStr = DateTime.now().toIso8601String().substring(0, 10);

        if (pairingDate != null && pairingDate.compareTo(todayStr) < 0) {
          try {
            await bandRepo.syncHistoricalDay(1).timeout(
              const Duration(seconds: 8),
              onTimeout: () => vitals,
            );
          } catch (e) {
            debugPrint('ℹ️ [SYNC MGR] Historical day 1 backfill skipped: $e');
          }
        } else {
          debugPrint('🛡️ [SYNC MGR] Fresh pairing detected ($pairingDate). Suppressing day 1 backfill to prevent factory test data ingestion.');
        }

        // ── Phase 4: Compute Wellness & Reload DB ───────────────────────
        _updateSnapshot(
          phase: HealthSyncPhase.calculatingScores,
          statusMessage: 'Calculating wellness scores...',
        );

        wellnessRepo.updateFromBandVitals(vitals, updateMode: true);
        await wellnessRepo.reloadWeeklyDataFromDatabase();
        await _recordFullSyncSuccess();

        // ── Phase 5: Completed ─────────────────────────────────────────
        _updateSnapshot(
          phase: HealthSyncPhase.completed,
          statusMessage: 'Sync completed successfully',
          clearError: true,
        );

        debugPrint(
            '✅ [SYNC MGR] Full synchronization pipeline completed successfully at $_lastFullSyncAt');

        // Gracefully reset snapshot phase to idle after brief completion notice
        _idleResetTimer = Timer(const Duration(seconds: 2), () {
          _updateSnapshot(
            phase: HealthSyncPhase.idle,
            statusMessage: '',
          );
        });

        return true;
      } catch (e) {
        _status = HealthSyncStatus.error;
        _lastError = e.toString();
        debugPrint('⚠️ [SYNC MGR] Health sync pipeline failed: $e');

        _updateSnapshot(
          phase: HealthSyncPhase.error,
          lastError: e.toString(),
          statusMessage: 'Sync failed: $e',
        );

        _idleResetTimer = Timer(const Duration(seconds: 4), () {
          _updateSnapshot(
            phase: HealthSyncPhase.idle,
            statusMessage: '',
          );
        });

        return false;
      } finally {
        _status = HealthSyncStatus.idle;
        _ongoingSync = null;
      }
    }();

    return _ongoingSync!;
  }

  // ── On-demand HR sample (used for quick check) ─────────────────────────

  /// Fetches latest HR sample if stale per 5-minute policy.
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

  // ── Cleanup ────────────────────────────────────────────────────────────

  void dispose() {
    _idleResetTimer?.cancel();
    _snapshotNotifier.dispose();
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
