import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import 'firebase_service.dart';

/// Secure, flavor-aware service for logging user interactions and route views to Firebase Analytics.
class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  bool get _isEnabled {
    if (!FirebaseService.isInitialized) return false;
    if (AppConfig.isInitialized && !AppConfig.instance.enableAnalytics) {
      return false;
    }
    return true;
  }

  /// Returns the [FirebaseAnalyticsObserver] if Analytics is initialized and enabled.
  FirebaseAnalyticsObserver? get observer {
    if (!_isEnabled) return null;
    return FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance);
  }

  /// Logs a custom analytics event with optional parameters.
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    if (!_isEnabled) {
      if (kDebugMode) {
        debugPrint('[AnalyticsService] (Disabled/No-Op) logEvent: $name, params: $parameters');
      }
      return;
    }

    try {
      await FirebaseAnalytics.instance.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e) {
      debugPrint('[AnalyticsService] Failed to log event $name: $e');
    }
  }

  /// Logs a screen view navigation event.
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    if (!_isEnabled) {
      return;
    }

    try {
      await FirebaseAnalytics.instance.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
    } catch (e) {
      debugPrint('[AnalyticsService] Failed to log screen view $screenName: $e');
    }
  }

  /// Sets the user ID for analytics tracking.
  Future<void> setUserId(String? id) async {
    if (!_isEnabled) return;

    try {
      await FirebaseAnalytics.instance.setUserId(id: id);
    } catch (e) {
      debugPrint('[AnalyticsService] Failed to set user ID: $e');
    }
  }

  /// Sets a custom user property.
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    if (!_isEnabled) return;

    try {
      await FirebaseAnalytics.instance.setUserProperty(
        name: name,
        value: value,
      );
    } catch (e) {
      debugPrint('[AnalyticsService] Failed to set user property $name: $e');
    }
  }

  /// Resets all analytics data for the current user.
  Future<void> resetAnalyticsData() async {
    if (!_isEnabled) return;

    try {
      await FirebaseAnalytics.instance.resetAnalyticsData();
    } catch (e) {
      debugPrint('[AnalyticsService] Failed to reset analytics data: $e');
    }
  }
}
