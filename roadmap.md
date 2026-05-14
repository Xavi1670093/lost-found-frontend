## Corrección de Errores Críticos (Parseo de Modelos y Legacy Data)

### 1. Sincronización del Modelo `ChatModel`
**Objetivo:** Adaptar el factory y los getters del modelo de chat para que lean correctamente la estructura de datos real que devuelve Firebase.
* **Archivo principal a modificar:** `lib/features/chats/data/models/chat_model.dart`.
* **Instrucciones:**
  1. **Parseo de Participantes:** En el `factory fromMap`, el backend envía un mapa `members` (ej: `{ "uid1": true, "uid2": true }`). Cambiar la asignación de `participants` para que extraiga las claves de `map['members']` y las convierta en una lista de Strings. (Dejar soporte fallback a `map['participants']` por si acaso).
  2. **Parseo del Título:** En `fromMap`, cambiar `postTitle: map['post_title'] ?? ''` por `postTitle: map['postTitle'] ?? map['post_title'] ?? ''`.
  3. **Getters de Usuario:** En el método `getOtherUserName`, cambiar la lectura a `usersInfo[otherUid]?['displayName'] ?? usersInfo[otherUid]?['name'] ?? defaultName`. En `getOtherUserPhoto`, asegurar que lea `photoUrl`.

### 2. Soporte a Chats Legacy (Traducción Forzada)
**Objetivo:** Traducir los chats antiguos que se crearon antes de implementar la constante de internacionalización.
* **Archivo principal a modificar:** `lib/features/chats/presentation/pages/chats_page.dart`.
* **Instrucciones:**
  1. Buscar el método `_getLastMessageText`.
  2. Ampliar la condición `if` para que no solo detecte `'SYSTEM_MSG_CHAT_STARTED'`, sino que también detecte cadenas estáticas antiguas usando `.toLowerCase()`. Ejemplo: `chat.lastMessage!.toLowerCase() == 'conversación iniciada'`.
  3. De esta forma, los chats antiguos también aplicarán la traducción dinámica `t.chatStarted`.

### 3. Evitar Crasheos Visuales por Datos Incompletos
**Objetivo:** Si un chat legacy no tiene `usersInfo` o `postImageUrl`, asegurar que la UI muestre avatares por defecto y no lance errores.
* **Archivo principal:** `lib/features/chats/presentation/pages/chats_page.dart`.
* **Instrucciones:**
  1. Revisar dónde se pinta la foto de perfil en el feed. Asegurar que si `chat.getOtherUserPhoto()` es nulo o vacío, renderice de forma segura un `Icon(Icons.person)` en lugar de intentar cargar un `CachedNetworkImage`.