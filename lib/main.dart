import 'package:flutter/material.dart';

import 'app.dart';
import 'core/services/app_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase, Crashlytics, and core app environment
  await AppInitializer.initialize();

  runApp(const EHGWellnessApp());
}
