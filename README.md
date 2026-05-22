# UniLost & Found (ULF) - Frontend

Aplicacion Flutter de UniLost & Found para publicar, buscar y recuperar objetos perdidos o encontrados dentro del campus de la Universitat Autonoma de Barcelona.

Revision de documentacion: 22 de mayo de 2026.

## Funcionalidades actuales

- Autenticacion con Firebase Auth y registro seguro mediante la callable `secureUniversityRegistration`.
- Registro restringido a cuentas UAB con formato de NIU de 7 digitos y dominio `@uab.cat`.
- Verificacion obligatoria de email antes de entrar en la app.
- Aceptacion de terminos y privacidad en registro, y guard de version legal con `requiredLegalVersion`.
- Feed reactivo desde Firebase Realtime Database sobre `/posts`, filtrado en cliente por centro, estado activo, categoria y texto.
- Publicacion de objetos `lost` y `found` con captura de foto, compresion WebP local, subida a Firebase Storage y geohash.
- Comprobacion previa de coincidencias con `checkPotentialMatches` antes de publicar.
- Geolocalizacion por GPS o selector de mapa con validacion local por poligono del centro y fallback por radio.
- Chats privados en tiempo real sobre `/chats`, `/messages` y `/user_chats`.
- Notificaciones push FCM e in-app para mensajes y matches, con bandeja de notificaciones y marcado como leido.
- Preferencias sincronizadas entre dispositivo y RTDB: tema, idioma y `pushNotificationsEnabled`.
- Internacionalizacion estatica en castellano, catalan e ingles mediante `AppStrings`.

## Stack tecnico

- Flutter SDK / Dart SDK: `sdk: ^3.8.0`
- Firebase: `firebase_core`, `firebase_auth`, `firebase_database`, `firebase_storage`, `firebase_app_check`, `firebase_messaging`
- Cloud Functions callable: `cloud_functions`
- Mapas y ubicacion: `flutter_map`, `latlong2`, `geolocator`, `permission_handler`, `dart_geohash`
- Imagenes: `image_picker`, `flutter_image_compress`, `cached_network_image`, `flutter_cache_manager`
- UI: Material 3, `google_fonts`, `shimmer`

## Estructura principal

```text
lib/
├── app.dart                         # MyApp, AppRoot y LegalGuardGate
├── main.dart                        # Inicializacion Firebase, App Check, FCM y settings
├── firebase_options.dart            # Configuracion generada por FlutterFire
├── core/
│   ├── localization/app_strings.dart
│   ├── services/
│   ├── settings/app_settings_controller.dart
│   └── theme/app_theme.dart
├── features/
│   ├── auth/
│   ├── chats/
│   ├── home/
│   ├── notifications/
│   ├── profile/
│   └── welcome/
└── shared/
    ├── utils/
    └── widgets/
```

## Configuracion local

```bash
flutter pub get
flutter run
```

Para web:

```bash
flutter run -d chrome
```

Si se cambia el proyecto Firebase o las apps registradas, regenerar la configuracion:

```bash
flutterfire configure
```

## Validacion y build

```bash
flutter analyze
flutter test
flutter build apk --release
flutter build appbundle --release
flutter build web --release
```

El build iOS requiere macOS y Xcode:

```bash
flutter build ipa --release
```

## Documentacion relacionada

- [Arquitectura](docs/architecture.md)
- [UI kit compartido](docs/ui_kit.md)

## Licencia

Proyecto bajo licencia MIT. Consulta [LICENSE](LICENSE).
