# 🗺️ Roadmap de Rediseño UI/UX (Frontend - Flutter)

Este roadmap detalla los pasos para modernizar la interfaz de la aplicación de objetos perdidos y encontrados, mejorando la usabilidad y la estética visual sin alterar la lógica de negocio ni la conexión con Firebase.

## FASE 1: Sistema de Diseño y Fundamentos (Core)
El objetivo es estandarizar la apariencia para que la app se sienta cohesiva y moderna.

- [ ] **Paleta de Colores y Tipografía (`lib/core/theme/app_theme.dart`)**
  - **Acción:** Transicionar a Material 3 (M3) activando `useMaterial3: true` en el `ThemeData`.
  - **Color:** Definir un `ColorScheme` claro y oscuro. Usar colores de acento vibrantes (ej. naranja/azul) para destacar estados ("Perdido" vs "Encontrado").
  - **Tipografía:** Integrar el paquete `google_fonts` y aplicar una fuente moderna y legible (ej. *Poppins*, *Montserrat* o *Inter*) para todo el `TextTheme`.
- [ ] **Componentes Globales (`lib/shared/widgets/`)**
  - **Acción:** Crear widgets reutilizables básicos (botones primarios/secundarios, campos de texto personalizados con bordes redondeados y estados de foco/error, tarjetas base).
  - **Estilos:** Añadir radios de borde (`BorderRadius.circular(16)`) y sombras suaves (`BoxShadow`) para dar profundidad.

## FASE 2: Navegación y Estructura Principal
Hacer que moverse por la aplicación sea fluido e intuitivo.

- [ ] **Navegación Principal (`lib/shared/widgets/main_navigation_page.dart`)**
  - **Acción:** Reemplazar el `BottomNavigationBar` clásico por un `NavigationBar` de Material 3 o un menú de navegación flotante.
  - **Mejora visual:** Añadir iconos rellenos/activos vs delineados/inactivos para indicar claramente la pestaña actual.

## FASE 3: Rediseño de Pantallas (Features)
Actualizar cada flujo de la aplicación utilizando los componentes de la Fase 1.

### Auth & Onboarding (`lib/features/auth/` & `lib/features/welcome/`)
- [ ] **Pantalla de Bienvenida (`welcome_page.dart`)**
  - **Acción:** Añadir una ilustración heroica o animación (usando Lottie) que represente la búsqueda/encuentro de objetos.
  - **UX:** Asegurar que los botones de inicio de sesión y registro tengan jerarquía visual (uno relleno, otro con borde).
- [ ] **Login y Registro (`login_page.dart`, `register_page.dart`)**
  - **Acción:** Limpiar el formulario. Usar iconos dentro de los campos de texto (`prefixIcon`). Agrupar lógicamente los elementos y dejar suficiente espacio en blanco (padding) para evitar saturación visual.

### Feed Principal y Detalles (`lib/features/home/`)
- [ ] **Pantalla Principal (`home_page.dart`)**
  - **Acción:** Rediseñar la lista de objetos usando un formato de "Grid" (cuadrícula) o "Cards" (tarjetas) grandes.
  - **Elementos de la Tarjeta:** Imagen del objeto (ocupando la mitad superior), título, fecha, ubicación, y un *Badge* (etiqueta) de color distintivo que indique si está "Perdido" o "Encontrado".
  - **UX:** Añadir una barra de búsqueda moderna en la parte superior con un botón para filtros (categoría, ubicación, fecha).
- [ ] **Detalle del Objeto (`post_detail_page.dart`)**
  - **Acción:** Implementar animaciones `Hero` en las imágenes para que transicionen suavemente desde la lista principal hasta el detalle.
  - **Layout:** Mostrar la imagen en grande (SliverAppBar), seguido de la información detallada abajo. Añadir un botón flotante o un botón fijo en la parte inferior (Call to Action) muy visible para "Reclamar objeto" o "Contactar".
- [ ] **Formularios de Creación (`found_form_screen.dart`, `edit_post_page.dart`)**
  - **Acción:** Para formularios largos, agrupar los campos en secciones visuales usando `Card` o implementar un `Stepper` (paso a paso).
  - **UX:** Mejorar el selector de imágenes mostrando una cuadrícula de previsualización de las fotos seleccionadas con la opción de eliminarlas fácilmente.

### Chats (`lib/features/chats/`)
- [ ] **Lista de Chats (`chats_page.dart`)**
  - **Acción:** Usar `ListTile` con avatares circulares (`CircleAvatar`). Destacar los mensajes no leídos con texto en negrita y un indicador de notificaciones (burbuja con el número de mensajes).
- [ ] **Pantalla de Chat (`chat_detail_page.dart`)**
  - **Acción:** Modernizar las burbujas de chat. Diferenciar visualmente los mensajes enviados (alineados a la derecha, color primario) de los recibidos (alineados a la izquierda, color gris claro/oscuro).
  - **UX:** Añadir la hora de cada mensaje en tamaño pequeño debajo o dentro de la burbuja y mantener el campo de entrada de texto siempre fijo al teclado.

### Perfil (`lib/features/profile/`)
- [ ] **Pantalla de Perfil (`profile_page.dart`)**
  - **Acción:** Mostrar la información del usuario (foto, nombre, centro educativo) centrada en la parte superior de forma limpia.
  - **UX:** Usar un `TabBar` para separar las vistas de "Mis Publicaciones" (`user_posts_page.dart`) y "Mis Reclamos" (`user_claims_page.dart`), evitando tener listas excesivamente largas en una sola vista.

## FASE 4: Microinteracciones y Estado (Polishing)
Los pequeños detalles que hacen que la app se sienta "Premium".

- [ ] **Manejo de Estados de Carga (Loading)**
  - **Acción:** Reemplazar los `CircularProgressIndicator` en las listas por efectos de *Shimmer* (esqueletos de carga) usando paquetes como `shimmer` para mejorar la percepción de velocidad.
- [ ] **Feedback de Acciones (Snackbars & Diálogos)**
  - **Acción:** Mostrar *Snackbars* flotantes con bordes redondeados y colores semánticos (verde para éxito, rojo para error) al reportar un objeto o editar un perfil.
- [ ] **Manejo de Estados Vacíos (Empty States)**
  - **Acción:** Diseñar pantallas de "estado vacío" amigables (con un icono o ilustración de una lupa triste y un texto que invite a la acción) para cuando no hay resultados de búsqueda o no hay chats.