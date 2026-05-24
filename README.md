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

## Configuración e Instalación Local

### Prerrequisitos
- **Flutter SDK:** versión `^3.8.0` (Dart SDK compatible).
- **Herramientas de plataforma:** Android Studio / VS Code con plugins de Flutter y Dart instalados, y Xcode si se compila para iOS (en macOS).
- **Firebase CLI:** Instalado y autenticado si necesitas regenerar configuraciones.

### Pasos de Instalación

1.  **Clonar el repositorio:**
    ```bash
    git clone <url-del-repositorio>
    cd lost-found-frontend
    ```

2.  **Obtener dependencias de Flutter:**
    ```bash
    flutter pub get
    ```

3.  **Configurar Firebase (Opcional si se requiere cambiar de proyecto):**
    Asegúrate de estar autenticado en Firebase CLI y ejecuta:
    ```bash
    flutterfire configure
    ```
    Esto regenerará el archivo `lib/firebase_options.dart` con las credenciales de tu proyecto.

4.  **Generación de Iconos de la Aplicación:**
    Si modificas el icono de la aplicación en `assets/icon/app_icon.png`, regenera los iconos nativos con:
    ```bash
    dart run flutter_launcher_icons
    ```

5.  **Ejecutar la aplicación:**
    - Para desarrollo en emulador o dispositivo físico:
      ```bash
      flutter run
      ```
    - Para desarrollo en entorno web (Google Chrome):
      ```bash
      flutter run -d chrome
      ```

## Estructura de Carpetas de `lib/`

La estructura sigue un diseño modular por funcionalidades (`features`) junto con un núcleo (`core`) y componentes compartidos (`shared`):

*   `lib/app.dart`: Configuración de MaterialApp, pasarela de autenticación (auth gate), pasarela legal (legal gate) y verificación de sesión.
*   `lib/main.dart`: Punto de entrada de la aplicación, inicializa Firebase, App Check, notificaciones en segundo plano (FCM) y controladores de configuración.
*   `lib/firebase_options.dart`: Opciones de conexión automática generadas por la CLI de FlutterFire.
*   `lib/core/`: Carpeta del núcleo. Contiene localizaciones estáticas, servicios del sistema (ubicación, permisos, caché, errores), ajustes de la app y temas visuales.
*   `lib/features/`: Módulos principales organizados por dominio:
    *   `auth/`: Gestión de login, registro institucional y aceptación de términos legales.
    *   `chats/`: Listado de conversaciones activas e interfaz de chat en tiempo real.
    *   `home/`: Feed principal de publicaciones, formularios de reporte (`found`/`lost`), detalles de objetos y geolocalización.
    *   `notifications/`: Bandeja de entrada de notificaciones push y notificaciones in-app.
    *   `profile/`: Ajustes del perfil del usuario, publicaciones propias y opciones de configuración.
    *   `welcome/`: Vista de bienvenida para usuarios no autenticados.
*   `lib/shared/`: Utilidades y widgets reutilizables y sin estado específico de un solo módulo.

## Validación y Build

```bash
# Ejecutar análisis de código estático
flutter analyze

# Ejecutar las pruebas unitarias e instrumentales
flutter test

# Compilar versiones de producción
flutter build apk --release          # APK de Android
flutter build appbundle --release    # App Bundle para Google Play
flutter build web --release          # Versión Web estática
flutter build ipa --release          # IPA de iOS (requiere macOS y Xcode)
```

## Documentación relacionada

- [Arquitectura de la aplicación](docs/architecture.md)
- [UI Kit y Componentes Compartidos](docs/ui_kit.md)

## Licencia

Proyecto bajo licencia MIT. Consulta [LICENSE](LICENSE).
