/// Supported build flavors for the application.
enum AppFlavor {
  dev,
  stage,
  prod;

  /// Returns true if the current flavor is development.
  bool get isDev => this == AppFlavor.dev;

  /// Returns true if the current flavor is staging.
  bool get isStage => this == AppFlavor.stage;

  /// Returns true if the current flavor is production.
  bool get isProd => this == AppFlavor.prod;

  /// Human-readable display name for the flavor.
  String get displayName {
    switch (this) {
      case AppFlavor.dev:
        return 'Development';
      case AppFlavor.stage:
        return 'Staging';
      case AppFlavor.prod:
        return 'Production';
    }
  }

  /// Application name based on this flavor.
  String get appName {
    switch (this) {
      case AppFlavor.dev:
        return 'EHG-Smart-App-Dev';
      case AppFlavor.stage:
        return 'EHG-Smart-App-Stage';
      case AppFlavor.prod:
        return 'EHG-Smart-App';
    }
  }

  /// Compact uppercase tag used in logs and diagnostics.
  String get tag {
    switch (this) {
      case AppFlavor.dev:
        return '[DEV]';
      case AppFlavor.stage:
        return '[STAGE]';
      case AppFlavor.prod:
        return '[PROD]';
    }
  }
}
