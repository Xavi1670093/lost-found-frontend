import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:unilost_found/core/localization/app_strings.dart';
import 'package:unilost_found/shared/utils/app_notifications.dart';
import 'package:unilost_found/features/chats/data/models/chat_model.dart';
import 'package:unilost_found/features/chats/presentation/pages/chat_detail_page.dart';
import 'package:unilost_found/features/home/presentation/pages/post_detail_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _markUnreadNotificationsAsRead();
  }

  Future<void> _markUnreadNotificationsAsRead() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snap = await FirebaseDatabase.instance
          .ref('users/${user.uid}/notifications')
          .orderByChild('read')
          .equalTo(false)
          .get();

      if (!snap.exists || snap.value == null) return;

      final data = snap.value;
      final unreadIds = <String>[];
      if (data is Map) {
        data.forEach((key, val) {
          unreadIds.add(key.toString());
        });
      }

      if (unreadIds.isEmpty) return;

      try {
        final callable = FirebaseFunctions.instance.httpsCallable('markNotificationsRead');
        await callable.call({'notificationIds': unreadIds});
        debugPrint("ULF_DEBUG: Cloud Function markNotificationsRead completed successfully.");
      } catch (e) {
        debugPrint("ULF_DEBUG: Cloud Function failed, falling back to local database update: $e");
        
        final updates = <String, dynamic>{};
        for (final id in unreadIds) {
          updates['users/${user.uid}/notifications/$id/read'] = true;
        }
        await FirebaseDatabase.instance.ref().update(updates);
      }
    } catch (e) {
      debugPrint("ULF_DEBUG: Error marking unread notifications: $e");
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseDatabase.instance
          .ref('users/${user.uid}/notifications/$notificationId/read')
          .set(true);
    } catch (e) {
      debugPrint("ULF_DEBUG: Error marking notification as read: $e");
    }
  }

  Future<void> _markAllAsRead(List<String> notificationIds) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || notificationIds.isEmpty) return;

    setState(() => _isProcessing = true);
    try {
      final updates = <String, dynamic>{};
      for (final id in notificationIds) {
        updates['users/${user.uid}/notifications/$id/read'] = true;
      }
      await FirebaseDatabase.instance.ref().update(updates);
      if (!mounted) return;
      final t = AppStrings.of(context);
      AppNotifications.showSuccess(context, t.postPublishedSuccess); // fallback success message
    } catch (e) {
      debugPrint("ULF_DEBUG: Error marking all as read: $e");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleNotificationTap(String id, Map<dynamic, dynamic> data) async {
    await _markAsRead(id);

    final nestedData = data['data'] is Map ? data['data'] as Map : null;
    final type = (data['type'] ?? nestedData?['type'])?.toString().toLowerCase();
    
    final chatId = (data['chatId'] ?? 
                    data['chat_id'] ?? 
                    nestedData?['chatId'] ?? 
                    nestedData?['chat_id'])?.toString();

    final matchPostId = (data['matchPostId'] ?? 
                         data['match_post_id'] ?? 
                         nestedData?['matchPostId'] ?? 
                         nestedData?['match_post_id'])?.toString();

    if (!mounted) return;

    if ((type == 'new_message' || type == 'chat' || type == 'message') && chatId != null) {
      _navigateToChat(chatId);
    } else if ((type == 'match_found' || type == 'match') && matchPostId != null) {
      _navigateToPost(matchPostId);
    }
  }

  Future<void> _navigateToChat(String chatId) async {
    if (!mounted) return;
    final t = AppStrings.of(context);
    setState(() => _isProcessing = true);

    try {
      final chatSnap = await FirebaseDatabase.instance.ref('chats/$chatId').get();
      if (!chatSnap.exists) {
        if (mounted) AppNotifications.showError(context, t.cannotOpenChat);
        return;
      }

      final chatData = Map<String, dynamic>.from(chatSnap.value as Map);
      final chatModel = ChatModel.fromMap(chatId, chatData);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailPage(
              chatId: chatId,
              chat: chatModel,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) AppNotifications.showError(context, t.cannotOpenChat);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _navigateToPost(String postId) async {
    if (!mounted) return;
    final t = AppStrings.of(context);
    setState(() => _isProcessing = true);

    try {
      final postSnap = await FirebaseDatabase.instance.ref('posts/$postId').get();
      if (!postSnap.exists) {
        if (mounted) AppNotifications.showError(context, t.centerLocationError); // fallback error
        return;
      }

      final postData = Map<dynamic, dynamic>.from(postSnap.value as Map);
      postData['id'] = postId;

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PostDetailPage(post: postData),
          ),
        );
      }
    } catch (e) {
      if (mounted) AppNotifications.showError(context, t.centerLocationError);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  String _formatTime(dynamic timestamp, String langCode) {
    if (timestamp == null) return '';
    try {
      final int ts = int.tryParse(timestamp.toString()) ?? 0;
      if (ts == 0) return '';
      final date = DateTime.fromMillisecondsSinceEpoch(ts);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 60) {
        final minutes = diff.inMinutes;
        if (langCode == 'es') {
          return 'hace $minutes ${minutes == 1 ? "minuto" : "minutos"}';
        } else if (langCode == 'ca') {
          return 'fa $minutes ${minutes == 1 ? "minut" : "minuts"}';
        } else {
          return '$minutes ${minutes == 1 ? "minute" : "minutes"} ago';
        }
      } else if (diff.inHours < 24) {
        final hours = diff.inHours;
        if (langCode == 'es') {
          return 'hace $hours ${hours == 1 ? "hora" : "horas"}';
        } else if (langCode == 'ca') {
          return 'fa $hours ${hours == 1 ? "hora" : "hores"}';
        } else {
          return '$hours ${hours == 1 ? "hour" : "hours"} ago';
        }
      } else {
        return '${date.day}/${date.month}';
      }
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(t.notificationsTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.notificationsTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          StreamBuilder<DatabaseEvent>(
            stream: FirebaseDatabase.instance
                .ref('users/${user.uid}/notifications')
                .onValue,
            builder: (context, snapshot) {
              final unreadIds = <String>[];
              if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                final data = snapshot.data!.snapshot.value;
                if (data is Map) {
                  data.forEach((key, val) {
                    if (val is Map) {
                      final valMap = Map<dynamic, dynamic>.from(val);
                      if (valMap['read'] == false) {
                        unreadIds.add(key.toString());
                      }
                    }
                  });
                }
              }

              if (unreadIds.isEmpty) return const SizedBox.shrink();

              return IconButton(
                icon: const Icon(Icons.done_all_rounded),
                tooltip: 'Mark all as read',
                onPressed: _isProcessing ? null : () => _markAllAsRead(unreadIds),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          StreamBuilder<DatabaseEvent>(
            stream: FirebaseDatabase.instance
                .ref('users/${user.uid}/notifications')
                .orderByChild('timestamp')
                .onValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                return _buildEmptyState(t, theme);
              }

              final rawData = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
              final List<Map<String, dynamic>> list = rawData.entries.map((entry) {
                return {
                  'id': entry.key.toString(),
                  'data': Map<dynamic, dynamic>.from(entry.value as Map),
                };
              }).toList();

              // Sort manually in descending order (newest first)
              list.sort((a, b) {
                final aData = a['data'] as Map<dynamic, dynamic>;
                final bData = b['data'] as Map<dynamic, dynamic>;
                final aTime = aData['timestamp'] ?? 0;
                final bTime = bData['timestamp'] ?? 0;
                return bTime.compareTo(aTime);
              });

              if (list.isEmpty) {
                return _buildEmptyState(t, theme);
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                itemCount: list.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = list[index];
                  final id = item['id'] as String;
                  final data = item['data'] as Map<dynamic, dynamic>;
                  final bool read = data['read'] == true;
                  final type = data['type']?.toString();
                  
                  IconData iconData = Icons.notifications_rounded;
                  Color iconColor = theme.colorScheme.primary;
                  if (type == 'new_message' || type == 'chat') {
                    iconData = Icons.chat_bubble_rounded;
                    iconColor = Colors.blue.shade600;
                  } else if (type == 'match_found' || type == 'match') {
                    iconData = Icons.celebration_rounded;
                    iconColor = Colors.orange.shade700;
                  }

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: read
                          ? theme.colorScheme.surface
                          : theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: read
                            ? theme.colorScheme.outlineVariant.withValues(alpha: 0.5)
                            : theme.colorScheme.primary.withValues(alpha: 0.25),
                        width: read ? 1.0 : 1.5,
                      ),
                      boxShadow: read
                          ? null
                          : [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundColor: iconColor.withValues(alpha: 0.15),
                          child: Icon(iconData, color: iconColor, size: 22),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                data['title']?.toString() ?? 'ULF Alerta',
                                style: TextStyle(
                                  fontWeight: read ? FontWeight.w600 : FontWeight.w800,
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            if (!read)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.error,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['body']?.toString() ?? '',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: read
                                      ? theme.colorScheme.onSurfaceVariant
                                      : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _formatTime(data['timestamp'], t.locale.languageCode),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                  fontWeight: read ? FontWeight.normal : FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () => _handleNotificationTap(id, data),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          if (_isProcessing)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppStrings t, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 72,
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              t.noNotifications,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
