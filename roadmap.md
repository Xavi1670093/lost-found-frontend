# 🗺️ Roadmap de Rediseño UI/UX y Correcciones Críticas (Frontend)

Este roadmap incluye las fases de estabilización de datos y lógica de negocio para garantizar que la app sea 100% funcional antes de pulir detalles visuales.

## FASE 0.1: Corrección de Layouts y Renderizado (Hotfixes)
- [x] Corrección de Conflicto Sliver/RenderBox (`user_posts_page.dart`).
- [x] Ajuste de Scroll Inferior en el Feed (`home_page.dart`).

## FASE 0.2: Corrección de Lógica de Negocio y Firebase (Hotfixes)
El objetivo es solucionar los fallos introducidos al manejar tipos de datos y consultas ineficientes en Firebase.

- [x] **Corrección de Creación de Chats (`post_detail_page.dart`)**
  - **Problema:** El uso del operador `<` para comparar Strings (`user_id` y `uid`) lanza una excepción en Dart, bloqueando la creación del chat.
  - **Acción:** Reemplazar la validación del `chatId` utilizando el método `.compareTo()`.
- [x] **Optimización de Actualización en Cascada (`edit_post_page.dart`)**
  - **Problema:** `_updateRelatedChatsStatus` intenta descargar toda la colección `chats`, lo que provoca un error de "Permission Denied" (y crasheos de memoria) ocultando el mensaje de éxito.
  - **Acción:** Refactorizar la función para usar una consulta indexada (`orderByChild('post_id').equalTo(postId)`) e iterar sobre los resultados de forma segura usando `.children` en lugar de hacer casting a `Map`.

## FASE 0.3: Sanitización de Datos en Creación de Chats (Hotfix)
El objetivo es evitar bloqueos de base de datos por datos nulos.

- [x] **Creación Segura de Chats (`post_detail_page.dart`)**
  - **Problema:** Firebase RTDB rechaza operaciones `.set()` si detecta algún campo `null` (ej. si el post cargado pierde su `id` o `title` en el parseo). Además, el casteo del mapa al navegar a `ChatDetailPage` puede romper el renderizado.
  - **Acción:** Refactorizar por completo la función `_contactOwner`. Añadir operadores *null-aware* (`??`) en todos los campos de Firebase, asegurar el casteo de UIDs como `String` y añadir trazabilidad (`debugPrint`) para registrar el fallo real si vuelve a ocurrir.

## FASE 1: Sistema de Diseño, Internacionalización y Fundamentos (Core)
- [ ] **Internacionalización (i18n):** Implementar soporte base en Español (por defecto), Inglés y Catalán.
- [ ] **Diseño Intuitivo (Material 3):** Configurar `app_theme.dart` activando M3, psicología del color y tipografía.

## FASE 2: Navegación Principal
- [ ] **Barra de Navegación (`main_navigation_page.dart`):** Renovar el menú inferior. Crear un botón "Home" flotante y destacado.

## FASE 3: Formularios, Autenticación y Prevención de Errores
- [ ] **Formularios Intuitivos y Ejemplos:** Asegurar que cada `TextField` tenga un `hintText` formativo referenciado a i18n.
- [ ] **Manejo Exhaustivo de Errores:** Interceptar excepciones de Firebase y mapearlas a alertas semánticas limpias.

## FASE 4: Rediseño de Pantallas (Features)
- [ ] **Feed Principal y Detalles:** Mejorar el *Grid* de `home_page`. Asegurar un layout expandible limpio en el detalle.
- [ ] **Chats y Perfil:** Refinar burbujas de chat, avatares y *empty states* amigables y traducidos.

## FASE 5: Microinteracciones y Pulido (Polishing)
- [ ] **Feedback de Acciones (Snackbars):** Crear un widget centralizado para notificaciones flotantes.
- [ ] **Estados de Carga (Loading):** Reemplazar indicadores básicos por esqueletos (Shimmer Effect).