import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:unilost_found/core/localization/app_strings.dart';
import 'package:unilost_found/core/settings/app_settings_controller.dart';
import 'package:unilost_found/core/theme/app_theme.dart';
import 'package:unilost_found/features/welcome/presentation/pages/welcome_page.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unilost_found/shared/utils/app_notifications.dart';
import 'package:unilost_found/shared/widgets/main_navigation_page.dart';
import 'package:unilost_found/shared/widgets/skeleton_loader.dart';
import 'package:unilost_found/features/auth/presentation/pages/terms_acceptance_screen.dart';

/// Clase principal de la aplicación que inicializa MaterialApp.
///
/// Define el tema claro/oscuro global, el idioma de inicio obtenido del
/// [settingsController], los delegados de traducción y un limitador de tamaño
/// de fuentes del sistema (`textScaler`) para garantizar consistencia visual.
class MyApp extends StatelessWidget {
  /// Controlador de configuración que provee el tema y el locale.
  final AppSettingsController settingsController;

  const MyApp({
    super.key,
    required this.settingsController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'UniLost & Found',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settingsController.themeMode,
          locale: settingsController.locale,
          supportedLocales: AppStrings.supportedLocales,
          localizationsDelegates: const [
            AppStrings.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            final mediaQueryData = MediaQuery.of(context);
            final clampedScaler = mediaQueryData.textScaler.clamp(
              minScaleFactor: 0.8,
              maxScaleFactor: 1.25,
            );
            return MediaQuery(
              data: mediaQueryData.copyWith(
                textScaler: clampedScaler,
              ),
              child: child!,
            );
          },
          home: AppRoot(settingsController: settingsController),
        );
      },
    );
  }
}

/// Raíz lógica de navegación de la aplicación.
///
/// Evalúa reactivamente el estado de autenticación de Firebase (`authStateChanges`):
/// - Si no hay usuario autenticado o su correo no está verificado, redirige a [WelcomePage].
/// - Si el usuario está autenticado y verificado, evalúa la validez temporal de su sesión
///   (máximo 14 días mediante `login_timestamp` en SharedPreferences) y redirige a [LegalGuardGate]
///   o fuerza el logout según corresponda.
class AppRoot extends StatefulWidget {
  final AppSettingsController settingsController;

  const AppRoot({
    super.key,
    required this.settingsController,
  });

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/icon/app_icon.png'), context);
  }

  Widget _buildLoadingScreen(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen(context);
        }

        final user = snapshot.data;

        if (user != null && user.emailVerified) {
          return FutureBuilder<bool>(
            future: _checkSessionValidity(),
            builder: (context, sessionSnapshot) {
              if (sessionSnapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingScreen(context);
              }

              if (sessionSnapshot.data == true) {
                return LegalGuardGate(
                  settingsController: widget.settingsController,
                  child: MainNavigationPage(settingsController: widget.settingsController),
                );
              } else {
                return WelcomePage(settingsController: widget.settingsController);
              }
            },
          );
        }

        return WelcomePage(settingsController: widget.settingsController);
      },
    );
  }

  Future<bool> _checkSessionValidity() async {
    final prefs = await SharedPreferences.getInstance();
    final loginTimestamp = prefs.getInt('login_timestamp');

    if (loginTimestamp == null) {
      // Si no hay marca, la creamos ahora para iniciar el contador
      await prefs.setInt('login_timestamp', DateTime.now().millisecondsSinceEpoch);
      return true;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = now - loginTimestamp;
    const twoWeeks = 14 * 24 * 60 * 60 * 1000;

    if (diff > twoWeeks) {
      await FirebaseAuth.instance.signOut();
      await prefs.remove('login_timestamp');

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final t = AppStrings.of(context);
          AppNotifications.showError(context, t.sessionExpired);
        });
      }
      return false;
    }

    return true;
  }
}

/// Pasarela protectora de aceptación legal obligatoria.
///
/// Escucha en tiempo real los datos del usuario en Firebase Realtime Database para comparar
/// la versión de términos y condiciones aceptada (`acceptedTermsVersion`) contra la versión
/// requerida por la aplicación (`requiredLegalVersion`). Si el usuario no ha aceptado
/// las políticas actualizadas, bloquea el paso y muestra la pantalla [TermsAcceptanceScreen].
class LegalGuardGate extends StatelessWidget {
  final AppSettingsController settingsController;
  final Widget child;

  const LegalGuardGate({
    super.key,
    required this.settingsController,
    required this.child,
  });

  bool _isVersionAccepted(String? acceptedVersion, String requiredVersion) {
    if (acceptedVersion == null) return false;
    if (acceptedVersion == requiredVersion) return true;
    try {
      final acceptedParts = acceptedVersion.split('.').map(int.parse).toList();
      final requiredParts = requiredVersion.split('.').map(int.parse).toList();
      for (int i = 0; i < requiredParts.length; i++) {
        final acceptedPart = i < acceptedParts.length ? acceptedParts[i] : 0;
        final requiredPart = requiredParts[i];
        if (acceptedPart > requiredPart) return true;
        if (acceptedPart < requiredPart) return false;
      }
      return true;
    } catch (_) {
      return acceptedVersion.compareTo(requiredVersion) >= 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return WelcomePage(settingsController: settingsController);
    }

    return StreamBuilder<DatabaseEvent>(
      stream: FirebaseDatabase.instance.ref('users/${user.uid}').onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoader(height: 40, width: 200),
                      SizedBox(height: 24),
                      SkeletonLoader(height: 150),
                      SizedBox(height: 24),
                      SkeletonLoader(height: 150),
                      SizedBox(height: 40),
                      SkeletonLoader(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        final data = snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;
        final String? acceptedVersion = data?['acceptedTermsVersion'] as String?;
        final accepted = _isVersionAccepted(acceptedVersion, requiredLegalVersion);

        if (accepted) {
          return child;
        }

        return TermsAcceptanceScreen(
          settingsController: settingsController,
        );
      },
    );
  }
}