import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:unilost_found/core/localization/app_strings.dart';
import 'package:unilost_found/core/settings/app_settings_controller.dart';
import 'package:unilost_found/core/theme/app_theme.dart';
import 'package:unilost_found/features/welcome/presentation/pages/welcome_page.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unilost_found/shared/utils/app_notifications.dart';
import 'package:unilost_found/shared/widgets/main_navigation_page.dart';

class MyApp extends StatelessWidget {
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint("ULF_DEBUG: Error loading app icon: $error");
                      return Icon(
                        Icons.inventory_2_outlined,
                        size: 120,
                        color: theme.colorScheme.primary,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
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
                return MainNavigationPage(settingsController: widget.settingsController);
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