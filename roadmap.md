## Tareas de Optimización, Ubicación y Caché (Frontend)

Este bloque define las instrucciones para asegurar el sistema de ubicación, resolver errores de renderizado de mapas, inicializar la seguridad y optimizar la caché de imágenes. Ejecuta cada paso de forma atómica y verifica antes de avanzar.

### 1. Inicialización de Seguridad (App Check)
**Objetivo:** Eliminar errores de token en consola y asegurar las peticiones a Firebase.
* **Paso 1.1:** Abre `lib/main.dart`. Importa `package:firebase_app_check/firebase_app_check.dart`.
* **Paso 1.2:** Inmediatamente después de `Firebase.initializeApp()`, añade la inicialización de App Check usando `AndroidProvider.debug` y `AppleProvider.debug` (para entorno de desarrollo).

### 2. Validación Preventiva de Coordenadas GPS
**Objetivo:** Validar que la ubicación del dispositivo esté dentro de la geocerca del centro antes de permitir la publicación, evitando peticiones inválidas al backend.
* **Paso 2.1:** Abre `lib/core/services/location_service.dart`. Asegúrate de que `isPointInPolygon` retorne `false` inmediatamente si el array del polígono está vacío o tiene menos de 3 puntos.
* **Paso 2.2:** Abre el gestor de traducciones (`lib/core/localization/app_strings.dart`) y añade la clave `error_location_outside_center` con sus traducciones (ES, CA, EN) indicando que la ubicación debe estar dentro del recinto.
* **Paso 2.3:** Abre `lib/features/home/presentation/pages/found_form_screen.dart`. En la función de "Obtener ubicación actual" (GPS), justo después de obtener el `Position`, conviértelo a `LatLng` y pásalo por `LocationService.isPointInPolygon`.
* **Paso 2.4:** Si retorna `false`, aborta el proceso, oculta cualquier *loader* y muestra un `SnackBar` de error consumiendo la clave traducida. No guardes la ubicación en el estado.

### 3. Reparación del Selector de Mapa Manual (`flutter_map`)
**Objetivo:** Solucionar el pantallazo en blanco al abrir el mapa manual, causado por cálculos de límites inválidos.
* **Paso 3.1:** Abre `lib/shared/widgets/map_picker_page.dart`.
* **Paso 3.2:** Elimina la lógica de `_expandBounds`, ya que invertir los ejes causa crashes si el polígono es pequeño.
* **Paso 3.3:** En `MapOptions`, establece `cameraConstraint: CameraConstraint.unconstrained()`.
* **Paso 3.4:** Asegúrate de que `widget.initialCenter` tiene unas coordenadas válidas antes de inicializar el mapa.

### 4. Sistema Integral de Caché de Imágenes
**Objetivo:** Garantizar que todas las imágenes se guarden en caché para ahorrar ancho de banda.
* **Paso 4.1:** Verifica en `pubspec.yaml` que `cached_network_image` y `flutter_cache_manager` estén instalados.
* **Paso 4.2:** Reemplaza todas las instancias de `Image.network` en `chat_detail_page.dart` y `post_detail_page.dart` por `CachedNetworkImage`, utilizando el `CustomCacheManager` existente y manejando estados de carga con `skeleton_loader.dart`.