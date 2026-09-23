/// Defines synchronization policies and refresh rules for wearable health metrics.
///
/// Ensures BLE traffic and battery consumption are tightly controlled:
/// - Heart Rate updates on Home & Vitals at most once every 5 minutes.
/// - Cold start sync occurs only if no recent sync happened or on calendar change.
/// - Real-time HR is restricted strictly to active training sessions.
class HealthSyncPolicy {
  const HealthSyncPolicy._();

  /// Maximum frequency for Heart Rate checks on Home and Vitals screens.
  static const Duration heartRateRefreshInterval = Duration(minutes: 5);

  /// Threshold beyond which a cold start sync is deemed necessary.
  static const Duration coldStartSyncThreshold = Duration(minutes: 15);

  /// Minimum delay before retrying a failed synchronization.
  static const Duration failedSyncRetryDelay = Duration(minutes: 2);

  /// Checks if Heart Rate on Home or Vitals should be refreshed from the band.
  ///
  /// Returns `true` if never synced, or if [lastSync] is 5+ minutes in the past.
  static bool shouldRefreshHeartRate(DateTime? lastSync) {
    if (lastSync == null) return true;
    return DateTime.now().difference(lastSync) >= heartRateRefreshInterval;
  }

  /// Checks if a cold-start sync should execute upon application launch.
  static bool shouldColdStartSync(DateTime? lastSync) {
    if (lastSync == null) return true;
    final now = DateTime.now();
    // Refresh if past threshold or date boundary crossed
    final hasDayChanged = now.day != lastSync.day || now.month != lastSync.month || now.year != lastSync.year;
    return hasDayChanged || now.difference(lastSync) >= coldStartSyncThreshold;
  }
}
