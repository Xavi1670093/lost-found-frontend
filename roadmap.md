## Tareas Pendientes: Mejoras y Correcciones de UI/UX y Lógica de Ubicación

A continuación se detallan las tareas que el agente de IA debe implementar en el repositorio del Frontend. Cada tarea debe desarrollarse comprobando el correcto funcionamiento, la integridad del código y asegurando el soporte a los 3 idiomas (Español, Catalán, Inglés).

### 1. Añadir Títulos a los Campos del Formulario de Publicación
**Objetivo:** Mejorar la accesibilidad y claridad del formulario añadiendo títulos descriptivos encima o en el borde de cada campo de entrada.
* **Archivos implicados:** `lib/features/home/presentation/pages/found_form_screen.dart` (y cualquier otro formulario de publicación de objetos perdidos), `lib/shared/widgets/custom_text_field.dart`, `lib/core/localization/app_strings.dart`.
* **Instrucciones:**
  1. Modificar el componente `CustomTextField` (o los campos directos en el formulario) para aceptar una nueva propiedad `label` o `title` que renderice un widget `Text` antes del campo de entrada o use la propiedad `labelText` de `InputDecoration`.
  2. Aplicar el estilo tipográfico definido en `app_theme.dart` para que los títulos mantengan la coherencia visual.
  3. Añadir las claves de traducción necesarias en `app_strings.dart` para cada campo (ej. Título, Descripción, Categoría, Ubicación) en los 3 idiomas soportados.
  4. Verificar que no se produzcan desbordamientos visuales (overflows) en pantallas pequeñas tras añadir los textos.

### 2. Aumentar el Ancho de Exploración (Paneo) del Mapa
**Objetivo:** Permitir al usuario desplazar la cámara del mapa lateralmente para una mejor visualización, ya que el ancho actual está muy restringido.
* **Archivos implicados:** `lib/shared/widgets/map_picker_page.dart`.
* **Instrucciones:**
  1. Localizar la configuración de la cámara del mapa (`CameraTargetBounds` o los límites de paneo de la librería de mapas utilizada).
  2. Modificar las coordenadas `LatLngBounds` de restricción sumando un margen (offset) de longitud (este/oeste) al polígono del centro/universidad para permitir el desplazamiento horizontal.
  3. Ajustar el `minMaxZoomPreference` si es necesario, para que al hacer zoom out el usuario no vea un mapa vacío, pero tenga suficiente libertad de paneo.
  4. Probar en simuladores para asegurar que el área expandida permite una navegación cómoda sin salirse completamente del contexto de la universidad.

### 3. Validar Rango del GPS Actual en las Publicaciones
**Objetivo:** Evitar que los usuarios publiquen objetos utilizando su ubicación GPS si se encuentran físicamente fuera del recinto de la universidad/centro.
* **Archivos implicados:** `lib/features/home/presentation/pages/found_form_screen.dart`, un servicio de ubicación (ej. `lib/core/services/location_service.dart` o utilidades equivalentes), `lib/core/localization/app_strings.dart`, `lib/core/services/error_handler.dart`.
* **Instrucciones:**
  1. Al pulsar la opción "Usar ubicación actual", obtener las coordenadas GPS del dispositivo.
  2. Calcular la distancia (usando la fórmula de Haversine o utilidades integradas) entre las coordenadas obtenidas y el centroide (o polígono) de la universidad activa.
  3. Establecer un radio de tolerancia lógico (ej. 1km o los límites de la universidad).
  4. Si las coordenadas exceden el radio, cancelar el proceso y mostrar un Snackbar/Diálogo de error.
  5. Añadir el mensaje de error "Tu ubicación actual está fuera del recinto de la universidad" (o similar) en `app_strings.dart` para los 3 idiomas.

### 4. Corregir Selección Manual de Ubicación en el Mapa
**Objetivo:** Reparar el fallo que impide al usuario colocar un marcador seleccionando un punto manualmente en el mapa.
* **Archivos implicados:** `lib/shared/widgets/map_picker_page.dart`.
* **Instrucciones:**
  1. Inspeccionar el evento `onTap` o `onMapCreated` del widget del mapa.
  2. Asegurar que al dispararse el evento táctil en una coordenada válida (`LatLng`), el estado del widget (`setState` o controlador del estado actual) se actualice colocando un `Marker` visual en dicha posición.
  3. Sobrescribir la variable local de ubicación seleccionada con las nuevas coordenadas.
  4. Validar que el botón de confirmación/guardado envíe la coordenada correcta mediante `Navigator.pop(context, selectedLocation)`.