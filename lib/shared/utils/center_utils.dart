class CenterUtils {
  static const String defaultCenterId = 'uab';
  static final RegExp _validCenterId = RegExp(r'^[a-z0-9_-]+$');

  static String normalizeCenterId(
    Object? raw, {
    String fallback = defaultCenterId,
  }) {
    final normalizedFallback = _normalizeScalar(fallback) ?? defaultCenterId;
    if (raw == null) return normalizedFallback;

    if (raw is Map) {
      for (final entry in raw.entries) {
        final key = entry.key.toString().toLowerCase().replaceAll('-', '_');
        if (key == 'center_id' || key == 'centerid') {
          return normalizeCenterId(entry.value, fallback: normalizedFallback);
        }
      }
      return normalizedFallback;
    }

    return _normalizeScalar(raw) ?? normalizedFallback;
  }

  static String? _normalizeScalar(Object raw) {
    final normalized = raw.toString().trim().toLowerCase();
    if (normalized.isEmpty || !_validCenterId.hasMatch(normalized)) {
      return null;
    }
    return normalized;
  }
}
