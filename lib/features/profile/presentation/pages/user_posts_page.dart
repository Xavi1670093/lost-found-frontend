import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../../core/localization/app_strings.dart';

class UserPostsPage extends StatelessWidget {
  const UserPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final user = FirebaseAuth.instance.currentUser;

    // Consulta: Filtramos en /posts por nuestro user_id
    final query = FirebaseDatabase.instance
        .ref()
        .child('posts')
        .orderByChild('user_id')
        .equalTo(user?.uid);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.publishedObjects),
      ),
      body: StreamBuilder(
        stream: query.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // Si no hay datos o la ruta está vacía
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(t.userHistory), // O un texto tipo "Aún no has publicado nada"
                ],
              ),
            );
          }

          // Convertimos los datos de Firebase en una lista manejable
          final Map<dynamic, dynamic> postsMap =
          snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

          final List<Map<String, dynamic>> postsList = [];
          postsMap.forEach((key, value) {
            postsList.add({
              'id': key,
              ...Map<String, dynamic>.from(value as Map),
            });
          });

          // Ordenamos por fecha de creación (más recientes primero)
          postsList.sort((a, b) => b['created_at'].compareTo(a['created_at']));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: postsList.length,
            itemBuilder: (context, index) {
              final post = postsList[index];
              final isLost = post['type'] == 'lost';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isLost ? Colors.red.shade100 : Colors.green.shade100,
                    child: Icon(
                      isLost ? Icons.search : Icons.check_circle_outline,
                      color: isLost ? Colors.red : Colors.green,
                    ),
                  ),
                  title: Text(post['title'] ?? 'Sin título'),
                  subtitle: Text("${post['category']} · ${post['status']}"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Ver detalle del objeto
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}