import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:unilost_found/core/localization/app_strings.dart';
import 'package:unilost_found/shared/widgets/skeleton_loader.dart';
import 'chat_detail_page.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(t.messages)),
        body: Center(child: Text(t.mustLoginForChats)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t.messages, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: FirebaseDatabase.instance.ref('user_chats/${user.uid}').onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildSkeletonList();
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return _buildEmptyState(theme, t);
          }

          final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          final chatIds = data.keys.toList();

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchChatsDetails(chatIds),
            builder: (context, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting && !futureSnapshot.hasData) {
                return _buildSkeletonList();
              }

              final chats = futureSnapshot.data ?? [];

              if (chats.isEmpty && futureSnapshot.connectionState != ConnectionState.waiting) {
                return _buildEmptyState(theme, t);
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: chats.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final chatId = chats[index]['id'];
                  final chat = chats[index]['data'] as Map<dynamic, dynamic>;
                  final lastTime = chat['last_message_time'] ?? chat['created_at'] ?? 0;
                  final timeStr = _formatTime(lastTime);

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatDetailPage(chatId: chatId, chat: chat),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Icon(Icons.person_outline_rounded, color: theme.colorScheme.primary),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        chat['post_title'] ?? t.defaultItemTitle,
                                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      timeStr,
                                      style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  chat['last_message'] ?? t.noMessagesYet,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontStyle: chat['last_message'] == null ? FontStyle.italic : FontStyle.normal,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const SkeletonLoader(width: 56, height: 56, borderRadius: BorderRadius.all(Radius.circular(28))),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonLoader(width: 120, height: 16),
                  const SizedBox(height: 8),
                  const SkeletonLoader(width: double.infinity, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppStrings t) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(t.noChatsYet, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchChatsDetails(List<dynamic> chatIds) async {
    if (chatIds.isEmpty) return [];
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
    final results = await Future.wait(futures);
    final List<Map<String, dynamic>> fetchedChats = results.whereType<Map<String, dynamic>>().toList();
    fetchedChats.sort((a, b) {
      final aTime = a['data']['last_message_time'] ?? a['data']['created_at'] ?? 0;
      final bTime = b['data']['last_message_time'] ?? b['data']['created_at'] ?? 0;
      return bTime.compareTo(aTime);
    });
    return fetchedChats;
  }

  String _formatTime(int timestamp) {
    if (timestamp == 0) return "";
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    }
    return "${date.day}/${date.month}";
  }
}
