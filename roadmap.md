## [COMPLETADO] Mejoras Visuales en Chats y Corrección de Subida (Frontend)

### 1. Solución Definitiva: Error 403 al Subir Imágenes y App Check [COMPLETADO]
**Objetivo:** Evitar que Firebase Storage rechace las subidas de objetos (Error 403) forzando el envío del `ContentType` y solucionando las advertencias del proveedor de App Check.
* **Archivos:** `lib/features/home/presentation/pages/found_form_screen.dart`, `lib/main.dart`
* **Acciones realizadas:**
  - Metadata `image/jpeg` añadida a las subidas en `found_form_screen.dart`.
  - Inicialización de `FirebaseAppCheck` con `AndroidProvider.debug` en `main.dart`.

### 2. Extensión del Modelo de Chat [COMPLETADO]
**Objetivo:** Soportar la lectura del creador del post y su foto de perfil.
* **Archivos:** `lib/features/chats/data/models/chat_model.dart`
* **Acciones realizadas:**
  - Añadido `postOwnerId` al modelo.
  - Implementados métodos `getPublisherName()` y `getPublisherPhoto()` con lógica de fallback.

### 3. Rediseño de Tarjeta en la Lista de Chats [COMPLETADO]
**Objetivo:** Mostrar simultáneamente el símbolo/imagen del objeto perdido y la información del publicador.
* **Archivos:** `lib/features/chats/presentation/pages/chats_page.dart`
* **Acciones realizadas:**
  - Rediseñado el `leading` para mostrar la miniatura del objeto (radio 12).
  - Añadida fila de información del publicador (avatar y nombre) debajo del título.
  - Implementada carga robusta de imágenes con `CachedNetworkImage` y fallbacks visuales premium.
  - Garantizada la internacionalización mediante `AppStrings`.