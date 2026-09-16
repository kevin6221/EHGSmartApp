import '../config/app_flavor.dart';

/// Centralized security policies and configuration constraints for the application.
class SecurityConfig {
  SecurityConfig._();

  /// Enforces HTTPS across all remote network requests.
  static const bool enforceHttps = true;

  /// Determines whether cleartext (HTTP) traffic is permitted for local debugging.
  ///
  /// Strictly prohibited in [AppFlavor.stage] and [AppFlavor.prod].
  static bool allowCleartextTraffic(AppFlavor flavor) {
    return flavor.isDev;
  }

  /// Flag indicating whether detailed error stack traces should be shown to users.
  ///
  /// In production, errors are captured by Crashlytics and users see user-friendly messages.
  static bool showDetailedErrors(AppFlavor flavor) {
    return flavor.isDev;
  }

  /// Recommended max idle timeout before sensitive health data session expires (in minutes).
  static const int sessionTimeoutMinutes = 30;
}
