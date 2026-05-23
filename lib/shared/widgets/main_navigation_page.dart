import 'package:flutter/material.dart';
import 'package:unilost_found/core/localization/app_strings.dart';
import 'package:unilost_found/core/settings/app_settings_controller.dart';
import 'package:unilost_found/features/chats/presentation/pages/chats_page.dart';
import 'package:unilost_found/features/home/presentation/pages/home_page.dart';
import 'package:unilost_found/features/profile/presentation/pages/profile_page.dart';
import 'package:unilost_found/features/home/presentation/pages/found_form_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unilost_found/features/welcome/presentation/pages/welcome_page.dart';
import 'package:unilost_found/shared/widgets/notification_bell.dart';
import 'package:unilost_found/shared/utils/app_notifications.dart';

/// [MainNavigationPage] es la vista contenedor principal que gestiona
/// la barra de navegación inferior de la aplicación móvil.
///
/// Permite alternar de forma fluida entre las pantallas principales de la aplicación:
/// * [ChatsPage] (índice 0): Panel de mensajería instantánea.
/// * [HomePage] (índice 1): Feed de objetos y previsualización de mapa.
/// * [ProfilePage] (índice 2): Gestión de perfil de usuario y publicaciones propias.
///
/// Incorpora un botón flotante central (FAB) que despliega opciones rápidas
/// para que los estudiantes reporten hallazgos o pérdidas de objetos.
class MainNavigationPage extends StatefulWidget {
  /// Controlador de configuración de la aplicación (idioma, modo oscuro).
  final AppSettingsController settingsController;

  const MainNavigationPage({super.key, required this.settingsController});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  /// Índice de la pestaña activa en la barra de navegación inferior.
  /// Por defecto inicia en la pestaña Inicio ([HomePage]). Es estático para persistir la sección seleccionada tras reconstrucciones.
  static int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    // Inicializar FCM y registrar token una vez cargada la navegación principal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AppNotifications.initFCM(context);
      }
    });
  }

  void _showLogoutDialog() {
    final t = AppStrings.of(context);
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.logout_rounded, color: theme.colorScheme.error),
            const SizedBox(width: 12),
            Text(t.logoutTitle),
          ],
        ),
        content: Text(t.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(t.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.errorContainer,
              foregroundColor: theme.colorScheme.error,
              elevation: 0,
              minimumSize: const Size(120, 44),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              
              // 1. Cierra la sesión en Firebase (elimina el token de acceso activo en el dispositivo actual).
              await FirebaseAuth.instance.signOut();
              
              // 2. Limpia los datos de almacenamiento local asociados a la sesión.
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('login_timestamp');

              // 3. Redirige obligatoriamente a la página de bienvenida eliminando el historial de navegación para evitar retornos inseguros.
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WelcomePage(settingsController: widget.settingsController),
                  ),
                  (route) => false,
                );
              }
            },
            child: Text(t.logout),
          ),
        ],
      ),
    );
  }

  void _openOptions() {
    final t = AppStrings.of(context);
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline_rounded, color: Colors.green),
              ),
              title: Text(t.reportFound, style: const TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FoundFormScreen(postType: 'found'))
                );
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.help_outline_rounded, color: Colors.orange),
              ),
              title: Text(t.reportLost, style: const TextStyle(fontWeight: FontWeight.w600)),
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
    final t = AppStrings.of(context);
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
      appBar: _currentIndex == 1
          ? null
          : AppBar(
              title: Text(
                _currentIndex == 0 ? t.messages : t.profile,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              actions: const [
                NotificationBell(),
                SizedBox(width: 8),
              ],
            ),
      extendBody: true,
      body: pages[_currentIndex],
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 65,
        color: theme.colorScheme.surface.withValues(alpha: 0.95),
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            // Pestaña de Mensajes/Chats
            Expanded(
              child: _NavigationTab(
                icon: _currentIndex == 0 ? Icons.chat_bubble_rounded : Icons.chat_bubble_outline_rounded,
                label: t.chats,
                isSelected: _currentIndex == 0,
                onTap: () => setState(() => _currentIndex = 0),
              ),
            ),
            
            // Espacio central reservado físicamente para el botón flotante (FAB)
            const Expanded(child: SizedBox()),
            
            // Pestaña del Perfil de usuario
            Expanded(
              child: _NavigationTab(
                icon: _currentIndex == 2 ? Icons.person_rounded : Icons.person_outline_rounded,
                label: t.profile,
                isSelected: _currentIndex == 2,
                onTap: () => setState(() => _currentIndex = 2),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _currentIndex == 1 ? _openOptions : () => setState(() => _currentIndex = 1),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          highlightElevation: 0,
          shape: const CircleBorder(),
          child: AnimatedSwitcher(
            key: const ValueKey('main_navigation_fab_switcher'),
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => RotationTransition(
              turns: anim,
              child: ScaleTransition(scale: anim, child: child),
            ),
            child: Icon(
              _currentIndex == 1 ? Icons.add_rounded : Icons.home_rounded,
              key: ValueKey(_currentIndex == 1 ? 'add' : 'home'),
              size: 36,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _NavigationTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavigationTab({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}