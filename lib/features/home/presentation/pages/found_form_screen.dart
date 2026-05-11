import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';
import 'package:unilost_found/core/localization/app_strings.dart';
import 'package:unilost_found/core/services/permission_service.dart';
import 'package:unilost_found/shared/widgets/custom_button.dart';
import 'package:unilost_found/shared/widgets/custom_text_field.dart';

class FoundFormScreen extends StatefulWidget {
  final String postType;

  const FoundFormScreen({
    super.key,
    this.postType = 'found',
  });

  @override
  State<FoundFormScreen> createState() => _FoundFormScreenState();
}

class _FoundFormScreenState extends State<FoundFormScreen> {
  File? imageFile;
  Position? _currentPosition;
  bool _isPublishing = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? selectedCategoryKey;
  DateTime? selectedDate;

  final Map<String, String> categoryOptions = {
    'keys': 'Llaves', // We'll use t.keys in build
    'wallet': 'Cartera',
    'devices': 'Dispositivo',
    'clothing': 'Ropa',
    'other': 'Otros',
  };

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _pickImage() async {
    final hasPermission = await PermissionService.requestCamera();
    if (!hasPermission) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (picked != null) setState(() => imageFile = File(picked.path));
  }

  Future<void> _getLocation() async {
    final t = AppStrings.of(context);
    final hasPermission = await PermissionService.requestLocation();
    if (!hasPermission) return;
    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      _showError(t.locationError);
    }
  }

  Future<void> _submit() async {
    final t = AppStrings.of(context);
    if (!_formKey.currentState!.validate()) return;
    if (selectedCategoryKey == null || selectedDate == null) {
      _showError(t.selectCategoryAndDate);
      return;
    }

    setState(() => _isPublishing = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception(t.sessionError);

      final userSnapshot = await FirebaseDatabase.instance.ref('users/${user.uid}/center_id').get();
      final centerId = userSnapshot.value?.toString() ?? "uab";

      final postsRef = FirebaseDatabase.instance.ref('posts');
      final newPostRef = postsRef.push();

      await newPostRef.set({
        'id': newPostRef.key,
        'user_id': user.uid,
        'center_id': centerId,
        'type': widget.postType,
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'category': selectedCategoryKey,
        'status': 'active',
        'coords': {
          'lat': _currentPosition?.latitude ?? 41.500,
          'lng': _currentPosition?.longitude ?? 2.110,
        },
        'photo_path': '',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'is_deleted': false,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.postType == 'found' ? t.publishSuccessFound : t.publishSuccessLost),
            backgroundColor: widget.postType == 'found' ? Colors.green : Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showError("${t.publishError}: $e");
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg), 
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final theme = Theme.of(context);
    final isFound = widget.postType == 'found';

    final Map<String, String> categories = {
      'keys': t.keys,
      'wallet': t.wallets,
      'devices': t.devices,
      'clothing': t.clothes,
      'other': t.others,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(isFound ? t.reportFoundTitle : t.reportLostTitle),
        backgroundColor: Colors.transparent,
      ),
      body: _isPublishing
          ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image Picker Section
                    _buildSectionTitle(t.objectPhoto, theme),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: theme.colorScheme.outlineVariant, width: 1.5),
                        ),
                        child: imageFile == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo_rounded, size: 48, color: theme.colorScheme.primary),
                                  const SizedBox(height: 12),
                                  Text(t.tapToTakePhoto, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: Image.file(imageFile!, fit: BoxFit.cover),
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Details Section
                    _buildSectionTitle(t.basicInfo, theme),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: t.objectTitleLabel,
                      hintText: t.objectTitleHint,
                      controller: titleController,
                      validator: (value) => value == null || value.isEmpty ? t.fieldRequired : null,
                    ),
                    const SizedBox(height: 24),
                    
                    Text(t.category, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: categories.entries.map((entry) {
                        final isSelected = selectedCategoryKey == entry.key;
                        return ChoiceChip(
                          label: Text(entry.value),
                          selected: isSelected,
                          onSelected: (_) => setState(() => selectedCategoryKey = entry.key),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          showCheckmark: false,
                          backgroundColor: theme.colorScheme.surface,
                          selectedColor: theme.colorScheme.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),

                    _buildSectionTitle(t.descriptionDetails, theme),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: t.descriptionHint,
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6)),
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildSectionTitle(t.locationAndDate, theme),
                    const SizedBox(height: 16),
                    _buildActionTile(
                      Icons.location_on_rounded,
                      _currentPosition != null ? t.locationObtained : t.getCurrentLocation,
                      _getLocation,
                      _currentPosition != null,
                      theme,
                    ),
                    const SizedBox(height: 12),
                    _buildActionTile(
                      Icons.calendar_today_rounded,
                      selectedDate == null 
                        ? t.selectDate
                        : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                      _pickDate,
                      selectedDate != null,
                      theme,
                    ),
                    const SizedBox(height: 48),

                    CustomButton(
                      text: t.publishButton,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 40),
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
        letterSpacing: 1.2,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String text, VoidCallback onTap, bool isCompleted, ThemeData theme) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
            width: isCompleted ? 2 : 1,
          ),
          boxShadow: isCompleted ? [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ] : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: isCompleted ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                  color: isCompleted ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (isCompleted)
              Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary, size: 22),
          ],
        ),
      ),
    );
  }
}
