import 'package:flutter/material.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/settings/app_settings_controller.dart';

class ProfilePage extends StatelessWidget {
  final AppSettingsController settingsController;
  // --- AÑADIDO: Parámetro para la función de cerrar sesión ---
  final VoidCallback onLogout;

  const ProfilePage({
    super.key,
    required this.settingsController,
    required this.onLogout, // --- Requerido en el constructor ---
  });

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);

    return AnimatedBuilder(
      animation: settingsController,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Center(
              child: CircleAvatar(
                radius: 42,
                child: Icon(Icons.person, size: 42),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Usuario UAB',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),

            Card(
              child: ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: Text(t.publishedObjects),
                subtitle: Text(t.userHistory),
                onTap: () {},
              ),
            ),

            Card(
              child: SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: Text(t.darkMode),
                value: settingsController.isDarkMode,
                onChanged: (value) {
                  settingsController.setDarkMode(value);
                },
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.language_outlined),
                title: Text(t.language),
                subtitle: Text(_languageLabel(
                  context,
                  settingsController.locale.languageCode,
                )),
                trailing: DropdownButton<String>(
                  value: settingsController.locale.languageCode,
                  underline: const SizedBox(),
                  items: [
                    DropdownMenuItem(
                      value: 'es',
                      child: Text(t.spanish),
                    ),
                    DropdownMenuItem(
                      value: 'ca',
                      child: Text(t.catalan),
                    ),
                    DropdownMenuItem(
                      value: 'en',
                      child: Text(t.english),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    settingsController.setLocale(Locale(value));
                  },
                ),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: Text(t.settings),
                subtitle: Text(t.futureOptions),
                onTap: () {},
              ),
            ),

            // --- AÑADIDO: Opción de Cerrar Sesión según el Sketch  ---
            Card(
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.red),
                title: const Text(
                  'Cerrar sesión',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                ),
                onTap: onLogout, // Ejecuta la función que viene del padre
              ),
            ),
          ],
        );
      },
    );
  }

  String _languageLabel(BuildContext context, String code) {
    final t = AppStrings.of(context);

    switch (code) {
      case 'ca':
        return t.catalan;
      case 'en':
        return t.english;
      case 'es':
      default:
        return t.spanish;
    }
  }
}