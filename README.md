# UniLost & Found - UAB Campus

![App Header](https://img.shields.io/badge/Flutter-v3.22+-blue?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Backend-orange?logo=firebase)
![License](https://img.shields.io/badge/License-MIT-green)

**UniLost & Found (ULF)** es una aplicación móvil diseñada para la gestión de objetos perdidos y encontrados en el campus de la Universidad Autónoma de Barcelona (UAB).

## 🚀 Características Principales

- **Internacionalización**: Soporte completo para Español, Catalán e Inglés.
- **Autenticación Segura**: Acceso restringido a usuarios con correo institucional `@uab.cat`.
- **Feed en Tiempo Real**: Visualización instantánea de objetos mediante Firebase Realtime Database.
- **Geolocalización**: Mapa interactivo para ubicar hallazgos y pérdidas.
- **Chat Integrado**: Comunicación directa entre los usuarios involucrados.

## 🛠️ Requisitos e Instalación

### Prerrequisitos
- Flutter SDK (versión estable recomendada)
- Dart SDK
- Android Studio / VS Code con plugins de Flutter y Dart

### Configuración Inicial
1. Clona el repositorio:
   ```bash
   git clone https://github.com/Xavi1670093/lost-found-frontend.git
   ```
2. Instala las dependencias:
   ```bash
   flutter pub get
   ```
3. Configura Firebase:
   - Asegúrate de tener el archivo `lib/firebase_options.dart` generado mediante `flutterfire configure`.
   - Verifica los archivos `google-services.json` (Android) y `GoogleService-Info.plist` (iOS) si es necesario.

## 📱 Ejecución

Para ejecutar la aplicación en modo desarrollo:

```bash
# Ejecutar en el dispositivo conectado (Android/iOS)
flutter run

# Ejecutar en modo Web
flutter run -d chrome
```

## 🏗️ Arquitectura y Componentes

Para detalles técnicos sobre la estructura del proyecto, consulta nuestra [Guía de Arquitectura](docs/architecture.md).

### Componentes Core
- **Localization**: Sistema propio en `lib/core/localization/`.
- **Theme**: Estilo Material 3 centralizado en `lib/core/theme/`.
- **Services**: Gestión de permisos y errores en `lib/core/services/`.

---
© 2026 UniLost & Found Project - UAB
