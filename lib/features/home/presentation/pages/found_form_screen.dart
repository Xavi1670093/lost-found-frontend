import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:unilost_found/core/localization/app_strings.dart';
import 'package:unilost_found/core/services/permission_service.dart';
import 'package:unilost_found/shared/widgets/custom_button.dart';
import 'package:unilost_found/shared/widgets/custom_text_field.dart';
import 'package:unilost_found/core/services/error_handler.dart';
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
      final userSnap = await FirebaseDatabase.instance.ref('users/${user.uid}/center_id').get();
      final centerId = userSnap.value?.toString().toLowerCase() ?? 'uab';
      
      final boundsSnap = await FirebaseDatabase.instance.ref('centers/$centerId/bounds').get();
      if (boundsSnap.exists) {
        setState(() {
          _centerBounds = Map<String, dynamic>.from(boundsSnap.value as Map);
        });
      } else if (centerId == 'uab') {
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
    final minLat = _centerBounds!['minLat'] as double;
    final maxLat = _centerBounds!['maxLat'] as double;
    final minLng = _centerBounds!['minLng'] as double;
    final maxLng = _centerBounds!['maxLng'] as double;
    
    return lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng;
  }

  String? selectedCategoryKey;
  DateTime? selectedDate;

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
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (!context.mounted) return;

      if (!_isWithinBounds(position.latitude, position.longitude)) {
        _showError(t.outsideBoundsError(_centerBounds?['name'] ?? 'UAB'));
        return;
      }

      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      if (!context.mounted) return;
      _showError(t.locationError);
    }
  }

  Future<void> _openMapPicker() async {
    if (_centerBounds == null) return;
    
    final initialLat = (_centerBounds!['minLat'] + _centerBounds!['maxLat']) / 2;
    final initialLng = (_centerBounds!['minLng'] + _centerBounds!['maxLng']) / 2;
    
    final osm.LatLng? pickedPoint = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerPage(
          initialCenter: osm.LatLng(initialLat, initialLng),
          bounds: LatLngBounds(
            osm.LatLng(_centerBounds!['minLat'], _centerBounds!['minLng']),
            osm.LatLng(_centerBounds!['maxLat'], _centerBounds!['maxLng']),
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

      String imageUrl = "";
      if (imageFile != null) {
        try {
          final storageRef = FirebaseStorage.instance.ref().child('posts/${newPostRef.key}/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');
          final uploadTask = storageRef.putFile(
            imageFile!,
            SettableMetadata(contentType: 'image/jpeg'),
          );
          final snapshotTask = await uploadTask;
          imageUrl = await snapshotTask.ref.getDownloadURL();
        } on FirebaseException catch (e) {
          if (e.code == 'permission-denied') {
             throw Exception(t.errorImageUpload);
          }
          rethrow;
        } catch (e) {
          rethrow;
        }
      }

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
          'lat': _currentPosition?.latitude ?? 41.502,
          'lng': _currentPosition?.longitude ?? 2.103,
        },
        'imageUrl': imageUrl,
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
