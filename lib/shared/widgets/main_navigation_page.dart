import 'package:flutter/material.dart';
// --- FIX: Importamos el LoginPage para que el Logout funcione ---
import '../../features/auth/presentation/pages/login_page.dart';
import '../../core/settings/app_settings_controller.dart';
import '../../features/chats/presentation/pages/chats_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

class MainNavigationPage extends StatefulWidget {
  final AppSettingsController settingsController;

  const MainNavigationPage({
    super.key,
    required this.settingsController,
  });

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  // --- LÓGICA DE CIERRE DE SESIÓN (Cumple RNF03: Seguridad e Integridad) ---
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
        content: const Text('¿Estás seguro de que quieres salir?'),
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
              Navigator.pop(dialogContext); // Cerramos el pop-up

              // --- FIX: Navegación de seguridad definitiva ---
              // Borra toda la pila de navegación para que no puedan volver atrás
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

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomePage(),
      const ChatsPage(),
      ProfilePage(settingsController: widget.settingsController),
    ];

    return Scaffold(
      // --- HEADER GLOBAL (Cumple RF03) ---
      appBar: AppBar(
        title: const Text('UniLost & Found'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Evita la flecha automática del login
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.red),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),

      body: pages[_currentIndex],

      // --- BOTÓN CENTRAL HOME (Ajustado en altura y tamaño) ---
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 32), // Bajamos el botón para que pegue a la barra
        child: Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              if (_currentIndex == 0) // Solo brilla si estamos en Home
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () => setState(() => _currentIndex = 0),
            backgroundColor: Theme.of(context).colorScheme.primary,
            elevation: 0,
            shape: const CircleBorder(),
            child: const Icon(Icons.home, color: Colors.white, size: 35),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // --- BARRA INFERIOR CON EFECTO FOG/SOMBRA ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1), // Efecto "Fog"
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(-10, -10),
            ),
          ],
        ),
        child: BottomAppBar(
          padding: EdgeInsets.zero,
          height: 65,
          // --- FIX: Usamos 'color' en lugar de 'backgroundColor' ---
          color: Theme.of(context).scaffoldBackgroundColor,
          shape: const CircularNotchedRectangle(),
          notchMargin: 6.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(
                  _currentIndex == 1 ? Icons.chat_bubble : Icons.chat_bubble_outline,
                  color: _currentIndex == 1 ? Theme.of(context).colorScheme.primary : Colors.grey,
                ),
                onPressed: () => setState(() => _currentIndex = 1),
              ),
              const SizedBox(width: 48), // Espacio para el botón central
              IconButton(
                icon: Icon(
                  _currentIndex == 2 ? Icons.person : Icons.person_outline,
                  color: _currentIndex == 2 ? Theme.of(context).colorScheme.primary : Colors.grey,
                ),
                onPressed: () => setState(() => _currentIndex = 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}