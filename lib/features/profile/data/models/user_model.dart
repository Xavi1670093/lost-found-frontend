import '../../../../core/constants/constants.dart';

class UserModel {
  final String id;
  final String centerId;
  final UserRole role;
  final String email;
  final String name;
  final String? photoPath;
  final LatLng? lastGps;
  final Map<String, bool> settings;
  final int createdAt;
  final int updatedAt;
  final bool isDeleted;

  UserModel({
    required this.id,
    required this.centerId,
    this.role = UserRole.student,
    required this.email,
    required this.name,
    this.photoPath,
    this.lastGps,
    this.settings = const {'push_notifications': true, 'dark_mode': false},
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'center_id': centerId,
      'role': role.name,
      'email': email,
      'name': name,
      'photo_path': photoPath,
      'last_gps': lastGps?.toMap(),
      'settings': settings,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_deleted': isDeleted,
    };
  }

  factory UserModel.fromMap(Map<dynamic, dynamic> map) {
    return UserModel(
      id: map['id'],
      centerId: map['center_id'],
      role: UserRole.values.byName(map['role']),
      email: map['email'],
      name: map['name'],
      photoPath: map['photo_path'],
      lastGps: map['last_gps'] != null ? LatLng.fromMap(map['last_gps']) : null,
      settings: Map<String, bool>.from(map['settings']),
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
      isDeleted: map['is_deleted'],
    );
  }
}