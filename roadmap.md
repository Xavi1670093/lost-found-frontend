# 🗺️ Roadmap: Resolución de Bugs, Mejoras Auth y Fase QA

Este roadmap guía la implementación de correcciones en la rama `mejorar-UX-UI`, alineando el código del Frontend con la arquitectura actual del Backend (Cloud Functions y RTDB), e incorporando las nuevas mejoras de sesión e internacionalización (i18n).

## FASE 1: Corrección de Errores Críticos (Integración Backend)
**Objetivo:** Restaurar la funcionalidad de edición y optimizar la sincronización del chat respetando los triggers del lado del servidor.

- [ ] **Fix Edición de Publicaciones (`lib/features/profile/presentation/pages/edit_post_page.dart`):**
  - **Alinear Payload con Cloud Function:** La función `updatePostStatus` en el backend espera estrictamente los parámetros `postId` y `newStatus`. Actualmente, el frontend envía un mapa con `status` (junto a título, descripción y categoría). Se debe cambiar el parámetro enviado a `newStatus: _selectedStatus`.
  - **Actualización de Textos:** Como la Cloud Function *solo* actualiza el estado, el título, descripción y categoría deben actualizarse directamente desde el frontend hacia la Realtime Database (`FirebaseDatabase.instance.ref('posts/${widget.postId}').update({...})`), ya que las reglas en `database.rules.json` permiten la escritura en el nodo `posts` si el `user_id` coincide con el del usuario autenticado.

- [ ] **Fix Fallos y Latencia en el Chat (`lib/features/chats/presentation/pages/chat_detail_page.dart`):**
  - **Eliminar Redundancia de Actualización:** El backend cuenta con un trigger (`onMessageCreated.ts`) que actualiza atómicamente el último mensaje en el nodo del chat y en los índices de todos los miembros.
  - **Acción a tomar:** Eliminar la instrucción manual en `_sendMessage` donde el frontend hace el `update` de `chats/${widget.chatId}` con `last_message`. El frontend únicamente debe empujar (`push()`) el nuevo mensaje a la ruta `messages/${widget.chatId}` y dejar que la Cloud Function haga la sincronización. Esto evita conflictos de permisos o colisiones de datos.

## FASE 2: Mejoras de Autenticación e Inicio de Sesión
**Objetivo:** Añadir flexibilidad en los campos de entrada y establecer el ciclo de vida de la sesión.

- [ ] **Emails Case-Insensitive (`login_page.dart` y `register_page.dart`):**
  - **Normalización Inmediata:** Aplicar la función `.trim().toLowerCase()` al texto extraído de los controladores antes de ejecutar cualquier validación. Esto es vital porque la función del backend `secureUniversityRegistration` usa una división estricta por arroba (`email.split("@")[1]`) para verificar el dominio contra el nodo de centros permitidos.
  - **Validación Uniforme:** Comprobar que las validaciones RegEx sigan funcionando perfectamente con la cadena convertida a minúsculas.

- [ ] **Persistencia de Sesión (Límite de 10 días):**
  - **Registro de Marca de Tiempo:** Modificar el flujo de login y registro para guardar un `login_timestamp` (la fecha de entrada) en almacenamiento local seguro (`SharedPreferences` o equivalente) al iniciarse la sesión.
  - **Verificación de Caducidad:** Al arrancar la aplicación, si Firebase reporta un usuario activo, comparar la fecha actual con el `login_timestamp`. Si el lapso es superior a 10 días, forzar `FirebaseAuth.instance.signOut()`, borrar la marca de tiempo local y redirigir al login mostrando una advertencia traducida al usuario.

## FASE 3: Cobertura Total de Internacionalización (i18n)
**Objetivo:** Erradicar textos estáticos (hardcodeados) y asegurar la triple cobertura idiomática.

- [ ] **Auditoría de Formularios y Errores:** Validar que los SnackBar de fallos (en los bloques catch de las funciones corregidas) usen estrictamente `AppStrings.of(context)`.
- [ ] **Nuevas Claves en Diccionarios:** Añadir la nueva clave para la sesión caducada ("Tu sesión ha caducado por seguridad después de 10 días...") a los archivos de Español (por defecto), Inglés y Catalán para mantener la simetría de las traducciones.

## FASE 4: Optimización y Seguridad
**Objetivo:** Garantizar un rendimiento óptimo de la UI y prevenir fugas de datos sensibles.

- [ ] **Gestión de Memoria (Dispose):** Verificar `edit_post_page.dart` y el chat para asegurar que todos los `TextEditingController` sean liberados en los métodos `dispose()`.
- [ ] **Limpieza de Trazas:** Sustituir los usos de `debugPrint` o `print` que expongan pasos del registro o login por métodos que se oculten automáticamente en modo "Release".
- [ ] **Reconstrucción del Árbol (FPS):** Intervenir en los ListView de chats y posts para envolver widgets estáticos (iconos fijos, paddings, divisores) con el modificador `const`, ahorrando carga a la GPU.