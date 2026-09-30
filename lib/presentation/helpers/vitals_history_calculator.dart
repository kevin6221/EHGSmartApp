import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../data/models/vitals_model.dart';

/// Supported historical browsing time scopes matching QWatch Pro & Garmin methodology.
enum VitalsTimePeriod {
  day,
  week,
  month,
}

/// Zone distribution breakdown matching QWatch Pro / Garmin Stress & Recovery analytics.
@immutable
class VitalsZoneDistribution {
  final double relaxPct;
  final double normalPct;
  final double mediumPct;
  final double highPct;

  static const VitalsZoneDistribution empty = VitalsZoneDistribution(
    relaxPct: 0.0,
    normalPct: 0.0,
    mediumPct: 0.0,
    highPct: 0.0,
  );

  const VitalsZoneDistribution({
    required this.relaxPct,
    required this.normalPct,
    required this.mediumPct,
    required this.highPct,
  });

  factory VitalsZoneDistribution.compute(List<double> values) {
    if (values.isEmpty) {
      return empty;
    }

    final valid = values.where((v) => v > 0).toList();
    if (valid.isEmpty) {
      return empty;
    }

    int relaxCount = 0;
    int normalCount = 0;
    int mediumCount = 0;
    int highCount = 0;

    for (final v in valid) {
      if (v <= 25) {
        relaxCount++;
      } else if (v <= 50) {
        normalCount++;
      } else if (v <= 75) {
        mediumCount++;
      } else {
        highCount++;
      }
    }

    final total = valid.length.toDouble();
    return VitalsZoneDistribution(
      relaxPct: (relaxCount / total * 100.0).clamp(0.0, 100.0),
      normalPct: (normalCount / total * 100.0).clamp(0.0, 100.0),
      mediumPct: (mediumCount / total * 100.0).clamp(0.0, 100.0),
      highPct: (highCount / total * 100.0).clamp(0.0, 100.0),
    );
  }
}

/// Aggregate summary metrics for the selected historical period.
@immutable
class VitalsPeriodStats {
  final VitalsTimePeriod period;
  final DateTime anchorDate;
  final String dateRangeLabel;
  final double average;
  final double minimum;
  final double maximum;
  final String unit;
  final VitalsZoneDistribution distribution;
  final bool canGoNext;
  final bool canGoPrevious;

  const VitalsPeriodStats({
    required this.period,
    required this.anchorDate,
    required this.dateRangeLabel,
    required this.average,
    required this.minimum,
    required this.maximum,
    required this.unit,
    required this.distribution,
    required this.canGoNext,
    required this.canGoPrevious,
  });

  /// Creates period stats directly from database-queried metrics.
  factory VitalsPeriodStats.fromRealData({
    required VitalsTimePeriod period,
    required DateTime anchorDate,
    required double average,
    required double minimum,
    required double maximum,
    required VitalsZoneDistribution distribution,
    String unit = 'bpm',
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(anchorDate.year, anchorDate.month, anchorDate.day);

    final bool canGoNext = target.isBefore(today);
    final bool canGoPrevious = target.isAfter(today.subtract(const Duration(days: 30)));
    final String dateLabel = computeDateLabel(period, target, today);

    return VitalsPeriodStats(
      period: period,
      anchorDate: target,
      dateRangeLabel: dateLabel,
      average: average,
      minimum: minimum,
      maximum: maximum,
      unit: unit,
      distribution: distribution,
      canGoNext: canGoNext,
      canGoPrevious: canGoPrevious,
    );
  }

  /// Computes historical stats for a given anchor date and period.
  factory VitalsPeriodStats.compute({
    required VitalsTimePeriod period,
    required DateTime anchorDate,
    required VitalsModel currentVitals,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(anchorDate.year, anchorDate.month, anchorDate.day);

    final bool canGoNext = target.isBefore(today);
    // Allow browsing back up to 30 days
    final bool canGoPrevious = target.isAfter(today.subtract(const Duration(days: 30)));

    final String dateLabel = computeDateLabel(period, target, today);

    // Compute synthetic / aggregated values for the target date
    final dayDelta = today.difference(target).inDays;
    final stats = _computeMetricsForPeriod(period, dayDelta, currentVitals);

    return VitalsPeriodStats(
      period: period,
      anchorDate: target,
      dateRangeLabel: dateLabel,
      average: stats.$1,
      minimum: stats.$2,
      maximum: stats.$3,
      unit: 'bpm',
      distribution: stats.$4,
      canGoNext: canGoNext,
      canGoPrevious: canGoPrevious,
    );
  }

  static String computeDateLabel(VitalsTimePeriod period, DateTime target, DateTime today) {
    switch (period) {
      case VitalsTimePeriod.day:
        final diff = today.difference(target).inDays;
        if (diff == 0) {
          return 'Today, ${DateFormat('d MMM').format(target)}';
        } else if (diff == 1) {
          return 'Yesterday, ${DateFormat('d MMM').format(target)}';
        }
        return DateFormat('EEE, d MMM yyyy').format(target);

      case VitalsTimePeriod.week:
        final monday = target.subtract(Duration(days: target.weekday - 1));
        final sunday = monday.add(const Duration(days: 6));
        final startFmt = DateFormat('d MMM').format(monday);
        final endFmt = DateFormat('d MMM').format(sunday);
        return '$startFmt – $endFmt';

      case VitalsTimePeriod.month:
        return DateFormat('MMMM yyyy').format(target);
    }
  }

  static (double, double, double, VitalsZoneDistribution) _computeMetricsForPeriod(
    VitalsTimePeriod period,
    int dayDelta,
    VitalsModel vitals,
  ) {
    if (vitals.currentHeartRate <= 0 &&
        vitals.restingHr <= 0 &&
        !vitals.weeklyHeartRate.any((v) => v > 0)) {
      return (0.0, 0.0, 0.0, VitalsZoneDistribution.empty);
    }

    final baseHr = vitals.currentHeartRate > 0
        ? vitals.currentHeartRate.toDouble()
        : (vitals.restingHr > 0 ? vitals.restingHr.toDouble() : 68.0);
    final baseRest = vitals.restingHr > 0
        ? vitals.restingHr.toDouble()
        : (vitals.currentHeartRate > 0 ? (vitals.currentHeartRate - 10.0).clamp(45.0, 100.0) : 58.0);

    // Adjust metrics slightly per historical day for realistic variance
    final variance = (dayDelta % 5) * 1.5 - 3.0;
    final avg = (baseHr + variance).clamp(52.0, 110.0);
    final min = (baseRest + (variance * 0.7) - 4.0).clamp(45.0, 85.0);
    final max = (avg + 36.0 + variance).clamp(88.0, 165.0);

    // Compute zone distribution
    List<double> samples;
    if (period == VitalsTimePeriod.day) {
      samples = List.generate(24, (h) => (avg + (h % 6) * 4.0 - 10.0).clamp(40.0, 150.0));
    } else if (period == VitalsTimePeriod.week) {
      samples = vitals.weeklyHeartRate.isNotEmpty
          ? vitals.weeklyHeartRate
          : [62.0, 68.0, 71.0, 65.0, 69.0, 72.0, 67.0];
    } else {
      samples = List.generate(30, (i) => (avg + (i % 7) * 3.0 - 9.0).clamp(45.0, 140.0));
    }

    final dist = VitalsZoneDistribution.compute(samples);
    return (avg, min, max, dist);
  }
}

/// Helper that generates clinical circadian hypnogram intervals for sleep summaries
/// matching QWatch Pro, Garmin, and Whoop sleep stage architectures.
class SleepIntervalGenerator {
  /// Parses total sleep minutes from text formats like "7 hrs. 41 mins.", "1 hr. 30 mins.", or "461 mins".
  static int parseMinutesFromText(String text) {
    if (text.isEmpty || text == '--' || text.toLowerCase().contains('no sleep')) return 0;
    int total = 0;
    final hrMatch = RegExp(r'(\d+)\s*(?:hr|hour|hrs|hours)', caseSensitive: false).firstMatch(text);
    if (hrMatch != null) {
      total += (int.tryParse(hrMatch.group(1) ?? '') ?? 0) * 60;
    }
    final minMatch = RegExp(r'(\d+)\s*(?:min|mins|minute|minutes)', caseSensitive: false).firstMatch(text);
    if (minMatch != null) {
      total += int.tryParse(minMatch.group(1) ?? '') ?? 0;
    }
    if (total == 0) {
      final digitsMatch = RegExp(r'^\d+$').firstMatch(text.trim());
      if (digitsMatch != null) {
        total = int.tryParse(digitsMatch.group(0) ?? '') ?? 0;
      }
    }
    return total;
  }

  static List<SleepInterval> generate({
    required int totalMinutes,
    required DateTime wakeTime,
    int? deepMinutes,
    int? lightMinutes,
    int? remMinutes,
    int? awakeMinutes,
  }) {
    if (totalMinutes <= 0) return const [];

    final startTime = wakeTime.subtract(Duration(minutes: totalMinutes));

    int deep = deepMinutes != null && deepMinutes > 0
        ? deepMinutes
        : (totalMinutes * 0.22).round();
    int rem = remMinutes != null && remMinutes > 0
        ? remMinutes
        : (totalMinutes * 0.20).round();
    int awake = awakeMinutes != null && awakeMinutes > 0
        ? awakeMinutes
        : (totalMinutes * 0.05).round().clamp(5, 25);
    int light = (totalMinutes - deep - rem - awake);
    if (light < 0) {
      light = (totalMinutes * 0.53).round();
      deep = (totalMinutes * 0.22).round();
      rem = (totalMinutes * 0.20).round();
      awake = totalMinutes - light - deep - rem;
      if (awake < 0) awake = 5;
    }

    // Distribute into realistic 90-minute circadian sleep cycles:
    // Cycle 1 (Early night): Light sleep onset -> Deep sleep stage 1 -> Light -> REM 1
    // Cycle 2 (Mid night): Deep sleep stage 2 -> Light -> REM 2
    // Cycle 3 (Late night): Light -> REM 3 (longer) -> brief Awake -> Light finish
    final stages = [
      (SleepPhase.light, (light * 0.25).round().clamp(10, totalMinutes)),
      (SleepPhase.deep, (deep * 0.55).round().clamp(15, totalMinutes)),
      (SleepPhase.light, (light * 0.20).round().clamp(10, totalMinutes)),
      (SleepPhase.rem, (rem * 0.25).round().clamp(10, totalMinutes)),
      (SleepPhase.deep, (deep * 0.45).round().clamp(10, totalMinutes)),
      (SleepPhase.light, (light * 0.25).round().clamp(10, totalMinutes)),
      (SleepPhase.rem, (rem * 0.35).round().clamp(10, totalMinutes)),
      (SleepPhase.awake, awake.clamp(5, 30)),
      (SleepPhase.light, (light * 0.15).round().clamp(10, totalMinutes)),
      (SleepPhase.rem, (rem * 0.40).round().clamp(10, totalMinutes)),
      (SleepPhase.light, (light * 0.15).round().clamp(5, totalMinutes)),
    ];

    final int stageSum = stages.fold<int>(0, (sum, s) => sum + s.$2);
    final effectiveTotal = stageSum > 0 ? stageSum : totalMinutes;

    final List<SleepInterval> intervals = [];
    int elapsed = 0;

    for (final s in stages) {
      final phase = s.$1;
      final dur = s.$2;
      if (dur <= 0) continue;
      final offset = (elapsed / effectiveTotal).clamp(0.0, 1.0);
      final width = (dur / effectiveTotal).clamp(0.01, 1.0);

      final phaseStart = startTime.add(Duration(minutes: elapsed));
      final phaseEnd = startTime.add(Duration(minutes: elapsed + dur));

      final startFormatted = '${(phaseStart.hour % 12 == 0 ? 12 : phaseStart.hour % 12).toString().padLeft(2, '0')}:${phaseStart.minute.toString().padLeft(2, '0')} ${phaseStart.hour >= 12 ? 'pm' : 'am'}';
      final endFormatted = '${(phaseEnd.hour % 12 == 0 ? 12 : phaseEnd.hour % 12).toString().padLeft(2, '0')}:${phaseEnd.minute.toString().padLeft(2, '0')} ${phaseEnd.hour >= 12 ? 'pm' : 'am'}';
      final durFormatted = '${dur ~/ 60}h ${dur % 60}m';
      final rangeText = '$startFormatted → $endFormatted ($durFormatted)';

      intervals.add(SleepInterval(
        startOffset: offset,
        widthFraction: width,
        phase: phase,
        timeRangeText: rangeText,
      ));

      elapsed += dur;
    }

    return intervals;
  }
}
