import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../core/settings/app_settings_controller.dart';
import '../../features/chats/presentation/pages/chats_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/home/presentation/pages/found_form_screen.dart';

class MainNavigationPage extends StatefulWidget {
  final AppSettingsController settingsController;
  const MainNavigationPage({super.key, required this.settingsController});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  // --- FUNCIÓN DE LOGOUT (RNF03: Seguridad) ---
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
              // RNF03: Seguridad - Limpiamos el historial de navegación [cite: 215]
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
              leading: const Icon(Icons.search),
              title: const Text("He encontrado"),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FoundFormScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning),
              title: const Text("He perdido"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Definimos las páginas inyectando las dependencias necesarias [cite: 145]
    final pages = [
      const HomePage(),
      const ChatsPage(),
      ProfilePage(
        settingsController: widget.settingsController,
        onLogout: _showLogoutDialog, // Pasamos la función al perfil
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('UniLost & Found'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          // Icono de Notificaciones según Sketch (RF14) [cite: 30]
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          pages[_currentIndex],

          // ➕ BOTÓN NUEVO (BIEN POSICIONADO)
          Positioned(
            right: 16,
            bottom: 120, // 👈 MÁS ARRIBA (NO CHOCA CON HOME)
            child: FloatingActionButton(
              heroTag: "addButton",
              mini: true,
              onPressed: _openOptions,
              backgroundColor: Colors.green,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),

      // BOTÓN HOME CON EFECTO GLOW (RF03) [cite: 27]
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 32),
        child: Container(
          height: 70, width: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              if (_currentIndex == 0)
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                  blurRadius: 20, spreadRadius: 5,
                ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () => setState(() => _currentIndex = 0),
            backgroundColor: Theme.of(context).colorScheme.primary,
            elevation: _currentIndex == 0 ? 8 : 0,
            shape: const CircleBorder(),
            child: Icon(
                _currentIndex == 0 ? Icons.home : Icons.home_outlined,
                color: Colors.white, size: 35
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // BARRA INFERIOR CON SOMBRA (FOG) [cite: 34]
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15, spreadRadius: 2, offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomAppBar(
          padding: EdgeInsets.zero,
          height: 65,
          color: Theme.of(context).scaffoldBackgroundColor,
          shape: const CircularNotchedRectangle(),
          notchMargin: 6.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(_currentIndex == 1 ? Icons.chat_bubble : Icons.chat_bubble_outline),
                color: _currentIndex == 1 ? Theme.of(context).colorScheme.primary : Colors.grey,
                onPressed: () => setState(() => _currentIndex = 1),
              ),
              const SizedBox(width: 48),
              IconButton(
                icon: Icon(_currentIndex == 2 ? Icons.person : Icons.person_outline),
                color: _currentIndex == 2 ? Theme.of(context).colorScheme.primary : Colors.grey,
                onPressed: () => setState(() => _currentIndex = 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}