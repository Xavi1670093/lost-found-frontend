# 📱 UniLost & Found (ULF) - Frontend Mobile App

![Flutter SDK](https://img.shields.io/badge/Flutter-v3.8.0+-02569B?logo=flutter&logoColor=white)
![Firebase Core](https://img.shields.io/badge/Firebase-v3.6.0+-FFCA28?logo=firebase&logoColor=black)
![License](https://img.shields.io/badge/License-MIT-4CAF50?logo=open-source-initiative&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-E0E0E0)

**UniLost & Found (ULF)** es la aplicación móvil oficial de la comunidad del campus de la **Universidad Autónoma de Barcelona (UAB)** destinada a la publicación y recuperación ágil de objetos perdidos y encontrados dentro del recinto universitario.

El proyecto está construido sobre **Flutter** y consume los servicios en la nube de **Firebase** mediante un enfoque arquitectónico modular, responsivo y seguro de *Confianza Cero* (Zero-Trust).

---

## 🚀 Funcionalidades Principales

* **Traducción y Localización Completa**: Soporte nativo para tres idiomas: **Castellano (Español)**, **Catalán** e **Inglés**, gestionado estáticamente sin sobrecargas de rendimiento.
* **Seguridad y Acceso Restringido**: Registro restringido exclusivamente a estudiantes y personal con correo institucional de la UAB (`@uab.cat`) con validación regex robusta.
* **Feed Reactivo en Tiempo Real**: Los reportes y objetos perdidos se ordenan cronológicamente y se actualizan al instante en el feed general mediante suscripciones a Firebase Realtime Database.
* **Geolocalización y Geovallado (Geofencing)**: Validación geográfica doble en el cliente (fórmula esférica de Haversine y cálculo elipsoidal WGS84 con Geolocator) y por polígonos UAB (algoritmo de Ray-Casting) para evitar publicaciones fuera de los campus universitarios.
* **Chat Integrado Directo**: Conexión de chat instantánea bidireccional entre el estudiante que reportó el hallazgo y el propietario del objeto.
* **Sesiones Seguras**: Control defensivo del token local guardando marcas de tiempo. La sesión expira de forma obligatoria transcurridos **14 días** de inactividad por motivos de seguridad.

---

## 🛠️ Requisitos Técnicos y Entorno

### Prerrequisitos de Desarrollo
* **Flutter SDK**: `^3.8.0` o superior.
* **Dart SDK**: `^3.0.0` o superior.
* **Sistemas de Destino**: Android 6.0 (API 23)+, iOS 13+ o navegadores Web modernos con soporte WebGL.

### 📦 Dependencias Clave (pubspec.yaml)
* `firebase_core`: `^3.6.0` (Enlace de servicios en la nube)
* `firebase_auth`: `^5.3.0` (Gestión de usuarios y tokens institucionales)
* `firebase_database`: `^11.1.0` (Sincronización en tiempo real de chats y feed)
* `firebase_storage`: `^12.1.0` (Almacenamiento de imágenes comprimidas)
* `firebase_app_check`: `^0.3.2+10` (Seguridad anti-bots a nivel de API)
* `flutter_map` & `latlong2`: `^7.0.2` (Renderizado interactivo de mapas cartográficos)
* `geolocator` & `permission_handler`: (Acceso nativo a coordenadas y sensores del GPS)
* `cached_network_image` & `flutter_cache_manager`: (Caché local ultrarrápida de fotos de objetos)

---

## 🚀 Configuración e Instalación

1. **Clonar el repositorio localmente**:
   ```bash
   git clone https://github.com/Xavi1670093/lost-found-frontend.git
   ```

2. **Acceder al directorio del proyecto**:
   ```bash
   cd lost-found-frontend
   ```

3. **Descargar e instalar dependencias de Dart**:
   ```bash
   flutter pub get
   ```

4. **Inicializar y Configurar la infraestructura de Firebase**:
   * Asegúrese de tener instalado el [Firebase CLI](https://firebase.google.com/docs/cli).
   * Inicie sesión y autogenere el archivo de configuración ejecutando:
     ```bash
     flutterfire configure
     ```
   * Esto creará automáticamente [lib/firebase_options.dart](file:///home/carlesp/Documentos/UAB/Github/lost-found-frontend/lib/firebase_options.dart) y enlazará las credenciales seguras de Android, iOS y Web.

---

## 💻 Comandos de Ejecución y Pruebas

### Modo Desarrollo (Debugging)
```bash
# Ejecutar en el emulador o dispositivo físico conectado por defecto
flutter run

# Ejecutar específicamente en el navegador Web (Chrome)
flutter run -d chrome

# Iniciar en modo de observación y depuración detallada (verbose)
flutter run -v
```

### Análisis Estático de Código
Antes de realizar cualquier aporte o confirmación de cambios, ejecute el linter oficial para asegurar la ausencia de advertencias sintácticas:
```bash
flutter analyze
```

---

## 📦 Compilación y Despliegue de Producción (Release)

### 🤖 Android (Generación de Binarios)
```bash
# Compilar un Android App Bundle (.aab) para publicar en Google Play Store
flutter build appbundle --release

# Compilar un archivo instalador tradicional (.apk) de producción
flutter build apk --release
```

### 🍎 iOS (Generación de Archivo IPA)
*Requiere un equipo macOS configurado con Xcode.*
```bash
# Compilar archivo IPA optimizado para la App Store o distribución Ad-Hoc
flutter build ipa --release
```

### 🌐 Web (Generación de Estáticos HTML/JS)
```bash
# Compilar archivos web estáticos optimizados con renderizado HTML (CanvasKit/Skia)
flutter build web --release
```

---

## 🏗️ Guías de Arquitectura e Interfaces

Para profundizar en los detalles arquitectónicos y el sistema visual de la aplicación, consulte la documentación oficial localizada bajo el directorio `/docs`:

* **[Especificación de la Arquitectura de Software](docs/architecture.md)**: Estructura de capas modulares, DI, gestión del estado e integración defensiva con Firebase.
* **[Catálogo del UI Kit de Widgets Compartidos](docs/ui_kit.md)**: Parámetros, responsividad y adaptaciones visuales de los componentes reutilizables en `lib/shared/widgets/`.

---
© 2026 UniLost & Found Project - UAB Campus Community
