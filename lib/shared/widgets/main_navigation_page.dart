import 'package:flutter/material.dart';
import 'package:unilost_found/features/auth/presentation/pages/login_page.dart';
import 'package:unilost_found/core/settings/app_settings_controller.dart';
import 'package:unilost_found/features/chats/presentation/pages/chats_page.dart';
import 'package:unilost_found/features/home/presentation/pages/home_page.dart';
import 'package:unilost_found/features/profile/presentation/pages/profile_page.dart';
import 'package:unilost_found/features/home/presentation/pages/found_form_screen.dart';

class MainNavigationPage extends StatefulWidget {
  final AppSettingsController settingsController;
  const MainNavigationPage({super.key, required this.settingsController});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 1; // Default to Home

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text('¿Cerrar sesión?'),
          ],
        ),
        content: const Text('¿Estás seguro de que quieres salir de ULF?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(settingsController: widget.settingsController),
                ),
                    (route) => false,
              );
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  void _openOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.search, color: Colors.green),
              title: const Text("He encontrado algo"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FoundFormScreen(postType: 'found'))
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning, color: Colors.orange),
              title: const Text("He perdido algo"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FoundFormScreen(postType: 'lost'))
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pages = [
      const ChatsPage(),
      const HomePage(),
      ProfilePage(
        settingsController: widget.settingsController,
        onLogout: _showLogoutDialog,
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            icon: Icon(Icons.chat_bubble_outline_rounded),
            label: 'Chats',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.home_rounded),
            icon: Icon(Icons.home_outlined),
            label: 'Inicio',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person_rounded),
            icon: Icon(Icons.person_outline_rounded),
            label: 'Perfil',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton.extended(
              onPressed: _openOptions,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Reportar'),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }
}