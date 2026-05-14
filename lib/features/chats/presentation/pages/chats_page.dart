import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:unilost_found/core/localization/app_strings.dart';
import 'package:unilost_found/shared/widgets/skeleton_loader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:unilost_found/shared/utils/category_utils.dart';
import '../../data/models/chat_model.dart';
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

          return FutureBuilder<List<ChatModel>>(
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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                itemCount: chats.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  final timeStr = _formatTime(chat.lastMessageTime);

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatDetailPage(chatId: chat.id, chat: chat),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Leading: Imagen del post o Icono de Categoría
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: chat.postImageUrl != null && chat.postImageUrl!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: chat.postImageUrl!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const SkeletonLoader(
                                      width: 60,
                                      height: 60,
                                      borderRadius: BorderRadius.all(Radius.circular(12)),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      width: 60,
                                      height: 60,
                                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                                      child: Icon(CategoryUtils.getCategoryIcon(chat.postCategory), color: theme.colorScheme.primary),
                                    ),
                                  )
                                : Container(
                                    width: 60,
                                    height: 60,
                                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                                    child: Icon(CategoryUtils.getCategoryIcon(chat.postCategory), color: theme.colorScheme.primary),
                                  ),
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
                                        chat.postTitle.isNotEmpty ? chat.postTitle : t.defaultItemTitle,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -0.2,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      timeStr,
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                // Subtitle: Información del OTRO usuario
                                Row(
                                  children: [
                                    ClipOval(
                                      child: chat.getOtherUserPhoto() != null
                                          ? CachedNetworkImage(
                                              imageUrl: chat.getOtherUserPhoto()!,
                                              width: 24,
                                              height: 24,
                                              fit: BoxFit.cover,
                                              errorWidget: (context, url, error) => Icon(
                                                Icons.person,
                                                size: 16,
                                                color: theme.colorScheme.onSurfaceVariant,
                                              ),
                                            )
                                          : Icon(
                                              Icons.person,
                                              size: 16,
                                              color: theme.colorScheme.onSurfaceVariant,
                                            ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        chat.getOtherUserName(t.defaultUserName),
                                        style: theme.textTheme.labelMedium?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                // Last message
                                Text(
                                  _getLastMessageText(chat, t),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                    fontStyle: (chat.lastMessage == null || chat.lastMessage == 'SYSTEM_MSG_CHAT_STARTED') 
                                      ? FontStyle.italic 
                                      : FontStyle.normal,
                                    height: 1.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: theme.colorScheme.outline,
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
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 80,
                color: theme.colorScheme.primary.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              t.noChatsYet,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              t.noMessagesYetDetail,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<ChatModel>> _fetchChatsDetails(List<dynamic> chatIds) async {
    if (chatIds.isEmpty) return [];
    final futures = chatIds.map((id) async {
      final snap = await FirebaseDatabase.instance.ref('chats/$id').get();
      if (snap.exists) {
        return ChatModel.fromMap(id.toString(), snap.value as Map<dynamic, dynamic>);
      }
      return null;
    });
    final results = await Future.wait(futures);
    final List<ChatModel> fetchedChats = results.whereType<ChatModel>().toList();
    fetchedChats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    return fetchedChats;
  }

  String _formatTime(int timestamp) {
    if (timestamp == 0) return "";
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    }
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return "$day/$month";
  }

  String _getLastMessageText(ChatModel chat, AppStrings t) {
    if (chat.lastMessage == null || chat.lastMessage!.isEmpty) {
      return t.chatStarted;
    }
    
    final msg = chat.lastMessage!;
    if (msg == 'SYSTEM_MSG_CHAT_STARTED' || msg.toLowerCase() == 'conversación iniciada') {
      return t.chatStarted;
    }
    
    return msg;
  }
}