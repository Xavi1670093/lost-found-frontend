## Tareas Pendientes (Ejecución para Agente IA)

### 1. Corrección Visual: Solapamiento del Search Bar en el Feed
**Objetivo:** Evitar que la barra de búsqueda se superponga incorrectamente con el título "UniLost & Found" al hacer scroll en la página principal.
* **Archivo principal a modificar:** `lib/features/home/presentation/pages/home_page.dart`.
* **Instrucciones:**
  1. Analizar el árbol de widgets actual (SliverAppBar, CustomScrollView, Stack o SafeArea).
  2. Si se usa un `SliverAppBar`, ajustar los parámetros `pinned`, `floating` y los márgenes (`bottom` property) para asegurar que el título y la barra de búsqueda tengan un espacio reservado estricto.
  3. Si se usa un `Stack`, añadir un contenedor con un `Color` de fondo sólido (con la opacidad correcta o `BackdropFilter`) detrás de la barra de búsqueda para ocultar el texto que pasa por debajo, o sincronizar el `ScrollController` para que el título desaparezca de forma elegante (fade out).
  4. Probar el scroll hacia arriba y hacia abajo en emuladores de diferentes tamaños (pantalla pequeña y grande).

### 2. Mejora UI en Chats: Imagen del Producto y Cabecera de Usuario
**Objetivo:** Añadir contexto visual al chat mostrando de qué producto se habla y con quién.
* **Archivos principales a modificar:** `lib/features/chats/presentation/pages/chats_page.dart` (lista) y `lib/features/chats/presentation/pages/chat_detail_page.dart` (detalle).
* **Instrucciones:**
  1. **En la vista de Lista (`chats_page.dart`):** Consumir el campo `postImageUrl` (inyectado por el backend) y mostrar un pequeño thumbnail (Avatar o contenedor redondeado) al lado de la información del chat, usando el componente global `SkeletonLoader` mientras carga.
  2. **En la vista de Detalle (`chat_detail_page.dart`):** Modificar el `AppBar`. En la propiedad `title` o `leading`, implementar un `Row` que contenga un `CircleAvatar` en miniatura con la foto de perfil del otro usuario, seguido de su nombre.
  3. Asegurarse de manejar los casos nulos (usuario sin foto) usando un icono por defecto.

### 3. Modificación Formulario: Etiqueta "(Recomendable)" en Fotos
**Objetivo:** Incitar al usuario a subir fotos sin hacerlo estrictamente obligatorio.
* **Archivos principales a modificar:** `lib/features/home/presentation/pages/found_form_screen.dart` (y equivalentes de posts) y `lib/core/localization/app_strings.dart` (o los archivos `.arb` correspondientes).
* **Instrucciones:**
  1. Crear una nueva clave de traducción para "(Recomendable)". **Obligatorio:** Proveer la traducción en los 3 idiomas de la app (Ej: Español: "(Recomendable)", Inglés: "(Recommended)", Catalán: "(Recomanable)").
  2. En el widget selector de imágenes del formulario, añadir un widget `Text` al lado o debajo del título de la sección que lea esta nueva clave usando el sistema de localización de la app. Usar un color secundario o un estilo de fuente ligeramente más pequeño para no saturar la UI.

### 4. Corrección de Internacionalización: "Conversación Iniciada"
**Objetivo:** Que el texto por defecto de un chat nuevo se muestre en el idioma del dispositivo.
* **Archivos principales a modificar:** `lib/features/chats/presentation/pages/chats_page.dart` y archivos de localización (`app_strings.dart` / `.arb`).
* **Instrucciones:**
  1. Añadir las claves de traducción para el inicio de chat en los 3 idiomas (Ej: Español: "Conversación iniciada", Inglés: "Chat started", Catalán: "Conversa iniciada").
  2. En la lógica donde se pinta el `lastMessage` del chat en la lista, añadir un condicional: Si el valor de `lastMessage` es `"SYSTEM_MSG_CHAT_STARTED"` (o si está vacío/nulo en un chat sin mensajes), renderizar la clave de traducción correspondiente.
  3. Si el mensaje es cualquier otro texto, renderizar el texto tal cual.