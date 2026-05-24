# UI kit compartido

Catálogo de widgets reutilizables en `lib/shared/widgets/`, alineado con el código actual del frontend.

## CustomButton

Archivo: `lib/shared/widgets/custom_button.dart`

Botón reutilizable para acciones primarias y secundarias.

| Parámetro | Tipo | Default | Uso |
| :--- | :--- | :--- | :--- |
| `text` | `String` | requerido | Texto visible del botón. |
| `onPressed` | `VoidCallback?` | requerido | Acción al presionar. Si es `null`, el botón queda deshabilitado. |
| `isPrimary` | `bool` | `true` | Muestra un `ElevatedButton` si es primario, o un `OutlinedButton` si es secundario. |
| `isLoading` | `bool` | `false` | Sustituye el contenido por un spinner de carga y deshabilita la acción. |
| `icon` | `IconData?` | `null` | Icono opcional que se muestra antes del texto. |

Usa los estilos globales de `AppTheme` para tamaño mínimo, radios, colores y tipografía.

## CustomTextField

Archivo: `lib/shared/widgets/custom_text_field.dart`

Campo de formulario con etiqueta opcional, iconos y validación.

| Parámetro | Tipo | Default | Uso |
| :--- | :--- | :--- | :--- |
| `label` | `String` | requerido | Texto de la etiqueta. |
| `hintText` | `String?` | `null` | Texto de sugerencia (placeholder). |
| `controller` | `TextEditingController?` | `null` | Controlador externo del valor del campo. |
| `isPassword` | `bool` | `false` | Activa `obscureText` para contraseñas. |
| `keyboardType` | `TextInputType` | `TextInputType.text` | Tipo de teclado virtual. |
| `textInputAction` | `TextInputAction?` | `null` | Acción del teclado (ej. enviar, siguiente). |
| `onFieldSubmitted` | `void Function(String)?` | `null` | Callback ejecutado al enviar desde el teclado. |
| `prefixIcon` | `IconData?` | `null` | Icono inicial del campo. |
| `validator` | `String? Function(String?)?` | `null` | Validador de formulario para integración con `Form`. |
| `suffixIcon` | `Widget?` | `null` | Widget ubicado al final del campo. |
| `maxLines` | `int` | `1` | Cantidad máxima de líneas de texto. |
| `showLabel` | `bool` | `true` | Si es `true`, renderiza un `FieldLabel` sobre el campo. |
| `isRequired` | `bool` | `false` | Añade una marca visual de obligatoriedad a la etiqueta. |

## CustomCard

Archivo: `lib/shared/widgets/custom_card.dart`

Contenedor estilizado sobre `Card` que incluye soporte para interacción táctil (`InkWell`) y padding configurable.

| Parámetro | Tipo | Default | Uso |
| :--- | :--- | :--- | :--- |
| `child` | `Widget` | requerido | Contenido interno de la tarjeta. |
| `padding` | `EdgeInsetsGeometry?` | `EdgeInsets.all(16)` | Espaciado interno. |
| `onTap` | `VoidCallback?` | `null` | Habilita la interacción táctil y la animación de pulsación. |
| `color` | `Color?` | `null` | Color de fondo opcional. |

La forma visual final se deriva de `ThemeData.cardTheme`; actualmente usa bordes redondeados amplios adaptados a temas claro/oscuro con recorte anti-alias.

## FieldLabel

Archivo: `lib/shared/widgets/field_label.dart`

Etiqueta compacta para formularios. Recibe `label` y `isRequired`; si el campo es obligatorio, añade un asterisco rojo de advertencia al lado del texto.

## SkeletonLoader

Archivo: `lib/shared/widgets/skeleton_loader.dart`

Placeholder animado tipo shimmer sensible al tema visual activo.

| Parámetro | Tipo | Default | Uso |
| :--- | :--- | :--- | :--- |
| `width` | `double` | `double.infinity` | Ancho del bloque shimmer. |
| `height` | `double` | `20` | Alto del bloque shimmer. |
| `borderRadius` | `BorderRadius?` | `BorderRadius.circular(8)` | Radio de los bordes. |

Incluye el constructor de utilidad `SkeletonLoader.postGrid()`, el cual devuelve un `SliverGrid` compuesto por 6 tarjetas shimmer simulando la carga del feed de posts.

## MainNavigationPage

Archivo: `lib/shared/widgets/main_navigation_page.dart`

Contenedor principal para la navegación de usuarios autenticados. Gestiona:
- Las pestañas principales: `ChatsPage`, `HomePage` y `ProfilePage`.
- Un `BottomAppBar` personalizado con un botón de acción flotante (FAB) centralizado.
- Inicialización del servicio de mensajería en segundo plano con `AppNotifications.initFCM`.
- Confirmación de salida a través de un diálogo que limpia el `login_timestamp` local.
- Menú emergente (Bottom Sheet) para el reporte de objetos perdidos (`lost`) o encontrados (`found`).

## NotificationBell

Archivo: `lib/shared/widgets/notification_bell.dart`

Icono interactivo de campana de notificaciones utilizado en las barras de navegación. Escucha `/users/{uid}/notifications` en tiempo real, filtra aquellas con `read == false`, muestra un badge con contador dinámico (soporta hasta `9+`) y redirige a la vista `NotificationsPage`.

## LanguageSelectorWidget

Archivo: `lib/shared/widgets/language_selector_widget.dart`

Selector desplegable de idioma conectado a `AppSettingsController.setLocale`. Modifica el idioma local en caliente y sincroniza los campos `settings/language` y `preferredLanguage` del usuario autenticado en la base de datos remota.

## LegalMarkdownDialog

Archivo: `lib/shared/widgets/legal_markdown_dialog.dart`

Diálogo modal diseñado para renderizar documentos de formato Markdown obtenidos desde `assets/legal/`. Se emplea durante el registro para que el usuario revise y acepte los términos y condiciones o la política de privacidad.

## MapPickerPage

Archivo: `lib/shared/widgets/map_picker_page.dart`

Pantalla de selección geográfica interactiva basada en `flutter_map`. Recibe una coordenada inicial, límites geográficos y un polígono opcional; permite arrastrar un marcador y devuelve un objeto `LatLng` al formulario de publicación tras validar que se encuentra en la zona permitida.
