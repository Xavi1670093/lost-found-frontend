import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:unilost_found/core/localization/app_strings.dart';
import 'package:unilost_found/shared/widgets/custom_button.dart';
import 'package:unilost_found/shared/widgets/custom_text_field.dart';
import 'package:unilost_found/shared/widgets/field_label.dart';
import 'package:unilost_found/core/services/error_handler.dart';
import 'package:unilost_found/shared/utils/app_notifications.dart';
import 'package:unilost_found/shared/utils/category_utils.dart';

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

  final List<String> _categories = CategoryUtils.categories;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.post['title'] ?? '',
    );

    _descriptionController = TextEditingController(
      text: widget.post['description'] ?? '',
    );

    _selectedStatus = (widget.post['status']?.toString() ?? 'active').toLowerCase().trim();
    _selectedCategory = (widget.post['category']?.toString() ?? 'others').toLowerCase().trim();

    if (!_statuses.contains(_selectedStatus)) {
      _selectedStatus = 'active';
    }

    if (!_categories.contains(_selectedCategory)) {
      _selectedCategory = 'others';
    }
  }

  Future<void> _saveChanges() async {
    final t = AppStrings.of(context);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      // 1. Actualizamos campos de texto directamente en RTDB (permitido por reglas de seguridad)
      await FirebaseDatabase.instance.ref('posts/${widget.postId}').update({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'status': _selectedStatus,
        'updated_at': ServerValue.timestamp,
      });

      // 2. Notificamos al backend para actualizar el estado (esto dispara triggers en el servidor)
      final callable = FirebaseFunctions.instance.httpsCallable('updatePostStatus');
      await callable.call({
        'postId': widget.postId,
        'newStatus': _selectedStatus,
      });

      if (!mounted) return;

      AppNotifications.showSuccess(context, t.postEditedSuccess);
      Navigator.pop(context);
    } on FirebaseException catch (e) {
      if (!mounted) return;
      debugPrint("ULF_DEBUG: FirebaseException during saveChanges: ${e.code} - ${e.message}");
      final message = e.code == 'permission-denied' ? t.errorSaving : ErrorHandler.getMessage(e, t);
      AppNotifications.showError(context, message);
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
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.delete_outline_rounded, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  t.deleteConfirmationTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Text(t.deleteConfirmationMessage),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(t.cancel),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(t.deletePost.split(' ')[0]), // "Eliminar"
                    ),
                  ),
                ),
              ],
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

      AppNotifications.showSuccess(context, t.postDeletedSuccess);
      Navigator.pop(context);
    } on FirebaseException catch (e) {
      if (!mounted) return;
      debugPrint("ULF_DEBUG: FirebaseException during deletePost: ${e.code} - ${e.message}");
      final message = e.code == 'permission-denied' ? t.errorDeleting : ErrorHandler.getMessage(e, t);
      AppNotifications.showError(context, message);
    } catch (e) {
      if (!mounted) return;
      final message = ErrorHandler.getMessage(e, t);
      AppNotifications.showError(context, message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }



  String _statusLabel(String status, AppStrings t) {
    return CategoryUtils.getStatusLabel(status, t);
  }

  String _categoryLabel(String category, AppStrings t) {
    return CategoryUtils.getCategoryLabel(category, t);
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
              CustomTextField(
                label: t.titleLabel,
                controller: _titleController,
                hintText: t.objectTitleHint,
                isRequired: true,
                validator: (value) => (value == null || value.trim().isEmpty) ? t.fieldRequired : null,
              ),

              const SizedBox(height: 24),

              CustomTextField(
                label: "${t.descriptionLabel} ${t.optional}",
                controller: _descriptionController,
                maxLines: 4,
                hintText: t.descriptionHint,
              ),

              const SizedBox(height: 24),

              FieldLabel(label: t.category, isRequired: true),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
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

              FieldLabel(label: t.currentStatus, isRequired: true),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedStatus,
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

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}