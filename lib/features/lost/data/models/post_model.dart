import '../../../../core/constants/constants.dart';

class PostModel {
  final String id;
  final String userId;
  final String centerId;
  final PostType type;
  final String title;
  final String description;
  final ItemCategory category;
  final PostStatus status;
  final LatLng coords;
  final String? photoPath;
  final int createdAt;
  final int updatedAt;
  final bool isDeleted;

  PostModel({
    required this.id,
    required this.userId,
    required this.centerId,
    required this.type,
    required this.title,
    required this.description,
    required this.category,
    this.status = PostStatus.active,
    required this.coords,
    this.photoPath,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'center_id': centerId,
      'type': type.name,
      'title': title,
      'description': description,
      'category': category.name,
      'status': status.name,
      'coords': coords.toMap(),
      'photo_path': photoPath,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_deleted': isDeleted,
    };
  }

  factory PostModel.fromMap(Map<dynamic, dynamic> map) {
    return PostModel(
      id: map['id'],
      userId: map['user_id'],
      centerId: map['center_id'],
      type: PostType.values.byName(map['type']),
      title: map['title'],
      description: map['description'],
      category: ItemCategory.values.byName(map['category']),
      status: PostStatus.values.byName(map['status']),
      coords: LatLng.fromMap(map['coords']),
      photoPath: map['photo_path'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
      isDeleted: map['is_deleted'],
    );
  }
}