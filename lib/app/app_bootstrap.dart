import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/config/app_config.dart';
import '../core/services/firebase_service.dart';
import '../core/services/logger_service.dart';
import '../core/theme/app_colors.dart';
import 'app.dart';

/// Centralized, reusable application startup sequence.
///
/// Ensures uniform initialization of binding, configuration, system overlays,
/// logging, and Firebase services across all flavor entry points.
Future<void> bootstrap(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize environment configuration
  AppConfig.initialize(config);

  // 2. Configure system UI overlays
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // 3. Initialize Firebase services for the active flavor
  await FirebaseService.initialize(config);

  AppLogger.i('Launching ${config.flavor.appName} [Base URL: ${config.apiBaseUrl}]');

  // 4. Launch the application
  runApp(const EHGWellnessApp());
}
