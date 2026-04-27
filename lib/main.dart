import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:unilost_found/app.dart';
import 'package:unilost_found/core/settings/app_settings_controller.dart';
import 'firebase_options.dart';

void main() async {
  // 1. Aseguramos que Flutter esté listo
  WidgetsFlutterBinding.ensureInitialized();

  // 2. INICIALIZAMOS LA NUBE (Sprint 5)
  // Conecta el frontend con la infraestructura de la UAB
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. CARGAMOS LOS AJUSTES DE XAVI
  // Quitamos 'prefs' del constructor porque no lo acepta
  final settingsController = AppSettingsController();

  // loadSettings() ya busca internamente SharedPreferences
  await settingsController.loadSettings();

  // 4. LANZAMOS LA APP
  runApp(
    MyApp(settingsController: settingsController),
  );
}