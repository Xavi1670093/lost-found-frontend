import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:unilost_found/core/localization/app_strings.dart';
import 'package:unilost_found/shared/widgets/custom_button.dart';
import 'package:unilost_found/shared/widgets/custom_text_field.dart';
import 'package:unilost_found/core/services/error_handler.dart';
import 'package:unilost_found/shared/utils/app_notifications.dart';

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
    final t = AppStrings.of(context);
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

      if (!mounted) return;
      AppNotifications.showSuccess(context, t.updateSuccess);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      final message = ErrorHandler.getMessage(e, t);
      AppNotifications.showError(context, message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deletePost() async {
    final t = AppStrings.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(t.deleteConfirmationTitle),
          content: Text(t.deleteConfirmationMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(t.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(t.deletePost.split(' ')[0]), // "Eliminar"
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

      if (!mounted) return;
      AppNotifications.showSuccess(context, t.deleteSuccess);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      final message = ErrorHandler.getMessage(e, t);
      AppNotifications.showError(context, message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _updateRelatedChatsStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Bypassing global query restrictions by using user-specific indices
      final userChatsRef = FirebaseDatabase.instance.ref('user_chats/${user.uid}');
      final snapshot = await userChatsRef.get();

      if (snapshot.exists) {
        for (final child in snapshot.children) {
          final chatId = child.key;
          if (chatId == null) continue;

          final chatRef = FirebaseDatabase.instance.ref('chats/$chatId');
          final chatSnap = await chatRef.get();

          if (chatSnap.exists) {
            final chatData = chatSnap.value as Map;
            if (chatData['post_id'].toString() == widget.postId) {
              await chatRef.update({
                'post_title': _titleController.text.trim(),
                'post_status': _selectedStatus,
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error updating related chats: $e');
    }
  }

  String _statusLabel(String status, AppStrings t) {
    switch (status) {
      case 'matched': return t.statusMatched;
      case 'returned': return t.statusReturned;
      default: return t.statusInProcess;
    }
  }

  String _categoryLabel(String category, AppStrings t) {
    switch (category) {
      case 'keys': return t.keys;
      case 'wallet': return t.wallets;
      case 'devices': return t.devices;
      case 'clothing': return t.clothes;
      default: return t.others;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final theme = Theme.of(context);
    final isLost = widget.post['type'] == 'lost';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isLost ? t.editPostTitleLost : t.editPostTitleFound,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _saving
          ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(t.titleLabel, theme),
              const SizedBox(height: 8),
              CustomTextField(
                label: t.titleLabel,
                controller: _titleController,
                hintText: t.objectTitleHint,
                validator: (value) => (value == null || value.trim().isEmpty) ? t.fieldRequired : null,
              ),

              const SizedBox(height: 24),

              _buildSectionTitle(t.descriptionLabel, theme),
              const SizedBox(height: 8),
              CustomTextField(
                label: t.descriptionLabel,
                controller: _descriptionController,
                maxLines: 4,
                hintText: t.descriptionHint,
              ),

              const SizedBox(height: 24),

              _buildSectionTitle(t.category, theme),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(border: InputBorder.none),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(_categoryLabel(category, t)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedCategory = value);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              _buildSectionTitle(t.currentStatus, theme),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(border: InputBorder.none),
                    items: _statuses.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(_statusLabel(status, t)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedStatus = value);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 40),

              CustomButton(
                text: t.saveChanges,
                onPressed: _saveChanges,
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _deletePost,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: Text(t.deletePost),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title.toUpperCase(),
      style: theme.textTheme.labelMedium?.copyWith(
        letterSpacing: 1.1,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurfaceVariant,
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