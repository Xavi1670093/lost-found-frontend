import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class EditPostPage extends StatefulWidget {
  final String postId;
  final Map<dynamic, dynamic> post;

  const EditPostPage({
    super.key,
    required this.postId,
    required this.post,
  });

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  late String _selectedStatus;
  late String _selectedCategory;

  bool _saving = false;

  final List<String> _statuses = [
    'active',
    'matched',
    'returned',
  ];

  final List<String> _categories = [
    'keys',
    'wallet',
    'devices',
    'clothing',
    'bags',
    'study',
    'accessories',
    'other',
  ];

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.post['title'] ?? '',
    );

    _descriptionController = TextEditingController(
      text: widget.post['description'] ?? '',
    );

    _selectedStatus = widget.post['status'] ?? 'active';
    _selectedCategory = widget.post['category'] ?? 'other';

    if (!_statuses.contains(_selectedStatus)) {
      _selectedStatus = 'active';
    }

    if (!_categories.contains(_selectedCategory)) {
      _selectedCategory = 'other';
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final now = DateTime.now().millisecondsSinceEpoch;

      await FirebaseDatabase.instance.ref('posts/${widget.postId}').update({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'status': _selectedStatus,
        'updated_at': now,
      });

      await _updateRelatedChatsStatus();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Publicación actualizada correctamente.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deletePost() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Eliminar publicación'),
          content: const Text(
            '¿Seguro que quieres eliminar esta publicación?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() => _saving = true);

    try {
      await FirebaseDatabase.instance.ref('posts/${widget.postId}').update({
        'is_deleted': true,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Publicación eliminada.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _updateRelatedChatsStatus() async {
    final chatsSnapshot = await FirebaseDatabase.instance.ref('chats').get();

    if (chatsSnapshot.value == null) return;

    final chatsMap = chatsSnapshot.value as Map<dynamic, dynamic>;

    for (final entry in chatsMap.entries) {
      final chatId = entry.key.toString();
      final chat = Map<dynamic, dynamic>.from(entry.value as Map);

      if (chat['post_id'] == widget.post['id']) {
        await FirebaseDatabase.instance.ref('chats/$chatId').update({
          'post_title': _titleController.text.trim(),
          'post_status': _selectedStatus,
        });
      }
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'matched':
        return 'Encontrado';
      case 'returned':
        return 'Devuelto';
      default:
        return 'En proceso';
    }
  }

  String _categoryLabel(String category) {
    switch (category) {
      case 'keys':
        return 'Llaves';
      case 'wallet':
        return 'Cartera';
      case 'devices':
        return 'Dispositivo';
      case 'clothing':
        return 'Ropa';
      case 'bags':
        return 'Mochila/Bolsa';
      case 'study':
        return 'Material de estudio';
      case 'accessories':
        return 'Accesorios';
      default:
        return 'Otros';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLost = widget.post['type'] == 'lost';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isLost ? 'Editar petición' : 'Editar objeto',
        ),
      ),
      body: _saving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Título',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Título del objeto',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El título es obligatorio';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              const Text(
                'Descripción',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Descripción del objeto',
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Categoría',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(_categoryLabel(category)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              const Text(
                'Estado',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: _statuses.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(_statusLabel(status)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    _selectedStatus = value;
                  });
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _saveChanges,
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar cambios'),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _deletePost,
                  icon: const Icon(Icons.delete),
                  label: const Text('Eliminar publicación'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}