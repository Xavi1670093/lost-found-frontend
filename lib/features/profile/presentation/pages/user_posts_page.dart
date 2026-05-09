import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../../core/localization/app_strings.dart';
import 'edit_post_page.dart';

class UserPostsPage extends StatelessWidget {
  final String? type;

  const UserPostsPage({
    super.key,
    this.type,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Debes iniciar sesión.'),
        ),
      );
    }

    final query = FirebaseDatabase.instance
        .ref()
        .child('posts')
        .orderByChild('user_id')
        .equalTo(user.uid);

    final title = type == 'lost' ? 'Peticiones' : t.publishedObjects;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: StreamBuilder(
        stream: query.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return _EmptyState(text: t.userHistory);
          }

          final Map<dynamic, dynamic> postsMap =
          snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

          final List<Map<String, dynamic>> postsList = [];

          postsMap.forEach((key, value) {
            final post = Map<String, dynamic>.from(value as Map);

            final matchesType = type == null || post['type'] == type;
            final isNotDeleted = post['is_deleted'] != true;

            if (matchesType && isNotDeleted) {
              postsList.add({
                'id': key.toString(),
                ...post,
              });
            }
          });

          postsList.sort((a, b) {
            final aDate = a['created_at'] ?? 0;
            final bDate = b['created_at'] ?? 0;
            return bDate.compareTo(aDate);
          });

          if (postsList.isEmpty) {
            return _EmptyState(
              text: type == 'lost'
                  ? 'Todavía no tienes peticiones.'
                  : 'Todavía no has publicado objetos.',
            );
          }

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
                    backgroundColor:
                    isLost ? Colors.red.shade100 : Colors.green.shade100,
                    child: Icon(
                      isLost ? Icons.search : Icons.check_circle_outline,
                      color: isLost ? Colors.red : Colors.green,
                    ),
                  ),
                  title: Text(post['title'] ?? 'Sin título'),
                  subtitle: Text(
                    '${_categoryLabel(post['category'])} · ${_statusLabel(post['status'])}',
                  ),
                  trailing: const Icon(Icons.edit),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditPostPage(
                          postId: post['id'],
                          post: post,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  static String _statusLabel(dynamic status) {
    switch (status) {
      case 'matched':
        return 'Encontrado';
      case 'returned':
        return 'Devuelto';
      default:
        return 'En proceso';
    }
  }

  static String _categoryLabel(dynamic category) {
    switch (category) {
      case 'keys':
        return 'Llaves';
      case 'wallet':
        return 'Cartera';
      case 'devices':
        return 'Dispositivo';
      case 'clothing':
        return 'Ropa';
      case 'bags':
        return 'Mochila/Bolsa';
      case 'study':
        return 'Material de estudio';
      case 'accessories':
        return 'Accesorios';
      default:
        return 'Otros';
    }
  }
}

class _EmptyState extends StatelessWidget {
  final String text;

  const _EmptyState({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(text),
        ],
      ),
    );
  }
}