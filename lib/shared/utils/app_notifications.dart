import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:unilost_found/core/theme/app_theme.dart';
import 'package:unilost_found/core/services/permission_service.dart';
import 'package:unilost_found/core/localization/app_strings.dart';
import 'package:unilost_found/features/chats/data/models/chat_model.dart';
import 'package:unilost_found/features/chats/presentation/pages/chat_detail_page.dart';
import 'package:unilost_found/features/home/presentation/pages/post_detail_page.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  final type = message.data['type']?.toString();
  debugPrint("ULF_DEBUG: Background message received: ${message.messageId}, type: $type");
}

class AppNotifications {
  /// Tracks the currently active chat ID on screen to prevent showing foreground notifications for it.
  static String? activeChatId;

  /// Initializes FCM listeners, requests permissions, gets token, and registers on the backend.
  static Future<void> initFCM(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 1. Request notifications permission using permission_service
    await PermissionService.requestNotification();

    // 2. Retrieve FCM Token
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        debugPrint("ULF_DEBUG: FCM Token retrieved: $fcmToken");
        
        // 3. Send using Callable Cloud Function saveFcmToken
        final callable = FirebaseFunctions.instance.httpsCallable('saveFcmToken');
        await callable.call({'token': fcmToken});
        debugPrint("ULF_DEBUG: FCM Token successfully registered on backend.");
      }
    } catch (e) {
      debugPrint("ULF_DEBUG: Error saving FCM token: $e");
    }

    // 4. Foreground listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("ULF_DEBUG: Foreground message received: ${message.notification?.title}");
      
      final data = message.data;
      final nestedData = data['data'] is Map ? data['data'] as Map : null;
      final chatId = (data['chatId'] ?? 
                      data['chat_id'] ?? 
                      nestedData?['chatId'] ?? 
                      nestedData?['chat_id'])?.toString();

      if (chatId != null && activeChatId == chatId) {
        debugPrint("ULF_DEBUG: Suppressing notification for active chat: $chatId");
        return;
      }

      final notification = message.notification;
      if (notification != null && context.mounted) {
        showForegroundNotification(
          context,
          notification.title ?? "ULF Alert",
          notification.body ?? "",
        );
      }
    });

    // 5. App opened from background state via push notification click
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("ULF_DEBUG: Notification clicked (app in background): ${message.messageId}");
      if (context.mounted) {
        handlePushNavigation(context, message.data);
      }
    });

    // 6. App opened from terminated state via push notification click
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint("ULF_DEBUG: Notification clicked (app was terminated): ${message.messageId}");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            handlePushNavigation(context, message.data);
          }
        });
      }
    });
  }

  /// Handles user redirection based on the notification data payload
  static Future<void> handlePushNavigation(BuildContext context, Map<dynamic, dynamic> data) async {
    final nestedData = data['data'] is Map ? data['data'] as Map : null;
    final type = (data['type'] ?? nestedData?['type'])?.toString().toLowerCase();
    
    final chatId = (data['chatId'] ?? 
                    data['chat_id'] ?? 
                    nestedData?['chatId'] ?? 
                    nestedData?['chat_id'])?.toString();

    final matchPostId = (data['postId'] ??
                         data['post_id'] ??
                         data['matchPostId'] ?? 
                         data['match_post_id'] ?? 
                         nestedData?['postId'] ??
                         nestedData?['post_id'] ??
                         nestedData?['matchPostId'] ?? 
                         nestedData?['match_post_id'])?.toString();

    debugPrint("ULF_DEBUG: Handling push navigation: type=$type, chatId=$chatId, matchPostId=$matchPostId");

    if (!context.mounted) return;
    final t = AppStrings.of(context);

    if ((type == 'new_message' || type == 'chat' || type == 'message') && chatId != null) {
      try {
        final chatSnap = await FirebaseDatabase.instance.ref('chats/$chatId').get();
        if (!chatSnap.exists) {
          if (context.mounted) showError(context, t.cannotOpenChat);
          return;
        }

        final chatData = Map<String, dynamic>.from(chatSnap.value as Map);
        final chatModel = ChatModel.fromMap(chatId, chatData);

        if (context.mounted) {
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
        debugPrint("ULF_DEBUG: Error navigating to chat: $e");
        if (context.mounted) showError(context, t.cannotOpenChat);
      }
    } else if ((type == 'match_found' || type == 'match' || type == 'matched' || type == 'possible_match') && matchPostId != null) {
      try {
        final postSnap = await FirebaseDatabase.instance.ref('posts/$matchPostId').get();
        if (!postSnap.exists) {
          if (context.mounted) showError(context, t.centerLocationError);
          return;
        }

        final postData = Map<dynamic, dynamic>.from(postSnap.value as Map);
        postData['id'] = matchPostId;

        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PostDetailPage(post: postData),
            ),
          );
        }
      } catch (e) {
        debugPrint("ULF_DEBUG: Error navigating to post: $e");
        if (context.mounted) showError(context, t.centerLocationError);
      }
    }
  }

  /// Displays a premium styled notification banner for foreground messages.
  static void showForegroundNotification(BuildContext context, String title, String body) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: theme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: AppTheme.successColor,
      icon: Icons.check_circle_rounded,
    );
  }

  static void showError(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: AppTheme.errorColor,
      icon: Icons.error_rounded,
    );
  }

  static void showWarning(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: AppTheme.warningColor,
      icon: Icons.warning_rounded,
    );
  }

  static void _showSnackBar(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required IconData icon,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                softWrap: true,
                overflow: TextOverflow.visible,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
