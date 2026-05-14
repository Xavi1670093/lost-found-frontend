import 'package:firebase_auth/firebase_auth.dart';

class ChatModel {
  final String id;
  final String postTitle;
  final String? postImageUrl;
  final String? lastMessage;
  final int lastMessageTime;
  final int createdAt;
  final Map<String, dynamic> usersInfo;
  final List<String> participants;

  ChatModel({
    required this.id,
    required this.postTitle,
    this.postImageUrl,
    this.lastMessage,
    required this.lastMessageTime,
    required this.createdAt,
    required this.usersInfo,
    required this.participants,
  });

  factory ChatModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return ChatModel(
      id: id,
      postTitle: map['post_title'] ?? '',
      postImageUrl: map['postImageUrl']?.toString(),
      lastMessage: map['last_message']?.toString(),
      lastMessageTime: map['last_message_time'] ?? map['created_at'] ?? 0,
      createdAt: map['created_at'] ?? 0,
      usersInfo: map['usersInfo'] != null 
          ? Map<String, dynamic>.from(map['usersInfo']) 
          : {},
      participants: map['participants'] != null 
          ? List<String>.from(map['participants']) 
          : [],
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
    return usersInfo[otherUid]?['name'] ?? defaultName;
  }

  String? getOtherUserPhoto() {
    final otherUid = getOtherUserId();
    if (otherUid.isEmpty) return null;
    return usersInfo[otherUid]?['photoUrl']?.toString();
  }
}
