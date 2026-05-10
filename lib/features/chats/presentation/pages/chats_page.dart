import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'chat_detail_page.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text('Debes iniciar sesión para ver tus chats.'),
      );
    }

    return StreamBuilder<DatabaseEvent>(
      stream: FirebaseDatabase.instance.ref('user_chats/${user.uid}').onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Center(
            child: Text('Todavía no tienes chats.'),
          );
        }

        // data contiene los IDs de los chats autorizados
        final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
        final chatIds = data.keys.toList();

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchChatsDetails(chatIds),
          builder: (context, futureSnapshot) {
            if (futureSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final chats = futureSnapshot.data ?? [];

            if (chats.isEmpty) {
              return const Center(
                child: Text('Todavía no tienes chats.'),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: chats.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final chatId = chats[index]['id'];
                final chat = chats[index]['data'] as Map<dynamic, dynamic>;

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _statusColor(chat['post_status'] ?? 'active'),
                      child: const Icon(Icons.chat_bubble_outline),
                    ),
                    title: Text(chat['post_title'] ?? 'Objeto'),
                    subtitle: Text(
                      chat['last_message'] ?? 'Sin mensajes todavía',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatDetailPage(
                            chatId: chatId,
                            chat: chat,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // Función para obtener los detalles de los chats a partir de sus IDs
  Future<List<Map<String, dynamic>>> _fetchChatsDetails(List<dynamic> chatIds) async {
    final List<Map<String, dynamic>> fetchedChats = [];

    for (final id in chatIds) {
      final snap = await FirebaseDatabase.instance.ref('chats/$id').get();
      if (snap.exists) {
        fetchedChats.add({
          'id': id.toString(),
          'data': snap.value as Map<dynamic, dynamic>,
        });
      }
    }

    // Ordenar por fecha del último mensaje
    fetchedChats.sort((a, b) {
      final aTime = a['data']['last_message_time'] ?? a['data']['created_at'] ?? 0;
      final bTime = b['data']['last_message_time'] ?? b['data']['created_at'] ?? 0;
      return bTime.compareTo(aTime);
    });

    return fetchedChats;
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
}