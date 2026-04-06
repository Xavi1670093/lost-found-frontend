import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:unilost_found/app.dart';
import 'package:unilost_found/core/settings/app_settings_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsController = AppSettingsController();
  await settingsController.loadSettings();

  runApp(
    MyApp(settingsController: settingsController),
  );
}