import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../../core/localization/app_strings.dart';

class UserClaimsPage extends StatelessWidget {
  const UserClaimsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final user = FirebaseAuth.instance.currentUser;

    // Buscamos en /posts los objetos que TÚ has publicado
    final query = FirebaseDatabase.instance
        .ref()
        .child('posts')
        .orderByChild('user_id')
        .equalTo(user?.uid);

    return Scaffold(
      appBar: AppBar(title: const Text("Mis Peticiones")),
      body: StreamBuilder(
        stream: query.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Si no hay datos, mostramos el texto de "historial vacío"
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return Center(child: Text(t.userHistory));
          }

          final Map<dynamic, dynamic> postsMap = snapshot.data!.snapshot.value as Map;
          final List<Map<String, dynamic>> myLostItems = [];

          postsMap.forEach((key, value) {
            // Según el esquema: type == 'lost' son tus peticiones de ayuda
            if (value['type'] == 'lost' && value['is_deleted'] == false) {
              myLostItems.add(Map<String, dynamic>.from(value));
            }
          });

          if (myLostItems.isEmpty) {
            return const Center(child: Text("No has publicado ningún objeto perdido"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: myLostItems.length,
            itemBuilder: (context, index) {
              final item = myLostItems[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.orangeAccent,
                    child: Icon(Icons.help_outline, color: Colors.white),
                  ),
                  title: Text(item['title'] ?? 'Sin título'),
                  subtitle: Text("${item['category']} · ${item['status']}"),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          );
        },
      ),
    );
  }
}