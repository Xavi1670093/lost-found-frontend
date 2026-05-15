# Catálogo de UI Compartida (Shared Widgets)

Este documento describe los widgets reutilizables ubicados en `lib/shared/widgets/`, diseñados bajo los principios de Material 3 y preparados para internacionalización.

## 1. CustomButton (`custom_button.dart`)
Botón estandarizado con soporte para estados de carga y estilos primario/secundario.

**Propiedades:**
- `text`: El texto a mostrar (localizado).
- `onPressed`: Callback de acción.
- `isPrimary`: `true` para color sólido, `false` para estilo *outlined*.
- `isLoading`: Muestra un spinner y deshabilita el botón si es `true`.
- `icon`: Icono opcional antes del texto.

---

## 2. CustomTextField (`custom_text_field.dart`)
Campo de entrada de texto estilizado con validación integrada.

**Propiedades:**
- `label`: Título del campo.
- `hintText`: Texto de sugerencia.
- `controller`: Controlador para capturar el valor.
- `isPassword`: Oculta el texto si es `true`.
- `validator`: Función de validación personalizada.
- `keyboardType`: Tipo de teclado (email, número, etc.).

---

## 3. CustomCard (`custom_card.dart`)
Contenedor con bordes redondeados y sombra suave, utilizado para listar objetos y secciones de perfil.

**Propiedades:**
- `child`: Contenido interno.
- `onTap`: Hace que la tarjeta sea interactiva.
- `padding`: Espaciado interno personalizable.

---

## 4. SkeletonLoader (`skeleton_loader.dart`)
Componente para estados de carga (*shimmer effect*) que mejora la percepción de rendimiento.

**Constructores estáticos:**
- `SkeletonLoader.postGrid()`: Genera una rejilla de carga para el feed principal.
- `SkeletonLoader.chatList()`: Genera una lista de carga para la pantalla de mensajes.

---

## 5. MainNavigationPage (`main_navigation_page.dart`)
Componente estructural que gestiona la barra de navegación inferior y el cambio entre las pantallas principales (`Home`, `Chats`, `Profile`).

**Características:**
- Usa un `NavigationBar` de Material 3.
- Mantiene el estado de las páginas mediante un `IndexedStack`.
