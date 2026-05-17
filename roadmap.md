# Roadmap de Implementación y Corrección - Frontend (Flutter)

## 1. Ajuste del Payload de Edición de Publicaciones
**Objetivo:** Asegurar que los datos enviados al editar coincidan perfectamente con las reglas de Firebase, complementando la corrección del backend.
* **Archivos objetivo:** Controladores/Vistas de edición de posts (ej. `edit_post_page.dart` o repositorio correspondiente).
* **Tareas Atómicas:**
    1.  **Consistencia de Datos:** Al ejecutar el método `.update()` para guardar los cambios, asegurar que el `Map` enviado contenga exactamente los campos modificados (Título, Descripción, Categoría, Estado actual).
    2.  **Validación de Cadenas:** Garantizar que el valor enviado en la clave `status` o `category` coincida carácter por carácter con las opciones admitidas por la base de datos para evitar un rechazo silencioso en la UI.

## 2. Corrección del Solapamiento en Editar Perfil (UI)
**Objetivo:** Arreglar el error visual donde el label "Editar nom" se superpone con el texto de la caja.
* **Archivos objetivo:** `lib/features/profile/presentation/pages/edit_profile_page.dart`.
* **Tareas Atómicas:**
    1.  **Refactor del Input:** Cambiar la estructura de `Stack` o decoración defectuosa a una estructura limpia: Utilizar un widget `Column` con alineación `CrossAxisAlignment.start`. Dentro, colocar un widget `Text` para la etiqueta ("Editar nom"), un separador `SizedBox(height: 8)` y finalmente el `TextFormField` sin la propiedad interna `labelText`.

## 3. Asignación Correcta de Mensajes (i18n y Feedback Visual)
**Objetivo:** Mostrar los avisos precisos para cada acción individual (evitar que muestre "Publicación actualizada" al guardar el perfil) y visibilizar errores críticos.
* **Archivos objetivo:** Vistas de perfil, pantallas de edición de posts y manejador de errores.
* **Tareas Atómicas:**
    1.  **Corrección de Copy-Paste:** En las funciones `onSuccess` de la edición de perfil, cambiar la clave de traducción invocada de `post_updated_success` a la correspondiente, como `profile_updated_success`.
    2.  **Visibilización de Errores:** Envolver los métodos de guardado/edición en un bloque `try/catch (FirebaseException e)`. En caso de fallo (como un *Permission denied* persistente), renderizar un `SnackBar` rojo consumiendo el sistema de traducciones (`AppLocalizations`) para que el usuario sea consciente del fallo, en lugar de que el error solo exista en la terminal.