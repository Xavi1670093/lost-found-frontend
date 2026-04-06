import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:unilost_found/core/localization/app_strings.dart';
import 'package:unilost_found/core/settings/app_settings_controller.dart';
import 'package:unilost_found/core/theme/app_theme.dart';
import 'package:unilost_found/features/welcome/presentation/pages/welcome_page.dart';

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

class AppRoot extends StatelessWidget {
  final AppSettingsController settingsController;

  const AppRoot({
    super.key,
    required this.settingsController,
  });

  @override
  Widget build(BuildContext context) {
    return WelcomePage(settingsController: settingsController);
  }
}