import 'dart:async';
import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../security/secure_storage_service.dart';
import '../theme/app_colors.dart';

/// Pre-flight application initializer.
///
/// Keeps `main.dart` minimal and isolates crash reporting, Firebase bootstrapping,
/// and system UI styling from the widget tree.
abstract final class AppInitializer {
  /// Bootstraps essential core services before `runApp`.
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 1. Setup native system overlay styling immediately to avoid flash
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // 2. Initialize Firebase and configure Crashlytics error handlers
    try {
      await Firebase.initializeApp();

      // Catch Flutter framework errors (rendering, build, etc.)
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;

      // Catch uncaught asynchronous / isolate platform errors
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      // Analytics can run in background without blocking startup frame
      unawaited(FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true));
    } catch (e, st) {
      debugPrint('⚠️ [APP INIT] Firebase initialization warning: $e\n$st');
    }

    // 3. Defer non-critical first-install cleanup without blocking initial frame
    unawaited(SecureStorageService().ensureFreshInstallState());
  }
}
