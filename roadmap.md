# 🗺️ Roadmap: Auditoría Final, i18n, Errores y Optimización (Fase QA)

Este roadmap está enfocado en pulir los detalles finales de la aplicación, garantizando que cumpla con los estándares de producción en rendimiento, seguridad, y experiencia de usuario (internacionalización y manejo de errores).

## FASE 1: Cobertura Total de Internacionalización (i18n)
El objetivo es que absolutamente ningún texto esté "hardcodeado" en la interfaz.

- [ ] **Auditoría de Widgets de UI:** Rastrear todos los archivos en `lib/features/` y `lib/shared/` para asegurar que todo el texto renderizado provenga de `AppStrings.of(context)`.
- [ ] **Validadores de Formularios:** Traducir los textos de validación (`validator`) en los formularios de Login, Registro y Creación de Posts (ej. "El correo es obligatorio", "La contraseña es muy corta").
- [ ] **Textos de Ayuda (Hints/Placeholders):** Confirmar que cada `CustomTextField` tiene su texto de ejemplo traducido y habilitado (ej. "Ej: llaves de coche...").
- [ ] **Verificación de Diccionarios:** Asegurar que las claves en Español (defecto), Inglés y Catalán sean simétricas (ningún idioma debe tener claves faltantes).

## FASE 2: Estandarización de Errores (Error Handling)
El objetivo es que el usuario nunca vea un error técnico y que siempre reciba instrucciones claras.

- [ ] **Mapeo de Errores de Firebase:** Revisar `lib/core/services/error_handler.dart`. Asegurar la captura de códigos como `user-not-found`, `wrong-password`, `permission-denied`, `network-request-failed`, etc.
- [ ] **Formato "Por favor, ...":** Modificar las traducciones de los errores mapeados para que sigan una estructura formativa y educada. 
  - *Mal:* "Credenciales incorrectas."
  - *Bien:* "Por favor, verifica que tu correo y contraseña sean correctos."
- [ ] **Consistencia Visual:** Asegurar que `AppNotifications` (los Snackbars) use el color semántico correcto (rojo/naranja para errores, verde para éxito) y muestre el mensaje traducido.

## FASE 3: Optimización de Código y Seguridad
El objetivo es mejorar los FPS de la aplicación, evitar fugas de memoria y asegurar la confidencialidad.

- [ ] **Modificadores Const:** Aplicar `const` a todos los constructores y widgets estáticos posibles (paddings, iconos, textos fijos) para evitar que Flutter reconstruya ramas innecesarias del árbol de widgets.
- [ ] **Gestión de Memoria (Dispose):** Auditar los *StatefulWidgets* (especialmente formularios y chats) para asegurar que todos los `TextEditingController`, *FocusNodes* y *Streams* se destruyan correctamente en el método `dispose()`.
- [ ] **Limpieza de Logs:** Reemplazar cualquier función `print()` por `debugPrint()` o `log()` de `dart:developer`. Esto garantiza que información sensible (IDs, correos) no sea visible en la consola de la versión de producción (Release mode).