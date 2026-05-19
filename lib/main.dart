import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:unilost_found/app.dart';
import 'package:unilost_found/core/settings/app_settings_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // 🚀 IMPORTADO PARA CONTROLAR LA WEB
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // (Sprint 5) Conecta el frontend con la infraestructura de la UAB
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🚀 SOLUCIÓN AL CRASHEO WEB: Inicialización condicional de App Check
  try {
    if (kIsWeb) {
      // En la Web usamos el proveedor por defecto (reCAPTCHA v3 o Enterprise según vuestra consola)
      await FirebaseAppCheck.instance.activate(
        webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
      );
    } else {
      // En dispositivos móviles (Android/iOS) se mantienen vuestros proveedores de depuración
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );
    }
  } catch (e) {
    debugPrint("Firebase AppCheck Ignored/Error: $e");
  }

  // (Sprint 5) Configuración de persistencia local para asegurar que el token se mantenga
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