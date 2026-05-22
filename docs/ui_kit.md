# UI kit compartido

Catalogo de widgets reutilizables en `lib/shared/widgets/`, alineado con el codigo actual del frontend.

## CustomButton

Archivo: `lib/shared/widgets/custom_button.dart`

Boton reutilizable para acciones primarias y secundarias.

| Parametro | Tipo | Default | Uso |
| :--- | :--- | :--- | :--- |
| `text` | `String` | requerido | Texto visible del boton. |
| `onPressed` | `VoidCallback?` | requerido | Accion. Si es `null`, el boton queda deshabilitado. |
| `isPrimary` | `bool` | `true` | `ElevatedButton` si es primario, `OutlinedButton` si no. |
| `isLoading` | `bool` | `false` | Sustituye contenido por spinner y deshabilita la accion. |
| `icon` | `IconData?` | `null` | Icono opcional antes del texto. |

Usa los estilos globales de `AppTheme` para tamano minimo, radios, colores y tipografia.

## CustomTextField

Archivo: `lib/shared/widgets/custom_text_field.dart`

Campo de formulario con etiqueta opcional, iconos y validacion.

| Parametro | Tipo | Default | Uso |
| :--- | :--- | :--- | :--- |
| `label` | `String` | requerido | Texto de la etiqueta. |
| `hintText` | `String?` | `null` | Placeholder. |
| `controller` | `TextEditingController?` | `null` | Control externo del valor. |
| `isPassword` | `bool` | `false` | Activa `obscureText`. |
| `keyboardType` | `TextInputType` | `TextInputType.text` | Tipo de teclado. |
| `textInputAction` | `TextInputAction?` | `null` | Accion del teclado. |
| `onFieldSubmitted` | `void Function(String)?` | `null` | Callback al enviar desde teclado. |
| `prefixIcon` | `IconData?` | `null` | Icono inicial. |
| `validator` | `String? Function(String?)?` | `null` | Validador de formulario. |
| `suffixIcon` | `Widget?` | `null` | Widget final. |
| `maxLines` | `int` | `1` | Lineas maximas. |
| `showLabel` | `bool` | `true` | Muestra `FieldLabel`. |
| `isRequired` | `bool` | `false` | Marca visual de obligatoriedad. |

## CustomCard

Archivo: `lib/shared/widgets/custom_card.dart`

Wrapper sobre `Card` con `InkWell` y padding configurable.

| Parametro | Tipo | Default | Uso |
| :--- | :--- | :--- | :--- |
| `child` | `Widget` | requerido | Contenido. |
| `padding` | `EdgeInsetsGeometry?` | `EdgeInsets.all(16)` | Espaciado interno. |
| `onTap` | `VoidCallback?` | `null` | Habilita interaccion tactil. |
| `color` | `Color?` | `null` | Color de fondo opcional. |

La forma visual final viene de `ThemeData.cardTheme`; actualmente usa radios amplios en claro/oscuro y clip anti-alias.

## FieldLabel

Archivo: `lib/shared/widgets/field_label.dart`

Etiqueta compacta para formularios. Recibe `label` y `isRequired`; si el campo es obligatorio, anade un asterisco rojo.

## SkeletonLoader

Archivo: `lib/shared/widgets/skeleton_loader.dart`

Placeholder shimmer sensible al tema.

| Parametro | Tipo | Default |
| :--- | :--- | :--- |
| `width` | `double` | `double.infinity` |
| `height` | `double` | `20` |
| `borderRadius` | `BorderRadius?` | `BorderRadius.circular(8)` |

Incluye `SkeletonLoader.postGrid()`, que devuelve un `SliverGrid` de 6 tarjetas de carga para el feed.

## MainNavigationPage

Archivo: `lib/shared/widgets/main_navigation_page.dart`

Contenedor principal autenticado. Gestiona:

- Pestañas `ChatsPage`, `HomePage` y `ProfilePage`.
- `BottomAppBar` con FAB central.
- Inicializacion de FCM mediante `AppNotifications.initFCM`.
- Dialogo de cierre de sesion con limpieza de `login_timestamp`.
- Bottom sheet para publicar objeto `found` o `lost`.

## NotificationBell

Archivo: `lib/shared/widgets/notification_bell.dart`

Icono de notificaciones usado en Home, Chats y Perfil. Escucha `/users/{uid}/notifications` filtrando `read == false`, muestra badge con contador hasta `9+` y abre `NotificationsPage`.

## LanguageSelectorWidget

Archivo: `lib/shared/widgets/language_selector_widget.dart`

Selector de idioma conectado a `AppSettingsController.setLocale`. Cambia el locale local y sincroniza `settings/language` y `preferredLanguage` cuando hay usuario autenticado.

## LegalMarkdownDialog

Archivo: `lib/shared/widgets/legal_markdown_dialog.dart`

Dialogo para mostrar documentos legales desde `assets/legal/`. Se usa en registro para terminos y politica de privacidad.

## MapPickerPage

Archivo: `lib/shared/widgets/map_picker_page.dart`

Selector de ubicacion basado en `flutter_map`. Recibe centro inicial, bounds y poligono opcional; devuelve un `LatLng` seleccionado al formulario de publicacion.
