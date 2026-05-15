import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:unilost_found/core/localization/app_strings.dart';
import 'package:unilost_found/core/services/permission_service.dart';
import 'package:unilost_found/shared/widgets/custom_button.dart';
import 'package:unilost_found/shared/widgets/custom_text_field.dart';
import 'package:unilost_found/shared/widgets/field_label.dart';
import 'package:unilost_found/core/services/error_handler.dart';
import 'package:unilost_found/core/services/location_service.dart';
import 'package:unilost_found/shared/utils/app_notifications.dart';
import 'package:unilost_found/shared/utils/category_utils.dart';
import 'package:unilost_found/shared/widgets/map_picker_page.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as osm;

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
  String _locationMethod = 'gps'; // 'gps' o 'map'
  Map<String, dynamic>? _centerBounds;
  String? _centerId;
  String? _userName;
  bool _isPublishing = false;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    _loadCenterBounds();
  }

  Future<void> _loadCenterBounds() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      final userSnap = await FirebaseDatabase.instance.ref('users/${user.uid}').get();
      if (userSnap.exists) {
        final userData = Map<dynamic, dynamic>.from(userSnap.value as Map);
        _centerId = userData['center_id']?.toString().toLowerCase() ?? 'uab';
        _userName = userData['name']?.toString() ?? user.displayName;
      } else {
        _centerId = 'uab';
        _userName = user.displayName;
      }
      
      final fetchId = _centerId!;
      final boundsSnap = await FirebaseDatabase.instance.ref('centers/$fetchId/bounds').get();
      if (boundsSnap.exists) {
        setState(() {
          _centerBounds = Map<String, dynamic>.from(boundsSnap.value as Map);
        });
      } else if (fetchId == 'uab') {
        // Fallback para UAB si no está en la DB
        _centerBounds = {
          'minLat': 41.490,
          'maxLat': 41.510,
          'minLng': 2.090,
          'maxLng': 2.120,
          'name': 'UAB'
        };
      }
    } catch (_) {}
  }

  bool _isWithinBounds(double lat, double lng) {
    if (_centerBounds == null) return true;
    
    // Extracción segura de límites con fallback para evitar NoSuchMethodError
    final double? minLat = _centerBounds!['minLat'] as double?;
    final double? maxLat = _centerBounds!['maxLat'] as double?;
    final double? minLng = _centerBounds!['minLng'] as double?;
    final double? maxLng = _centerBounds!['maxLng'] as double?;

    if (minLat == null || maxLat == null || minLng == null || maxLng == null) {
      return true; // Si los límites son corruptos, permitimos por defecto para no bloquear al usuario
    }
    
    // Calculamos el centroide de la universidad (garantizado no nulo)
    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;
    
    // Validamos que el usuario esté en un radio de 1.5km del centro de la uni
    return LocationService.isWithinRadius(lat, lng, centerLat, centerLng, 1500);
  }

  String? selectedCategoryKey;
  DateTime selectedDate = DateTime.now();

  // Las opciones de categoría se cargan dinámicamente desde AppStrings en el build

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
      // Obtenemos la posición con un timeout de 10 segundos para no bloquear la UI indefinidamente
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      if (!mounted) return;

      // Validación en tiempo real (Tarea 3)
      if (!_isWithinBounds(position.latitude, position.longitude)) {
        _showError(t.outsideBoundsError(_centerBounds?['name'] ?? 'UAB'));
        // IMPORTANTE: No sobreescribimos _currentPosition si está fuera de rango
        return;
      }

      setState(() {
        _currentPosition = position;
      });
      
      // Feedback visual de éxito
      if (mounted) {
        AppNotifications.showSuccess(context, t.locationObtained);
      }
    } catch (e) {
      if (!mounted) return;
      _showError(t.locationError);
    }
  }

  Future<void> _openMapPicker() async {
    final t = AppStrings.of(context);
    
    // Comprobación de nulidad exhaustiva (Prioridad Cero)
    if (_centerBounds == null) {
      _showError(t.centerLocationError);
      return;
    }

    // Extracción segura de coordenadas con respaldo (fallback) preventivo
    final double? minLat = _centerBounds!['minLat'] as double?;
    final double? maxLat = _centerBounds!['maxLat'] as double?;
    final double? minLng = _centerBounds!['minLng'] as double?;
    final double? maxLng = _centerBounds!['maxLng'] as double?;

    // Si falta algún dato crítico, abortamos la apertura para evitar el Crash
    if (minLat == null || maxLat == null || minLng == null || maxLng == null) {
      _showError(t.centerLocationError);
      return;
    }
    
    // Cálculo seguro del centroide (garantizado no nulo)
    final initialLat = (minLat + maxLat) / 2;
    final initialLng = (minLng + maxLng) / 2;
    
    final osm.LatLng? pickedPoint = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerPage(
          initialCenter: osm.LatLng(initialLat, initialLng),
          bounds: LatLngBounds(
            osm.LatLng(minLat, minLng),
            osm.LatLng(maxLat, maxLng),
          ),
        ),
      ),
    );

    if (pickedPoint != null) {
      setState(() {
        _currentPosition = Position(
          latitude: pickedPoint.latitude,
          longitude: pickedPoint.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      });
    }
  }

  Future<void> _submit() async {
    final t = AppStrings.of(context);
    if (!_formKey.currentState!.validate()) return;
    
    // 1. Obtener centro y límites para valores por defecto seguros
    final centerId = _centerId ?? 'uab';
    final centerName = _centerBounds?['name']?.toString() ?? 'UAB Campus';
    
    // Cálculo del centroide para el fallback (evita valores fuera de rango)
    final double defaultLat = ((_centerBounds?['minLat'] as double? ?? 41.490) + (_centerBounds?['maxLat'] as double? ?? 41.510)) / 2;
    final double defaultLng = ((_centerBounds?['minLng'] as double? ?? 2.090) + (_centerBounds?['maxLng'] as double? ?? 2.120)) / 2;

    // 2. Validación de ubicación (Tarea 3)
    if (_currentPosition != null && !_isWithinBounds(_currentPosition!.latitude, _currentPosition!.longitude)) {
      _showError(t.outsideBoundsError(centerName));
      return;
    }

    if (selectedCategoryKey == null) {
      _showError(t.selectCategoryAndDate);
      return;
    }

    setState(() => _isPublishing = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception(t.sessionError);

      final postsRef = FirebaseDatabase.instance.ref('posts');
      final newPostRef = postsRef.push();

      String imageUrl = "";
      if (imageFile != null) {
        try {
          final storageRef = FirebaseStorage.instance.ref().child('posts/${newPostRef.key}/${user.uid}.jpg');
          final uploadTask = await storageRef.putFile(
            imageFile!,
            SettableMetadata(contentType: 'image/jpeg'),
          );
          imageUrl = await uploadTask.ref.getDownloadURL();
        } on FirebaseException catch (e) {
          if (e.code == 'permission-denied') {
             throw Exception(t.errorImageUpload);
          }
          rethrow;
        } catch (e) {
          rethrow;
        }
      }

      // Cálculo del Geohash (Requerido por Security Rules)
      final lat = _currentPosition?.latitude ?? defaultLat;
      final lng = _currentPosition?.longitude ?? defaultLng;
      final geohash = GeoHasher().encode(lng, lat);

      // 3. Envío de datos con estructura compatible con Security Rules
      await newPostRef.set({
        'id': newPostRef.key,
        'user_id': user.uid,
        'user_name': _userName ?? 'Estudiante', // Campo requerido para denormalización
        'center_id': centerId.toLowerCase(),
        'type': widget.postType,
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'category': selectedCategoryKey,
        'status': 'active',
        'location': centerName, // CAMPO CRÍTICO: Requerido por la DB
        'coords': {
          'lat': lat,
          'lng': lng,
          'geohash': geohash, // CAMPO CRÍTICO: Requerido por la DB
        },
        'imageUrl': imageUrl,
        'date': selectedDate.millisecondsSinceEpoch,
        'created_at': ServerValue.timestamp,
        'updated_at': ServerValue.timestamp,
        'is_deleted': false,
      });

      if (mounted) {
        AppNotifications.showSuccess(
          context, 
          widget.postType == 'found' ? t.publishSuccessFound : t.publishSuccessLost
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      final message = ErrorHandler.getMessage(e, t);
      _showError(message);
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  void _showError(String msg) {
    AppNotifications.showError(context, msg);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final theme = Theme.of(context);
    final isFound = widget.postType == 'found';

    final Map<String, String> categories = {
      for (var cat in CategoryUtils.categories) cat: CategoryUtils.getCategoryLabel(cat, t),
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
                    Row(
                      children: [
                        _buildSectionTitle(t.objectPhoto, theme),
                        const SizedBox(width: 8),
                        Text(
                          t.recommended,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
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
                      isRequired: true,
                      validator: (value) => value == null || value.isEmpty ? t.fieldRequired : null,
                    ),
                    const SizedBox(height: 24),
                    
                    FieldLabel(label: t.category, isRequired: true),
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

                    CustomTextField(
                      label: "${t.descriptionDetails} ${t.optional}",
                      hintText: t.descriptionHint,
                      controller: descriptionController,
                      maxLines: 4,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 32),

                    _buildSectionTitle(t.locationOptional, theme),
                    const SizedBox(height: 16),
                    SegmentedButton<String>(
                      segments: [
                        ButtonSegment(
                          value: 'gps',
                          label: Text(t.gpsLocation),
                          icon: const Icon(Icons.my_location_rounded, size: 18),
                        ),
                        ButtonSegment(
                          value: 'map',
                          label: Text(t.mapLocation),
                          icon: const Icon(Icons.map_rounded, size: 18),
                        ),
                      ],
                      selected: {_locationMethod},
                      onSelectionChanged: (newSelection) {
                        setState(() {
                          _locationMethod = newSelection.first;
                          _currentPosition = null;
                        });
                      },
                      style: SegmentedButton.styleFrom(
                        visualDensity: VisualDensity.comfortable,
                        selectedBackgroundColor: theme.colorScheme.primaryContainer,
                        selectedForegroundColor: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildActionTile(
                      _locationMethod == 'gps' ? Icons.location_on_rounded : Icons.map_outlined,
                      _currentPosition != null 
                        ? t.locationObtained 
                        : (_locationMethod == 'gps' ? t.getCurrentLocation : t.mapLocation),
                      _locationMethod == 'gps' ? _getLocation : _openMapPicker,
                      _currentPosition != null,
                      theme,
                    ),
                    const SizedBox(height: 12),
                    FieldLabel(label: t.dateLabel, isRequired: true),
                    _buildActionTile(
                      Icons.calendar_today_rounded,
                       "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                      _pickDate,
                      true,
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
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
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
  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
