import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:unilost_found/features/chats/presentation/pages/chat_detail_page.dart';

import '../../../chats/presentation/pages/chat_detail_page.dart';

class PostDetailPage extends StatelessWidget {
  final Map<dynamic, dynamic> post;

  const PostDetailPage({
    super.key,
    required this.post,
  });

  Future<void> _contactOwner(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para contactar.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final postOwnerId = post['user_id']?.toString();
    final postId = post['id']?.toString();

    if (postOwnerId == null || postId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se puede abrir el chat de este objeto.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (postOwnerId == currentUser.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No puedes abrir un chat contigo mismo.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final chatsRef = FirebaseDatabase.instance.ref('chats');
      final snapshot = await chatsRef.get();

      String? existingChatId;
      Map<dynamic, dynamic>? existingChat;

      if (snapshot.value != null) {
        final chatsMap = snapshot.value as Map<dynamic, dynamic>;

        chatsMap.forEach((key, value) {
          final chat = Map<dynamic, dynamic>.from(value as Map);
          final members = Map<dynamic, dynamic>.from(chat['members'] ?? {});

          final samePost = chat['post_id'] == postId;
          final hasCurrentUser = members[currentUser.uid] == true;
          final hasOwner = members[postOwnerId] == true;

          if (samePost && hasCurrentUser && hasOwner) {
            existingChatId = key.toString();
            existingChat = chat;
          }
        });
      }

      if (existingChatId != null && existingChat != null) {
        if (!context.mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailPage(
              chatId: existingChatId!,
              chat: existingChat!,
            ),
          ),
        );

        return;
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      final newChatRef = chatsRef.push();

      final newChat = {
        'id': newChatRef.key,
        'center_id': post['center_id'] ?? 'uab',
        'post_id': postId,
        'post_title': post['title'] ?? 'Objeto',
        'post_owner_id': postOwnerId,
        'post_status': post['status'] ?? 'active',
        'members': {
          currentUser.uid: true,
          postOwnerId: true,
        },
        'last_message': null,
        'last_message_time': null,
        'created_at': now,
      };

      await newChatRef.set(newChat);

      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailPage(
            chatId: newChatRef.key!,
            chat: newChat,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al abrir chat: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLost = post['type'] == 'lost';
    final theme = Theme.of(context);
    final status = post['status'] ?? 'active';

    return Scaffold(
      appBar: AppBar(
        title: Text(post['title'] ?? 'Detalle'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250,
              width: double.infinity,
              color: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.image,
                size: 100,
                color: theme.colorScheme.primary,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text(isLost ? 'PERDIDO' : 'ENCONTRADO'),
                        backgroundColor:
                        isLost ? Colors.red.shade100 : Colors.green.shade100,
                      ),
                      Chip(
                        label: Text(
                          post['category']?.toString().toUpperCase() ?? 'OTROS',
                        ),
                      ),
                      Chip(
                        label: Text(_statusLabel(status)),
                        backgroundColor: _statusColor(status),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Text(
                    post['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    post['description'] ?? 'Sin descripción',
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 24),

                  const Divider(),

                  ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: const Text('Ubicación'),
                    subtitle: Text(post['location'] ?? 'UAB - Campus'),
                  ),

                  ListTile(
                    leading: const Icon(Icons.calendar_today_outlined),
                    title: const Text('Publicado el'),
                    subtitle: Text(
                      DateTime.fromMillisecondsSinceEpoch(
                        post['created_at'] ?? 0,
                      ).toString().split(' ')[0],
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => _contactOwner(context),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Contactar'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _statusLabel(String status) {
    switch (status) {
      case 'matched':
        return 'Encontrado';
      case 'returned':
        return 'Devuelto';
      default:
        return 'En proceso';
    }
  }

  static Color _statusColor(String status) {
    switch (status) {
      case 'matched':
        return Colors.orange.shade100;
      case 'returned':
        return Colors.green.shade100;
      default:
        return Colors.blue.shade100;
    }
  }
}