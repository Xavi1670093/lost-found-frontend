class ChatModel {
  final String id;
  final String centerId;
  final String postId;
  final Map<String, bool> members;
  final String? lastMessage;
  final int? lastMessageTime;
  final int createdAt;

  ChatModel({
    required this.id,
    required this.centerId,
    required this.postId,
    required this.members,
    this.lastMessage,
    this.lastMessageTime,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'center_id': centerId,
      'post_id': postId,
      'members': members,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime,
      'created_at': createdAt,
    };
  }
}

class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final int timestamp;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'sender_id': senderId,
    'text': text,
    'timestamp': timestamp,
  };
}