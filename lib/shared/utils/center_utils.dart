import 'package:firebase_database/firebase_database.dart';

class CenterUtils {
  static const String defaultCenterId = 'uab';
  static final RegExp _validCenterId = RegExp(r'^[a-z0-9_-]+$');

  // Caché en memoria para los datos de los centros
  static final Map<String, Map<dynamic, dynamic>> _cache = {};

  /// Guarda los datos de un centro en caché
  static void cacheCenter(String centerId, Map<dynamic, dynamic> data) {
    _cache[centerId.toLowerCase()] = data;
  }

  /// Recupera los datos de un centro de la caché
  static Map<dynamic, dynamic>? getCachedCenter(String centerId) {
    return _cache[centerId.toLowerCase()];
  }

  /// Precarga todos los centros desde la base de datos de Firebase
  static Future<void> preloadCenters() async {
    try {
      final snap = await FirebaseDatabase.instance.ref('centers').get();
      if (snap.exists && snap.value is Map) {
        final data = Map<dynamic, dynamic>.from(snap.value as Map);
        data.forEach((key, val) {
          if (val is Map) {
            cacheCenter(key.toString(), Map<dynamic, dynamic>.from(val));
          }
        });
      }
    } catch (_) {
      // Ignorar fallos de red durante la precarga, se resolverá bajo demanda
    }
  }

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

  /// Compara si las coordenadas dadas coinciden exactamente con las del centro por defecto.
  static bool isDefaultCenterLocation(String centerId, double lat, double lng) {
    final centerData = getCachedCenter(centerId);
    if (centerData == null) return false;
    final bounds = centerData['bounds'];
    if (bounds is Map) {
      final double minLat = double.tryParse(bounds['minLat']?.toString() ?? '') ?? 0.0;
      final double maxLat = double.tryParse(bounds['maxLat']?.toString() ?? '') ?? 0.0;
      final double minLng = double.tryParse(bounds['minLng']?.toString() ?? '') ?? 0.0;
      final double maxLng = double.tryParse(bounds['maxLng']?.toString() ?? '') ?? 0.0;
      if (minLat == 0.0 || maxLat == 0.0 || minLng == 0.0 || maxLng == 0.0) return false;
      final double defaultLat = (minLat + maxLat) / 2;
      final double defaultLng = (minLng + maxLng) / 2;
      return (lat - defaultLat).abs() < 1e-7 && (lng - defaultLng).abs() < 1e-7;
    }
    return false;
  }
}
