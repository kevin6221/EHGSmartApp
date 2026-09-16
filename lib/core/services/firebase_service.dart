import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import 'logger_service.dart';

/// Centralized service for initializing Firebase across environments,
/// configuring Crashlytics fatal/non-fatal handlers, and managing feature flags.
class FirebaseService {
  FirebaseService._();

  static bool _isInitialized = false;

  /// Returns true if Firebase Core was successfully initialized.
  static bool get isInitialized => _isInitialized;

  /// Initializes Firebase using the provided [config].
  ///
  /// If credentials (google-services.json or GoogleService-Info.plist)
  /// are not yet present for the active flavor, initialization fails gracefully
  /// without crashing the application.
  static Future<void> initialize(AppConfig config) async {
    try {
      if (config.firebaseOptions != null) {
        await Firebase.initializeApp(options: config.firebaseOptions);
      } else {
        await Firebase.initializeApp();
      }

      _isInitialized = true;

      // Crashlytics setup
      if (config.enableCrashlytics) {
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
        await FirebaseCrashlytics.instance.setCustomKey('flavor', config.flavor.name);
        await FirebaseCrashlytics.instance.setCustomKey('app_name', config.flavor.appName);
        await FirebaseCrashlytics.instance.sendUnsentReports();

        // Pass all uncaught "fatal" errors from the framework to Crashlytics
        FlutterError.onError = (FlutterErrorDetails details) {
          FirebaseCrashlytics.instance.recordFlutterFatalError(details);
          if (kDebugMode) {
            FlutterError.presentError(details);
          }
        };

        // Pass all uncaught asynchronous errors to Crashlytics
        PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return true;
        };
      } else {
        // In dev or when Crashlytics is disabled, present errors to the console
        FlutterError.onError = FlutterError.presentError;
      }

      // Analytics setup
      if (config.enableAnalytics) {
        await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
        await FirebaseAnalytics.instance.setUserProperty(
          name: 'app_flavor',
          value: config.flavor.name,
        );
      } else {
        await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
      }

      AppLogger.i('Firebase initialized successfully for flavor: ${config.flavor.displayName}');
    } catch (e) {
      _isInitialized = false;
      FlutterError.onError = FlutterError.presentError;
      AppLogger.w(
        'Firebase initialization skipped for ${config.flavor.displayName}: $e. '
        'Add google-services.json or GoogleService-Info.plist to link native Firebase.',
      );
    }
  }
}
