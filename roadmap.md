## Tareas Pendientes: Ubicación e Imágenes (Flutter)

Este bloque define las instrucciones para corregir y optimizar la selección de ubicación y la gestión de caché de imágenes. Ejecuta cada paso de forma atómica y verifica su funcionamiento antes de pasar al siguiente.

### 1. Validación de Coordenadas GPS (Ubicación Actual)
**Objetivo:** Validar que la ubicación actual del dispositivo se encuentre dentro de los límites (geocerca) del centro seleccionado (ej. UAB) y mostrar un error en 3 idiomas si no es válido.

* **Paso 1.1: Internacionalización (i18n):**
    * Abre el sistema de traducciones (ej. `lib/core/localization/app_strings.dart` o archivos `.arb`).
    * Añade la clave `error_location_outside_center` con sus traducciones en Español, Catalán e Inglés. (Ej. ES: "La ubicación debe estar dentro del recinto del centro.", CA: "La ubicació ha d'estar dins del recinte del centre.", EN: "Location must be within the center's premises.").
* **Paso 1.2: Lógica de Validación de Geocerca:**
    * Abre `lib/core/services/location_service.dart`.
    * Crea una función `bool isPointInPolygon(LatLng point, List<LatLng> polygon)` utilizando el algoritmo de Ray-Casting para determinar si las coordenadas actuales caen dentro de los límites del centro.
    * Asegúrate de obtener el polígono del centro actual desde el estado global o la base de datos de Firebase.
* **Paso 1.3: Integración en la Interfaz de Usuario:**
    * Abre `lib/features/home/presentation/pages/found_form_screen.dart`.
    * Modifica la función de "Obtener ubicación actual". Una vez obtenidas las coordenadas, llama a la función de validación.
    * Si el resultado es `false`, detén el flujo y muestra un `SnackBar` o diálogo de error consumiendo la clave `error_location_outside_center`.

### 2. Corrección del Selector de Mapa Manual
**Objetivo:** Solucionar el error que impide abrir el mapa para la selección manual y restringir la vista al centro.

* **Paso 2.1: Depuración y Corrección de `map_picker_page.dart`:**
    * Analiza `lib/shared/widgets/map_picker_page.dart` y los logs de error asociados al presionar el botón de selección manual.
    * Verifica que el `GoogleMapController` se esté inicializando correctamente y que los permisos de ubicación no estén bloqueando la renderización inicial si se denegaron previamente.
    * Asegúrate de que la API Key de Google Maps esté correctamente inyectada en los archivos de configuración nativos (`AndroidManifest.xml` y `AppDelegate.swift`).
* **Paso 2.2: Restricción de Cámara:**
    * En el widget de Google Maps dentro de `map_picker_page.dart`, configura la propiedad `cameraTargetBounds` utilizando el polígono/bounding box del centro actual (ej. UAB).
    * Añade validación visual al marcador para que no pueda ser soltado fuera del polígono del centro.

### 3. Sistema Integral de Caché de Imágenes
**Objetivo:** Garantizar que todas las imágenes (posts y chats) se guarden en caché y se revaliden automáticamente si hay modificaciones.

* **Paso 3.1: Configuración de `cached_network_image`:**
    * Verifica en `pubspec.yaml` que el paquete `cached_network_image` y `flutter_cache_manager` estén instalados y actualizados.
    * Crea una configuración personalizada en `flutter_cache_manager` (ej. `CustomCacheManager`) para manejar la expiración y revalidación basadas en las cabeceras `eTag` o `Last-Modified` proporcionadas por Firebase Storage.
* **Paso 3.2: Refactorización de Widgets de Imagen:**
    * Busca todas las instancias de `Image.network` a lo largo del proyecto (especialmente en `lib/features/chats/presentation/pages/chat_detail_page.dart` y `post_detail_page.dart`).
    * Reemplázalas por `CachedNetworkImage`.
    * Implementa los constructores `placeholder` (usando `lib/shared/widgets/skeleton_loader.dart` si es posible) y `errorWidget` para manejar estados de carga y fallo de forma limpia.