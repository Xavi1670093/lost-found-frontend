# 🗺️ Roadmap de Rediseño UI/UX y Correcciones Críticas (Frontend)

Este roadmap incluye las fases de estabilización de renderizado (Slivers vs RenderBox) para corregir los crasheos de layout, así como ajustes de usabilidad para navegación, seguido de las mejoras de diseño y arquitectura.

## FASE 0.1: Corrección de Layouts y Renderizado (Hotfixes)
El objetivo es solucionar las incompatibilidades entre Slivers y RenderBoxes que provocan pantallas rojas o cierres de la app.

- [ ] **Corrección de Conflicto Sliver/RenderBox (`user_posts_page.dart`)**
  - **Problema:** El `StreamBuilder` devuelve un `SkeletonLoader.postGrid()` (que es un Sliver) pero luego devuelve un `GridView.builder` (que es un RenderBox) dentro del body de un Scaffold estándar.
  - **Acción:** Convertir el `body` del `Scaffold` en un `CustomScrollView`. Cambiar el `GridView.builder` por un `SliverPadding` con un `SliverGrid` dentro. Así, tanto el estado de carga (Skeleton) como el estado con datos (Grid) serán Slivers y no romperán el árbol de renderizado.
- [ ] **Ajuste de Scroll Inferior en el Feed (`home_page.dart`)**
  - **Problema:** Los últimos objetos de la lista quedan tapados por la nueva barra de navegación inferior.
  - **Acción:** Localizar el último widget del `CustomScrollView` (actualmente `SliverToBoxAdapter(child: SizedBox(height: 32))`) e incrementar su altura a al menos `120` o usar el padding del `SafeArea` inferior para asegurar que se pueda hacer scroll hasta ver los objetos completamente.
- [ ] **Gestión de Errores Silenciosos de Imágenes**
  - **Acción:** Asegurarse de que si el backend devuelve perfiles u objetos sin imágenes válidas, no se rompa la aserción de Flutter, añadiendo manejadores de error en las cargas de red (ej. `errorBuilder` en `Image.network`).

## FASE 1: Sistema de Diseño, Internacionalización y Fundamentos (Core)
- [ ] **Internacionalización (i18n):** Implementar soporte base en Español (por defecto), Inglés y Catalán.
- [ ] **Diseño Intuitivo (Material 3):** Configurar `app_theme.dart` activando M3, psicología del color y tipografía.

## FASE 2: Navegación Principal
- [ ] **Barra de Navegación (`main_navigation_page.dart`):** Renovar el menú inferior. Crear un botón "Home" flotante y destacado.

## FASE 3: Formularios, Autenticación y Prevención de Errores
- [ ] **Formularios Intuitivos y Ejemplos:** Asegurar que cada `TextField` tenga un `hintText` formativo referenciado a i18n.
- [ ] **Manejo Exhaustivo de Errores:** Interceptar excepciones de Firebase y mapearlas a alertas semánticas limpias.

## FASE 4: Rediseño de Pantallas (Features)
- [ ] **Feed Principal y Detalles:** Mejorar el *Grid* de `home_page` integrando correctamente *badges* e iconos. Asegurar un layout expandible limpio en el detalle.
- [ ] **Chats y Perfil:** Refinar burbujas de chat, avatares y *empty states* amigables y traducidos.

## FASE 5: Microinteracciones y Pulido (Polishing)
- [ ] **Feedback de Acciones (Snackbars):** Crear un widget centralizado para notificaciones flotantes.
- [ ] **Estados de Carga (Loading):** Reemplazar indicadores básicos por un sistema generalizado de esqueletos (Shimmer Effect).