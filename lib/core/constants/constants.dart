enum PostType { lost, found }
enum PostStatus { active, matched, returned }
enum UserRole { student, janitor, admin }

enum ItemCategory {
  accessories, clothing, devices, wallet, keys, bags, study, other
}

class LatLng {
  final double lat;
  final double lng;

  LatLng({required this.lat, required this.lng});

  Map<String, dynamic> toMap() => {'lat': lat, 'lng': lng};
  factory LatLng.fromMap(Map<dynamic, dynamic> map) =>
      LatLng(lat: map['lat'], lng: map['lng']);
}