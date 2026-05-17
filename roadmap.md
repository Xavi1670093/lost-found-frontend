# Roadmap de Mantenimiento y Documentación: Frontend (Flutter)

Este documento contiene las instrucciones detalladas para el agente de IA encargado de refactorizar los comentarios y actualizar la documentación del repositorio Frontend.

**REGLA DE ORO:** Todos los comentarios y documentación generada deben estar estrictamente en Castellano. Ningún cambio debe alterar el árbol de widgets, la gestión del estado, la navegación o la integración con Firebase. La experiencia de usuario, el rendimiento y el soporte para los 3 idiomas deben permanecer intactos.

## Fase 1: Limpieza y Optimización de Comentarios en el Código

**Objetivo:** Mejorar la legibilidad del código Dart y asegurar el uso correcto de `///` para la documentación de la API interna.

* **Paso 1.1: Limpieza de la estructura `lib/`**
    * Inspeccionar los directorios principales (`core`, `features`, `shared`).
    * Eliminar comentarios autogenerados por Flutter que ya no aporten valor.
    * Eliminar código comentado y bloques de pruebas manuales olvidados en los archivos UI o controladores.
* **Paso 1.2: Documentación de Widgets y Controladores**
    * Añadir comentarios DartDoc (`///`) a todas las clases de Widgets personalizados en `lib/shared/widgets/` (ej. `custom_button.dart`, `custom_card.dart`), especificando qué propiedades reciben y su propósito en la UI.
    * Documentar la lógica de estado y controladores en `lib/features/` (ej. Auth, Home, Profile, Chats). Explicar brevemente el ciclo de vida de los datos desde Firebase hasta la vista.
* **Paso 1.3: Documentación de Internacionalización y Core**
    * Analizar `lib/core/localization/app_strings.dart` (o el sistema de l10n utilizado). Comentar claramente cómo se deben añadir nuevas claves para soportar correctamente los 3 idiomas de la aplicación.
    * Documentar los servicios base en `lib/core/services/` (ej. `location_service.dart`, `permission_service.dart`, `error_handler.dart`) detallando los flujos de permisos y el manejo de excepciones de hardware o red.
* **Paso 1.4: Validación Linter**
    * Tras modificar los comentarios, ejecutar `flutter analyze` para asegurar que no se han introducido errores de sintaxis y que la estructura del código cumple con las normativas estándar de Dart.

## Fase 2: Actualización de la Documentación Oficial

**Objetivo:** Proporcionar una visión clara del estado del frontend para futuros desarrollos y mantenimiento.

* **Paso 2.1: Actualización de la Arquitectura UI/UX**
    * Revisar y actualizar `docs/architecture.md`. Definir claramente el patrón de diseño utilizado (ej. Clean Architecture, MVC, MVVM) basándose en la separación actual de carpetas (`core`, `features`, `shared`).
    * Explicar la inyección de dependencias y el gestor de estado (Provider, Riverpod, BLoC, GetX, etc.) detectado en la capa de presentación.
* **Paso 2.2: Documentación del UI Kit**
    * Actualizar `docs/ui_kit.md`. Listar todos los componentes reutilizables encontrados en `lib/shared/widgets/`, describiendo su uso, variaciones de diseño (temas claros/oscuros definidos en `lib/core/theme/app_theme.dart`) y comportamiento responsivo.
* **Paso 2.3: Mapeo de Funcionalidades y Firebase**
    * Redactar un nuevo apartado en la documentación que relacione cada vista principal (ej. `home_page.dart`, `chat_detail_page.dart`) con los servicios de Firebase consumidos (Firestore, Auth, Storage, Cloud Messaging).
* **Paso 2.4: Revisión del `README.md`**
    * Actualizar el `README.md` con las dependencias clave actualizadas (`pubspec.yaml`), los comandos exactos para ejecutar la aplicación en los distintos entornos (Android, iOS, Web) y las instrucciones para compilar versiones de lanzamiento.