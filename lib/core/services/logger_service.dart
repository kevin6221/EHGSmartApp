import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../security/log_sanitizer.dart';

/// Senior-level secure logger abstraction that enforces log level policies,
/// sanitizes sensitive data (PII, tokens), and respects flavor-specific logging flags.
class AppLogger {
  AppLogger._();

  /// Logs a debug-level message. Silenced in production or when logging is disabled.
  static void d(String message, {String? tag}) {
    _log(LogLevel.debug, message, tag: tag);
  }

  /// Logs an informational message. Silenced in production or when logging is disabled.
  static void i(String message, {String? tag}) {
    _log(LogLevel.info, message, tag: tag);
  }

  /// Logs a warning message.
  static void w(String message, {String? tag, dynamic error, StackTrace? stack}) {
    _log(LogLevel.warning, message, tag: tag, error: error, stack: stack);
  }

  /// Logs an error message.
  static void e(String message, {String? tag, dynamic error, StackTrace? stack}) {
    _log(LogLevel.error, message, tag: tag, error: error, stack: stack);
  }

  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stack,
  }) {
    final hasConfig = AppConfig.isInitialized;
    final enableLogging = hasConfig ? AppConfig.instance.enableLogging : kDebugMode;

    // Completely silence debug and info logs if logging is disabled for this flavor
    if (!enableLogging && (level == LogLevel.debug || level == LogLevel.info)) {
      return;
    }

    final flavorTag = hasConfig ? AppConfig.instance.flavor.tag : '[INIT]';
    final levelTag = level.label;
    final customTag = tag != null ? '[$tag]' : '';
    final sanitizedMessage = LogSanitizer.sanitize(message);

    final formatted = '$flavorTag $levelTag $customTag $sanitizedMessage';
    debugPrint(formatted);

    if (error != null) {
      debugPrint('$flavorTag $levelTag Details: $error');
    }
    if (stack != null && (hasConfig ? AppConfig.instance.flavor.isDev : kDebugMode)) {
      debugPrint('$flavorTag $levelTag Stack: $stack');
    }
  }
}

enum LogLevel {
  debug('[DEBUG]'),
  info('[INFO]'),
  warning('[WARN]'),
  error('[ERROR]');

  final String label;
  const LogLevel(this.label);
}
