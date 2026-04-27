import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import '../../../../core/services/permission_service.dart';

class FoundFormScreen extends StatefulWidget {
  const FoundFormScreen({super.key});

  @override
  State<FoundFormScreen> createState() => _FoundFormScreenState();
}

class _FoundFormScreenState extends State<FoundFormScreen> {

  File? imageFile;

  String locationText = "Tocar para obtener ubicación";

  final _formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? selectedCategory;
  DateTime? selectedDate;

  final List<String> categories = [
    "Llaves",
    "Cartera",
    "Dispositivo",
    "Ropa",
    "Otros"
  ];

  // 📅 Selector fecha
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // 🚀 Submit
  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (selectedCategory == null) {
      _showError("Selecciona una categoría");
      return;
    }

    if (selectedDate == null) {
      _showError("Selecciona una fecha");
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Publicado 🚀")),
    );

    Navigator.pop(context);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void _cancel() {
    Navigator.pop(context);
  }

  Future<void> _pickImage() async {
    final hasPermission = await PermissionService.requestCamera();
    if (!hasPermission) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  Future<void> _getLocation() async {
    final hasPermission = await PermissionService.requestLocation();
    if (!hasPermission) return;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      locationText =
      "Lat: ${position.latitude}, Lng: ${position.longitude}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("He encontrado"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 📝 TÍTULO
              const Text("Título",
                  style: TextStyle(fontWeight: FontWeight.bold)),

              const SizedBox(height: 8),

              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: "Ej: Llavero rojo",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? "Campo obligatorio" : null,
              ),

              const SizedBox(height: 20),

              // 🏷️ CATEGORÍA
              const Text("Categoría",
                  style: TextStyle(fontWeight: FontWeight.bold)),

              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                children: categories.map((cat) {
                  return ChoiceChip(
                    label: Text(cat),
                    selected: selectedCategory == cat,
                    onSelected: (_) {
                      setState(() {
                        selectedCategory = cat;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // 📷 FOTO (solo UI por ahora)
              const Text("Foto",
                  style: TextStyle(fontWeight: FontWeight.bold)),

              const SizedBox(height: 8),

              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: imageFile == null
                      ? const Center(child: Text("Tocar para hacer foto 📷"))
                      : Image.file(imageFile!, fit: BoxFit.cover),
                ),
              ),

              const SizedBox(height: 20),

              // 📄 DESCRIPCIÓN
              const Text("Descripción",
                  style: TextStyle(fontWeight: FontWeight.bold)),

              const SizedBox(height: 8),

              TextFormField(
                controller: descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Describe dónde lo encontraste...",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              // 📍 UBICACIÓN (mock)
              const Text("Ubicación",
                  style: TextStyle(fontWeight: FontWeight.bold)),

              const SizedBox(height: 8),

              GestureDetector(
                onTap: _getLocation,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(locationText),
                ),
              ),

              const SizedBox(height: 20),

              // 📅 FECHA
              const Text("Fecha",
                  style: TextStyle(fontWeight: FontWeight.bold)),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedDate == null
                          ? "Selecciona fecha"
                          : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _pickDate,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // 🔘 BOTONES
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _cancel,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text("Cancelar",
                          style: TextStyle(color: Colors.red)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text("Publicar"),
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