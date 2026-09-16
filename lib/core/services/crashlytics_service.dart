import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../security/log_sanitizer.dart';
import 'firebase_service.dart';

/// Secure, flavor-aware service for reporting crashes and exceptions to Firebase Crashlytics.
class CrashlyticsService {
  CrashlyticsService._();

  static final CrashlyticsService instance = CrashlyticsService._();

  bool get _isEnabled {
    if (!FirebaseService.isInitialized) return false;
    if (AppConfig.isInitialized && !AppConfig.instance.enableCrashlytics) {
      return false;
    }
    return true;
  }

  /// Logs a non-fatal or fatal error to Crashlytics with sanitized information.
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    Iterable<Object> information = const [],
    bool fatal = false,
    bool? printDetails,
  }) async {
    if (!_isEnabled) {
      if (kDebugMode) {
        debugPrint('[CrashlyticsService] (Disabled/No-Op) Error: $exception, reason: $reason');
      }
      return;
    }

    try {
      final sanitizedReason = reason != null ? LogSanitizer.sanitize(reason.toString()) : null;
      final sanitizedInfo = information.map((info) => LogSanitizer.sanitize(info.toString())).toList();

      await FirebaseCrashlytics.instance.recordError(
        exception,
        stack,
        reason: sanitizedReason,
        information: sanitizedInfo,
        fatal: fatal,
        printDetails: printDetails,
      );
    } catch (e) {
      debugPrint('[CrashlyticsService] Failed to record error: $e');
    }
  }

  /// Appends a sanitized breadcrumb message to the Crashlytics session.
  Future<void> log(String message) async {
    if (!_isEnabled) {
      return;
    }

    try {
      final sanitized = LogSanitizer.sanitize(message);
      await FirebaseCrashlytics.instance.log(sanitized);
    } catch (e) {
      debugPrint('[CrashlyticsService] Failed to log breadcrumb: $e');
    }
  }

  /// Sets a custom key/value pair for subsequent crash reports.
  Future<void> setCustomKey(String key, Object value) async {
    if (!_isEnabled) return;

    try {
      final sanitizedVal = value is String ? LogSanitizer.sanitize(value) : value;
      await FirebaseCrashlytics.instance.setCustomKey(key, sanitizedVal);
    } catch (e) {
      debugPrint('[CrashlyticsService] Failed to set custom key: $e');
    }
  }

  /// Associates a unique user identifier with crash reports.
  Future<void> setUserIdentifier(String identifier) async {
    if (!_isEnabled) return;

    try {
      await FirebaseCrashlytics.instance.setUserIdentifier(identifier);
    } catch (e) {
      debugPrint('[CrashlyticsService] Failed to set user identifier: $e');
    }
  }

  /// Forces a test crash to verify Crashlytics setup on the Firebase Console dashboard.
  ///
  /// Reference: https://firebase.google.com/docs/crashlytics/android/get-started#add-sdk
  void testCrash() {
    FirebaseCrashlytics.instance.crash();
  }

  /// Sends a non-fatal test error report to immediately activate the Crashlytics dashboard.
  Future<void> sendTestReport() async {
    if (!_isEnabled) return;
    try {
      await FirebaseCrashlytics.instance.recordError(
        Exception('Crashlytics Test Event: Verification Successful'),
        StackTrace.current,
        reason: 'Initial setup verification',
        fatal: false,
      );
      debugPrint('[CrashlyticsService] Sent test verification event to Firebase Crashlytics.');
    } catch (e) {
      debugPrint('[CrashlyticsService] Failed to send test event: $e');
    }
  }
}
