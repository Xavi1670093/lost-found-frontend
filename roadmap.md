# Roadmap de Frontend (Flutter)

Este documento detalla las tareas atómicas a ejecutar por el agente de IA para solucionar los bugs y añadir las nuevas funcionalidades requeridas en la aplicación Flutter.

## 1. Cierre de Sesión Seguro (Local) y Persistencia
* **Objetivo**: Asegurar que el cierre de sesión borre la persistencia en el dispositivo actual sin afectar a otros dispositivos, y permitir que la sesión dure hasta 10 días por defecto.
* **Archivos implicados**: Controladores de autenticación (`lib/features/auth/presentation/...` o capa de dominio/aplicación).
* **Instrucciones**:
    1. En la inicialización de Firebase, configurar la persistencia de sesión a local (`browserLocalPersistence` si hay soporte web) para que el token se renueve y mantenga al usuario logueado al cerrar y abrir la app.
    2. Al ejecutar el método de logout, llamar a `await FirebaseAuth.instance.signOut();` para eliminar el token exclusivamente en el dispositivo actual.
    3. Borrar cualquier almacenamiento local asociado (ej. limpiar caché de usuario con `SharedPreferences` o `SecureStorage`).
    4. Limpiar el estado global de los controladores (Riverpod, Bloc, o Provider) para que no queden datos residuales.
    5. Redirigir al usuario forzosamente a la pantalla de Login limpiando el historial de navegación (`pushAndRemoveUntil`).

## 2. Buscador de Inicio: Botón Limpiar y Persistencia al Scroll
* **Objetivo**: Mejorar la experiencia de usuario con la barra de búsqueda en el Home.
* **Archivos implicados**: `lib/features/home/presentation/pages/home_page.dart`.
* **Instrucciones**:
    1. Añadir un botón condicional en el `TextField` de búsqueda: `suffixIcon: IconButton(icon: Icon(Icons.clear), onPressed: () => searchController.clear())`. Al limpiarlo, se debe actualizar el estado para mostrar la lista completa de objetos.
    2. Evitar que el texto se borre al hacer scroll manteniendo el `TextEditingController` como variable de estado de la clase (o en el gestor de estado) e instanciándolo solo en el `initState`.
    3. Para que la barra se mantenga visible al bajar, extraer el `TextField` fuera de la lista scrolleable (ej. en un `Column` estático arriba del `Expanded/ListView`) o usar un `SliverAppBar` con `floating: true` y `pinned: true`.

## 3. Ampliación de Categorías e Iconos por Defecto
* **Objetivo**: Añadir las nuevas categorías con soporte para los 3 idiomas y configurar iconos por defecto.
* **Archivos implicados**: `lib/core/localization/app_strings.dart` (o archivos `.arb`), modelos de datos, widgets de tarjeta como `lib/shared/widgets/custom_card.dart`.
* **Instrucciones**:
    1. Añadir las categorías: `["accessories", "clothes", "devices", "wallets", "keys", "bags", "study", "others"]`.
    2. Configurar las traducciones de estas 8 categorías para los 3 idiomas de la app en los archivos de internacionalización.
    3. Crear un método o mapa de constantes que asocie un `IconData` específico a cada categoría de la nueva lista.
    4. En las tarjetas de la lista, implementar lógica de fallback: si la publicación no tiene imagen (`imageUrl` es null o vacío), renderizar un contenedor destacando el icono asociado a su categoría.

## 4. Mejoras de Interfaz: Formato del Mapa y Textos "(Opcionales)"
* **Objetivo**: Estilizar el mapa y clarificar los formularios.
* **Archivos implicados**: `lib/features/home/presentation/pages/home_page.dart`, `lib/features/home/presentation/pages/found_form_screen.dart`, `lib/shared/widgets/custom_text_field.dart`.
* **Instrucciones**:
    1. Aumentar el `height` del contenedor que envuelve el mapa inicial en la vista de Home para proporcionar un formato más agradable visualmente.
    2. Modificar el texto del `label` o `hintText` en los campos no obligatorios de los formularios para agregar el string "(Opcional)", asegurando usar la traducción correspondiente.

## 5. Edición de Texto en Campos (Solución de Cursor)
* **Objetivo**: Solucionar el problema que obliga al usuario a borrar texto para editar palabras intermedias.
* **Archivos implicados**: Formularios o `lib/shared/widgets/custom_text_field.dart`.
* **Instrucciones**:
    1. Revisar dónde se instancia el `TextEditingController` del input afectado.
    2. Asegurarse de que el controlador no se esté recreando dentro del método `build()`. Debe declararse, inicializarse en `initState` y liberarse en `dispose()`.
    3. Verificar que no se estén perdiendo o recreando las `Key` de los widgets padres de forma innecesaria, lo que provoca la pérdida del foco y el reseteo del cursor al final del texto.

## 6. Filtrado de Pines en el Mapa
* **Objetivo**: Que los marcadores del mapa reflejen la búsqueda de texto y/o filtro de categoría activos.
* **Archivos implicados**: `lib/features/home/presentation/pages/home_page.dart`.
* **Instrucciones**:
    1. El `Set<Marker>` usado por el mapa debe generarse iterando sobre la **lista filtrada** de publicaciones, no sobre la lista total.
    2. Cada vez que cambie el valor del buscador de texto o la categoría seleccionada, regenerar los marcadores.
    3. Refrescar la vista del mapa para que los pines visibles cambien dinámicamente según lo que ve el usuario en la lista principal.

## 7. Solución: Subida de Fotos y Guardado en Base de Datos
* **Objetivo**: Permitir adjuntar y visualizar imágenes en las publicaciones, vinculando el almacenamiento con la base de datos.
* **Archivos implicados**: `lib/features/home/presentation/pages/found_form_screen.dart`, capa de repositorio (Firestore y Storage).
* **Instrucciones**:
    1. Utilizar `image_picker` para seleccionar la imagen localmente.
    2. Subir el archivo a `FirebaseStorage` en la ruta correspondiente (ej. `posts/{userId}_{timestamp}.jpg`).
    3. Mostrar un indicador de carga mientras se espera el `await uploadTask`.
    4. Obtener la URL pública usando `getDownloadURL()` tras la subida exitosa.
    5. Incluir esta URL en el mapa de datos que se enviará a Firestore (`imageUrl` o `images: []`) al momento de crear el documento de la publicación.