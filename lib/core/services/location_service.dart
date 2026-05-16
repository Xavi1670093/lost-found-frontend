import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  /// Calcula la distancia en metros entre dos puntos.
  static double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  /// Verifica si una ubicación está dentro de un radio determinado (en metros) desde un punto central.
  static bool isWithinRadius(double lat, double lng, double centerLat, double centerLng, double radiusInMeters) {
    final distance = calculateDistance(lat, lng, centerLat, centerLng);
    return distance <= radiusInMeters;
  }

  /// Determina si un punto está dentro de un polígono usando Ray-Casting.
  static bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
    if (polygon.isEmpty || polygon.length < 3) return false;

    bool isInside = false;
    int j = polygon.length - 1;

    for (int i = 0; i < polygon.length; i++) {
      if ((polygon[i].latitude > point.latitude) != (polygon[j].latitude > point.latitude) &&
          (point.longitude <
              (polygon[j].longitude - polygon[i].longitude) *
                  (point.latitude - polygon[i].latitude) /
                  (polygon[j].latitude - polygon[i].latitude) +
                  polygon[i].longitude)) {
        isInside = !isInside;
      }
      j = i;
    }

    return isInside;
  }
}
