import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:unilost_found/core/localization/app_strings.dart';
import 'package:unilost_found/core/services/custom_cache_manager.dart';
import 'package:unilost_found/shared/widgets/custom_button.dart';
import 'package:unilost_found/shared/widgets/custom_text_field.dart';
import 'package:unilost_found/shared/widgets/field_label.dart';
import 'package:unilost_found/core/services/error_handler.dart';
import 'package:unilost_found/shared/utils/app_notifications.dart';
import 'package:unilost_found/shared/utils/category_utils.dart';
import 'package:unilost_found/shared/utils/image_utils.dart';

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
  File? _imageFile;
  String? _currentImageUrl;

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
    _currentImageUrl = ImageUtils.postImageUrlFrom(widget.post);

    if (!_statuses.contains(_selectedStatus)) {
      _selectedStatus = 'active';
    }

    if (!_categories.contains(_selectedCategory)) {
      _selectedCategory = 'others';
    }
  }

  Future<void> _pickImage() async {
    final t = AppStrings.of(context);
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: Text(t.camera),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: Text(t.gallery),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final File? picked = await ImageUtils.pickAndProcessImage(
      source: source,
      imageQuality: 80,
    );

    if (picked != null) {
      setState(() {
        _imageFile = picked;
      });
    }
  }

  Future<void> _saveChanges() async {
    final t = AppStrings.of(context);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      String? imageUrl;
      String? imagePath;
      // Si el usuario seleccionó una nueva foto, la subimos a Firebase Storage
      if (_imageFile != null) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          imagePath = 'posts/${widget.postId}/post_image_${DateTime.now().millisecondsSinceEpoch}.webp';
          final storageRef = FirebaseStorage.instance.ref().child(imagePath);
          final metadata = SettableMetadata(
            contentType: 'image/webp',
            customMetadata: {'optimized': 'true'},
          );

          try {
            final snapshot = await storageRef.putFile(_imageFile!, metadata);
            imageUrl = await snapshot.ref.getDownloadURL();
          } catch (e) {
            if (mounted) {
              setState(() => _saving = false);
              AppNotifications.showError(context, t.errorImageUpload);
            }
            return;
          }
        }
      }

      // 1. Actualizamos campos directamente en RTDB
      final Map<String, dynamic> updates = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'status': _selectedStatus,
        'updated_at': ServerValue.timestamp,
      };

      if (imageUrl != null) {
        updates['imageUrl'] = imageUrl;
        updates['postImageUrl'] = imageUrl;
        if (imagePath != null) {
          updates['photo_path'] = imagePath;
        }
      }

      await FirebaseDatabase.instance.ref('posts/${widget.postId}').update(updates);

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
        'updated_at': ServerValue.timestamp,
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
              // Cabecera de la Imagen del Objeto
              FieldLabel(label: t.objectPhoto, isRequired: false),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: theme.colorScheme.outlineVariant, width: 1.5),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_imageFile != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.file(
                            _imageFile!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        )
                      else if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: CachedNetworkImage(
                            imageUrl: _currentImageUrl!,
                            cacheManager: CustomCacheManager.instance,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.broken_image_rounded, size: 48, color: theme.colorScheme.error),
                                const SizedBox(height: 12),
                                Text(t.errorImageUpload, style: TextStyle(color: theme.colorScheme.error)),
                              ],
                            ),
                          ),
                        )
                      else
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_rounded, size: 48, color: theme.colorScheme.primary),
                            const SizedBox(height: 12),
                            Text(
                              t.tapToTakePhoto,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      if (_imageFile != null || (_currentImageUrl != null && _currentImageUrl!.isNotEmpty))
                        Positioned(
                          right: 12,
                          bottom: 12,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

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
