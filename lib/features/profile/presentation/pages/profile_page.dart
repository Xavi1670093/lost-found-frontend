import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unilost_found/core/localization/app_strings.dart';
import 'package:unilost_found/core/settings/app_settings_controller.dart';
import 'package:unilost_found/shared/utils/app_notifications.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:unilost_found/shared/widgets/custom_card.dart';
import 'package:unilost_found/shared/widgets/skeleton_loader.dart';
import 'package:unilost_found/core/services/custom_cache_manager.dart';
import 'package:unilost_found/shared/utils/image_utils.dart';
import 'user_posts_page.dart';
import 'package:unilost_found/shared/widgets/legal_markdown_dialog.dart';

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
  String? _oldPhotoUrl;
  int _imageVersion = DateTime.now().millisecondsSinceEpoch;

  Future<void> _pickAndUploadPhoto(DatabaseReference ref, String userId, String? currentPhotoUrl) async {
    final t = AppStrings.of(context);
    
    // 1. Elegir e imagen usando el procesador unificado
    final processedImage = await ImageUtils.pickAndProcessImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (processedImage == null) return;

    setState(() {
      _oldPhotoUrl = currentPhotoUrl;
      _isUploadingPhoto = true;
    });

    try {
      // 2. Subir a Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('users/$userId/profile_image');
      
      final metadata = SettableMetadata(
        contentType: 'image/webp',
      );

      await storageRef.putFile(processedImage, metadata).timeout(
        const Duration(seconds: 15),
      );
      
      // Ya NO actualizamos el RTDB manualmente aquí. 
      // Dejamos que el backend procese la imagen a .webp y actualice el campo 'photoUrl'.
      debugPrint("ULF_DEBUG: Upload finished, waiting for backend processing...");
      
    } catch (e) {
      if (mounted) {
        AppNotifications.showError(context, t.errorSaving);
        setState(() {
          _isUploadingPhoto = false;
          _oldPhotoUrl = null;
        });
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
          
          // Priorizamos siempre la URL más actualizada (camelCase 'photoUrl') y luego el formato heredado (snake_case)
          if (camelUrl != null && camelUrl.isNotEmpty) {
            photoUrl = camelUrl;
          } else if (snakeUrl != null && snakeUrl.isNotEmpty) {
            photoUrl = snakeUrl;
          } else {
            final legacyImg = data['imageUrl']?.toString();
            photoUrl = (legacyImg != null && legacyImg.isNotEmpty) ? legacyImg : null;
          }
          
          debugPrint("ULF_DEBUG: Final photoUrl: $photoUrl");
          
          // Solo completamos el estado de subida si el photoUrl actual es diferente del que teníamos antes de subir (para evitar trigger falso inmediato)
          if (_isUploadingPhoto && photoUrl != null && photoUrl != _oldPhotoUrl) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _isUploadingPhoto = false;
                  _oldPhotoUrl = null;
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
                                onTap: () => _pickAndUploadPhoto(userRef, user.uid, photoUrl),
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
                                                  imageUrl: photoUrl.contains('?') 
                                                      ? "$photoUrl&v=$_imageVersion" 
                                                      : "$photoUrl?v=$_imageVersion",
                                                  cacheManager: CustomCacheManager.instance,
                                                  width: 100,
                                                  height: 100,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) => const SkeletonLoader(
                                                    width: 100,
                                                    height: 100,
                                                    borderRadius: BorderRadius.all(Radius.circular(50)),
                                                  ),
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
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              userName,
                              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              user.email ?? "",
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
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
                              textAlign: TextAlign.center,
                              softWrap: true,
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
                              ListTile(
                                leading: Icon(Icons.dark_mode_outlined, color: theme.colorScheme.primary),
                                title: Text(t.appTheme),
                                subtitle: Text(
                                  widget.settingsController.themeMode == ThemeMode.system
                                      ? t.themeSystem
                                      : widget.settingsController.themeMode == ThemeMode.dark
                                          ? t.themeDark
                                          : t.themeLight,
                                ),
                                trailing: DropdownButton<ThemeMode>(
                                  value: widget.settingsController.themeMode,
                                  underline: const SizedBox(),
                                  items: [
                                    DropdownMenuItem(
                                      value: ThemeMode.light,
                                      child: Text(t.themeLight),
                                    ),
                                    DropdownMenuItem(
                                      value: ThemeMode.dark,
                                      child: Text(t.themeDark),
                                    ),
                                    DropdownMenuItem(
                                      value: ThemeMode.system,
                                      child: Text(t.themeSystem),
                                    ),
                                  ],
                                  onChanged: (ThemeMode? value) {
                                    if (value != null) {
                                      widget.settingsController.setThemeMode(value);
                                    }
                                  },
                                ),
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
                              const Divider(height: 1),
                              PushNotificationsSwitchTile(settingsController: widget.settingsController),
                              const Divider(height: 1),
                              ListTile(
                                leading: Icon(Icons.support_agent_rounded, color: theme.colorScheme.primary),
                                title: Text(t.customerSupport),
                                trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.colorScheme.onSurfaceVariant),
                                onTap: _showSupportDialog,
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
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => const LegalMarkdownDialog(documentName: 'terms'),
                                );
                              },
                              child: Text(
                                t.termsAndConditions,
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "•",
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => const LegalMarkdownDialog(documentName: 'privacy'),
                                );
                              },
                              child: Text(
                                t.privacyPolicy,
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
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
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _EditNameDialogContent(
        currentName: currentName,
        userRef: ref,
      ),
    );
  }

  void _showSupportDialog() {
    final t = AppStrings.of(context);
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.support_agent_rounded, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  t.customerSupport,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.supportHelpText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  t.email,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  'support@unilostfound.com',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  t.phone,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  '+34 XXX XX XX XX',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t.close),
            ),
          ],
        );
      },
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
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
          ),
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

class _EditNameDialogContent extends StatefulWidget {
  final String currentName;
  final DatabaseReference userRef;

  const _EditNameDialogContent({
    required this.currentName,
    required this.userRef,
  });

  @override
  State<_EditNameDialogContent> createState() => _EditNameDialogContentState();
}

class _EditNameDialogContentState extends State<_EditNameDialogContent> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final theme = Theme.of(context);
    final bool isFormValid = _controller.text.trim().isNotEmpty;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(t.editNameTitle),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.newNameLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: !_isSaving,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return t.fieldRequired;
                    }
                    return null;
                  },
                  onChanged: (_) {
                    setState(() {});
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSaving 
                    ? null 
                    : () {
                        _focusNode.unfocus();
                        _formKey.currentState?.reset();
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(t.cancel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: (_isSaving || !isFormValid)
                    ? null
                    : () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          setState(() => _isSaving = true);
                          try {
                            await widget.userRef.update({
                              'name': _controller.text.trim(), 
                              'updated_at': ServerValue.timestamp
                            });
                            if (context.mounted) {
                              Navigator.pop(context);
                              AppNotifications.showSuccess(context, t.profileUpdatedSuccess);
                            }
                          } on FirebaseException catch (e) {
                            if (context.mounted) {
                              setState(() => _isSaving = false);
                              debugPrint("ULF_DEBUG: FirebaseException during profile update: ${e.code} - ${e.message}");
                              AppNotifications.showError(context, t.errorSaving);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              setState(() => _isSaving = false);
                              AppNotifications.showError(context, t.errorSaving);
                            }
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: _isSaving 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(t.save),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class PushNotificationsSwitchTile extends StatelessWidget {
  final AppSettingsController settingsController;

  const PushNotificationsSwitchTile({super.key, required this.settingsController});

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final theme = Theme.of(context);

    return SwitchListTile.adaptive(
      secondary: Icon(Icons.notifications_active_outlined, color: theme.colorScheme.primary),
      title: Text(t.settingsPushToggle),
      subtitle: Text(
        t.settingsPushDesc,
        style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
      ),
      value: settingsController.pushNotificationsEnabled,
      onChanged: (v) => settingsController.setPushNotifications(v),
    );
  }
}
