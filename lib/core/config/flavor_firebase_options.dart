import 'package:firebase_core/firebase_core.dart';
import 'app_flavor.dart';
import 'firebase_options_dev.dart' as dev_opts;
import 'firebase_options_prod.dart' as prod_opts;
import 'firebase_options_stage.dart' as stage_opts;

/// Provides flavor-specific [FirebaseOptions] for Dart-level Firebase initialization.
///
/// Injects the exact Firebase configuration corresponding to the active build flavor.
class FlavorFirebaseOptions {
  FlavorFirebaseOptions._();

  /// Returns the [FirebaseOptions] for the given [flavor].
  static FirebaseOptions? getOptions(AppFlavor flavor) {
    switch (flavor) {
      case AppFlavor.dev:
        return dev_opts.DefaultFirebaseOptions.currentPlatform;
      case AppFlavor.stage:
        return stage_opts.DefaultFirebaseOptions.currentPlatform;
      case AppFlavor.prod:
        return prod_opts.DefaultFirebaseOptions.currentPlatform;
    }
  }
}
