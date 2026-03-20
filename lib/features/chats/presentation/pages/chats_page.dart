import 'package:flutter/material.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final chats = [
      ('Usuario 1', 'Hola, he perdido 4 macs y 1 iphone'),
      ('Usuario 2', 'Tienes mi mochila, devuelvemela'),
      ('Usuario 3', 'Dame 5 gramillos'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: chats.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final chat = chats[index];
          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(chat.$1),
              subtitle: Text(chat.$2),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }
}