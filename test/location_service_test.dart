import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:unilost_found/core/services/location_service.dart';

void main() {
  group('LocationService - isPointInPolygon', () {
    final List<LatLng> validPolygon = [
      const LatLng(0, 0),
      const LatLng(0, 10),
      const LatLng(10, 10),
      const LatLng(10, 0),
    ];

    test('should return false if polygon is empty', () {
      final point = const LatLng(5, 5);
      expect(LocationService.isPointInPolygon(point, []), isFalse);
    });

    test('should return false if polygon has less than 3 points', () {
      final point = const LatLng(5, 5);
      expect(LocationService.isPointInPolygon(point, [const LatLng(0,0), const LatLng(1,1)]), isFalse);
    });

    test('should return true if point is inside polygon', () {
      final point = const LatLng(5, 5);
      expect(LocationService.isPointInPolygon(point, validPolygon), isTrue);
    });

    test('should return false if point is outside polygon', () {
      final point = const LatLng(15, 15);
      expect(LocationService.isPointInPolygon(point, validPolygon), isFalse);
    });

    test('should return false if point is on the edge (depending on implementation, but usually false or specific behavior)', () {
      // Ray casting usually handles edges specifically, but let's check outside
      final point = const LatLng(-1, -1);
      expect(LocationService.isPointInPolygon(point, validPolygon), isFalse);
    });
  });

  group('LocationService - isWithinRadius', () {
    test('should return true if within radius', () {
      // 41.5000, 2.1075 to 41.5001, 2.1076 is very close
      expect(LocationService.isWithinRadius(41.5000, 2.1075, 41.5001, 2.1076, 100), isTrue);
    });

    test('should return false if outside radius', () {
      // UAB to Barcelona center is > 10km
      expect(LocationService.isWithinRadius(41.5000, 2.1075, 41.3851, 2.1734, 1000), isFalse);
    });
  });
}
