import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:unilost_found/core/localization/app_strings.dart';
import 'package:unilost_found/core/settings/app_settings_controller.dart';
import 'package:unilost_found/shared/utils/app_notifications.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:unilost_found/shared/widgets/custom_card.dart';
import 'package:unilost_found/shared/widgets/skeleton_loader.dart';
import 'package:unilost_found/core/services/permission_service.dart';
import 'user_posts_page.dart';

class ProfilePage extends StatefulWidget {
  final AppSettingsController settingsController;
  final VoidCallback onLogout;

  const ProfilePage({
    super.key,
    required this.settingsController,
    required this.onLogout,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isUploadingPhoto = false;
  int _imageVersion = DateTime.now().millisecondsSinceEpoch;

  Future<void> _pickAndUploadPhoto(DatabaseReference ref, String userId) async {
    final t = AppStrings.of(context);
    
    // 1. Solicitar permisos y elegir imagen
    final hasPermission = await PermissionService.requestCamera();
    if (!hasPermission) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile == null) return;

    // 2. Validar formato (jpg/jpeg o png)
    final path = pickedFile.path.toLowerCase();
    if (!path.endsWith('.jpg') && !path.endsWith('.jpeg') && !path.endsWith('.png')) {
      if (mounted) AppNotifications.showError(context, t.unsupportedFormat);
      return;
    }

    setState(() => _isUploadingPhoto = true);

    try {
      // 3. Subir a Firebase Storage
      final file = File(pickedFile.path);
      final storageRef = FirebaseStorage.instance.ref().child('users/$userId/profile_image');
      
      final metadata = SettableMetadata(
        contentType: path.endsWith('.png') ? 'image/png' : 'image/jpeg',
      );

      await storageRef.putFile(file, metadata);
      
      // Ya NO actualizamos el RTDB manualmente aquí. 
      // Dejamos que el backend procese la imagen a .webp y actualice el campo 'photoUrl'.
      debugPrint("ULF_DEBUG: Upload finished, waiting for backend processing...");
      
    } catch (e) {
      if (mounted) {
        AppNotifications.showError(context, t.errorSaving);
        setState(() => _isUploadingPhoto = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
    }

    final DatabaseReference userRef = FirebaseDatabase.instance.ref('users/${user.uid}');

    return StreamBuilder<DatabaseEvent>(
      stream: userRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildSkeleton(theme);
        }

        String userName = t.defaultUserName;
        String userRole = t.studentRole;
        String centerId = t.uabAcronym;
        String? photoUrl;

        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          final data = Map<dynamic, dynamic>.from(snapshot.data!.snapshot.value as Map);
          userName = data['name'] ?? t.defaultUserName;
          userRole = data['role'] == 'admin' ? t.adminRole : t.studentRole;
          centerId = (data['center_id'] ?? t.uabAcronym).toString().toUpperCase();
          final snakeUrl = data['photo_url']?.toString();
          final camelUrl = data['photoUrl']?.toString();
          
          // Priorizamos la URL que contenga .webp (procesada por el backend)
          if (camelUrl != null && camelUrl.contains('.webp')) {
            photoUrl = camelUrl;
          } else if (snakeUrl != null && snakeUrl.contains('.webp')) {
            photoUrl = snakeUrl;
          } else {
            photoUrl = camelUrl ?? snakeUrl ?? data['imageUrl'];
          }
          
          debugPrint("ULF_DEBUG: Final photoUrl: $photoUrl");
          
          if (_isUploadingPhoto && photoUrl != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _isUploadingPhoto = false;
                  _imageVersion = DateTime.now().millisecondsSinceEpoch;
                });
                AppNotifications.showSuccess(context, t.editPhotoSuccess);
              }
            });
          }
        }

        return AnimatedBuilder(
          animation: widget.settingsController,
          builder: (context, _) {
            return Scaffold(
              body: CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                      ),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: () => _pickAndUploadPhoto(userRef, user.uid),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                    child: _isUploadingPhoto
                                        ? const CircularProgressIndicator()
                                        : photoUrl != null
                                            ? ClipOval(
                                                child: CachedNetworkImage(
                                                  imageUrl: "$photoUrl?v=$_imageVersion",
                                                  width: 100,
                                                  height: 100,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) => const CircularProgressIndicator(),
                                                  errorWidget: (context, url, error) {
                                                     debugPrint("ULF_DEBUG: Image load error: $error");
                                                     return Icon(Icons.person_rounded, size: 50, color: theme.colorScheme.primary);
                                                   },
                                                ),
                                              )
                                            : Icon(Icons.person_rounded, size: 50, color: theme.colorScheme.primary),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => _showEditNameDialog(userName, userRef),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: theme.colorScheme.secondary, shape: BoxShape.circle),
                                    child: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            userName,
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email ?? "",
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "$userRole | $centerId",
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Content
                  SliverPadding(
                    padding: const EdgeInsets.all(24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildSectionTitle(t.myActivity, theme),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionCard(
                                Icons.inventory_2_outlined,
                                t.myFindings,
                                theme.colorScheme.primary,
                                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserPostsPage(type: 'found'))),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildActionCard(
                                Icons.search_rounded,
                                t.myLosses,
                                theme.colorScheme.secondary,
                                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserPostsPage(type: 'lost'))),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),
                        _buildSectionTitle(t.settingsTitle, theme),
                        const SizedBox(height: 12),
                        
                        CustomCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              SwitchListTile(
                                secondary: Icon(Icons.dark_mode_outlined, color: theme.colorScheme.primary),
                                title: Text(t.darkMode),
                                value: widget.settingsController.isDarkMode,
                                onChanged: (v) => widget.settingsController.setDarkMode(v),
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: Icon(Icons.language_outlined, color: theme.colorScheme.primary),
                                title: Text(t.language),
                                subtitle: Text(_languageLabel(context, widget.settingsController.locale.languageCode)),
                                trailing: DropdownButton<String>(
                                  value: widget.settingsController.locale.languageCode,
                                  underline: const SizedBox(),
                                  items: [
                                    DropdownMenuItem(value: 'es', child: Text(t.spanish)),
                                    DropdownMenuItem(value: 'ca', child: Text(t.catalan)),
                                    DropdownMenuItem(value: 'en', child: Text(t.english)),
                                  ],
                                  onChanged: (v) => v != null ? widget.settingsController.setLocale(Locale(v)) : null,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),
                        Center(
                          child: TextButton.icon(
                            onPressed: widget.onLogout,
                            icon: const Icon(Icons.logout_rounded, color: Colors.red),
                            label: Text(t.logout, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              backgroundColor: Colors.red.withValues(alpha: 0.05),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 120),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditNameDialog(String currentName, DatabaseReference ref) {
    final t = AppStrings.of(context);
    final controller = TextEditingController(text: currentName);
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(t.editNameTitle),
          content: TextField(
            controller: controller,
            enabled: !isSaving,
            decoration: InputDecoration(
              labelText: t.newNameLabel,
              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(context),
              child: Text(t.cancel),
            ),
            ElevatedButton(
              onPressed: isSaving 
                ? null 
                : () async {
                    if (controller.text.trim().isNotEmpty) {
                      setState(() => isSaving = true);
                      try {
                        await ref.update({
                          'name': controller.text.trim(), 
                          'updated_at': DateTime.now().millisecondsSinceEpoch
                        });
                        if (context.mounted) {
                          Navigator.pop(context);
                          AppNotifications.showSuccess(context, t.updateSuccess);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          setState(() => isSaving = false);
                          AppNotifications.showError(context, t.errorSaving);
                        }
                      }
                    }
                  },
              child: isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(t.save),
            ),
          ],
        ),
      ),
    ).then((_) => controller.dispose());
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

  Widget _buildActionCard(IconData icon, String title, Color color, VoidCallback onTap) {
    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSkeleton(ThemeData theme) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SkeletonLoader(
              height: 250,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonLoader(width: 150, height: 20),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: SkeletonLoader(height: 100, borderRadius: BorderRadius.circular(16))),
                      const SizedBox(width: 16),
                      Expanded(child: SkeletonLoader(height: 100, borderRadius: BorderRadius.circular(16))),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const SkeletonLoader(width: 150, height: 20),
                  const SizedBox(height: 16),
                  SkeletonLoader(height: 120, borderRadius: BorderRadius.circular(16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _languageLabel(BuildContext context, String code) {
    final t = AppStrings.of(context);
    switch (code) {
      case 'ca': return t.catalan;
      case 'en': return t.english;
      default: return t.spanish;
    }
  }
}
