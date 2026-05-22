class CenterUtils {
  static const String defaultCenterId = 'uab';
  static final RegExp _validCenterId = RegExp(r'^[a-z0-9_-]+$');

  static String normalizeCenterId(
    Object? raw, {
    String fallback = defaultCenterId,
  }) {
    if (raw == null) return fallback;

    if (raw is Map) {
      return normalizeCenterId(
        raw['center_id'] ?? raw['centerId'],
        fallback: fallback,
      );
    }

    final normalized = raw.toString().trim().toLowerCase();
    if (normalized.isEmpty || !_validCenterId.hasMatch(normalized)) {
      return fallback;
    }

    return normalized;
  }
}
