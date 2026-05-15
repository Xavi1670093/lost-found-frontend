import 'package:geolocator/geolocator.dart';

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
}
