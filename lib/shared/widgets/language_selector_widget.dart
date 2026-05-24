import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:unilost_found/core/settings/app_settings_controller.dart';

/// Selector interactivo de idioma de la aplicación.
///
/// Presenta botones de selección para los tres idiomas soportados (Español, Catalán, Inglés).
/// Cuando el usuario pulsa un idioma, actualiza el controlador local de ajustes [settingsController]
/// y escribe la preferencia en el nodo `/users/{uid}/preferredLanguage` de Firebase Realtime Database
/// en caso de estar autenticado, sincronizando los textos de forma instantánea.
class LanguageSelectorWidget extends StatelessWidget {
  /// Controlador de configuración de la app que gestiona la persistencia local y remota del idioma.
  final AppSettingsController settingsController;

  const LanguageSelectorWidget({
    super.key,
    required this.settingsController,
  });

  @override
  Widget build(BuildContext context) {
    final currentLocale = settingsController.locale;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final languages = [
      {'code': 'es', 'label': 'ES'},
      {'code': 'ca', 'label': 'CA'},
      {'code': 'en', 'label': 'EN'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: languages.map((lang) {
        final isSelected = currentLocale.languageCode == lang['code'];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: GestureDetector(
            onTap: () async {
              if (!isSelected) {
                final langCode = lang['code']!;
                await settingsController.setLocale(Locale(langCode));
                
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  try {
                    await FirebaseDatabase.instance
                        .ref('users/${user.uid}')
                        .update({'preferredLanguage': langCode});
                  } catch (e) {
                    debugPrint('ULF_DEBUG: Error updating preferredLanguage: $e');
                  }
                }
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : (isDark ? Colors.grey[850] : Colors.grey[200]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Text(
                lang['label']!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
