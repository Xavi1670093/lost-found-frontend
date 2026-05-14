## Corrección de Errores: UI de Chats y Traducciones

### 1. Mapeo Correcto de Nombres e Imágenes en Chats
**Objetivo:** Mostrar correctamente el contexto visual del chat usando los metadatos inyectados por el Backend.
* **Archivos principales:** `lib/features/chats/presentation/pages/chats_page.dart` y `chat_detail_page.dart`.
* **Instrucciones:**
  1. Revisar el modelo de datos `Chat` (ej. `chat_model.dart`). Asegurarse de que mapea correctamente los campos `postImageUrl` y la información del otro usuario (`otherUserName`, `otherUserAvatar` o extraídos de `usersInfo[otherUid]`).
  2. En la UI, si `postImageUrl` no es nulo y no está vacío, renderizar la imagen con un `CachedNetworkImage` o el componente por defecto de la app. Si falla la carga de la URL, mostrar un icono por defecto (`Icons.image_not_supported`).
  3. Renderizar el nombre y foto de perfil del usuario destinatario extrayendo su información del mapa de participantes del documento del chat.

### 2. Interceptación y Traducción del Mensaje del Sistema
**Objetivo:** Capturar la constante enviada por el backend y traducirla al idioma actual de la app.
* **Archivos principales:** `lib/features/chats/presentation/pages/chats_page.dart` (y/o el Widget que pinta los items de la lista).
* **Instrucciones:**
  1. Localizar el widget `Text` que renderiza el `lastMessage` (el texto de previsualización en la lista de chats).
  2. Añadir un condicional exacto: `if (chat.lastMessage == 'SYSTEM_MSG_CHAT_STARTED')`.
  3. Si la condición se cumple, llamar a la traducción correspondiente (ej. `AppStrings.of(context).chatStarted` o el método que use el sistema de i18n). Si no se cumple, mostrar `chat.lastMessage` directamente.
  4. Si "Conversación iniciada" sigue saliendo hardcodeado, hacer una búsqueda global (`Ctrl+Shift+F`) de esa cadena literal en el repositorio Frontend y reemplazarla por la clave de internacionalización.

### 3. Verificación de Subida de Archivos (Manejo de Errores)
**Objetivo:** Evitar que la app crashee o se quede colgada si el Storage devuelve un error 403.
* **Archivo principal:** Lógica de subida en `found_form_screen.dart` o en su controlador/repositorio correspondiente.
* **Instrucciones:**
  1. Envolver la llamada de subida de imagen a Firebase Storage en un bloque `try-catch`.
  2. Si ocurre una excepción de Storage, capturarla y mostrar un `SnackBar` o diálogo al usuario indicando: "Error al subir la imagen. Inténtalo de nuevo." (usando el sistema de traducciones en los 3 idiomas).