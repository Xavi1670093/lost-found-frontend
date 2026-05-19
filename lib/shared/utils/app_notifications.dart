import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unilost_found/core/theme/app_theme.dart';
import 'package:unilost_found/core/services/permission_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("ULF_DEBUG: Background message received: ${message.messageId}");
}

class AppNotifications {
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
      final notification = message.notification;
      if (notification != null && context.mounted) {
        showForegroundNotification(
          context,
          notification.title ?? "ULF Alert",
          notification.body ?? "",
        );
      }
    });
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
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
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
