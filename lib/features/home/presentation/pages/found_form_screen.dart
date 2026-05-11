import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';
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
  String locationText = "Obtener ubicación actual";
  Position? _currentPosition;
  bool _isPublishing = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? selectedCategory;
  DateTime? selectedDate;

  final List<String> categories = ["Llaves", "Cartera", "Dispositivo", "Ropa", "Otros"];

  String _mapCategoryToBackend(String category) {
    switch (category) {
      case "Llaves": return "keys";
      case "Cartera": return "wallet";
      case "Dispositivo": return "devices";
      case "Ropa": return "clothing";
      default: return "other";
    }
  }

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
    final hasPermission = await PermissionService.requestLocation();
    if (!hasPermission) return;
    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
        locationText = "Ubicación obtenida ✓";
      });
    } catch (e) {
      _showError("No se pudo obtener la ubicación");
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedCategory == null || selectedDate == null) {
      _showError("Selecciona categoría y fecha");
      return;
    }

    setState(() => _isPublishing = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Sesión no iniciada");

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
        'category': _mapCategoryToBackend(selectedCategory!),
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
            content: Text(widget.postType == 'found' ? "¡Objeto encontrado publicado!" : "¡Alerta de pérdida publicada!"),
            backgroundColor: widget.postType == 'found' ? Colors.green : Colors.orange,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showError("Error al publicar: $e");
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFound = widget.postType == 'found';

    return Scaffold(
      appBar: AppBar(
        title: Text(isFound ? "Reportar Hallazgo" : "Reportar Pérdida"),
        backgroundColor: Colors.transparent,
      ),
      body: _isPublishing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image Picker Section
                    _buildSectionTitle("Foto del objeto", theme),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: theme.colorScheme.outlineVariant, width: 2),
                        ),
                        child: imageFile == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo_rounded, size: 48, color: theme.colorScheme.primary),
                                  const SizedBox(height: 12),
                                  Text("Toca para tomar una foto", style: TextStyle(color: theme.colorScheme.primary)),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.file(imageFile!, fit: BoxFit.cover),
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Details Section
                    _buildSectionTitle("Información básica", theme),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: "Título del objeto",
                      hintText: "Ej: Llavero de la UAB",
                      controller: titleController,
                      validator: (value) => value == null || value.isEmpty ? "Campo obligatorio" : null,
                    ),
                    const SizedBox(height: 20),
                    
                    const Text("Categoría", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((cat) {
                        return ChoiceChip(
                          label: Text(cat),
                          selected: selectedCategory == cat,
                          onSelected: (_) => setState(() => selectedCategory = cat),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          showCheckmark: false,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),

                    _buildSectionTitle("Descripción y detalles", theme),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Describe el objeto y dónde lo encontraste...",
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildSectionTitle("Ubicación y Fecha", theme),
                    const SizedBox(height: 16),
                    _buildActionTile(
                      Icons.location_on_rounded,
                      locationText,
                      _getLocation,
                      _currentPosition != null,
                      theme,
                    ),
                    const SizedBox(height: 12),
                    _buildActionTile(
                      Icons.calendar_today_rounded,
                      selectedDate == null 
                        ? "Seleccionar fecha" 
                        : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                      _pickDate,
                      selectedDate != null,
                      theme,
                    ),
                    const SizedBox(height: 48),

                    CustomButton(
                      text: "Publicar anuncio",
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 32),
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
            width: isCompleted ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isCompleted ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
                  color: isCompleted ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (isCompleted)
              Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary, size: 20),
          ],
        ),
      ),
    );
  }
}