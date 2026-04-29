import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:unilost_found/app.dart';
import 'package:unilost_found/core/settings/app_settings_controller.dart';
import 'firebase_options.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

 // (Sprint 5)
  // Conecta el frontend con la infraestructura de la UAB
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final settingsController = AppSettingsController();
  await settingsController.loadSettings();

  runApp(
    MyApp(settingsController: settingsController),
  );
}