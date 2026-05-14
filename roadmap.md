## Tareas Pendientes: Internacionalización y Documentación (Agente IA)

### 1. Auditoría y Estandarización de Traducciones (i18n)
**Objetivo:** Garantizar que toda la interfaz de usuario de Flutter esté traducida al 100% en los 3 idiomas del proyecto (Español, Inglés y Catalán) de forma segura y sin romper la maquetación.

**Instrucciones Atómicas:**
1. **Escaneo de Textos Huérfanos:** Analizar exhaustivamente todos los archivos dentro de `lib/features/`, `lib/shared/` y `lib/core/` para identificar cualquier cadena de texto en duro (*hardcoded*).
2. **Centralización:** Extraer todos los textos encontrados y añadirlos al sistema de internacionalización actual (específicamente revisando `lib/core/localization/app_strings.dart` u otros archivos de recursos).
3. **Validación de Completitud:** Comparar los mapas de traducciones de los 3 idiomas. Asegurar que por cada clave existente en el idioma base, exista una traducción precisa y gramaticalmente correcta en los otros dos idiomas.
4. **Pruebas de UI (Overflow):** Asegurar que las traducciones no rompan el diseño. Escribir o ejecutar pruebas que verifiquen que los textos más largos (comunes al traducir) se ajusten correctamente en componentes como `custom_button.dart`, `custom_card.dart` y pantallas principales.

### 2. Actualización Integral de la Documentación del Proyecto
**Objetivo:** Reflejar la arquitectura, los componentes y el estado actual de la aplicación Flutter para facilitar el mantenimiento y la integración de nuevos desarrolladores.

**Instrucciones Atómicas:**
1. **Documentación de Arquitectura:** Actualizar el `README.md` (o crear un archivo `docs/architecture.md`) detallando la estructura basada en *features* actual (`auth`, `chats`, `home`, `profile`, `welcome`).
2. **Documentación de Componentes Core:** Redactar un resumen sobre el funcionamiento de la configuración global en `lib/core/` (ej. `app_settings_controller.dart`, `error_handler.dart`, `permission_service.dart` y `app_theme.dart`).
3. **Catálogo de UI Compartida:** Documentar el propósito y los parámetros requeridos de los widgets reutilizables en `lib/shared/widgets/` (botones, tarjetas, campos de texto y loaders).
4. **Guía de Despliegue y Ejecución:** Actualizar las instrucciones del `README.md` con los comandos exactos de Flutter necesarios para ejecutar el proyecto en Android, iOS y Web, así como la configuración inicial de Firebase (`firebase_options.dart`).