# 🗺️ Roadmap de Rediseño UI/UX y Correcciones Críticas (Frontend)

Este roadmap incluye una fase inicial obligatoria de estabilización para corregir las regresiones (bugs) de datos causadas en la refactorización visual, seguido de las mejoras de diseño, internacionalización y arquitectura.

## FASE 0: Estabilización y Prevención de Crasheos (Hotfixes)
El objetivo es asegurar que la capa de datos no rompa la interfaz antes de seguir diseñando.

- [ ] **Parseo Seguro de Firebase (Evitar Crasheos por Casting)**
  - **Archivos:** `lib/features/home/presentation/pages/home_page.dart`
  - **Acción:** Reemplazar todas las asignaciones `snapshot.data!.snapshot.value as Map<dynamic, dynamic>` por un mapeo seguro usando la iteración directa de `.children`. Firebase a veces devuelve un `List` en lugar de un `Map`, lo que rompe el Feed y el Mapa.
- [ ] **Sincronización de Animaciones (Hero)**
  - **Archivos:** `home_page.dart` (`_RealObjectCard`)
  - **Acción:** Envolver el contenedor superior de la imagen/icono en un widget `Hero(tag: 'post_image_${post['id']}')`. Actualmente está en `post_detail_page.dart` pero falta el origen en la tarjeta, rompiendo la transición.
- [ ] **Unificación de Consultas (Case-Sensitivity en Filtros)**
  - **Archivos:** `home_page.dart` y `profile_page.dart`
  - **Acción:** Estandarizar la lectura/escritura de `center_id`. Asegurar que siempre se consulte y formatee en minúsculas (ej. "uab" en lugar de "UAB") para que el filtro `orderByChild('center_id').equalTo(centerId)` no falle al cargar los posts.
- [ ] **Type Safety en Tiempos y Coordenadas**
  - **Archivos:** `post_detail_page.dart` y `home_page.dart`
  - **Acción:** Implementar métodos `tryParse` para castear de forma segura `lat`, `lng` y `created_at`. Evitar que variables corruptas o enviadas como `String` crasheen `fromMillisecondsSinceEpoch` o el renderizado de latlong2 en el mapa.

## FASE 1: Sistema de Diseño, Internacionalización y Fundamentos (Core)
- [ ] **Internacionalización (i18n):** Implementar soporte base en Español (por defecto), Inglés y Catalán migrando textos estáticos.
- [ ] **Diseño Intuitivo (Material 3):** Configurar `app_theme.dart` activando M3, psicología del color (verde/naranja) y tipografía legible.
- [ ] **Componentes Globales:** Estandarizar tarjetas y botones para consistencia visual.

## FASE 2: Navegación Principal
- [ ] **Barra de Navegación (`main_navigation_page.dart`):** Renovar el menú inferior. Crear un botón "Home" o central grande, distintivo y flotante para mejorar la usabilidad, con iconos intuitivos según estado.

## FASE 3: Formularios, Autenticación y Prevención de Errores
- [ ] **Formularios Intuitivos y Ejemplos:** Asegurar que cada `TextField` tenga un `hintText` como ejemplo formativo, referenciado desde el sistema de idiomas.
- [ ] **Manejo Exhaustivo de Errores:** Interceptar excepciones de Firebase (autenticación, recuperar chats) y mapearlas a alertas semánticas limpias y traducidas, ocultando el error en crudo.

## FASE 4: Rediseño de Pantallas (Features)
- [ ] **Feed Principal y Detalles:** Mejorar el *Grid* de `home_page` integrando correctamente *badges* e iconos. Asegurar un layout expandible limpio en el detalle.
- [ ] **Chats y Perfil:** Refinar burbujas de chat, avatares y *empty states* amigables y traducidos.

## FASE 5: Microinteracciones y Pulido (Polishing)
- [ ] **Feedback de Acciones (Snackbars):** Crear un widget centralizado para notificaciones flotantes de éxito/error.
- [ ] **Estados de Carga (Loading):** Reemplazar indicadores básicos por un sistema generalizado de esqueletos (Shimmer Effect).