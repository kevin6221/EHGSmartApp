/// Utility for scrubbing sensitive data (PII, tokens, passwords, API keys) from logs and breadcrumbs.
class LogSanitizer {
  LogSanitizer._();

  // Pattern for emails
  static final RegExp _emailRegex = RegExp(
    r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b',
  );

  // Pattern for Bearer / Auth tokens
  static final RegExp _bearerTokenRegex = RegExp(
    r'(Bearer\s+)[A-Za-z0-9\-_.]+',
    caseSensitive: false,
  );

  // Pattern for API keys or private tokens
  static final RegExp _apiKeyRegex = RegExp(
    r'((?:api[_-]?key|secret|token|password|auth[_-]?token)\s*[=:]\s*["\x27]?)[^"\x27\s,;]+(["\x27]?)',
    caseSensitive: false,
  );

  // Pattern for 16-digit credit cards or sensitive IDs
  static final RegExp _creditCardRegex = RegExp(
    r'\b(?:\d{4}[-\s]?){3}\d{4}\b',
  );

  /// Sanitizes [message] by masking detected sensitive patterns.
  static String sanitize(String message) {
    if (message.isEmpty) return message;

    var sanitized = message;

    // Mask emails: j***@domain.com
    sanitized = sanitized.replaceAllMapped(_emailRegex, (match) {
      final email = match.group(0)!;
      final parts = email.split('@');
      if (parts.length == 2 && parts[0].isNotEmpty) {
        final prefix = parts[0][0];
        return '$prefix***@${parts[1]}';
      }
      return '***@***.***';
    });

    // Mask Bearer tokens: Bearer [REDACTED]
    sanitized = sanitized.replaceAllMapped(_bearerTokenRegex, (match) {
      final prefix = match.group(1)!;
      return '$prefix[REDACTED_TOKEN]';
    });

    // Mask API keys and passwords: key=[REDACTED]
    sanitized = sanitized.replaceAllMapped(_apiKeyRegex, (match) {
      final prefix = match.group(1)!;
      final quote = match.group(2) ?? '';
      return '$prefix[REDACTED]$quote';
    });

    // Mask credit cards: ****-****-****-1234
    sanitized = sanitized.replaceAllMapped(_creditCardRegex, (match) {
      final digits = match.group(0)!.replaceAll(RegExp(r'\D'), '');
      if (digits.length >= 4) {
        final last4 = digits.substring(digits.length - 4);
        return '****-****-****-$last4';
      }
      return '****-****-****-****';
    });

    return sanitized;
  }
}
