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
            // Solo mostramos loading si NO HAY DATOS PREVIOS.
            // Si ya hay datos, mantenemos la lista visible mientras se actualiza en silencio.
            if (futureSnapshot.connectionState == ConnectionState.waiting && !futureSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final chats = futureSnapshot.data ?? [];

            if (chats.isEmpty && futureSnapshot.connectionState != ConnectionState.waiting) {
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

  // Función optimizada para obtener detalles de múltiples chats simultáneamente
  Future<List<Map<String, dynamic>>> _fetchChatsDetails(List<dynamic> chatIds) async {
    if (chatIds.isEmpty) return [];

    // 1. Mapeamos cada ID a un Future que descarga su contenido
    final futures = chatIds.map((id) async {
      final snap = await FirebaseDatabase.instance.ref('chats/$id').get();
      if (snap.exists) {
        return {
          'id': id.toString(),
          'data': snap.value as Map<dynamic, dynamic>,
        };
      }
      return null;
    });

    // 2. Ejecutamos TODAS las peticiones a Firebase al mismo tiempo (Concurrencia)
    final results = await Future.wait(futures);

    // 3. Filtramos los nulos (por si algún chat fue eliminado en la BD)
    final List<Map<String, dynamic>> fetchedChats = results
        .whereType<Map<String, dynamic>>()
        .toList();

    // 4. Ordenar por fecha del último mensaje
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