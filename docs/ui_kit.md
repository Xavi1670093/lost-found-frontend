# 🎨 Catálogo de UI Kit y Widgets Compartidos - UniLost & Found

Este documento detalla el catálogo de widgets personalizados y reutilizables ubicados en [lib/shared/widgets/](file:///home/carlesp/Documentos/UAB/Github/lost-found-frontend/lib/shared/widgets). Estos componentes constituyen el sistema de diseño visual de la aplicación, alineados estrictamente con las directrices estéticas de **Material 3**, con soporte nativo de accesibilidad, adaptabilidad responsiva e internacionalización.

---

## 🧱 1. CustomButton (`custom_button.dart`)

Un botón táctil estandarizado con un gradiente sutil o bordes delineados que responde dinámicamente a estados de carga o inactividad.

### 📝 Propiedades y Parámetros

| Parámetro | Tipo | Requerido / Opcional | Valor por Defecto | Propósito |
| :--- | :--- | :--- | :--- | :--- |
| `text` | `String` | **Requerido** | - | Texto localizado que se mostrará en el centro del botón. |
| `onPressed` | `VoidCallback` | **Requerido** | - | Acción a ejecutar tras la pulsación del usuario. |
| `isPrimary` | `bool` | Opcional | `true` | Determina el estilo: `true` (relleno sólido con color de énfasis), `false` (estilo delineated/outlined). |
| `isLoading` | `bool` | Opcional | `false` | Si es `true`, reemplaza el texto/icono por un spinner de carga y deshabilita la pulsación. |
| `icon` | `IconData?` | Opcional | `null` | Icono decorativo que acompaña al texto en la parte izquierda. |

### 🌗 Adaptación y Comportamiento Responivo
* **Tema Claro/Oscuro**: Consume el color primario de énfasis del tema actual. En el modo oscuro, reduce el contraste del gradiente de fondo para evitar fatiga visual del usuario.
* **Responsividad**: Expande su ancho al máximo de su contenedor padre (`double.infinity`) garantizando un área de pulsación táctil ergonómica y cómoda (mínimo de 48px de altura).

---

## 📝 2. CustomTextField (`custom_text_field.dart`)

Un campo de texto altamente avanzado y adaptado a formularios interactivos que integra soporte nativo para contraseñas, validación reactiva y control del teclado del dispositivo.

### 📝 Propiedades y Parámetros

| Parámetro | Tipo | Requerido / Opcional | Valor por Defecto | Propósito |
| :--- | :--- | :--- | :--- | :--- |
| `label` | `String` | **Requerido** | - | Texto de la etiqueta superior descriptiva. |
| `hintText` | `String?` | Opcional | `null` | Marcador de posición (placeholder) que se muestra en vacío. |
| `controller` | `TextEditingController?` | Opcional | `null` | Controlador para capturar o inicializar el contenido escrito. |
| `isPassword` | `bool` | Opcional | `false` | Si es `true`, oculta los caracteres y añade un botón para alternar visibilidad. |
| `keyboardType` | `TextInputType` | Opcional | `TextInputType.text` | Tipo de teclado virtual a invocar (ej: numérico, correo, texto). |
| `prefixIcon` | `IconData?` | Opcional | `null` | Icono representativo al inicio del campo de texto. |
| `validator` | `String? Function(String?)?` | Opcional | `null` | Función de validación defensiva del formulario. |
| `suffixIcon` | `Widget?` | Opcional | `null` | Widget a renderizar al final del campo (ej: botones interactivos). |
| `maxLines` | `int` | Opcional | `1` | Cantidad de líneas verticales máximas permitidas. |
| `showLabel` | `bool` | Opcional | `true` | Controla la visualización de la etiqueta superior del campo. |
| `isRequired` | `bool` | Opcional | `false` | Indica si el campo es obligatorio (añade un asterisco rojo a la etiqueta). |

### 🌗 Adaptación y Comportamiento Responivo
* **Tema Claro/Oscuro**: Ajusta dinámicamente el color de fondo del campo (`filled`) y del texto introducido de acuerdo al brillo del tema. Los bordes activos cambian al color primario del tema para indicar enfoque visual.
* **Responsividad**: Se adapta de forma elástica a la anchura del dispositivo. En layouts angostos, reduce el espaciado para evitar el desbordamiento de pantalla (*overflow*).

---

## 🎴 3. CustomCard (`custom_card.dart`)

Contenedor estilizado en forma de tarjeta táctil que unifica la presentación visual de publicaciones de objetos, mensajes de chats y configuraciones del perfil.

### 📝 Propiedades y Parámetros

| Parámetro | Tipo | Requerido / Opcional | Valor por Defecto | Propósito |
| :--- | :--- | :--- | :--- | :--- |
| `child` | `Widget` | **Requerido** | - | Componente o estructura interna a albergar dentro de la tarjeta. |
| `padding` | `EdgeInsetsGeometry?` | Opcional | `const EdgeInsets.all(16.0)` | Espaciado interno personalizado del contenido. |
| `onTap` | `VoidCallback?` | Opcional | `null` | Acción táctil que habilita animaciones de pulsación e interactividad. |
| `color` | `Color?` | Opcional | `null` | Color de fondo personalizado. Si es nulo, toma el de la superficie del tema. |

### 🌗 Adaptación y Comportamiento Responivo
* **Tema Claro/Oscuro**: En modo claro, renderiza una elevación sutil con bordes definidos. En modo oscuro, utiliza elevaciones basadas en tonalidades de grises Material 3 para mejorar la visualización en pantallas AMOLED/OLED.
* **Responsividad**: Utiliza bordes redondeados consistentes (`BorderRadius.circular(16)`) que se adaptan de forma fluida a grids dinámicos o layouts de tipo lista.

---

## 🏷️ 4. FieldLabel (`field_label.dart`)

Un pequeño widget especializado que actúa como etiqueta para inputs de texto, unificando la tipografía y jerarquía visual de los títulos de formularios.

### 📝 Propiedades y Parámetros

| Parámetro | Tipo | Requerido / Opcional | Valor por Defecto | Propósito |
| :--- | :--- | :--- | :--- | :--- |
| `label` | `String` | **Requerido** | - | Texto descriptivo de la etiqueta. |
| `isRequired` | `bool` | Opcional | `false` | Si es `true`, renderiza un asterisco rojo (`*`) en negrita para marcar obligatoriedad. |

### 🌗 Adaptación y Comportamiento Responivo
* **Tema Claro/Oscuro**: Mapea automáticamente el color del texto al esquema de contraste apropiado (`onSurfaceVariant`) para mantener el estándar de accesibilidad visual AAA.
* **Responsividad**: Diseñado con comportamiento auto-envolvente (`Row` con tamaño mínimo) para integrarse sin desbordamientos en cualquier parte de la interfaz.

---

## ⏳ 5. SkeletonLoader (`skeleton_loader.dart`)

Un widget animado con un efecto de parpadeo suave (*shimmer effect*) que simula el esqueleto visual de los componentes durante la carga asíncrona de datos desde Firebase.

### 📝 Constructores y Helpers Estáticos

* **Constructor Base (`SkeletonLoader`)**: Crea una caja con un ancho, alto y radio de esquinas configurables por parámetros.
* **`SkeletonLoader.postGrid()`**: Genera una cuadrícula tridimensional compuesta de 6 tarjetas ficticias con imágenes y bloques de texto en parpadeo, idéntica a la visualización de carga de objetos en [HomePage](file:///home/carlesp/Documentos/UAB/Github/lost-found-frontend/lib/features/home/presentation/pages/home_page.dart).

### 🌗 Adaptación y Comportamiento Responivo
* **Tema Claro/Oscuro**: Modifica dinámicamente sus colores base y de resplandor (`baseColor` / `highlightColor`):
  * **Modo Claro**: Alterna entre tonalidades de gris claro (`Colors.grey[300]` y `Colors.grey[100]`).
  * **Modo Oscuro**: Alterna entre tonalidades de gris oscuro/carbón (`Colors.grey[800]` y `Colors.grey[700]`).
* **Responsividad**: Adopta el espacio exacto del elemento final que reemplazará, de manera que la transición de carga a datos no altere el tamaño de la UI.

---

## 🗺️ 6. MainNavigationPage (`main_navigation_page.dart`)

La pieza estructural de navegación principal de la aplicación. Integra el contenedor de pantallas, el menú inferior e interactúa dinámicamente con el botón flotante central de reportes rápidos.

### 📝 Estructura y Comportamiento
* **Barra de Navegación**: Utiliza un menú de navegación `BottomAppBar` de Material 3 con muesca central circular (`CircularNotchedRectangle`) para alojar estéticamente el botón de acción principal.
* **FAB Central Animado**: Un botón flotante central con un gradiente vistoso que realiza transiciones suaves de escala y rotación entre un icono de casa (`Icons.home_rounded`) o de agregar objeto (`Icons.add_rounded`) dependiendo de la sección en la que se encuentre el usuario.
* **Expiración de Sesión**: Se comunica activamente con la capa transversal del sistema para comprobar que el token del usuario se mantenga verificado y vigente, garantizando un cierre de sesión seguro en caso de inactividad o superación de la cuota de 14 días.
