import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:unilost_found/core/localization/app_strings.dart';
import 'package:unilost_found/shared/widgets/custom_button.dart';
import '../../../chats/presentation/pages/chat_detail_page.dart';
import 'package:unilost_found/core/services/error_handler.dart';
import 'package:unilost_found/shared/utils/app_notifications.dart';

class PostDetailPage extends StatefulWidget {
  final Map<dynamic, dynamic> post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  bool _isLoading = false;

  Future<void> _contactOwner(BuildContext context) async {
    final t = AppStrings.of(context);
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      AppNotifications.showError(context, t.loginRequiredToContact);
      return;
    }

    if (!currentUser.emailVerified) {
      AppNotifications.showError(context, t.verifyEmailToChat);
      return;
    }

    final postOwnerId = widget.post['user_id']?.toString();
    final postId = widget.post['id']?.toString();

    if (postOwnerId == null || postId == null) {
      AppNotifications.showError(context, t.cannotOpenChat);
      return;
    }

    if (postOwnerId == currentUser.uid) {
      AppNotifications.showError(context, t.cannotChatSelf);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final callable = FirebaseFunctions.instance.httpsCallable('getOrCreateChat');
      final result = await callable.call({
        'postId': postId,
        'postOwnerId': postOwnerId,
        'centerId': widget.post['center_id'] ?? 'uab',
        'postTitle': widget.post['title'] ?? t.defaultItemTitle,
        'postStatus': widget.post['status'] ?? 'active',
      });

      final String chatId = result.data['chatId'];

      // Recuperamos el chat de la base de datos para asegurar consistencia
      final chatSnap = await FirebaseDatabase.instance.ref('chats/$chatId').get();

      if (!chatSnap.exists) {
        throw Exception(t.chatRecoverError);
      }

      final chatData = Map<String, dynamic>.from(chatSnap.value as Map);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailPage(
            chatId: chatId,
            chat: chatData,
          ),
        ),
      );
    } catch (e) {
      debugPrint('[ERROR] _contactOwner: $e');
      if (!mounted) return;
      final message = ErrorHandler.getMessage(e, t);
      AppNotifications.showError(context, message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final theme = Theme.of(context);
    final post = widget.post;
    final isLost = post['type'] == 'lost';
    final currentUser = FirebaseAuth.instance.currentUser;
    final isMyPost = currentUser?.uid == post['user_id'];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'post_image_${post['id']}',
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primaryContainer,
                        theme.colorScheme.primaryContainer.withOpacity(0.5),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      _getCategoryIcon(post['category']?.toString()),
                      size: 100,
                      color: theme.colorScheme.primary.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category and Date Row
                  Row(
                    children: [
                      _InfoChip(
                        icon: _getCategoryIcon(post['category']?.toString()),
                        label: _categoryLabel(post['category']?.toString(), t),
                        color: theme.colorScheme.secondaryContainer,
                        textColor: theme.colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 12),
                      _InfoChip(
                        icon: Icons.calendar_today_rounded,
                        label: _formatDate(post['created_at']),
                        color: theme.colorScheme.surfaceVariant,
                        textColor: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Title and Status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          post['title'] ?? t.defaultItemTitle,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isLost ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isLost ? Colors.orange.withOpacity(0.3) : Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          isLost ? t.lostStatus : t.foundStatus,
                          style: TextStyle(
                            color: isLost ? Colors.orange.shade800 : Colors.green.shade800,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description Section
                  _buildSectionHeader(t.descriptionLabel, theme),
                  const SizedBox(height: 12),
                  Text(
                    post['description'] ?? t.noDescription,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Location Section
                  _buildSectionHeader(t.locationLabel, theme),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Icon(Icons.location_on_rounded, color: theme.colorScheme.primary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post['location'] ?? 'UAB Campus',
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Cerdanyola del Vallès, Barcelona',
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, t, theme, isMyPost),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Text(
      title.toUpperCase(),
      style: theme.textTheme.labelMedium?.copyWith(
        letterSpacing: 1.2,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, AppStrings t, ThemeData theme, bool isMyPost) {
    if (isMyPost) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: CustomButton(
          text: _isLoading ? t.openingChat : t.contactOwner,
          isLoading: _isLoading,
          onPressed: () => _contactOwner(context),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'keys': return Icons.vpn_key_rounded;
      case 'wallet': return Icons.account_balance_wallet_rounded;
      case 'devices': return Icons.devices_rounded;
      case 'clothing': return Icons.checkroom_rounded;
      default: return Icons.inventory_2_rounded;
    }
  }

  String _categoryLabel(String? category, AppStrings t) {
    switch (category?.toLowerCase()) {
      case 'keys': return t.keys;
      case 'wallet': return t.wallets;
      case 'devices': return t.devices;
      case 'clothing': return t.clothes;
      default: return t.others;
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final int ts = int.tryParse(timestamp.toString()) ?? 0;
      if (ts == 0) return '';
      final date = DateTime.fromMillisecondsSinceEpoch(ts);
      return "${date.day}/${date.month}/${date.year}";
    } catch (_) {
      return '';
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}