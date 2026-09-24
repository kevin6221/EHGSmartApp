import 'package:flutter/foundation.dart';

/// Data class representing an actionable, contextual recommendation
/// for health vitals cards.
@immutable
class MetricRecommendation {
  final String status;
  final String whatItIs;
  final String yourReading;
  final String doThis;

  const MetricRecommendation({
    required this.status,
    required this.whatItIs,
    required this.yourReading,
    required this.doThis,
  });
}

/// Dynamic Health & Wellness Recommendation Engine.
///
/// Converts real-time and historical biometric signals (HRV, Resting HR,
/// SpO2, Respiratory Rate, Blood Pressure) into contextual, clinically-sound,
/// sports-science validated guidance.
class RecommendationEngine {
  const RecommendationEngine._();

  /// Computes dynamic advice and reading assessment for Heart Rate Variability (HRV).
  static MetricRecommendation getHrvRecommendation(
    int hrvMs, [
    List<double>? weeklyHrv,
  ]) {
    const whatItIs =
        'The variation in time between consecutive heartbeats. Higher variability reflects a responsive, adaptable autonomic nervous system that transitions effortlessly between strain and recovery.';

    if (hrvMs <= 0) {
      return const MetricRecommendation(
        status: '--',
        whatItIs: whatItIs,
        yourReading:
            'No HRV reading recorded yet today. Wear your band during sleep to capture your autonomic baseline.',
        doThis:
            'Wear your band snugly overnight and sync in the morning to establish your personal HRV range.',
      );
    }

    // Baseline comparison if history is available
    double? weeklyAvg;
    if (weeklyHrv != null && weeklyHrv.isNotEmpty) {
      final valid = weeklyHrv.where((v) => v > 0).toList();
      if (valid.isNotEmpty) {
        weeklyAvg = valid.reduce((a, b) => a + b) / valid.length;
      }
    }

    if (hrvMs < 40) {
      final diffText = (weeklyAvg != null && hrvMs < weeklyAvg)
          ? 'Below your 7-day average of ${weeklyAvg.round()} ms. '
          : '';
      return MetricRecommendation(
        status: 'Low',
        whatItIs: whatItIs,
        yourReading:
            '${diffText}Your nervous system indicates elevated autonomic stress or incomplete recovery from recent physical strain or lack of rest.',
        doThis:
            'Keep physical exertion light and aerobic today. Prioritize an early bedtime and avoid late meals or alcohol.',
      );
    } else if (hrvMs <= 75) {
      return MetricRecommendation(
        status: 'Balanced',
        whatItIs: whatItIs,
        yourReading:
            'In your optimal baseline range ($hrvMs ms). Your sympathetic and parasympathetic branches are well balanced.',
        doThis:
            'Your body is well-adapted for moderate to vigorous training today. Maintain consistent hydration.',
      );
    } else {
      return MetricRecommendation(
        status: 'Optimal',
        whatItIs: whatItIs,
        yourReading:
            'Optimal autonomic resilience ($hrvMs ms). Your parasympathetic recovery is robust and primed for peak exertion.',
        doThis:
            'You have high capacity for demanding workouts, high-intensity intervals, or challenging mental tasks today.',
      );
    }
  }

  /// Computes dynamic advice for Resting Heart Rate (RHR).
  static MetricRecommendation getRestingHrRecommendation(
    int restingHr, [
    List<double>? weeklyRestingHr,
  ]) {
    const whatItIs =
        'Your heart rate when completely at rest, measured during deep sleep or quiet wakefulness. A lower resting heart rate indicates stronger cardiovascular efficiency.';

    if (restingHr <= 0) {
      return const MetricRecommendation(
        status: '--',
        whatItIs: whatItIs,
        yourReading:
            'No resting heart rate recorded yet today. Wear your band during sleep to track baseline readings.',
        doThis:
            'Keep your band on overnight to allow nocturnal baseline measurements.',
      );
    }

    if (restingHr < 55) {
      return MetricRecommendation(
        status: 'Athletic',
        whatItIs: whatItIs,
        yourReading:
            'Excellent cardiovascular fitness ($restingHr bpm). Your cardiac stroke volume is high, requiring fewer beats per minute at rest.',
        doThis:
            'Maintain your current aerobic conditioning and recovery protocols.',
      );
    } else if (restingHr <= 75) {
      return MetricRecommendation(
        status: 'In your range',
        whatItIs: whatItIs,
        yourReading:
            'In your optimal range ($restingHr bpm). Your resting heart rate indicates healthy autonomic recovery and standard metabolic load.',
        doThis:
            'Continue regular daily movement and wind down 30 minutes before sleep.',
      );
    } else {
      return MetricRecommendation(
        status: 'Elevated',
        whatItIs: whatItIs,
        yourReading:
            'Elevated resting heart rate ($restingHr bpm). This may reflect dehydration, acute stress, delayed digestion, or mild systemic fatigue.',
        doThis:
            'Prioritize hydration, avoid caffeine after midday, and allow extra recovery time before intense exertion.',
      );
    }
  }

  /// Computes dynamic advice for Blood Oxygen Saturation (SpO2).
  static MetricRecommendation getBloodOxygenRecommendation(int spo2) {
    const whatItIs =
        'The percentage of oxygen your red blood cells carry from your lungs to the rest of your body. Normal levels range from 95% to 100%.';

    if (spo2 <= 0) {
      return const MetricRecommendation(
        status: '--',
        whatItIs: whatItIs,
        yourReading:
            'No blood oxygen data recorded yet. Sync your band or trigger a measurement to view saturation levels.',
        doThis:
            'Ensure the band is positioned one finger width above your wrist bone for accurate optical readings.',
      );
    }

    if (spo2 >= 95) {
      return MetricRecommendation(
        status: 'In your range',
        whatItIs: whatItIs,
        yourReading:
            'In your optimal range ($spo2%). Your blood oxygen saturation indicates robust pulmonary gas exchange and arterial delivery.',
        doThis:
            'Maintain optimal hydration and practice deep diaphragmatic breathing throughout your day.',
      );
    } else if (spo2 >= 90) {
      return MetricRecommendation(
        status: 'Borderline',
        whatItIs: whatItIs,
        yourReading:
            'Slightly lower than optimal at $spo2%. This can be caused by shallow breathing, posture, high altitude, or poor air circulation.',
        doThis:
            'Take 10 deep, slow belly breaths in fresh air and ensure the sensor has good skin contact.',
      );
    } else {
      return MetricRecommendation(
        status: 'Low',
        whatItIs: whatItIs,
        yourReading:
            'Blood oxygen is measured at $spo2%. Saturation below 90% indicates sub-optimal peripheral oxygenation.',
        doThis:
            'Rest immediately in an upright posture. Re-test in 5 minutes. If levels remain below 90%, seek medical attention.',
      );
    }
  }

  /// Computes dynamic advice for Breathing Rate.
  static MetricRecommendation getBreathingRateRecommendation(double rate) {
    const whatItIs =
        'The number of breaths you take per minute during sleep. A steady, baseline breathing rate indicates undisturbed sleep and good respiratory efficiency.';

    if (rate <= 0) {
      return const MetricRecommendation(
        status: '--',
        whatItIs: whatItIs,
        yourReading:
            'No nocturnal respiratory data available yet. Wear your band during sleep to calculate breathing stability.',
        doThis:
            'Keep your band fastened during overnight sleep to measure your nocturnal respiration.',
      );
    }

    if (rate <= 16.0) {
      return MetricRecommendation(
        status: 'Normal',
        whatItIs: whatItIs,
        yourReading:
            'Steady at ${rate.toStringAsFixed(1)} breaths/min. Calm, stable nocturnal respiration confirms restful slow-wave sleep phases.',
        doThis:
            'Maintain a cool, ventilated sleep environment between 18°C–20°C for optimal nocturnal breathing.',
      );
    } else {
      return MetricRecommendation(
        status: 'Elevated',
        whatItIs: whatItIs,
        yourReading:
            'Slightly elevated at ${rate.toStringAsFixed(1)} breaths/min. This can be caused by late physical exertion, higher ambient room temperature, or mild airway resistance.',
        doThis:
            'Wind down with 5 minutes of slow box breathing before sleep to calm your autonomic nervous system.',
      );
    }
  }
}
