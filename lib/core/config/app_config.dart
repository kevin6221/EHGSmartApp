import 'package:firebase_core/firebase_core.dart';
import 'app_flavor.dart';
export 'app_flavor.dart';
import 'flavor_firebase_options.dart';

/// Immutable environment configuration holding flavor, endpoints, security policies, and feature flags.
class AppConfig {
  final AppFlavor flavor;
  final String apiBaseUrl;
  final bool enableCrashlytics;
  final bool enableAnalytics;
  final bool enableLogging;
  final FirebaseOptions? firebaseOptions;

  /// Application name derived directly from the active [flavor].
  String get appName => flavor.appName;

  const AppConfig({
    required this.flavor,
    required this.apiBaseUrl,
    required this.enableCrashlytics,
    required this.enableAnalytics,
    required this.enableLogging,
    this.firebaseOptions,
  });

  /// Factory constructor for the Development environment.
  factory AppConfig.dev({
    String? apiBaseUrl,
    bool enableCrashlytics = true,
    bool enableAnalytics = true,
    bool enableLogging = true,
    FirebaseOptions? firebaseOptions,
  }) {
    return AppConfig(
      flavor: AppFlavor.dev,
      apiBaseUrl: apiBaseUrl ?? 'https://dev-api.ehgsmart.com/v1',
      enableCrashlytics: enableCrashlytics,
      enableAnalytics: enableAnalytics,
      enableLogging: enableLogging,
      firebaseOptions: firebaseOptions ?? FlavorFirebaseOptions.getOptions(AppFlavor.dev),
    );
  }

  /// Factory constructor for the Staging environment.
  factory AppConfig.stage({
    String? apiBaseUrl,
    bool enableCrashlytics = true,
    bool enableAnalytics = true,
    bool enableLogging = true,
    FirebaseOptions? firebaseOptions,
  }) {
    return AppConfig(
      flavor: AppFlavor.stage,
      apiBaseUrl: apiBaseUrl ?? 'https://stage-api.ehgsmart.com/v1',
      enableCrashlytics: enableCrashlytics,
      enableAnalytics: enableAnalytics,
      enableLogging: enableLogging,
      firebaseOptions: firebaseOptions ?? FlavorFirebaseOptions.getOptions(AppFlavor.stage),
    );
  }

  /// Factory constructor for the Production environment.
  factory AppConfig.prod({
    String? apiBaseUrl,
    bool enableCrashlytics = true,
    bool enableAnalytics = true,
    bool enableLogging = false,
    FirebaseOptions? firebaseOptions,
  }) {
    return AppConfig(
      flavor: AppFlavor.prod,
      apiBaseUrl: apiBaseUrl ?? 'https://api.ehgsmart.com/v1',
      enableCrashlytics: enableCrashlytics,
      enableAnalytics: enableAnalytics,
      enableLogging: enableLogging,
      firebaseOptions: firebaseOptions ?? FlavorFirebaseOptions.getOptions(AppFlavor.prod),
    );
  }

  // --- Singleton Accessor ---
  static AppConfig? _instance;

  /// Returns true if the active [AppConfig] has been initialized.
  static bool get isInitialized => _instance != null;

  /// Returns the active [AppConfig] instance.
  ///
  /// Throws a [StateError] if accessed before [initialize] was called.
  static AppConfig get instance {
    final current = _instance;
    if (current == null) {
      throw StateError(
        'AppConfig has not been initialized. Call AppConfig.initialize() in your entrypoint before accessing instance.',
      );
    }
    return current;
  }

  /// Initializes the active configuration for the running app.
  static void initialize(AppConfig config) {
    _instance = config;
  }
}
