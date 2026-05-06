import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';
import '../../../../core/services/permission_service.dart';

class FoundFormScreen extends StatefulWidget {
  // 🚀 CORRECCIÓN: Definimos la variable aquí para que widget.postType funcione
  final String postType;

  const FoundFormScreen({
    super.key,
    this.postType = 'found', // Por defecto es 'found'
  });

  @override
  State<FoundFormScreen> createState() => _FoundFormScreenState();
}

class _FoundFormScreenState extends State<FoundFormScreen> {
  // --- ESTADO Y CONTROLADORES ---
  File? imageFile;
  String locationText = "Tocar para obtener ubicación";
  Position? _currentPosition;
  bool _isPublishing = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? selectedCategory;
  DateTime? selectedDate;

  final List<String> categories = ["Llaves", "Cartera", "Dispositivo", "Ropa", "Otros"];

  // --- LÓGICA DE APOYO ---

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
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _pickImage() async {
    final hasPermission = await PermissionService.requestCamera();
    if (!hasPermission) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
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

  // --- ENVÍO A FIREBASE ---
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
        'type': widget.postType, // ✅ Ahora widget.postType ya está definido
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

  // --- DISEÑO DE LA PANTALLA ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.postType == 'found' ? "He encontrado" : "He perdido"),
        backgroundColor: widget.postType == 'found' ? null : Colors.orange.shade100,
      ),
      body: _isPublishing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Título", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(hintText: "Ej: Llavero rojo", border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? "Campo obligatorio" : null,
              ),
              const SizedBox(height: 20),

              const Text("Categoría", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: categories.map((cat) {
                  return ChoiceChip(
                    label: Text(cat),
                    selected: selectedCategory == cat,
                    onSelected: (_) => setState(() => selectedCategory = cat),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              const Text("Foto", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 120, width: double.infinity,
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                  child: imageFile == null
                      ? const Center(child: Text("Tocar para hacer foto 📷"))
                      : Image.file(imageFile!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 20),

              const Text("Descripción", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(hintText: "Describe dónde lo encontraste...", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),

              const Text("Ubicación", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _getLocation,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                  child: Text(locationText),
                ),
              ),
              const SizedBox(height: 20),

              const Text("Fecha", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text(selectedDate == null ? "Selecciona fecha" : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}")),
                  IconButton(icon: const Icon(Icons.calendar_today), onPressed: _pickDate),
                ],
              ),
              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                      child: const Text("Cancelar", style: TextStyle(color: Colors.red)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text("Publicar", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}