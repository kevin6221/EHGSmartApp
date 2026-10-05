import 'package:flutter/material.dart';

import '../../../../data/models/workout_model.dart';

/// WHOOP / Garmin / Qwatch Pro-style Zone pacing, duration, and running execution guidance model.
class ZonePacingInfo {
  final int zoneNumber;
  final String title;
  final String intensityTag;
  final String hrRange;
  final String targetDuration;
  final String cadenceTarget;
  final String breathingTechnique;
  final String executionGuide;
  final String physiologicalBenefit;
  final IconData icon;

  const ZonePacingInfo({
    required this.zoneNumber,
    required this.title,
    required this.intensityTag,
    required this.hrRange,
    required this.targetDuration,
    required this.cadenceTarget,
    required this.breathingTechnique,
    required this.executionGuide,
    required this.physiologicalBenefit,
    required this.icon,
  });

  /// Factory producing activity and zone specific coaching guidance.
  factory ZonePacingInfo.forZoneAndCategory(int zone, WorkoutType category) {
    final isRun = category == WorkoutType.run;
    final isWalk = category == WorkoutType.walk;
    final isCycling = category == WorkoutType.cycling;

    switch (zone) {
      case 1:
        return ZonePacingInfo(
          zoneNumber: 1,
          title: 'Zone 1 · Recovery & Warm-up',
          intensityTag: '50% - 60% Max HR',
          hrRange: '< 115 bpm',
          targetDuration: '15 - 30 mins',
          cadenceTarget: isRun
              ? '150 - 160 spm'
              : (isCycling ? '75 - 85 rpm' : '100 - 110 spm'),
          breathingTechnique: 'Nasal Breathing Only (Calm & Steady)',
          executionGuide: isRun
              ? 'Very light conversational effort (RPE 2-3/10). Run or jog completely relaxed with zero burning in legs. You should easily sing or talk in full sentences without losing breath. Use soft, silent footfalls. Ideal for warm-up, cool-down, or flush-out runs.'
              : (isWalk
                  ? 'Casual relaxed walking pace. Keep shoulders relaxed, posture tall, and breathe purely through your nose to promote gentle circulation and joint mobility.'
                  : 'Effortless light spinning with minimal pedal resistance. Keeps blood flowing to flush out muscle soreness without stressing joints.'),
          physiologicalBenefit:
              'Stimulates cellular repair, increases muscular capillary blood flow, and flushes lactic waste without fatiguing the nervous system.',
          icon: Icons.spa_outlined,
        );
      case 2:
        return ZonePacingInfo(
          zoneNumber: 2,
          title: 'Zone 2 · Aerobic Base & Fat Burn',
          intensityTag: '60% - 70% Max HR',
          hrRange: '115 - 135 bpm',
          targetDuration: '30 - 75 mins',
          cadenceTarget: isRun
              ? '165 - 175 spm'
              : (isCycling ? '85 - 95 rpm' : '115 - 125 spm'),
          breathingTechnique: '3:3 Rhythm (Inhale 3 strides, Exhale 3 strides)',
          executionGuide: isRun
              ? 'Continuous, sustainable conversational pace (RPE 4-5/10). Land softly on your midfoot directly under your hips. You should be able to speak complete sentences comfortably. 75-80% of your total weekly mileage should be in Zone 2 to build elite endurance.'
              : (isWalk
                  ? 'Brisk, deliberate power walking. Pump your arms in a 90-degree bend, engage your core, and push firmly off your back toes at a sustainable brisk tempo.'
                  : 'Smooth, continuous spinning at high cadence. Maintain an all-day sustainable cadence while holding a clear conversation without panting.'),
          physiologicalBenefit:
              'Maximizes fat oxidation for energy, builds mitochondrial density in muscle cells, and significantly expands cardiac stroke volume.',
          icon: Icons.local_fire_department_rounded,
        );
      case 3:
        return ZonePacingInfo(
          zoneNumber: 3,
          title: 'Zone 3 · Aerobic Tempo',
          intensityTag: '70% - 80% Max HR',
          hrRange: '135 - 155 bpm',
          targetDuration: '20 - 45 mins',
          cadenceTarget: isRun
              ? '170 - 180 spm'
              : (isCycling ? '90 - 100 rpm' : '125+ spm'),
          breathingTechnique: '2:2 Rhythm (Inhale 2 strides, Exhale 2 strides)',
          executionGuide: isRun
              ? 'Comfortably hard tempo rhythm (RPE 6-7/10). Lean slightly forward from your ankles, engage your core, and drive elbows back. You can only speak in short 3-4 word phrases. Excellent for marathon, half-marathon, and 10k race pace preparation.'
              : (isWalk
                  ? 'Intense power walk on an incline or maximum road stride. Focus on powerful hip extension and rhythmic, deep diaphragmatic breathing.'
                  : 'Fast cadence spinning against moderate resistance. Requires active focus to hold steady cadence and wattage without drifting.'),
          physiologicalBenefit:
              'Improves aerobic efficiency, enhances heart output volume, and trains your muscles to recycle blood lactate under sustained aerodynamic stress.',
          icon: Icons.trending_up_rounded,
        );
      case 4:
        return ZonePacingInfo(
          zoneNumber: 4,
          title: 'Zone 4 · Lactate Threshold',
          intensityTag: '80% - 90% Max HR',
          hrRange: '155 - 175 bpm',
          targetDuration: '10 - 25 mins (3-8 min intervals)',
          cadenceTarget: isRun
              ? '175 - 185 spm'
              : (isCycling ? '95 - 105 rpm' : 'Max power cadence'),
          breathingTechnique: '2:1 or 1:1 Rapid Deep Breathing',
          executionGuide: isRun
              ? 'Hard race pace effort (RPE 8-9/10). Quick knee drive and snappy foot turnover. Deep, heavy breathing; speaking is nearly impossible. Execute as 3 to 8-minute intervals with 2-minute recovery jogs to build stamina and speed.'
              : (isWalk
                  ? 'Steep hill climb or maximum speed walk. Maximum leg drive, elevated heart rate, and strong uphill propulsion.'
                  : 'Heavy resistance hill climb or hard time-trial tempo. Produces burning in the quads that requires mental grit to sustain.'),
          physiologicalBenefit:
              'Pushes your lactate threshold higher, conditions your body to buffer acidosis, and significantly raises your VO2 max ceiling.',
          icon: Icons.bolt_rounded,
        );
      case 5:
      default:
        return ZonePacingInfo(
          zoneNumber: 5,
          title: 'Zone 5 · Anaerobic Peak & Sprints',
          intensityTag: '90% - 100% Max HR',
          hrRange: '175+ bpm',
          targetDuration: '3 - 10 mins (30-90s sprints)',
          cadenceTarget: isRun
              ? '180+ spm'
              : (isCycling ? '105+ rpm' : 'Max effort'),
          breathingTechnique: 'Max Rapid Ventilation (All-out respiration)',
          executionGuide: isRun
              ? 'All-out sprint effort (RPE 10/10). Maximum propulsion, aggressive knee drive, and violent arm pump. Sustainable only for 30 to 90 seconds. Always take full walking recovery between intervals to allow heart rate to reset.'
              : (isWalk
                  ? 'Max-grade incline sprint or stair climb at full power bursts.'
                  : 'Out-of-the-saddle standing sprints at maximum wattage and RPM bursts.'),
          physiologicalBenefit:
              'Recruits fast-twitch Type IIb muscle fibers, expands neuromuscular power, and boosts peak sprint acceleration and anaerobic capacity.',
          icon: Icons.electric_bolt_rounded,
        );
    }
  }
}
