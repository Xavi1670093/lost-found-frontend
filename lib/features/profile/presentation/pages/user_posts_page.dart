import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:unilost_found/core/localization/app_strings.dart';
import 'package:unilost_found/shared/widgets/skeleton_loader.dart';
import 'package:unilost_found/shared/widgets/custom_card.dart';
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
    final theme = Theme.of(context);

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Debes iniciar sesión.')));
    }

    final query = FirebaseDatabase.instance.ref('posts').orderByChild('user_id').equalTo(user.uid);
    final title = type == 'lost' ? 'Mis Peticiones' : 'Mis Hallazgos';

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: StreamBuilder(
        stream: query.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SkeletonLoader.postGrid();
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return _buildEmptyState(theme, title);
          }

          final Map<dynamic, dynamic> postsMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          final List<Map<String, dynamic>> postsList = [];

          postsMap.forEach((key, value) {
            final post = Map<String, dynamic>.from(value as Map);
            if ((type == null || post['type'] == type) && post['is_deleted'] != true) {
              postsList.add({'id': key.toString(), ...post});
            }
          });

          postsList.sort((a, b) => (b['created_at'] ?? 0).compareTo(a['created_at'] ?? 0));

          if (postsList.isEmpty) {
            return _buildEmptyState(theme, title);
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: postsList.length,
            itemBuilder: (context, index) {
              final post = postsList[index];
              final isLost = post['type'] == 'lost';

              return CustomCard(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditPostPage(postId: post['id'], post: post),
                    ),
                  );
                },
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: Center(
                          child: Icon(
                            isLost ? Icons.search_rounded : Icons.inventory_2_outlined,
                            size: 40,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post['title'] ?? 'Objeto',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _statusLabel(post['status']),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _statusColor(post['status']),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text('No hay publicaciones en $title', style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }

  String _statusLabel(dynamic status) {
    switch (status) {
      case 'matched': return 'Encontrado';
      case 'returned': return 'Devuelto';
      default: return 'Activo';
    }
  }

  Color _statusColor(dynamic status) {
    switch (status) {
      case 'matched': return Colors.orange;
      case 'returned': return Colors.green;
      default: return Colors.blue;
    }
  }
}
