import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:unilost_found/core/localization/app_strings.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
      return Scaffold(body: Center(child: Text(t.mustLogin)));
    }

    final query = FirebaseDatabase.instance.ref('posts').orderByChild('user_id').equalTo(user.uid);
    final title = type == 'lost' ? t.myLosses : t.myFindings;

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: StreamBuilder(
        stream: query.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          // Preprocesamos los datos para determinar qué sliver mostrar
          final bool isWaiting = snapshot.connectionState == ConnectionState.waiting;
          final bool hasNoData = !snapshot.hasData || snapshot.data!.snapshot.value == null;
          
          List<Map<String, dynamic>> postsList = [];
          if (!isWaiting && !hasNoData) {
            final Map<dynamic, dynamic> postsMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            postsMap.forEach((key, value) {
              final post = Map<String, dynamic>.from(value as Map);
              if ((type == null || post['type'] == type) && post['is_deleted'] != true) {
                postsList.add({'id': key.toString(), ...post});
              }
            });
            postsList.sort((a, b) => (b['created_at'] ?? 0).compareTo(a['created_at'] ?? 0));
          }

          return CustomScrollView(
            slivers: [
              // Estado de carga (Sliver)
              if (isWaiting)
                SkeletonLoader.postGrid(),

              // Estado vacío (Box envuelto en Sliver)
              if (!isWaiting && (hasNoData || postsList.isEmpty))
                SliverToBoxAdapter(child: _buildEmptyState(theme, title, t))
              
              // Estado con datos (Sliver)
              else if (!isWaiting)
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
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
                                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  ),
                                  child: post['imageUrl'] != null && post['imageUrl'].toString().isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                          child: CachedNetworkImage(
                                            imageUrl: post['imageUrl'],
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                            errorWidget: (context, url, error) => _buildCardIconFallback(theme, isLost),
                                          ),
                                        )
                                      : _buildCardIconFallback(theme, isLost),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      post['title'] ?? t.defaultItemTitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _statusLabel(post['status'], t),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: _statusColor(post['status'], theme),
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
                      childCount: postsList.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCardIconFallback(ThemeData theme, bool isLost) {
    return Center(
      child: Icon(
        isLost ? Icons.search_rounded : Icons.inventory_2_outlined,
        size: 40,
        color: theme.colorScheme.primary.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, String title, AppStrings t) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(t.noObjectsFoundForTitle(title), style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }

  String _statusLabel(dynamic status, AppStrings t) {
    switch (status) {
      case 'matched': return t.statusMatched;
      case 'returned': return t.statusReturned;
      default: return t.statusInProcess;
    }
  }

  Color _statusColor(dynamic status, ThemeData theme) {
    switch (status) {
      case 'matched': return Colors.orange;
      case 'returned': return Colors.green;
      default: return theme.colorScheme.primary;
    }
  }
}
