import 'package:flutter/animation.dart';

/// Centralized animation durations adhering to senior Flutter motion design standards.
/// Eliminates hardcoded magic numbers across the codebase.
class AppDurations {
  AppDurations._();

  /// Very fast micro-interactions (e.g. badge tap, icon switch): 150ms
  static const Duration micro = Duration(milliseconds: 150);

  /// Quick interactive feedback (e.g. button presses, pill tab toggles): 200ms
  static const Duration fast = Duration(milliseconds: 200);

  /// Standard transitions (e.g. mode changes, tab switch hints): 250ms
  static const Duration medium = Duration(milliseconds: 250);

  /// Card expansion and collapse transitions: 300ms
  static const Duration cardExpand = Duration(milliseconds: 300);

  /// Custom bottom nav bar fluid pill squash & stretch morphing: 320ms
  static const Duration navTabSwitch = Duration(milliseconds: 320);

  /// General tab switcher transition: 350ms
  static const Duration tabSwitch = Duration(milliseconds: 350);

  /// Screen navigation route transitions: 400ms
  static const Duration pageTransition = Duration(milliseconds: 400);

  /// Extended screen transitions: 450ms
  static const Duration pageTransitionSlow = Duration(milliseconds: 450);

  /// Chart entry and fill animations: 600ms
  static const Duration chartFill = Duration(milliseconds: 600);

  /// Daytime wellness wave chart drawing animation: 1000ms
  static const Duration chartDraw = Duration(milliseconds: 1000);

  /// Circular loader full 360-degree rotation: 1200ms
  static const Duration loaderSpin = Duration(milliseconds: 1200);

  /// Splash screen display hold time: 1600ms
  static const Duration splashDelay = Duration(milliseconds: 1600);

  /// Splash screen ambient ring pulsing cycle: 2400ms
  static const Duration splashPulse = Duration(milliseconds: 2400);

  /// Wardrobe tag scanner pulse duration: 2400ms
  static const Duration scanPulse = Duration(milliseconds: 2400);

  /// Wardrobe tag scanner radar sweep duration: 4000ms
  static const Duration scanRadarSweep = Duration(milliseconds: 4000);

  /// Onboarding radar scanner sweep rotation cycle: 12s
  static const Duration radarRotation = Duration(seconds: 12);

  /// Welcome screen orbital background rotation: 40s
  static const Duration orbitRotation = Duration(seconds: 40);
}

/// Centralized animation curves adhering to senior Flutter motion design standards.
class AppCurves {
  AppCurves._();

  /// Default ease in and out curve for general UI state transitions
  static const Curve standard = Curves.easeInOut;

  /// Fluid cubic curve for navigation bar morphing & squash/stretch
  static const Curve navTabSwitch = Curves.easeInOutCubic;

  /// Smooth ease-in-out cubic curve for card expansion
  static const Curve cardExpand = Curves.easeInOutCubic;

  /// Natural decelerating curve for charts and incoming elements
  static const Curve chartEase = Curves.easeOutCubic;

  /// Snappy deceleration for elements sliding into view
  static const Curve slideIn = Curves.easeOutCubic;

  /// Snappy acceleration for elements sliding out of view
  static const Curve slideOut = Curves.easeInCubic;

  /// Pulsing breathing curve
  static const Curve pulse = Curves.easeInOut;
}
