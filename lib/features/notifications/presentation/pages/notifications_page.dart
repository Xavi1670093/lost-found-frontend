import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final ref = FirebaseDatabase.instance.ref('notifications/$uid');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notificaciones"),
      ),
      body: StreamBuilder(
        stream: ref.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(
              child: Text("No tienes notificaciones aún"),
            );
          }

          final Map<dynamic, dynamic> data = snapshot.data!.snapshot.value as Map;

          // Convertimos a lista y ordenamos por fecha (más reciente arriba)
          final notifications = data.entries.toList()
            ..sort((a, b) => (b.value['timestamp'] ?? 0).compareTo(a.value['timestamp'] ?? 0));

          return ListView.builder(
            itemCount: notifications.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final notif = notifications[index].value;
              final notifId = notifications[index].key;
              final isMatch = notif['type'] == 'match';

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isMatch ? Colors.orange.shade100 : Colors.blue.shade100,
                  child: Icon(
                    isMatch ? Icons.auto_awesome : Icons.info_outline,
                    color: isMatch ? Colors.orange : Colors.blue,
                  ),
                ),
                title: Text(notif['title'] ?? 'Aviso'),
                subtitle: Text(notif['message'] ?? ''),
                trailing: notif['is_read'] == false
                    ? const Icon(Icons.circle, color: Colors.red, size: 10)
                    : null,
                onTap: () {
                  // Marcar como leída en Firebase al pulsar
                  ref.child(notifId).update({'is_read': true});
                },
              );
            },
          );
        },
      ),
    );
  }
}