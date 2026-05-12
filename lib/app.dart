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
          themeMode:
          settingsController.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          locale: settingsController.locale,
          supportedLocales: AppStrings.supportedLocales,
          localizationsDelegates: const [
            AppStrings.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
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
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        if (user != null && user.emailVerified) {
          return FutureBuilder<bool>(
            future: _checkSessionValidity(),
            builder: (context, sessionSnapshot) {
              if (sessionSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
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