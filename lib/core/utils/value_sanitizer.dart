class ValueSanitizer {
  /// Trims whitespace and removes invisible/zero-width characters from a string.
  static String sanitizeString(String? value) {
    if (value == null) return '';
    return value
        .replaceAll(RegExp(r'[\u200B-\u200D\uFEFF\u00A0]'), '')
        .trim();
  }

  /// Sanitizes a nullable string, returning null if empty after sanitization.
  static String? sanitizeNullableString(String? value) {
    if (value == null) return null;
    final sanitized = sanitizeString(value);
    return sanitized.isEmpty ? null : sanitized;
  }

  /// Sanitizes a UUID string, removing invisible characters and trimming.
  static String sanitizeUUID(String? value) {
    if (value == null) return '';
    return sanitizeString(value);
  }

  /// Logs each key/value in a map and sanitizes all string values.
  static Map<String, dynamic> logAndSanitize(
    Map<String, dynamic> payload, {
    String label = 'payload',
  }) {
    final sanitized = <String, dynamic>{};
    for (final entry in payload.entries) {
      final value = entry.value;
      if (value is String) {
        sanitized[entry.key] = sanitizeString(value);
      } else {
        sanitized[entry.key] = value;
      }
      print('$label[${entry.key}]: ${sanitized[entry.key]} (${sanitized[entry.key].runtimeType})');
    }
    return sanitized;
  }
}
