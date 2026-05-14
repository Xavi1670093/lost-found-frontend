## Corrección Definitiva: Metadata de Subida y Mapeo de Nombres

### 1. Especificar el Content-Type explícito al subir a Storage
**Objetivo:** Evitar que Firebase Storage rechace la imagen por llegar como `application/octet-stream`.
* **Archivos principales:** `lib/features/home/presentation/pages/found_form_screen.dart` (y la parte de edición de perfil).
* **Instrucciones:**
  1. En la llamada a `putFile` o `putData` de `FirebaseStorage.instance.ref()`, añadir el objeto `SettableMetadata` explícitamente.
  2. Ejemplo: `SettableMetadata(contentType: 'image/jpeg')`. Asegurarse de enviarlo en cada subida.

### 2. Tolerancia a Fallos en el Parseo de Nombres en Chats
**Objetivo:** Asegurar que si el mapa de `usersInfo` guarda el nombre como `displayName` (o `name`), el frontend lo recupere sin lanzar nulo.
* **Archivos principales:** `lib/features/chats/data/models/chat_model.dart`.
* **Instrucciones:**
  1. En el getter `getOtherUserName(String currentUserUid)` del modelo `ChatModel`, actualizar la lectura para soportar ambos formatos:
     `return usersInfo[otherUid]?['displayName'] ?? usersInfo[otherUid]?['name'] ?? 'Usuario';`
  2. Verificar que `getOtherUserPhoto` haga lo mismo: `return usersInfo[otherUid]?['photoUrl'] ?? usersInfo[otherUid]?['profile_image_url'];`

### 3. Red de Seguridad Visual (Avatares)
**Objetivo:** Evitar espacios vacíos si una imagen falla al cargar.
* **Archivos principales:** `lib/features/chats/presentation/pages/chats_page.dart` (y detalle de chat).
* **Instrucciones:**
  1. Todo widget `CachedNetworkImage` debe tener un `errorWidget: (context, url, error) => Icon(Icons.person)`.