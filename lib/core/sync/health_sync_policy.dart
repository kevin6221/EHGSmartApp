/// Defines synchronization policies and refresh rules for wearable health metrics.
///
/// All data syncs are **manual-only** (pull-to-refresh). No automatic background
/// polling. The intervals below define the minimum freshness threshold — if a
/// metric was synced within its window it is considered fresh and the pull-to-
/// refresh skip re-fetching it from the band, reducing BLE traffic and battery.
///
/// Reference fetch frequencies (matching QWatch Pro architecture):
/// - Heart Rate      → every 5 minutes
/// - HRV             → every 1 hour
/// - Blood Oxygen    → every 1 hour
/// - Stress          → every 30 minutes
/// - Blood Pressure  → every 2 hours
/// - Full health     → cold start / 15 min threshold
class HealthSyncPolicy {
  const HealthSyncPolicy._();

  // ── Per-vital refresh intervals ────────────────────────────────────────

  /// Heart Rate: considered stale after 5 minutes.
  static const Duration heartRateInterval = Duration(minutes: 5);

  /// HRV: considered stale after 1 hour.
  static const Duration hrvInterval = Duration(hours: 1);

  /// Blood Oxygen (SpO₂): considered stale after 1 hour.
  static const Duration bloodOxygenInterval = Duration(hours: 1);

  /// Stress: considered stale after 30 minutes.
  static const Duration stressInterval = Duration(minutes: 30);

  /// Blood Pressure: considered stale after 2 hours.
  static const Duration bloodPressureInterval = Duration(hours: 2);

  // ── Global sync thresholds ─────────────────────────────────────────────

  /// Threshold beyond which a cold start sync is deemed necessary.
  static const Duration coldStartSyncThreshold = Duration(minutes: 15);

  /// Minimum delay before retrying a failed synchronization.
  static const Duration failedSyncRetryDelay = Duration(minutes: 2);

  // ── Helper: generic freshness check ────────────────────────────────────

  /// Returns `true` if [lastSync] is null or older than [interval].
  static bool isStale(DateTime? lastSync, Duration interval) {
    if (lastSync == null) return true;
    return DateTime.now().difference(lastSync) >= interval;
  }

  /// Returns `true` when Heart Rate should be refreshed from the band.
  static bool shouldRefreshHeartRate(DateTime? lastSync) =>
      isStale(lastSync, heartRateInterval);

  /// Returns `true` when HRV should be refreshed from the band.
  static bool shouldRefreshHrv(DateTime? lastSync) =>
      isStale(lastSync, hrvInterval);

  /// Returns `true` when Blood Oxygen should be refreshed from the band.
  static bool shouldRefreshBloodOxygen(DateTime? lastSync) =>
      isStale(lastSync, bloodOxygenInterval);

  /// Returns `true` when Stress should be refreshed from the band.
  static bool shouldRefreshStress(DateTime? lastSync) =>
      isStale(lastSync, stressInterval);

  /// Returns `true` when Blood Pressure should be refreshed from the band.
  static bool shouldRefreshBloodPressure(DateTime? lastSync) =>
      isStale(lastSync, bloodPressureInterval);

  /// Checks if a cold-start sync should execute upon application launch.
  static bool shouldColdStartSync(DateTime? lastSync) {
    if (lastSync == null) return true;
    final now = DateTime.now();
    // Refresh if past threshold or date boundary crossed
    final hasDayChanged = now.day != lastSync.day ||
        now.month != lastSync.month ||
        now.year != lastSync.year;
    return hasDayChanged || now.difference(lastSync) >= coldStartSyncThreshold;
  }
}
