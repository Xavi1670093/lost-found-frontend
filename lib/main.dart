import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:unilost_found/app.dart';
import 'package:unilost_found/core/settings/app_settings_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'firebase_options.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

 // (Sprint 5)
  // Conecta el frontend con la infraestructura de la UAB
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicialización de App Check para seguridad de la infraestructura
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  // (Sprint 5) Configuración de persistencia local para asegurar que el token se mantenga
  // y se pueda gestionar manualmente el cierre de sesión por dispositivo.
  try {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  } catch (e) {
    debugPrint("Firebase Persistence Error: $e");
  }

  final settingsController = AppSettingsController();
  await settingsController.loadSettings();

  runApp(
    MyApp(settingsController: settingsController),
  );
}