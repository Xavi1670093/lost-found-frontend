import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:unilost_found/core/localization/app_strings.dart';

class ChatDetailPage extends StatefulWidget {
  final String chatId;
  final Map<dynamic, dynamic> chat;

  const ChatDetailPage({
    super.key,
    required this.chatId,
    required this.chat,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  bool _sending = false;

  Future<void> _sendMessage() async {
    final t = AppStrings.of(context);
    final text = _messageController.text.trim();
    if (text.isEmpty || _sending) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _sending = true);

    try {
      final now = DateTime.now().millisecondsSinceEpoch;

      final messageRef = FirebaseDatabase.instance
          .ref('messages/${widget.chatId}')
          .push();

      await messageRef.set({
        'id': messageRef.key,
        'sender_id': user.uid,
        'text': text,
        'timestamp': now,
      });

      await FirebaseDatabase.instance.ref('chats/${widget.chatId}').update({
        'last_message': text,
        'last_message_time': now,
      });

      _messageController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${t.sendError}: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';

    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final postTitle = widget.chat['post_title'] ?? t.defaultItemTitle;
    final postStatus = widget.chat['post_status'] ?? 'active';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(postTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(_statusLabel(postStatus, t), style: TextStyle(fontSize: 12, color: theme.colorScheme.primary)),
          ],
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: FirebaseDatabase.instance
                  .ref('messages/${widget.chatId}')
                  .orderByChild('timestamp')
                  .onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded, size: 48, color: theme.colorScheme.outline),
                        const SizedBox(height: 16),
                        Text(t.noMessagesYetDetail, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  );
                }

                final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                final messages = data.values
                    .map((e) => Map<dynamic, dynamic>.from(e as Map))
                    .toList();

                messages.sort(
                  (a, b) => (a['timestamp'] ?? 0).compareTo(b['timestamp'] ?? 0),
                );

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message['sender_id'] == user?.uid;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isMe
                                ? theme.colorScheme.primary
                                : theme.colorScheme.surfaceVariant.withOpacity(0.5),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: Radius.circular(isMe ? 20 : 4),
                              bottomRight: Radius.circular(isMe ? 4 : 20),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                message['text'] ?? '',
                                style: TextStyle(
                                  color: isMe
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onSurface,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTime(message['timestamp']),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isMe
                                      ? theme.colorScheme.onPrimary.withOpacity(0.7)
                                      : theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Container(
            padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).padding.bottom + 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: t.typeMessageHint,
                        hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filled(
                  onPressed: _sending ? null : _sendMessage,
                  icon: _sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String status, AppStrings t) {
    switch (status) {
      case 'matched': return t.statusMatched;
      case 'returned': return t.statusReturned;
      default: return t.statusInProcess;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
