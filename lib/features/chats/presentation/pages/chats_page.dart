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
      stream: FirebaseDatabase.instance.ref('chats').onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Center(
            child: Text('Todavía no tienes chats.'),
          );
        }

        final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

        final chats = <Map<String, dynamic>>[];

        data.forEach((key, value) {
          final chat = Map<dynamic, dynamic>.from(value as Map);
          final members = Map<dynamic, dynamic>.from(chat['members'] ?? {});

          if (members[user.uid] == true) {
            chats.add({
              'id': key.toString(),
              'data': chat,
            });
          }
        });

        chats.sort((a, b) {
          final aTime = a['data']['last_message_time'] ?? a['data']['created_at'] ?? 0;
          final bTime = b['data']['last_message_time'] ?? b['data']['created_at'] ?? 0;
          return bTime.compareTo(aTime);
        });

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