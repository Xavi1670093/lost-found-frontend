import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:unilost_found/core/services/custom_cache_manager.dart';
import 'package:unilost_found/shared/widgets/skeleton_loader.dart';
import 'package:unilost_found/core/localization/app_strings.dart';
import 'package:unilost_found/core/services/permission_service.dart';
import 'package:unilost_found/shared/widgets/custom_button.dart';
import 'package:unilost_found/shared/widgets/custom_text_field.dart';
import 'package:unilost_found/shared/widgets/field_label.dart';
import 'package:unilost_found/core/services/error_handler.dart';
import 'package:unilost_found/core/services/location_service.dart';
import 'package:unilost_found/shared/utils/app_notifications.dart';
import 'package:unilost_found/shared/utils/category_utils.dart';
import 'package:unilost_found/shared/utils/center_utils.dart';
import 'package:unilost_found/shared/utils/image_utils.dart';
import 'package:unilost_found/shared/widgets/map_picker_page.dart';
import 'package:unilost_found/features/home/presentation/pages/post_detail_page.dart'; // 2. IMPORTANTE: Importar la página de detalles
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

/// Pantalla que presenta el formulario de publicación de objetos.
///
/// Permite a los estudiantes reportar el hallazgo (`found`) o la pérdida (`lost`)
/// de pertenencias en el campus. Incluye flujos interactivos para capturar imágenes,
/// comprimirlas localmente, seleccionar geolocalización de forma automatizada por GPS
/// o selector interactivo en mapa, y ejecutar el algoritmo de coincidencia previo
/// a la publicación en base a coincidencias semánticas e indexadas en la nube.
class FoundFormScreen extends StatefulWidget {
  /// Tipo de reporte que se va a crear. Generalmente 'lost' o 'found'.
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
  List<LatLng>? _centerPolygon;
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
        _centerId = CenterUtils.normalizeCenterId(userData['center_id']);
        _userName = userData['name']?.toString() ?? user.displayName;
      } else {
        _centerId = CenterUtils.defaultCenterId;
        _userName = user.displayName;
      }
      
      final fetchId = CenterUtils.normalizeCenterId(_centerId);
      Map<dynamic, dynamic>? centerData = CenterUtils.getCachedCenter(fetchId);

      if (centerData == null) {
        final centerRef = FirebaseDatabase.instance.ref('centers/$fetchId');
        final centerSnap = await centerRef.get();
        if (centerSnap.exists) {
          centerData = Map<dynamic, dynamic>.from(centerSnap.value as Map);
          CenterUtils.cacheCenter(fetchId, centerData);
        }
      }
      
      final finalCenterData = centerData;
      if (finalCenterData != null) {
        setState(() {
          if (finalCenterData['bounds'] != null) {
            _centerBounds = Map<String, dynamic>.from(finalCenterData['bounds'] as Map);
          }
          if (finalCenterData['polygon'] != null) {
            _centerPolygon = (finalCenterData['polygon'] as List).map((point) {
              final p = Map<dynamic, dynamic>.from(point as Map);
              return LatLng(
                (p['lat'] as num).toDouble(),
                (p['lng'] as num).toDouble(),
              );
            }).toList();
          }
        });
      } else {
        // Fallback robusto para UAB si no hay conexión o no existe en la DB
        setState(() {
          _centerBounds = {
            'minLat': 41.450,
            'maxLat': 41.560,
            'minLng': 2.040,
            'maxLng': 2.170,
            'name': 'UAB Campus'
          };
          _centerPolygon ??= [
            const LatLng(41.507, 2.095),
            const LatLng(41.512, 2.105),
            const LatLng(41.505, 2.115),
            const LatLng(41.498, 2.108),
            const LatLng(41.496, 2.100),
          ];
        });
      }
    } catch (_) {
      setState(() {
        _centerId = CenterUtils.defaultCenterId;
        _centerBounds = {
          'minLat': 41.450,
          'maxLat': 41.560,
          'minLng': 2.040,
          'maxLng': 2.170,
          'name': 'UAB Campus'
        };
        _centerPolygon = [
          const LatLng(41.507, 2.095),
          const LatLng(41.512, 2.105),
          const LatLng(41.505, 2.115),
          const LatLng(41.498, 2.108),
          const LatLng(41.496, 2.100),
        ];
      });
    }
  }

  bool _isWithinBounds(double lat, double lng) {
    // 1. Prioridad: Validación por Polígono (Ray-Casting)
    if (_centerPolygon != null && _centerPolygon!.isNotEmpty) {
      return LocationService.isPointInPolygon(LatLng(lat, lng), _centerPolygon!);
    }

    // 2. Fallback: Validación por Radio de 1100m desde el centroide
    if (_centerBounds == null || _centerBounds!.isEmpty) return true;
    
    final double minLat = (_centerBounds!['minLat'] as num? ?? _centerBounds!['latMin'] as num? ?? 41.480).toDouble();
    final double maxLat = (_centerBounds!['maxLat'] as num? ?? _centerBounds!['latMax'] as num? ?? 41.520).toDouble();
    final double minLng = (_centerBounds!['minLng'] as num? ?? _centerBounds!['lngMin'] as num? ?? 2.085).toDouble();
    final double maxLng = (_centerBounds!['maxLng'] as num? ?? _centerBounds!['lngMax'] as num? ?? 2.130).toDouble();
    
    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;
    
    return LocationService.isWithinRadius(lat, lng, centerLat, centerLng, 1100);
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
    final picked = await ImageUtils.pickAndProcessImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (picked != null) setState(() => imageFile = picked);
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

      // Validación en tiempo real (Paso 1 del Roadmap Definitivo)
      if (!_isWithinBounds(position.latitude, position.longitude)) {
        _showError(t.errorLocationOutsideRecinct);
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
    debugPrint("ULF_DEBUG: _openMapPicker triggered. _centerBounds: $_centerBounds");
    
    // Extracción ultra-segura de coordenadas soportando múltiples formatos de nombres (minLat vs latMin)
    final double minLat = (_centerBounds?['minLat'] as num? ?? _centerBounds?['latMin'] as num? ?? 41.430).toDouble();
    final double maxLat = (_centerBounds?['maxLat'] as num? ?? _centerBounds?['latMax'] as num? ?? 41.580).toDouble();
    final double minLng = (_centerBounds?['minLng'] as num? ?? _centerBounds?['lngMin'] as num? ?? 2.020).toDouble();
    final double maxLng = (_centerBounds?['maxLng'] as num? ?? _centerBounds?['lngMax'] as num? ?? 2.190).toDouble();

    final initialLat = (minLat + maxLat) / 2;
    final initialLng = (minLng + maxLng) / 2;
    debugPrint("ULF_DEBUG: Final Calculated initial center: $initialLat, $initialLng");
    
    try {
      final LatLng? pickedPoint = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapPickerPage(
            initialCenter: LatLng(initialLat, initialLng),
            // Pasamos los límites para dibujar el círculo/polígono, pero el panning será libre para evitar crashes
            bounds: LatLngBounds(
              LatLng(minLat, minLng),
              LatLng(maxLat, maxLng),
            ),
            polygon: _centerPolygon,
          ),
        ),
      );
      debugPrint("ULF_DEBUG: Navigator returned: $pickedPoint");
      
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
    } catch (e) {
      debugPrint("ULF_DEBUG: Error opening MapPickerPage: $e");
    }
  }

  Future<void> _submit() async {
    final t = AppStrings.of(context);
    if (!_formKey.currentState!.validate()) return;
    
    final centerId = CenterUtils.normalizeCenterId(_centerId);
    final centerName = _centerBounds?['name']?.toString() ?? 'UAB Campus';
    
    final double minLat = (_centerBounds?['minLat'] as num? ?? _centerBounds?['latMin'] as num? ?? 41.480).toDouble();
    final double maxLat = (_centerBounds?['maxLat'] as num? ?? _centerBounds?['latMax'] as num? ?? 41.520).toDouble();
    final double minLng = (_centerBounds?['minLng'] as num? ?? _centerBounds?['lngMin'] as num? ?? 2.085).toDouble();
    final double maxLng = (_centerBounds?['maxLng'] as num? ?? _centerBounds?['lngMax'] as num? ?? 2.130).toDouble();

    final double defaultLat = (minLat + maxLat) / 2;
    final double defaultLng = (minLng + maxLng) / 2;

    if (_currentPosition != null) {
      if (!_isWithinBounds(_currentPosition!.latitude, _currentPosition!.longitude)) {
        _showError(t.errorLocationOutsideRecinct);
        return;
      }
    }

    if (selectedCategoryKey == null) {
      _showError(t.selectCategoryAndDate);
      return;
    }

    setState(() => _isPublishing = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception(t.sessionError);

      // --- NUEVA LÓGICA DE INTERCEPCIÓN (MATCHER) ---
      final callable = FirebaseFunctions.instance.httpsCallable('checkPotentialMatches');
      final result = await callable.call({
        'lang': AppStrings.of(context).locale.languageCode,
        'center_id': centerId.toLowerCase(),
        'category': selectedCategoryKey,
        'type': widget.postType,
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'postImageUrl': imageFile != null ? 'pending' : '',   // indica si el post tendrá imagen
        'created_at': DateTime.now().millisecondsSinceEpoch,  // timestamp para el score de fecha
      });

      if (!mounted) return;

      final matches = result.data['matches'] as List<dynamic>? ?? [];

      if (matches.isNotEmpty) {
        setState(() => _isPublishing = false); // Pausamos la carga para mostrar el popup
        
        final shouldPublishAnyway = await _showMatchesDialog(matches);
        
        if (!mounted) return;
        
        if (shouldPublishAnyway == true) {
          // Si el usuario decide ignorar las sugerencias, publicamos
          setState(() => _isPublishing = true);
          await _finalizePublish(user, centerId, centerName, defaultLat, defaultLng);
        }
      } else {
        // No hubo sugerencias del algoritmo, publicamos directamente
        await _finalizePublish(user, centerId, centerName, defaultLat, defaultLng);
      }

    } catch (e) {
      if (!mounted) return;
      final message = ErrorHandler.getMessage(e, t);
      _showError(message);
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }
  // MODIFICACIÓN 4: Lógica extraída de guardado final
  Future<void> _finalizePublish(User user, String centerId, String centerName, double defaultLat, double defaultLng) async {
    final t = AppStrings.of(context);
    final postsRef = FirebaseDatabase.instance.ref('posts');
    final newPostRef = postsRef.push();
    final postId = newPostRef.key;

    if (postId == null) throw Exception(t.errorSaving);

    final lat = _currentPosition?.latitude ?? defaultLat;
    final lng = _currentPosition?.longitude ?? defaultLng;
    final geohash = GeoHasher().encode(lng, lat);
    final imagePath = imageFile != null
        ? 'posts/$postId/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.webp'
        : null;

    String? imageUrl;
    if (imageFile != null && imagePath != null) {
      try {
        final processedImage = await ImageUtils.compressAndGetWebp(imageFile!);
        if (processedImage == null) throw Exception(t.errorImageUpload);

        final storageRef = FirebaseStorage.instance.ref().child(imagePath);
        final uploadTask = storageRef.putFile(processedImage, SettableMetadata(contentType: 'image/webp'));
        final snapshot = await uploadTask.whenComplete(() => null);
        imageUrl = await snapshot.ref.getDownloadURL();
      } catch (e) {
        if (!mounted) return;
        setState(() => _isPublishing = false);
        _showError(t.errorImageUpload);
        return;
      }
    }

    if (imageFile != null && (imageUrl == null || imageUrl.isEmpty)) {
      if (!mounted) return;
      setState(() => _isPublishing = false);
      _showError(t.errorImageUpload);
      return;
    }

    await newPostRef.set({
      'id': postId,
      'user_id': user.uid,
      'user_name': _userName ?? 'Estudiante',
      'center_id': centerId.toLowerCase(),
      'type': widget.postType,
      'title': titleController.text.trim(),
      'description': descriptionController.text.trim(),
      'category': selectedCategoryKey,
      'status': 'active',
      'location': centerName,
      'coords': {
        'lat': lat,
        'lng': lng,
        'geohash': geohash,
      },
      'photo_path': imagePath ?? '',
      'imageUrl': imageUrl ?? '',
      'postImageUrl': imageUrl ?? '',
      'date': selectedDate.millisecondsSinceEpoch,
      'created_at': ServerValue.timestamp,
      'updated_at': ServerValue.timestamp,
      'is_deleted': false,
    });

    if (!mounted) return;

    AppNotifications.showSuccess(
      context, 
      widget.postType == 'found' ? t.publishSuccessFound : t.publishSuccessLost
    );
    Navigator.pop(context);
  }

  // MODIFICACIÓN 5: Modal UI del Matcher
  Future<bool?> _showMatchesDialog(List<dynamic> matches) async {
    final theme = Theme.of(context);
    final t = AppStrings.of(context);
    int selectedIndex = 0;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // Obliga a interactuar con los botones
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: theme.colorScheme.surface,
          elevation: 6,
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            t.matcherTitle,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      t.matcherSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // List of matches
                    Flexible(
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 280),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: matches.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final match = matches[index];
                            final isSelected = selectedIndex == index;
                            final imageUrl = (match['postImageUrl'] ?? match['imageUrl'] ?? match['photo_url'] ?? '').toString();
                            return InkWell(
                              onTap: () {
                                setDialogState(() {
                                  selectedIndex = index;
                                });
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme.colorScheme.primary.withValues(alpha: 0.08)
                                      : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.outlineVariant,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: imageUrl.isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: imageUrl,
                                              cacheManager: CustomCacheManager.instance,
                                              width: 56,
                                              height: 56,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => const SkeletonLoader(
                                                width: 56,
                                                height: 56,
                                                borderRadius: BorderRadius.all(Radius.circular(12)),
                                              ),
                                              errorWidget: (context, url, error) => Container(
                                                width: 56,
                                                height: 56,
                                                color: theme.colorScheme.surfaceContainerHighest,
                                                child: Icon(
                                                  Icons.image_not_supported_rounded,
                                                  color: theme.colorScheme.onSurfaceVariant,
                                                ),
                                              ),
                                            )
                                          : Container(
                                              width: 56,
                                              height: 56,
                                              color: theme.colorScheme.surfaceContainerHighest,
                                              child: Icon(
                                                Icons.image_not_supported_rounded,
                                                color: theme.colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            match['title'] ?? 'Sin título',
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: theme.colorScheme.onSurface,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            match['description'] ?? '',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: theme.colorScheme.onSurfaceVariant,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      isSelected
                                          ? Icons.radio_button_checked_rounded
                                          : Icons.radio_button_off_rounded,
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurfaceVariant,
                                      size: 22,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Actions
                    CustomButton(
                      text: t.matcherViewButton,
                      onPressed: () async {
                        final selectedMatch = matches[selectedIndex];
                        final savedContext = context;
                        Navigator.pop(savedContext, false);
                        
                        final postSnap = await FirebaseDatabase.instance.ref('posts/${selectedMatch['id']}').get();
                        if (!mounted) return;
                        if (postSnap.exists) {
                          final postData = Map<dynamic, dynamic>.from(postSnap.value as Map);
                          await Navigator.push(
                            // ignore: use_build_context_synchronously
                            savedContext,
                            MaterialPageRoute(
                              builder: (_) => PostDetailPage(post: postData),
                            ),
                          );
                        } else {
                          // ignore: use_build_context_synchronously
                          AppNotifications.showError(savedContext, "No se pudo cargar el detalle del objeto.");
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    CustomButton(
                      text: t.matcherIgnoreButton,
                      isPrimary: false,
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
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
                        Flexible(
                          child: _buildSectionTitle(t.objectPhoto, theme),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            t.recommended,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
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
                    
                    // Vista previa del mapa si hay ubicación seleccionada
                    if (_currentPosition != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        height: 240,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                              initialZoom: 16,
                              interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.unilost.app',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                                    width: 40,
                                    height: 40,
                                    child: Icon(Icons.location_on_rounded, color: theme.colorScheme.primary, size: 30),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
