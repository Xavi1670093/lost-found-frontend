import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_functions/cloud_functions.dart';

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
    if (_isLoading) return; // Evita el doble click

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

    // Validación requerida por las reglas de seguridad del backend
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
    // Note the use of widget.post here since we are in the State class
    final isLost = widget.post['type'] == 'lost';
    final theme = Theme.of(context);
    final status = widget.post['status'] ?? 'active';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post['title'] ?? 'Detalle'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250,
              width: double.infinity,
              color: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.image,
                size: 100,
                color: theme.colorScheme.primary,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text(isLost ? 'PERDIDO' : 'ENCONTRADO'),
                        backgroundColor: isLost
                            ? Colors.red.shade100
                            : Colors.green.shade100,
                      ),
                      Chip(
                        label: Text(
                          widget.post['category']?.toString().toUpperCase() ??
                              'OTROS',
                        ),
                      ),
                      Chip(
                        label: Text(_statusLabel(status)),
                        backgroundColor: _statusColor(status),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.post['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.post['description'] ?? 'Sin descripción',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: const Text('Ubicación'),
                    subtitle: Text(widget.post['location'] ?? 'UAB - Campus'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today_outlined),
                    title: const Text('Publicado el'),
                    subtitle: Text(
                      DateTime.fromMillisecondsSinceEpoch(
                        widget.post['created_at'] ?? 0,
                      ).toString().split(' ')[0],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () => _contactOwner(context), // Se desactiva si está cargando
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.chat_bubble_outline),
                      label:
                          Text(_isLoading ? 'Abriendo chat...' : 'Contactar'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _statusLabel(String status) {
    switch (status) {
      case 'matched':
        return 'Encontrado';
      case 'returned':
        return 'Devuelto';
      default:
        return 'En proceso';
    }
  }

  static Color _statusColor(String status) {
    switch (status) {
      case 'matched':
        return Colors.orange.shade100;
      case 'returned':
        return Colors.green.shade100;
      default:
        return Colors.blue.shade100;
    }
  }
}