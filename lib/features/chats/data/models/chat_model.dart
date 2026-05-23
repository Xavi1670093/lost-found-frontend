import 'package:firebase_auth/firebase_auth.dart';

/// Modelo de datos que representa una sesión de chat entre dos estudiantes.
///
/// Contiene metadatos desnormalizados del objeto relacionado (título, categoría,
/// imagen), el estado de actividad del canal, el último mensaje intercambiado
/// y la información de perfil básica de los participantes para evitar consultas
/// repetidas a la base de datos de usuarios.
class ChatModel {
  /// Identificador único del chat.
  final String id;
  
  /// Título del post asociado al chat.
  final String postTitle;
  
  /// URL de la imagen del post.
  final String? postImageUrl;
  
  /// Categoría del objeto reportado en el post.
  final String postCategory;
  
  /// Contenido textual del último mensaje enviado en esta conversación.
  final String? lastMessage;
  
  /// Timestamp de envío del último mensaje (milisegundos desde la época).
  final int lastMessageTime;
  
  /// Timestamp de creación de la sala de chat.
  final int createdAt;
  
  /// Mapa desnormalizado con los nombres y fotos de perfil de los usuarios.
  final Map<String, dynamic> usersInfo;
  
  /// Listado con los IDs de los usuarios participantes del chat.
  final List<String> participants;
  
  /// ID del usuario que publicó el objeto.
  final String postOwnerId;
  
  /// Indica si el chat sigue activo para enviar mensajes o ha sido deshabilitado.
  final bool isActive;
  
  /// Motivo por el cual el chat fue cerrado (ej. 'deleted' o 'resolved').
  final String? disabledReason;

  ChatModel({
    required this.id,
    required this.postTitle,
    this.postImageUrl,
    required this.postCategory,
    this.lastMessage,
    required this.lastMessageTime,
    required this.createdAt,
    required this.usersInfo,
    required this.participants,
    required this.postOwnerId,
    this.isActive = true,
    this.disabledReason,
  });

  /// Factory para construir un [ChatModel] a partir de la respuesta cruda de RTDB.
  ///
  /// Cuenta con lógica de transformación flexible para:
  /// 1. Soportar la estructura de miembros representada como mapa (clave: uid)
  ///    o lista tradicional de participantes.
  /// 2. Tolerancia a inconsistencias de nomenclatura (camelCase vs snake_case) en
  ///    las propiedades provenientes del backend de Firebase.
  factory ChatModel.fromMap(String id, Map<dynamic, dynamic> map) {
    // Se procesa la lista de participantes mapeando la estructura dinámica de RTDB.
    // 'members' es preferido por eficiencia en reglas de seguridad en RTDB (objeto con UIDs como clave).
    // 'participants' se mantiene como fallback para retrocompatibilidad con esquemas antiguos.
    List<String> participantsList = [];
    if (map['members'] != null && map['members'] is Map) {
      participantsList = (map['members'] as Map).keys.map((e) => e.toString()).toList();
    } else if (map['participants'] != null) {
      participantsList = List<String>.from(map['participants']);
    }

    return ChatModel(
      id: id,
      postTitle: map['postTitle'] ?? map['post_title'] ?? '',
      postImageUrl: map['postImageUrl']?.toString() ?? map['post_image_url']?.toString(),
      postCategory: map['post_category']?.toString() ?? map['postCategory']?.toString() ?? map['category']?.toString() ?? 'others',
      lastMessage: map['last_message']?.toString(),
      lastMessageTime: map['last_message_time'] ?? map['created_at'] ?? 0,
      createdAt: map['created_at'] ?? 0,
      usersInfo: map['usersInfo'] != null 
          ? Map<String, dynamic>.from(map['usersInfo']) 
          : {},
      participants: participantsList,
      postOwnerId: map['post_owner_id']?.toString() ?? '',
      isActive: map['isActive'] ?? map['is_active'] ?? true,
      disabledReason: map['disabledReason'] ?? map['disabled_reason'],
    );
  }

  String getOtherUserId() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    return participants.firstWhere(
      (uid) => uid != currentUserId,
      orElse: () => '',
    );
  }

  String getOtherUserName(String defaultName) {
    final otherUid = getOtherUserId();
    if (otherUid.isEmpty) return defaultName;
    final info = usersInfo[otherUid];
    return info?['displayName'] ?? info?['name'] ?? 'Usuario';
  }

  String? getOtherUserPhoto() {
    final otherUid = getOtherUserId();
    if (otherUid.isEmpty) return null;
    final info = usersInfo[otherUid];
    return info?['photoUrl']?.toString() ?? 
           info?['photo_url']?.toString() ?? 
           info?['profile_image_url']?.toString() ??
           info?['imageUrl']?.toString();
  }

  String getPublisherName(String defaultName) {
    final uid = postOwnerId.isNotEmpty ? postOwnerId : getOtherUserId();
    if (uid.isEmpty) return defaultName;
    final info = usersInfo[uid];
    return info?['displayName'] ?? info?['name'] ?? defaultName;
  }

  String? getPublisherPhoto() {
    final uid = postOwnerId.isNotEmpty ? postOwnerId : getOtherUserId();
    if (uid.isEmpty) return null;
    final info = usersInfo[uid];
    return info?['photoUrl']?.toString() ?? 
           info?['photo_url']?.toString() ?? 
           info?['profile_image_url']?.toString() ??
           info?['imageUrl']?.toString();
  }
}
