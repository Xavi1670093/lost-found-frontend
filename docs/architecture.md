# Arquitectura del frontend

Este documento describe la arquitectura real del cliente Flutter de UniLost & Found a fecha 22 de mayo de 2026.

## Estructura

```text
lib/
├── main.dart                         # Bootstrap de Flutter y Firebase
├── app.dart                          # MaterialApp, auth gate, legal gate y sesion local
├── firebase_options.dart             # Opciones generadas por FlutterFire
├── core/
│   ├── localization/app_strings.dart  # i18n estatica es/ca/en
│   ├── services/                      # permisos, ubicacion, cache y errores
│   ├── settings/                      # AppSettingsController
│   └── theme/app_theme.dart           # Material 3 y paleta de marca
├── features/
│   ├── auth/                          # login, registro y aceptacion legal
│   ├── chats/                         # listado y detalle de chats
│   ├── home/                          # feed, formulario, detalle y mapa
│   ├── notifications/                 # bandeja de notificaciones in-app
│   ├── profile/                       # perfil, ajustes y posts propios
│   └── welcome/                       # entrada para usuarios anonimos
└── shared/
    ├── utils/                         # categorias, imagenes y notificaciones
    └── widgets/                       # componentes reutilizables
```

La separacion es por funcionalidades. En la practica, la capa de presentacion usa SDKs de Firebase y servicios compartidos directamente cuando el flujo es pequeno; las operaciones sensibles se delegan a Cloud Functions.

## Arranque de la aplicacion

`main.dart` monta `AppInitializer`, que ejecuta este orden:

1. `Firebase.initializeApp` con `DefaultFirebaseOptions.currentPlatform`.
2. Registro del handler FCM de background con `FirebaseMessaging.onBackgroundMessage`.
3. Activacion de Firebase App Check con proveedores `debug` para Android e iOS.
4. Persistencia local de Firebase Auth con `Persistence.LOCAL`.
5. Creacion y carga de `AppSettingsController`.

Cuando termina la inicializacion, `MyApp` configura tema, locale, delegados de localizacion y limita el escalado de texto entre `0.8` y `1.25`.

## Gates de acceso

`AppRoot` observa `FirebaseAuth.instance.authStateChanges()`:

- Sin usuario, o con email no verificado, muestra `WelcomePage`.
- Con usuario verificado, comprueba una marca local `login_timestamp`.
- Si han pasado mas de 14 dias desde esa marca, cierra sesion y elimina el timestamp.
- Si la sesion es valida, entra en `LegalGuardGate`.

`LegalGuardGate` escucha `/users/{uid}` en RTDB y compara `acceptedTermsVersion` con `requiredLegalVersion` (`1.0.0`). Si la version aceptada no es suficiente, muestra `TermsAcceptanceScreen`.

## Estado y preferencias

`AppSettingsController` extiende `ChangeNotifier` y combina cache local con sincronizacion remota:

- `SharedPreferences`: `theme_mode`, `is_dark_mode`, `selected_locale`, `push_notifications_enabled`.
- RTDB: `/users/{uid}/settings`.
- Idiomas soportados: `es`, `ca`, `en`.
- Tema soportado: `light`, `dark`, `system`.
- Toggle push: `pushNotificationsEnabled`.

Al cambiar tema, idioma o push, el controlador actualiza el estado local, persiste en `SharedPreferences` y escribe en RTDB cuando hay usuario autenticado. Tambien escucha cambios remotos para reflejarlos en la UI.

## Integracion con Firebase

### Authentication y registro

El registro no crea usuarios directamente desde el cliente. `RegisterPage` llama a la Cloud Function `secureUniversityRegistration` en `us-central1` con:

- `email`
- `password`
- `name`
- `language`
- flags de aceptacion legal

Despues inicia sesion, envia email de verificacion y cierra sesion si el correo aun no esta verificado. El frontend valida `@uab.cat` y NIU de 7 digitos antes de llamar al backend.

### Realtime Database

La app consume RTDB en tiempo real para:

- `/posts`: feed de objetos por `center_id`, filtrado localmente por `status == active`, `is_deleted == false`, categoria y busqueda textual.
- `/chats` y `/user_chats`: listado de chats y metadatos desnormalizados.
- `/messages/{chatId}`: mensajes del chat.
- `/users/{uid}/notifications`: campana, bandeja y marcado de lectura.
- `/users/{uid}/settings`: preferencias sincronizadas.

### Cloud Functions

Callables usadas por el cliente:

| Funcion | Uso en frontend |
| :--- | :--- |
| `secureUniversityRegistration` | Alta segura de usuarios institucionales. |
| `checkPotentialMatches` | Sugerencias antes de publicar un objeto. |
| `recordPostView` | Registro de visualizacion al abrir detalle de un post ajeno. |
| `getOrCreateChat` | Crear o recuperar chat con el propietario de un post. |
| `saveFcmToken` | Registrar token FCM del dispositivo. |

La publicacion actual se finaliza desde `FoundFormScreen` escribiendo en `/posts` tras pasar la comprobacion de matches y la validacion local de ubicacion. El backend mantiene triggers sobre `/posts` para validar geovallado, indexar activos, traducir y notificar matches.

### Storage e imagenes

Las fotos de posts se procesan en cliente mediante `ImageUtils` y `flutter_image_compress`, se suben como WebP a `posts/{postId}/{uid}_{timestamp}.webp` y se guardan en el post como `imageUrl` / `postImageUrl`.

El cliente renderiza imagenes con `CachedNetworkImage` y `CustomCacheManager`, que mantiene hasta 200 objetos durante 7 dias.

## Feed, publicacion y geovallado

`HomePage` carga el centro del usuario desde `/users/{uid}/center_id`, escucha posts del centro y ordena por `created_at` descendente.

`FoundFormScreen` permite dos formas de ubicacion:

- GPS actual con `Geolocator`.
- Selector manual con `MapPickerPage` y `flutter_map`.

La validacion local prioriza el poligono del centro con ray-casting (`LocationService.isPointInPolygon`) y usa radio como fallback. Si no hay ubicacion seleccionada, se usa el centroide de los bounds del centro.

## Chats y notificaciones

`MainNavigationPage` inicializa FCM con `AppNotifications.initFCM` al entrar en la navegacion principal. El flujo:

1. Pide permiso de notificaciones.
2. Obtiene token FCM.
3. Llama a `saveFcmToken`.
4. Escucha mensajes foreground.
5. Navega a chat o post cuando una notificacion se abre desde background o terminated.

La bandeja `NotificationsPage` escucha `/users/{uid}/notifications`, muestra solo no leidas y escribe `read = true` para marcar una o varias como leidas.

## Navegacion principal

`MainNavigationPage` mantiene tres secciones:

- Chats
- Home
- Perfil

El FAB central vuelve a Home si el usuario esta en otra pestana, o abre un bottom sheet para publicar objeto perdido/encontrado si ya esta en Home.
