# Roadmap de Desarrollo - Frontend (Flutter)

Este documento contiene las instrucciones atómicas para implementar las nuevas funcionalidades y correcciones visuales y de interacción en la aplicación Flutter.

## 1. Corrección de navegación al editar perfil
**Objetivo:** Evitar que la app regrese a la pantalla inicial tras guardar la configuración.
* **Paso 1:** Localizar el archivo de la vista de edición de perfil (ej. `lib/features/profile/presentation/pages/profile_page.dart` o `edit_profile_page.dart`).
* **Paso 2:** Buscar el manejador del botón de "Guardar".
* **Paso 3:** Reemplazar cualquier uso de `Navigator.pushAndRemoveUntil`, `pushReplacement` o enrutamientos que limpien la pila de navegación. Utilizar `Navigator.pop(context)` una vez que la llamada al backend responda con éxito, para volver limpiamente a la pantalla anterior.
* **Paso 4:** Manejar correctamente el estado de carga (mostrar un `CircularProgressIndicator` o similar) para evitar que el usuario pulse múltiples veces mientras se guarda.

## 2. Visualización global de fotos
**Objetivo:** Cargar y mostrar imágenes en vistas de detalle y perfil, no solo en el feed.
* **Paso 1:** Revisar los archivos `post_detail_page.dart` y `user_posts_page.dart`.
* **Paso 2:** Implementar el mismo widget de renderizado de imágenes usado en el feed (preferiblemente usando `CachedNetworkImage` para aprovechar el almacenamiento en caché de los archivos `.webp`).
* **Paso 3:** Manejar los estados de error (imagen no disponible) y carga para una UI fluida.

## 3. Botón de centrado de ubicación en el mapa
**Objetivo:** Añadir un control para que el usuario pueda centrar el mapa en su ubicación actual.
* **Paso 1:** Localizar el archivo que contiene la vista del mapa (integración con Google Maps o Mapbox).
* **Paso 2:** Añadir un `FloatingActionButton` posicionado sobre el mapa de forma que no colisione con otros elementos.
* **Paso 3:** En el evento `onPressed`, utilizar el servicio de ubicación (`lib/core/services/permission_service.dart`) para obtener las coordenadas actuales del dispositivo, solicitando permisos si es necesario.
* **Paso 4:** Invocar al controlador del mapa para animar la cámara hacia las coordenadas obtenidas con un nivel de zoom adecuado.

## 4. Edición de foto de perfil y sincronización con el Backend
**Objetivo:** Permitir cambiar la foto de perfil, enviando la imagen en el formato correcto y reaccionando a la compresión del backend.
* **Paso 1:** En la interfaz de edición de perfil, añadir un widget interactivo para abrir el `ImagePicker` asegurando que los archivos seleccionables sean compatibles (`jpg/jpeg` o `png`), para cumplir con las nuevas reglas de Storage.
* **Paso 2:** Subir el archivo original a Firebase Storage en la ruta designada (`users/{userId}/profile_image`), indicando correctamente su `contentType`.
* **Paso 3:** Puesto que el backend ahora se encarga de reescalar y convertir a `.webp` de forma asíncrona mediante una Cloud Function, mostrar un indicador de carga permanente en la foto de perfil mientras ocurre el proceso en la nube.
* **Paso 4:** Implementar un `StreamBuilder` (o actualizar el estado del Provider/Bloc escuchando cambios en tiempo real) sobre el documento del usuario en Firestore (`users/{userId}`). Cuando el campo `photoUrl` cambie a la nueva URL `.webp`, ocultar el estado de carga y renderizar la nueva imagen optimizada.

## 5. Búsqueda extendida en descripciones
**Objetivo:** Conectar el frontend con la nueva funcionalidad de backend para búsquedas.
* **Paso 1:** Comprobar el widget del buscador (`custom_text_field.dart` o vista de feed).
* **Paso 2:** Asegurar que el término de búsqueda se envía correctamente como parámetro en la llamada a Firebase.
* **Paso 3:** Verificar que los resultados mostrados en la lista pinten correctamente los elementos independientemente de si la coincidencia fue en el título o la descripción.

## 6. Corrección de solapamiento de pop-ups y botones (UI)
**Objetivo:** Solucionar los problemas visuales donde la barra de búsqueda y editar perfil se solapan o desbordan.
* **Paso 1:** Analizar el árbol de widgets donde ocurre el solapamiento. Comprobar la implementación correcta de `SafeArea`.
* **Paso 2:** Reemplazar posicionamientos absolutos que generen conflictos. Utilizar `Column`, `Expanded` o envolver elementos en `Flexible` para evitar errores de Overflow.
* **Paso 3:** Asegurar que los modales y barras de búsqueda respeten el teclado virtual (usando `resizeToAvoidBottomInset: true` en el `Scaffold` o ajustando márgenes dinámicamente con `MediaQuery`).

## 7. Soporte Multi-idioma (Internacionalización)
**Objetivo:** Garantizar que los nuevos textos de UI estén disponibles en todos los idiomas soportados.
* **Paso 1:** Identificar todas las cadenas de texto nuevas (ej. errores de formato de imagen, centrado de mapa).
* **Paso 2:** Añadir las traducciones correspondientes en el archivo `lib/core/localization/app_strings.dart` o equivalentes, abarcando el español, inglés y el tercer idioma de la app.