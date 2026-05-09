import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

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
          content: Text('Error al enviar mensaje: $e'),
          backgroundColor: Colors.red,
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
    final user = FirebaseAuth.instance.currentUser;
    final postTitle = widget.chat['post_title'] ?? 'Objeto';
    final postStatus = widget.chat['post_status'] ?? 'active';

    return Scaffold(
      appBar: AppBar(
        title: Text(postTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              label: Text(_statusLabel(postStatus)),
              backgroundColor: _statusColor(postStatus),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
            child: Row(
              children: [
                const Icon(Icons.inventory_2_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    postTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: FirebaseDatabase.instance
                  .ref('messages/${widget.chatId}')
                  .orderByChild('timestamp')
                  .onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    snapshot.data!.snapshot.value == null) {
                  return const Center(
                    child: Text('Todavía no hay mensajes.'),
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
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message['sender_id'] == user?.uid;

                    return Align(
                      alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              message['text'] ?? '',
                              style: TextStyle(
                                color: isMe
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTime(message['timestamp']),
                              style: TextStyle(
                                fontSize: 11,
                                color: isMe
                                    ? Theme.of(context)
                                    .colorScheme
                                    .onPrimary
                                    .withValues(alpha: 0.75)
                                    : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _sendMessage,
                    icon: _sending
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'matched':
        return 'Encontrado';
      case 'returned':
        return 'Devuelto';
      default:
        return 'En proceso';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'matched':
        return Colors.orange.shade100;
      case 'returned':
        return Colors.green.shade100;
      default:
        return Colors.blue.shade100;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}