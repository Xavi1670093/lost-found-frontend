# Roadmap Frontend - Uni Lost & Found

Este documento detalla las tareas atómicas que el agente de IA debe implementar en el frontend (Flutter) para resolver errores en la UI, optimizar la experiencia de usuario e implementar nuevas lógicas de ubicación y mapas.

## 1. Implementación Global de Botones de Retroceso (Back/Close)
**Objetivo:** Garantizar la navegación fluida y la posibilidad de retroceder o cerrar cualquier pantalla o popup.
* **Paso 1.1:** Inspeccionar `lib/features/home/presentation/pages/post_detail_page.dart` y asegurar que el `Scaffold` contenga un `AppBar` con `leading: BackButton()`. Si es un diseño sin AppBar, envolver el contenido principal en un `SafeArea` y posicionar un `IconButton(icon: Icon(Icons.arrow_back))` en la esquina superior izquierda.
* **Paso 1.2:** Revisar la creación de diálogos (`showDialog` / `showModalBottomSheet`) y asegurar que todos incluyen un botón visible de cerrar (cruz o cancelar) mediante `Navigator.pop(context)`.

## 2. Caché Eficiente de Imágenes de Perfil
**Objetivo:** Evitar renderizados repetitivos de la misma foto de perfil desde la red.
* **Paso 2.1:** Añadir/asegurar la dependencia `cached_network_image` en `pubspec.yaml`.
* **Paso 2.2:** Sustituir todos los `Image.network` o `NetworkImage` por `CachedNetworkImage` en los widgets de avatares (pantalla de chats, perfil, detalles de posts).
* **Paso 2.3:** Si el backend envía la URL con el token actualizado, usar esa URL. Asegurar la implementación de un `placeholder` (como `SkeletonLoader`) y un `errorWidget` por defecto.

## 3. Corrección de Refresco Excesivo en el Chat
**Objetivo:** Evitar que toda la página parpadee o se recargue al interactuar (escribir, enviar mensaje).
* **Paso 3.1:** Analizar `lib/features/chats/presentation/pages/chat_detail_page.dart`.
* **Paso 3.2:** Refactorizar el manejo de estado. Extraer el campo de texto y el botón de enviar a un widget `Stateful` independiente que maneje su propio estado sin reconstruir la lista de mensajes.
* **Paso 3.3:** Asegurar que la lista de mensajes use `StreamBuilder` devolviendo un `ListView.builder` que solo actualice las filas de los nuevos mensajes, evitando reconstruir el `Scaffold` completo.

## 4. UI: Etiqueta Opcional en Ubicación e i18n
**Objetivo:** Mostrar explícitamente que la ubicación no es obligatoria.
* **Paso 4.1:** En `lib/features/home/presentation/pages/found_form_screen.dart` (y `edit_post_page.dart`), localizar el campo o botón selector de ubicación.
* **Paso 4.2:** Modificar las cadenas en `lib/core/localization/app_strings.dart` para los 3 idiomas. Añadir una nueva key `location_optional`:
  * **ES:** "Ubicación (Opcional)"
  * **CA:** "Ubicació (Opcional)"
  * **EN:** "Location (Optional)"
* **Paso 4.3:** Asignar esta traducción al label del campo correspondiente.

## 5. Selección y Validación de Ubicación Bidireccional
**Objetivo:** Permitir GPS actual o mapa restringido, bloqueando ubicaciones fuera del centro.
* **Paso 5.1:** Crear un selector (Radio Buttons o Segmented Control) en el formulario de creación con dos opciones: "GPS Actual" y "Seleccionar en Mapa". Textos mapeados al sistema i18n.
* **Paso 5.2:** Lógica "GPS Actual": Obtener ubicación mediante `geolocator`. Comparar la latitud/longitud obtenida con las coordenadas `bounds` del centro (descargadas del backend).
* **Paso 5.3:** Si el GPS está fuera del `bounds`, mostrar un `SnackBar` o Dialogo de error traducido (ej. "Estás fuera del perímetro permitido para el centro UAB").
* **Paso 5.4:** Lógica "Mapa": Abrir el mapa centrado en la UAB, restringido por los mismos `bounds`, permitiendo soltar un pin.

## 6. Mejoras de Usabilidad del Mapa (Centrado, Rotación y Rendimiento)
**Objetivo:** Facilitar la orientación y minimizar espacio de caché limitando el área visual.
* **Paso 6.1:** En el mapa general (`home_page.dart`), establecer la propiedad de desactivación de rotación (por ejemplo, si es Google Maps: `rotateGesturesEnabled: false`).
* **Paso 6.2:** Añadir un `FloatingActionButton` superpuesto en el mapa con un icono de un edificio (`Icons.business` o `Icons.account_balance`). En el evento `onPressed`, utilizar el `MapController` para animar la cámara `animateCamera` a las coordenadas base del centro asociado al usuario (ej. UAB).
* **Paso 6.3:** Configurar los límites panorámicos de la cámara (`cameraTargetBounds`) utilizando el polígono/bounding box de la UAB más unos pocos kilómetros de margen. Esto bloquea que el usuario haga scroll hacia otra provincia/país, mejorando la caché del mapa y la usabilidad.