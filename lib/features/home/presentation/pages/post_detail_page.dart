import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:unilost_found/core/localization/app_strings.dart';
import 'package:unilost_found/shared/widgets/custom_button.dart';
import '../../../chats/presentation/pages/chat_detail_page.dart';

class PostDetailPage extends StatefulWidget {
  final Map<dynamic, dynamic> post;

  const PostDetailPage({
    super.key,
    required this.post,
  });

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  bool _isLoading = false;

  Future<void> _contactOwner(BuildContext context) async {
    if (_isLoading) return;

    final t = AppStrings.of(context);
    setState(() {
      _isLoading = true;
    });
    
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.loginRequiredToContact),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (!currentUser.emailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.verifyEmailToChat),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final postOwnerId = widget.post['user_id']?.toString();
    final postId = widget.post['id']?.toString();

    if (postOwnerId == null || postId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.cannotOpenChat),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (postOwnerId == currentUser.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.cannotChatSelf),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
       if (mounted) setState(() => _isLoading = false);
      return;
    }

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
      final chatSnap = await FirebaseDatabase.instance.ref('chats/$chatId').get();

      if (!chatSnap.exists) {
        throw Exception(t.chatRecoverError);
      }

      final chatData = chatSnap.value as Map<dynamic, dynamic>;

      if (!context.mounted) return;

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
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${t.chatOpenError}: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final isLost = widget.post['type'] == 'lost';
    final theme = Theme.of(context);
    final status = widget.post['status'] ?? 'active';

    final categoryKey = widget.post['category']?.toString() ?? 'other';
    final categoryName = _getCategoryName(categoryKey, t);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Collapsible Header with Image
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'post_image_${widget.post['id']}',
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                  ),
                  child: Center(
                    child: Icon(
                      isLost ? Icons.search_rounded : Icons.inventory_2_outlined,
                      size: 100,
                      color: theme.colorScheme.primary.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.background,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              margin: const EdgeInsets.only(top: -32),
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges
                  Row(
                    children: [
                      _buildStatusBadge(
                        isLost ? t.lostStatus : t.foundStatus,
                        isLost ? Colors.orange : Colors.green,
                      ),
                      const SizedBox(width: 10),
                      _buildStatusBadge(
                        categoryName.toUpperCase(),
                        theme.colorScheme.secondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    widget.post['title'] ?? '',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Date and Location
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 16, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(widget.post['created_at']),
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Description Section
                  Text(
                    t.description,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.post['description'] ?? t.noDescription,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Info Tiles
                  _buildInfoTile(
                    Icons.location_on_outlined,
                    t.location,
                    widget.post['location'] ?? t.campusUab,
                    theme,
                  ),
                  _buildInfoTile(
                    Icons.info_outline_rounded,
                    t.currentStatus,
                    _statusLabel(status, t),
                    theme,
                  ),
                  
                  const SizedBox(height: 48),

                  // Action Button
                  Center(
                    child: CustomButton(
                      text: _isLoading ? t.openingChat : t.contactOwner,
                      isLoading: _isLoading,
                      onPressed: () => _contactOwner(context),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(String key, AppStrings t) {
    switch (key.toLowerCase()) {
      case 'keys': return t.keys;
      case 'wallet': return t.wallets;
      case 'devices': return t.devices;
      case 'clothing': return t.clothes;
      default: return t.others;
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return "${date.day}/${date.month}/${date.year}";
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 4),
                Text(subtitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _statusLabel(String status, AppStrings t) {
    switch (status) {
      case 'matched': return t.statusMatched;
      case 'returned': return t.statusReturned;
      default: return t.statusInProcess;
    }
  }
}