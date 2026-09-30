import 'dart:math' as math;
import 'package:flutter/foundation.dart';

/// Baseline category for individual health metrics.
enum MetricBaselineStatus {
  low,
  normal,
  high,
  unrecorded,
}

/// Data class representing an actionable, contextual recommendation
/// for health vitals cards.
@immutable
class MetricRecommendation {
  final String status;
  final MetricBaselineStatus baselineStatus;
  final String whatItIs;
  final String yourReading;
  final String doThis;
  final double? baseline;

  const MetricRecommendation({
    required this.status,
    this.baselineStatus = MetricBaselineStatus.normal,
    required this.whatItIs,
    required this.yourReading,
    required this.doThis,
    this.baseline,
  });
}

/// Dynamic Health & Wellness Recommendation Engine.
///
/// Converts real-time and historical biometric signals (HRV, Resting HR,
/// SpO2, Respiratory Rate, Blood Pressure) into contextual, clinically-sound,
/// sports-science validated guidance matching the prototype specifications.
///
/// Baseline Status Decision:
/// A reading counts as "normal" if it is within about 4% of the person's own
/// 30-day baseline (minimum 0.5 units). Above that range = "high", below = "low".
class RecommendationEngine {
  const RecommendationEngine._();

  /// Resolves the 30-day personal baseline from explicit baseline or historical records,
  /// falling back to clinical default when historical samples are unavailable.
  static double resolveBaseline({
    double? baseline,
    List<double>? history,
    required double fallbackDefault,
  }) {
    if (baseline != null && baseline > 0) {
      return baseline;
    }
    if (history != null && history.isNotEmpty) {
      final valid = history.where((v) => v > 0).toList();
      if (valid.isNotEmpty) {
        return valid.reduce((a, b) => a + b) / valid.length;
      }
    }
    return fallbackDefault;
  }

  /// Evaluates a reading against a person's baseline:
  /// A reading counts as "normal" if it's within about 4% of the person's own
  /// 30-day baseline (minimum 0.5 units). Above that range = "high," below = "low."
  static MetricBaselineStatus evaluateAgainstBaseline({
    required double reading,
    required double baseline,
  }) {
    final double delta = math.max(baseline * 0.04, 0.5);
    final double lowerBound = baseline - delta;
    final double upperBound = baseline + delta;

    if (reading < lowerBound) {
      return MetricBaselineStatus.low;
    } else if (reading > upperBound) {
      return MetricBaselineStatus.high;
    } else {
      return MetricBaselineStatus.normal;
    }
  }

  /// Computes dynamic advice and reading assessment for Heart Rate Variability (HRV).
  ///
  /// Reference content from prototype:
  /// • Low: "Below your 30-day average. Something is still costing you - short sleep,
  ///   hard training, alcohol, or stress that hasn't cleared." → Do: "Keep today easy and aerobic. Push tomorrow instead."
  /// • Normal: "Sitting in your usual range. Your body has absorbed the last few days." → Do: "Train as planned."
  /// • High: "Above your average. This is the clearest green light the band gives for
  ///   hard work." → Do: "Take the harder session while it's on offer."
  static MetricRecommendation getHrvRecommendation(
    int hrvMs, [
    List<double>? weeklyHrv,
    double? baselineHrv,
  ]) {
    const whatItIs =
        'The variation in time between consecutive heartbeats. Higher variability reflects a responsive, adaptable autonomic nervous system that transitions effortlessly between strain and recovery.';

    if (hrvMs <= 0) {
      return const MetricRecommendation(
        status: '--',
        baselineStatus: MetricBaselineStatus.unrecorded,
        whatItIs: whatItIs,
        yourReading:
            'No HRV reading recorded yet today. Wear your band during sleep to capture your autonomic baseline.',
        doThis:
            'Wear your band snugly overnight and sync in the morning to establish your personal HRV range.',
      );
    }

    final double baseline = resolveBaseline(
      baseline: baselineHrv,
      history: weeklyHrv,
      fallbackDefault: 65.0,
    );

    final status = evaluateAgainstBaseline(
      reading: hrvMs.toDouble(),
      baseline: baseline,
    );

    switch (status) {
      case MetricBaselineStatus.low:
        return MetricRecommendation(
          status: 'Below average',
          baselineStatus: MetricBaselineStatus.low,
          baseline: baseline,
          whatItIs: whatItIs,
          yourReading:
              'Below your 30-day average. Something is still costing you - short sleep, hard training, alcohol, or stress that hasn\'t cleared.',
          doThis: 'Keep today easy and aerobic. Push tomorrow instead.',
        );
      case MetricBaselineStatus.high:
        return MetricRecommendation(
          status: 'Above average',
          baselineStatus: MetricBaselineStatus.high,
          baseline: baseline,
          whatItIs: whatItIs,
          yourReading:
              'Above your average. This is the clearest green light the band gives for hard work.',
          doThis: 'Take the harder session while it\'s on offer.',
        );
      case MetricBaselineStatus.normal:
      case MetricBaselineStatus.unrecorded:
        return MetricRecommendation(
          status: 'Normal',
          baselineStatus: MetricBaselineStatus.normal,
          baseline: baseline,
          whatItIs: whatItIs,
          yourReading:
              'Sitting in your usual range. Your body has absorbed the last few days.',
          doThis: 'Train as planned.',
        );
    }
  }

  /// Computes dynamic advice for Resting Heart Rate (RHR).
  ///
  /// Reference content from prototype:
  /// • Low: "Lower than your average - a sign of good aerobic fitness and a wellrecovered night."
  ///   → Do: "Nothing needed. Keep the routine that got you here."
  /// • Normal: "Steady against your average." → Do: "Nothing needed."
  /// • High: "Above your average. Late food, alcohol, a warm room or an early illness all raise it."
  ///   → Do: "Check the basics first: dinner time, hydration, room temperature."
  static MetricRecommendation getRestingHrRecommendation(
    int restingHr, [
    List<double>? weeklyRestingHr,
    double? baselineRestingHr,
  ]) {
    const whatItIs =
        'Your heart rate when completely at rest, measured during deep sleep or quiet wakefulness. A lower resting heart rate indicates stronger cardiovascular efficiency.';

    if (restingHr <= 0) {
      return const MetricRecommendation(
        status: '--',
        baselineStatus: MetricBaselineStatus.unrecorded,
        whatItIs: whatItIs,
        yourReading:
            'No resting heart rate recorded yet today. Wear your band during sleep to track baseline readings.',
        doThis:
            'Keep your band on overnight to allow nocturnal baseline measurements.',
      );
    }

    final double baseline = resolveBaseline(
      baseline: baselineRestingHr,
      history: weeklyRestingHr,
      fallbackDefault: 60.0,
    );

    final status = evaluateAgainstBaseline(
      reading: restingHr.toDouble(),
      baseline: baseline,
    );

    switch (status) {
      case MetricBaselineStatus.low:
        return MetricRecommendation(
          status: 'Below average',
          baselineStatus: MetricBaselineStatus.low,
          baseline: baseline,
          whatItIs: whatItIs,
          yourReading:
              'Lower than your average - a sign of good aerobic fitness and a wellrecovered night.',
          doThis: 'Nothing needed. Keep the routine that got you here.',
        );
      case MetricBaselineStatus.high:
        return MetricRecommendation(
          status: 'Above average',
          baselineStatus: MetricBaselineStatus.high,
          baseline: baseline,
          whatItIs: whatItIs,
          yourReading:
              'Above your average. Late food, alcohol, a warm room or an early illness all raise it.',
          doThis:
              'Check the basics first: dinner time, hydration, room temperature.',
        );
      case MetricBaselineStatus.normal:
      case MetricBaselineStatus.unrecorded:
        return MetricRecommendation(
          status: 'Steady',
          baselineStatus: MetricBaselineStatus.normal,
          baseline: baseline,
          whatItIs: whatItIs,
          yourReading: 'Steady against your average.',
          doThis: 'Nothing needed.',
        );
    }
  }

  /// Computes dynamic advice for Blood Oxygen Saturation (SpO2).
  ///
  /// Reference content from prototype:
  /// • Low: "Slightly under your average. One night on its own means little."
  ///   → Do: "Watch it across the week. If it keeps dropping, mention it to your GP."
  /// • Normal: "A normal overnight range." → Do: "Nothing needed."
  /// • High: "Comfortably normal." → Do: "Nothing needed."
  static MetricRecommendation getBloodOxygenRecommendation(
    int spo2, [
    List<double>? weeklyOxygen,
    double? baselineOxygen,
  ]) {
    const whatItIs =
        'The percentage of oxygen your red blood cells carry from your lungs to the rest of your body. Normal levels range from 95% to 100%.';

    if (spo2 <= 0) {
      return const MetricRecommendation(
        status: '--',
        baselineStatus: MetricBaselineStatus.unrecorded,
        whatItIs: whatItIs,
        yourReading:
            'No blood oxygen data recorded yet. Sync your band or trigger a measurement to view saturation levels.',
        doThis:
            'Ensure the band is positioned one finger width above your wrist bone for accurate optical readings.',
      );
    }

    final double baseline = resolveBaseline(
      baseline: baselineOxygen,
      history: weeklyOxygen,
      fallbackDefault: 98.0,
    );

    final status = evaluateAgainstBaseline(
      reading: spo2.toDouble(),
      baseline: baseline,
    );

    switch (status) {
      case MetricBaselineStatus.low:
        return MetricRecommendation(
          status: 'Under average',
          baselineStatus: MetricBaselineStatus.low,
          baseline: baseline,
          whatItIs: whatItIs,
          yourReading:
              'Slightly under your average. One night on its own means little.',
          doThis:
              'Watch it across the week. If it keeps dropping, mention it to your GP.',
        );
      case MetricBaselineStatus.high:
        return MetricRecommendation(
          status: 'Comfortably normal',
          baselineStatus: MetricBaselineStatus.high,
          baseline: baseline,
          whatItIs: whatItIs,
          yourReading: 'Comfortably normal.',
          doThis: 'Nothing needed.',
        );
      case MetricBaselineStatus.normal:
      case MetricBaselineStatus.unrecorded:
        return MetricRecommendation(
          status: 'Normal',
          baselineStatus: MetricBaselineStatus.normal,
          baseline: baseline,
          whatItIs: whatItIs,
          yourReading: 'A normal overnight range.',
          doThis: 'Nothing needed.',
        );
    }
  }

  /// Computes dynamic advice for Stress Load (/100).
  ///
  /// Reference content from prototype:
  /// • Low: "A calm day by your standards." → Do: "Good day to train."
  /// • Normal: "An ordinary day's load." → Do: "A short breathing session still helps."
  /// • High: "Elevated. Your body spent longer than usual in a stress response today."
  ///   → Do: "Five minutes of box breathing measurably drops this. Mind system, first card."
  static MetricRecommendation getStressRecommendation(
    int score, [
    List<double>? stressTimeline,
    double? baselineStress,
  ]) {
    const whatItIs =
        'Calculated from micro-fluctuations in heart rate intervals (autonomic balance). Lower scores signify parasympathetic recovery; higher scores indicate sympathetic arousal or cumulative systemic strain.';

    if (score <= 0) {
      return const MetricRecommendation(
        status: '--',
        baselineStatus: MetricBaselineStatus.unrecorded,
        whatItIs: whatItIs,
        yourReading:
            'No stress assessment recorded yet today. Wear your band throughout the day to track stress variations.',
        doThis:
            'Wear your band continuously to establish your baseline stress curve across active and quiet hours.',
      );
    }

    final double baseline = resolveBaseline(
      baseline: baselineStress,
      history: stressTimeline,
      fallbackDefault: 38.0,
    );

    final status = evaluateAgainstBaseline(
      reading: score.toDouble(),
      baseline: baseline,
    );

    switch (status) {
      case MetricBaselineStatus.low:
        return MetricRecommendation(
          status: 'Calm',
          baselineStatus: MetricBaselineStatus.low,
          baseline: baseline,
          whatItIs: whatItIs,
          yourReading: 'A calm day by your standards.',
          doThis: 'Good day to train.',
        );
      case MetricBaselineStatus.high:
        return MetricRecommendation(
          status: 'Elevated',
          baselineStatus: MetricBaselineStatus.high,
          baseline: baseline,
          whatItIs: whatItIs,
          yourReading:
              'Elevated. Your body spent longer than usual in a stress response today.',
          doThis:
              'Five minutes of box breathing measurably drops this. Mind system, first card.',
        );
      case MetricBaselineStatus.normal:
      case MetricBaselineStatus.unrecorded:
        return MetricRecommendation(
          status: 'Normal',
          baselineStatus: MetricBaselineStatus.normal,
          baseline: baseline,
          whatItIs: whatItIs,
          yourReading: 'An ordinary day\'s load.',
          doThis: 'A short breathing session still helps.',
        );
    }
  }

  /// Computes dynamic advice for Breathing Rate (/min).
  ///
  /// Reference content from prototype:
  /// • Low: "Below average - usually a deeply rested night." → Do: "Nothing needed."
  /// • Normal: "Your normal overnight rhythm." → Do: "Nothing needed."
  /// • High: "Up on your average. Often the first sign of a cold, a late drink, or a warm room."
  ///   → Do: "Treat today as a lighter day and watch tomorrow's reading."
  static MetricRecommendation getBreathingRateRecommendation(
    double rate, [
    List<double>? weeklyBreathing,
    double? baselineBreathing,
  ]) {
    const whatItIs =
        'The number of breaths you take per minute during sleep. A steady, baseline breathing rate indicates undisturbed sleep and good respiratory efficiency.';

    if (rate <= 0) {
      return const MetricRecommendation(
        status: '--',
        baselineStatus: MetricBaselineStatus.unrecorded,
        whatItIs: whatItIs,
        yourReading:
            'No nocturnal respiratory data available yet. Wear your band during sleep to calculate breathing stability.',
        doThis:
            'Keep your band fastened during overnight sleep to measure your nocturnal respiration.',
      );
    }

    final double baseline = resolveBaseline(
      baseline: baselineBreathing,
      history: weeklyBreathing,
      fallbackDefault: 14.5,
    );

    final status = evaluateAgainstBaseline(
      reading: rate,
      baseline: baseline,
    );

    switch (status) {
      case MetricBaselineStatus.low:
        return MetricRecommendation(
          status: 'Below average',
          baselineStatus: MetricBaselineStatus.low,
          baseline: baseline,
          whatItIs: whatItIs,
          yourReading: 'Below average - usually a deeply rested night.',
          doThis: 'Nothing needed.',
        );
      case MetricBaselineStatus.high:
        return MetricRecommendation(
          status: 'Above average',
          baselineStatus: MetricBaselineStatus.high,
          baseline: baseline,
          whatItIs: whatItIs,
          yourReading:
              'Up on your average. Often the first sign of a cold, a late drink, or a warm room.',
          doThis:
              'Treat today as a lighter day and watch tomorrow\'s reading.',
        );
      case MetricBaselineStatus.normal:
      case MetricBaselineStatus.unrecorded:
        return MetricRecommendation(
          status: 'Normal',
          baselineStatus: MetricBaselineStatus.normal,
          baseline: baseline,
          whatItIs: whatItIs,
          yourReading: 'Your normal overnight rhythm.',
          doThis: 'Nothing needed.',
        );
    }
  }

  /// Computes dynamic advice for daytime Heart Rate.
  static MetricRecommendation getHeartRateRecommendation(
    int hr, [
    List<double>? weeklyHr,
    double? baselineHr,
  ]) {
    const whatItIs =
        'The frequency of heart contractions per minute responding to metabolic demand and autonomic tone. At rest or during daily activity, a stable rhythm reflects cardiovascular efficiency.';

    if (hr <= 0) {
      return const MetricRecommendation(
        status: '--',
        baselineStatus: MetricBaselineStatus.unrecorded,
        whatItIs: whatItIs,
        yourReading:
            'No heart rate recorded yet today. Sync your band or take a live reading on the spot.',
        doThis:
            'Keep your band worn snugly one finger width above your wrist bone to ensure continuous optical capture.',
      );
    }

    final double baseline = resolveBaseline(
      baseline: baselineHr,
      history: weeklyHr,
      fallbackDefault: 72.0,
    );

    final status = evaluateAgainstBaseline(
      reading: hr.toDouble(),
      baseline: baseline,
    );

    switch (status) {
      case MetricBaselineStatus.low:
        return MetricRecommendation(
          status: 'Resting / Low',
          baselineStatus: MetricBaselineStatus.low,
          baseline: baseline,
          whatItIs: whatItIs,
          yourReading:
              'Your pulse is low and relaxed at $hr bpm. Your autonomic system is operating in a parasympathetic, restorative baseline state.',
          doThis:
              'Great state for focused cognitive tasks, mobility work, or deliberate recovery protocols.',
        );
      case MetricBaselineStatus.high:
        return MetricRecommendation(
          status: 'Elevated',
          baselineStatus: MetricBaselineStatus.high,
          baseline: baseline,
          whatItIs: whatItIs,
          yourReading:
              'Your pulse is elevated at $hr bpm. This may stem from recent exertion, caffeine, mild dehydration, or acute sympathetic arousal.',
          doThis:
              'Take 2 minutes to sit upright and practice slow 4-7-8 diaphragmatic breathing to down-regulate heart rate.',
        );
      case MetricBaselineStatus.normal:
      case MetricBaselineStatus.unrecorded:
        return MetricRecommendation(
          status: 'Normal',
          baselineStatus: MetricBaselineStatus.normal,
          baseline: baseline,
          whatItIs: whatItIs,
          yourReading:
              'Your pulse is in a healthy, balanced daytime range at $hr bpm. Cardiac output is efficiently matching current energy expenditure.',
          doThis:
              'Maintain regular hydration and proceed with your planned physical activities for the day.',
        );
    }
  }

  /// Computes dynamic advice for Sleep duration and quality.
  static MetricRecommendation getSleepRecommendation(
    String totalSleep, [
    List<dynamic>? sleepIntervals,
  ]) {
    const whatItIs =
        'The total duration and architecture of nocturnal sleep cycles (deep, light, and REM). Quality sleep orchestrates cellular repair, hormone balance, and neural consolidation.';

    double hours = 0.0;
    final hMatch = RegExp(r'(\d+)\s*h').firstMatch(totalSleep);
    final mMatch = RegExp(r'(\d+)\s*m').firstMatch(totalSleep);
    if (hMatch != null) {
      hours += double.tryParse(hMatch.group(1)!) ?? 0.0;
    }
    if (mMatch != null) {
      hours += (double.tryParse(mMatch.group(1)!) ?? 0.0) / 60.0;
    }

    if (hours <= 0.0) {
      return const MetricRecommendation(
        status: '--',
        baselineStatus: MetricBaselineStatus.unrecorded,
        whatItIs: whatItIs,
        yourReading:
            'No sleep data logged last night. Wear your band snugly overnight to capture full sleep architecture.',
        doThis:
            'Keep your band on tonight to allow the optical sensors to track your sleep duration and phases.',
      );
    }

    if (hours < 6.0) {
      return MetricRecommendation(
        status: 'Short sleep',
        baselineStatus: MetricBaselineStatus.low,
        whatItIs: whatItIs,
        yourReading:
            'Short sleep duration at $totalSleep. Sleeping under 6 hours impairs reaction time, metabolic regulation, and glycogen replenishment.',
        doThis:
            'Avoid heavy max-effort lifting today. Plan for a 20-minute power nap before 2 PM and target an early bedtime tonight.',
      );
    } else if (hours < 7.0) {
      return MetricRecommendation(
        status: 'Fair sleep',
        baselineStatus: MetricBaselineStatus.normal,
        whatItIs: whatItIs,
        yourReading:
            'Fair sleep duration at $totalSleep. Near baseline, but an extra 30–60 minutes would noticeably improve REM recovery and stamina.',
        doThis:
            'Aim to get to bed 30 minutes earlier tonight and keep dinner light and at least 2 hours before bed.',
      );
    } else if (hours <= 9.0) {
      return MetricRecommendation(
        status: 'Optimal',
        baselineStatus: MetricBaselineStatus.normal,
        whatItIs: whatItIs,
        yourReading:
            'Optimal sleep duration at $totalSleep. You spent adequate time in restorative deep and REM phases for cellular and neural rejuvenation.',
        doThis:
            'You are primed for peak physical exertion and demanding mental challenges today.',
      );
    } else {
      return MetricRecommendation(
        status: 'Extended',
        baselineStatus: MetricBaselineStatus.high,
        whatItIs: whatItIs,
        yourReading:
            'Extended recovery sleep at $totalSleep. Your body is likely compensating for sleep debt or repairing from intensive physical strain.',
        doThis:
            'Hydrate with electrolytes and get 15 minutes of direct morning sunlight to anchor your circadian rhythm.',
      );
    }
  }

  /// Computes dynamic advice for Blood Pressure estimate (e.g. "120/80").
  static MetricRecommendation getBloodPressureRecommendation(String bp) {
    const whatItIs =
        'The force of circulating blood against arterial walls during heart contraction (systolic) and relaxation (diastolic). An essential marker of vascular compliance and cardiac workload.';

    if (bp.isEmpty || bp == '0/0' || bp == '--/--' || bp == '--') {
      return const MetricRecommendation(
        status: '--',
        baselineStatus: MetricBaselineStatus.unrecorded,
        whatItIs: whatItIs,
        yourReading:
            'No blood pressure estimate recorded yet today. Take a live reading on the spot or sync your band.',
        doThis:
            'Keep your wrist still and at heart level during measurement for reliable optical pulse wave estimation.',
      );
    }

    final parts = bp.split('/');
    final int sbp = parts.isNotEmpty ? (int.tryParse(parts[0].trim()) ?? 0) : 0;
    final int dbp = parts.length > 1 ? (int.tryParse(parts[1].trim()) ?? 0) : 0;

    if (sbp <= 0) {
      return const MetricRecommendation(
        status: '--',
        baselineStatus: MetricBaselineStatus.unrecorded,
        whatItIs: whatItIs,
        yourReading:
            'No blood pressure reading available yet. Trigger an on-demand check.',
        doThis:
            'Use the live check button to take an instant optical blood pressure estimate.',
      );
    }

    if (sbp < 120 && (dbp <= 0 || dbp < 80)) {
      return MetricRecommendation(
        status: 'Optimal',
        baselineStatus: MetricBaselineStatus.normal,
        whatItIs: whatItIs,
        yourReading:
            'Optimal vascular pressure at $bp mmHg. Your arterial walls demonstrate healthy compliance and normal peripheral resistance.',
        doThis:
            'Maintain regular cardiovascular movement and a balanced intake of dietary minerals (potassium and magnesium).',
      );
    } else if (sbp < 130 && (dbp <= 0 || dbp < 80)) {
      return MetricRecommendation(
        status: 'Elevated',
        baselineStatus: MetricBaselineStatus.high,
        whatItIs: whatItIs,
        yourReading:
            'Slightly elevated systolic reading at $bp mmHg. Minor arterial tension detected, often associated with stress or caffeine.',
        doThis:
            'Drink a glass of water, reduce dietary sodium today, and take a 15-minute brisk walk.',
      );
    } else {
      return MetricRecommendation(
        status: 'High',
        baselineStatus: MetricBaselineStatus.high,
        whatItIs: whatItIs,
        yourReading:
            'High blood pressure reading at $bp mmHg. Indicates increased arterial resistance and cardiac workload.',
        doThis:
            'Sit quietly for 5 minutes, avoid caffeine, and re-test. If readings stay consistently high, consult a physician.',
      );
    }
  }

  /// Computes dynamic advice for Skin Temperature deviation.
  static MetricRecommendation getSkinTempRecommendation(double diff) {
    const whatItIs =
        'Fluctuations in peripheral skin temperature relative to your nocturnal baseline. Deviations reflect circadian phase shifts, ambient heat, or systemic immune responses.';

    if (diff == 0.0) {
      return const MetricRecommendation(
        status: 'Baseline',
        baselineStatus: MetricBaselineStatus.normal,
        whatItIs: whatItIs,
        yourReading:
            'Skin temperature matches your normal personal baseline exactly (0.0°C deviation).',
        doThis:
            'Your thermoregulatory status is stable. Proceed with regular daily training and activities.',
      );
    }

    if (diff.abs() <= 0.5) {
      return MetricRecommendation(
        status: 'Normal',
        baselineStatus: MetricBaselineStatus.normal,
        whatItIs: whatItIs,
        yourReading:
            'Skin temperature is well within your normal baseline (${diff > 0 ? '+' : ''}${diff.toStringAsFixed(1)}°C). Thermoregulation is balanced.',
        doThis:
            'Your autonomic temperature control is stable. Ideal for all normal activities.',
      );
    } else if (diff > 0.5) {
      return MetricRecommendation(
        status: 'Elevated',
        baselineStatus: MetricBaselineStatus.high,
        whatItIs: whatItIs,
        yourReading:
            'Skin temperature is elevated (+${diff.toStringAsFixed(1)}°C). May indicate an active immune response, late evening digestion, or warm sleeping environment.',
        doThis:
            'Stay well-hydrated, monitor how your body feels, and prioritize light restorative movement over intense sessions.',
      );
    } else {
      return MetricRecommendation(
        status: 'Lower',
        baselineStatus: MetricBaselineStatus.low,
        whatItIs: whatItIs,
        yourReading:
            'Skin temperature is lower than baseline (${diff.toStringAsFixed(1)}°C). Often stems from cool bedroom conditions or peripheral vasoconstriction.',
        doThis:
            'Ensure adequate warmth during sleep and spend extra time warming up your muscles before workouts.',
      );
    }
  }
}
