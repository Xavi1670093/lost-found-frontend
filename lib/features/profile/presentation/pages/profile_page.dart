import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/settings/app_settings_controller.dart';
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
  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.orange),
            const SizedBox(height: 16),
            const Text("Esperando respuesta de Firebase..."),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: widget.onLogout, child: const Text("Reintentar Login")),
          ],
        ),
      );
    }

    final DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(user.uid);

    return StreamBuilder<DatabaseEvent>(
      stream: userRef.onValue,
      builder: (context, snapshot) {
        String userName = "Cargando...";
        String userRole = "student";
        String centerId = "UAB";

        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          final data = Map<dynamic, dynamic>.from(snapshot.data!.snapshot.value as Map);
          userName = data['name'] ?? "Gur";
          userRole = data['role'] ?? "student";
          centerId = (data['center_id'] ?? "uab").toString().toUpperCase();
        }

        // Usamos AnimatedBuilder para que el cambio de idioma/tema sea instantáneo
        return AnimatedBuilder(
            animation: widget.settingsController,
            builder: (context, _) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // --- CABECERA ---
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: theme.colorScheme.primaryContainer,
                              child: Icon(Icons.person, size: 50, color: theme.colorScheme.primary),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: IconButton(
                                onPressed: () => _showEditNameDialog(userName, userRef),
                                icon: CircleAvatar(
                                  radius: 15,
                                  backgroundColor: theme.colorScheme.primary,
                                  child: const Icon(Icons.edit, size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(userName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        Text(user.email ?? "", style: TextStyle(color: Colors.grey.shade600)),
                        const SizedBox(height: 8),
                        Chip(label: Text("$userRole | $centerId", style: const TextStyle(fontSize: 12))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- SECCIÓN: MI ACTIVIDAD ---
                  _buildSectionTitle("Mi Actividad"),
                  _buildActionCard(
                    Icons.inventory_2_outlined,
                    t.publishedObjects,
                    Colors.blue,
                        () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const UserPostsPage())
                    ),
                  ),
                  _buildActionCard(
                      Icons.question_answer_outlined,
                      "Mis Peticiones",
                      Colors.orange,
                          () { /* TODO */ }
                  ),

                  const SizedBox(height: 20),

                  // --- SECCIÓN: AJUSTES (AQUÍ ESTÁ TU SELECTOR) ---
                  _buildSectionTitle(t.settings),

                  // Dark Mode
                  Card(
                    child: SwitchListTile(
                      secondary: const Icon(Icons.dark_mode_outlined),
                      title: Text(t.darkMode),
                      value: widget.settingsController.isDarkMode,
                      onChanged: (value) => widget.settingsController.setDarkMode(value),
                    ),
                  ),

                  // Idioma (RESTAURADO)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.language_outlined),
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
                        onChanged: (value) {
                          if (value != null) {
                            widget.settingsController.setLocale(Locale(value));
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Logout
                  Card(
                    color: Colors.red.withValues(alpha: 0.1),
                    elevation: 0,
                    child: ListTile(
                      leading: const Icon(Icons.logout_rounded, color: Colors.red),
                      title: const Text('Cerrar sesión', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      onTap: widget.onLogout,
                    ),
                  ),
                ],
              );
            }
        );
      },
    );
  }

  // --- MÉTODOS AUXILIARES ---

  void _showEditNameDialog(String currentName, DatabaseReference ref) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar Nombre"),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await ref.update({
                  'name': controller.text.trim(),
                  'updated_at': DateTime.now().millisecondsSinceEpoch
                });
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text("Guardar"),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 8),
      child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  Widget _buildActionCard(IconData icon, String title, Color color, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right, size: 18),
        onTap: onTap,
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