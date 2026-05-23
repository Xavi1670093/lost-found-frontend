import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:unilost_found/app.dart';
import 'package:unilost_found/core/settings/app_settings_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:unilost_found/shared/utils/app_notifications.dart';
import 'package:unilost_found/shared/utils/center_utils.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppInitializer());
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _initialized = false;
  String? _error;
  AppSettingsController? _settingsController;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // 1. Firebase initialization
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // 2. FCM background handler registration
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 3. App Check activation
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );

      // 4. Auth persistence
      try {
        await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
      } catch (e) {
        debugPrint("Firebase Persistence Error: $e");
      }

      // 5. Settings controller creation & load settings
      final controller = AppSettingsController();
      await controller.loadSettings();

      // 6. Preload centers static data in cache
      await CenterUtils.preloadCenters();

      if (mounted) {
        setState(() {
          _settingsController = controller;
          _initialized = true;
        });
      }
    } catch (e, stackTrace) {
      debugPrint("ULF_DEBUG: Initialization Error: $e\n$stackTrace");
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted) {
      return const SizedBox.shrink();
    }
    if (_initialized && _settingsController != null) {
      return MyApp(settingsController: _settingsController!);
    }

    // Capture system brightness to style splash/loading screen dynamically
    Brightness brightness = Brightness.light;
    try {
      brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    } catch (e) {
      debugPrint("ULF_DEBUG: Error reading platform brightness: $e");
    }
    final isDark = brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC);
    final primaryColor = const Color(0xFF0F766E); // Deep Teal
    final textColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: brightness,
        scaffoldBackgroundColor: scaffoldBg,
      ),
      home: Scaffold(
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
                        debugPrint("ULF_DEBUG: Error loading app icon during boot: $error");
                        return Icon(
                          Icons.inventory_2_outlined,
                          size: 120,
                          color: primaryColor,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_error != null) ...[
                    Text(
                      'Error de inicialización',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                  ] else ...[
                    CircularProgressIndicator(
                      color: primaryColor,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}