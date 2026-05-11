import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_functions/cloud_functions.dart';
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

    setState(() {
      _isLoading = true;
    });
    
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para contactar.'),
          backgroundColor: Colors.orange,
        ),
      );
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (!currentUser.emailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes verificar tu correo institucional antes de poder abrir un chat.'),
          backgroundColor: Colors.orange,
        ),
      );
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final postOwnerId = widget.post['user_id']?.toString();
    final postId = widget.post['id']?.toString();

    if (postOwnerId == null || postId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se puede abrir el chat de este objeto.'),
          backgroundColor: Colors.red,
        ),
      );
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (postOwnerId == currentUser.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No puedes abrir un chat contigo mismo.'),
          backgroundColor: Colors.orange,
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
        'postTitle': widget.post['title'] ?? 'Objeto',
        'postStatus': widget.post['status'] ?? 'active',
      });

      final String chatId = result.data['chatId'];
      final chatSnap = await FirebaseDatabase.instance.ref('chats/$chatId').get();

      if (!chatSnap.exists) {
        throw Exception("El chat no se pudo recuperar de la base de datos.");
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
          content: Text('Error al abrir chat: $e'),
          backgroundColor: Colors.red,
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
    final isLost = widget.post['type'] == 'lost';
    final theme = Theme.of(context);
    final status = widget.post['status'] ?? 'active';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Collapsible Header with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'post_image_${widget.post['id']}',
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withOpacity(0.4), Colors.transparent, Colors.transparent],
                    ),
                  ),
                  child: Icon(
                    isLost ? Icons.search_rounded : Icons.inventory_2_outlined,
                    size: 100,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges
                  Row(
                    children: [
                      _buildStatusBadge(
                        isLost ? 'PERDIDO' : 'ENCONTRADO',
                        isLost ? Colors.orange : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      _buildStatusBadge(
                        widget.post['category']?.toString().toUpperCase() ?? 'OTROS',
                        theme.colorScheme.secondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Title and Date
                  Text(
                    widget.post['title'] ?? '',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 16, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text(
                        DateTime.fromMillisecondsSinceEpoch(widget.post['created_at'] ?? 0)
                            .toString()
                            .split(' ')[0],
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description Section
                  Text(
                    'Descripción',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.post['description'] ?? 'Sin descripción',
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 32),

                  // Info Cards
                  _buildInfoTile(
                    Icons.location_on_outlined,
                    'Ubicación',
                    widget.post['location'] ?? 'UAB - Campus',
                    theme,
                  ),
                  _buildInfoTile(
                    Icons.info_outline_rounded,
                    'Estado actual',
                    _statusLabel(status),
                    theme,
                  ),
                  
                  const SizedBox(height: 40),

                  // Action Button
                  Center(
                    child: CustomButton(
                      text: _isLoading ? 'Abriendo chat...' : 'Contactar con el dueño',
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

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              Text(subtitle, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  static String _statusLabel(String status) {
    switch (status) {
      case 'matched': return 'Encontrado';
      case 'returned': return 'Devuelto';
      default: return 'En proceso';
    }
  }
}