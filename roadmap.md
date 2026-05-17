# Roadmap de Implementación - Frontend (Flutter)

## 1. Sincronización Visual y Prevención de Pin Fuera de Rango
**Objetivo:** Trabajar en conjunto con la mejora del backend para que el usuario no pueda enviar un formulario fallido por ubicación.
* **Archivos objetivo:** `lib/shared/widgets/map_picker_page.dart` y controladores de creación de posts.
* **Tareas Atómicas:**
    1.  **Validación Client-Side:** Implementar una validación en tiempo real cuando el usuario mueve el pin en el mapa. Si el pin excede el polígono o radio del centro seleccionado, desactivar el botón de "Confirmar Ubicación".
    2.  **Feedback Visual:** Mostrar un sombreado o borde en el mapa que delimite claramente el área permitida.

## 2. Refactorización de la UI del Perfil (Texto Sobrepuesto y Botones)
**Objetivo:** Corregir la estructura del layout en el apartado del perfil para que la UI sea robusta y esté alineada.
* **Archivos objetivo:** `lib/features/profile/presentation/pages/profile_page.dart` y `edit_profile_page.dart` (o equivalentes).
* **Tareas Atómicas:**
    1.  **Eliminación de Overflows:** Envolver el formulario completo en un `SingleChildScrollView` con un `Padding` adecuado. Esto evitará que el texto se "sobreponga" o que la pantalla rompa cuando el teclado virtual aparezca.
    2.  **Centrado de Controles:** Localizar el `Row` o contenedor de los botones de acción (Guardar/Cancelar). Usar un `Column` o `Row` con `mainAxisAlignment: MainAxisAlignment.center` para garantizar el centrado.
    3.  **Contenedores Flexibles:** Si hay textos de usuario largos (nombres, descripciones), envolverlos en widgets `Expanded` o `Flexible` dentro de sus respectivas filas para forzar saltos de línea suaves (`TextOverflow.clip` o `visible`) en lugar de amontonamientos.

## 3. Implementación Integral de i18n (3 Idiomas) para Respuestas
**Objetivo:** Asegurar que cada acción tenga un feedback apropiado y perfectamente traducido.
* **Archivos objetivo:** `lib/core/localization/app_strings.dart` y servicios de manejo de errores (`error_handler.dart` / vistas).
* **Tareas Atómicas:**
    1.  **Mapeo de Claves:** Añadir nuevas claves en los 3 idiomas (CA, ES, EN) para acciones CRUD: `post_published_success`, `post_edited_success`, `post_deleted_success`.
    2.  **Traducción de Errores de Servidor:** Crear un mapeo en `error_handler.dart` que capture los códigos estandarizados enviados por Firebase (ej. `out-of-bounds-location`) y los convierta a sus respectivas traducciones locales (ej. "La ubicación marcada está fuera de la universidad").
    3.  **Integración en UI:** Reemplazar todos los strings literales en los `SnackBar`, `AlertDialog` y `FlutterToast` con sus correspondientes llamadas dinámicas de traducción (ej. `AppLocalizations.of(context).translate(...)`).

## 4. Diseño Responsivo (Adaptabilidad de Dispositivos Estrechos)
**Objetivo:** Garantizar que la aplicación no pierda formato ni legibilidad en pantallas de menor tamaño o configuraciones de accesibilidad.
* **Archivos objetivo:** Pantallas principales como `home_page.dart`, `post_detail_page.dart` y tarjetas `custom_card.dart`.
* **Tareas Atómicas:**
    1.  **Escalado Seguro de Textos:** Implementar un límite máximo al `textScaleFactor` global o utilizar `FittedBox` en títulos críticos para evitar que las fuentes del sistema del usuario rompan los contenedores de altura fija.
    2.  **Uso de LayoutBuilder:** Reemplazar anchos fijos (anchos `width: 300`, etc.) por anchos relativos usando `MediaQuery.of(context).size.width` o envolviendo en `LayoutBuilder`.
    3.  **Distribución de Cajas (Wrap):** En áreas donde haya elementos como "etiquetas" o "categorías", usar el widget `Wrap` en lugar de `Row` para que los elementos salten a la siguiente línea en dispositivos muy estrechos, evitando el desbordamiento de píxeles.