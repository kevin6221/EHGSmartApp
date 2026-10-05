/// Centralized domain service for calculating heart rate zones, boundaries,
/// and physiological intensity thresholds (WHOOP / Garmin standard).
class HeartRateZoneCalculator {
  final int age;
  final int restingHeartRate;
  final int maxHeartRate;

  HeartRateZoneCalculator({
    this.age = 30,
    this.restingHeartRate = 60,
    int? customMaxHeartRate,
  }) : maxHeartRate = customMaxHeartRate ?? (220 - age).clamp(140, 220);

  /// Heart rate zone definition containing bounds and metadata.
  /// Standard 5-Zone Model (Edwards / Karvonen standard):
  /// - Z1: 50% - 60% Max HR (Recovery / Active Recovery)
  /// - Z2: 60% - 70% Max HR (Aerobic Endurance / Fat Burn)
  /// - Z3: 70% - 80% Max HR (Tempo / Aerobic Power)
  /// - Z4: 80% - 90% Max HR (Threshold / High Intensity)
  /// - Z5: 90% - 100% Max HR (Anaerobic / Peak Effort)
  int calculateZone(int bpm) {
    if (bpm <= 0) return 1;

    final z1Min = (maxHeartRate * 0.50).round();
    final z2Min = (maxHeartRate * 0.60).round();
    final z3Min = (maxHeartRate * 0.70).round();
    final z4Min = (maxHeartRate * 0.80).round();
    final z5Min = (maxHeartRate * 0.90).round();

    if (bpm >= z5Min) return 5;
    if (bpm >= z4Min) return 4;
    if (bpm >= z3Min) return 3;
    if (bpm >= z2Min) return 2;
    if (bpm >= z1Min) return 1;
    return 1;
  }

  /// Returns the BPM range for a given zone index (1 to 5).
  (int minBpm, int maxBpm) getZoneRange(int zone) {
    switch (zone) {
      case 1:
        return ((maxHeartRate * 0.50).round(), (maxHeartRate * 0.60).round() - 1);
      case 2:
        return ((maxHeartRate * 0.60).round(), (maxHeartRate * 0.70).round() - 1);
      case 3:
        return ((maxHeartRate * 0.70).round(), (maxHeartRate * 0.80).round() - 1);
      case 4:
        return ((maxHeartRate * 0.80).round(), (maxHeartRate * 0.90).round() - 1);
      case 5:
      default:
        return ((maxHeartRate * 0.90).round(), maxHeartRate);
    }
  }

  static String zoneName(int zone) {
    switch (zone) {
      case 1:
        return 'Easy';
      case 2:
        return 'Steady';
      case 3:
        return 'Moderate';
      case 4:
        return 'Hard';
      case 5:
      default:
        return 'Peak';
    }
  }

  static String zoneDescription(int zone) {
    switch (zone) {
      case 1:
        return 'Aerobic and sustainable. This is the range that builds an engine without costing you tomorrow.';
      case 2:
        return 'Controlled and comfortable. This is the range that builds endurance without costing you tomorrow.';
      case 3:
        return 'Steady and focused. This is the range that improves your fitness while staying sustainable.';
      case 4:
        return 'Challenging and strong. Use this range for short efforts with enough recovery between them.';
      case 5:
      default:
        return 'High intensity. Keep this range brief and return to an easier zone when you need to recover.';
    }
  }
}
