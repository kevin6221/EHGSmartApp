import 'package:flutter/material.dart';

import 'app.dart';
import 'core/services/app_initializer.dart';

/// Application entry point.
///
/// Pre-flight initialization is delegated to [AppInitializer] to keep startup
/// ultra-fast and the entry file clean and maintainable.
void main() async {
  await AppInitializer.initialize();
  runApp(const EHGWellnessApp());
}
