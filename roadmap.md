# 🗺️ Roadmap de Rediseño UI/UX y Mejoras Core (Frontend - Flutter)

Este roadmap detalla los pasos para modernizar la interfaz de la aplicación, haciéndola más intuitiva, accesible en múltiples idiomas y amigable en el manejo de errores, sin alterar la lógica de negocio base de Firebase.

## FASE 1: Sistema de Diseño, Internacionalización y Fundamentos (Core)
El objetivo es estandarizar la apariencia y la base idiomática para que la app se sienta cohesiva y global.

- [ ] **Internacionalización (i18n) (`lib/core/localization/`)**
  - **Acción:** Implementar soporte completo para 3 idiomas: **Español (idioma por defecto), Inglés y Catalán**.
  - **Detalle:** Migrar absolutamente todos los textos, botones, alertas y descripciones a un sistema de traducción (ej. `flutter_localizations` con archivos `.arb` o mapas de `app_strings.dart`).
- [ ] **Diseño Intuitivo: Paleta y Tipografía (`lib/core/theme/app_theme.dart`)**
  - **Acción:** Transicionar a Material 3 (M3). Diseñar una interfaz visualmente intuitiva utilizando la psicología del color (ej. colores vivos como verde/azul para éxito o "Encontrado", rojo/naranja para peligro, error o "Perdido").
  - **Tipografía e Iconos:** Usar tipografía legible y moderna (ej. Poppins o Inter) y una familia de iconos clara donde la acción se entienda casi sin leer.
- [ ] **Componentes Globales (`lib/shared/widgets/`)**
  - **Acción:** Crear botones, tarjetas y contenedores con un estilo moderno (bordes redondeados, sombras suaves).

## FASE 2: Navegación Principal
Hacer que moverse por la aplicación sea un proceso natural y jerárquico.

- [ ] **Rediseño de la Barra de Navegación (`lib/shared/widgets/main_navigation_page.dart`)**
  - **Acción:** Reemplazar la barra de navegación inferior clásica por un diseño más moderno e intuitivo.
  - **Botón Home Destacado:** Transformar el botón de "Home" (o la acción principal) en el elemento más llamativo de la barra. Utilizar un botón más grande, flotante y centrado (ej. un `FloatingActionButton` anclado a un `BottomAppBar` con muesca curva) para que el usuario siempre sepa cómo volver al inicio.
  - **i18n y UX:** Etiquetas en los 3 idiomas e iconos que cambien de estado (delineado cuando está inactivo, relleno/coloreado cuando está activo).

## FASE 3: Formularios, Autenticación y Prevención de Errores
Guiar al usuario en la introducción de datos y no dejarlo a ciegas cuando algo falla.

- [ ] **Formularios Intuitivos y Ejemplos (`lib/shared/widgets/custom_text_field.dart`)**
  - **Acción:** Añadir un texto de ayuda/ejemplo (`hintText` / placeholder) en todos y cada uno de los campos a rellenar de la app (registro, creación de posts, perfil).
  - **i18n:** Los ejemplos deben estar traducidos para ayudar al usuario a entender el formato deseado en su propio idioma (ej. *Ej: mochila azul con pines... / Ex: blue backpack with pins...*).
- [ ] **Manejo Exhaustivo de Errores de Cliente (`lib/features/auth/` y `core`)**
  - **Acción:** Interceptar las excepciones del Backend/Firebase y mapearlas a mensajes útiles.
  - **Detalle:** Añadir los casos faltantes (ej. *credencial incorrecta al iniciar sesión, correo en uso, contraseña débil, pérdida de conexión*).
  - **Formato y Traducción:** Nunca mostrar errores en crudo (ej. evitar "auth/wrong-password"). Mostrar un mensaje con formato correcto, semántico y traducido al Español, Inglés o Catalán según corresponda.

## FASE 4: Rediseño de Pantallas (Features)
Actualizar el resto de vistas aplicando los componentes y el sistema de idiomas.

- [ ] **Feed Principal y Detalles (`lib/features/home/`)**
  - **Acción:** Rediseñar la lista de objetos usando formato de tarjetas grandes e intuitivas, con *Badges* de estado ("Perdido"/"Encontrado") usando los colores definidos en la Fase 1.
- [ ] **Chats y Perfil (`lib/features/chats/`, `lib/features/profile/`)**
  - **Acción:** Modernizar burbujas de chat, avatares y la información del perfil. Asegurar que los estados vacíos (ej. "Aún no tienes chats") sean visualmente agradables, con un icono de ayuda y en el idioma correcto.

## FASE 5: Microinteracciones y Estado (Polishing)
Los pequeños detalles de feedback para cerrar la experiencia UX.

- [ ] **Feedback de Acciones (Snackbars & Diálogos)**
  - **Acción:** Crear un componente unificado para alertas. 
  - **Formato Correcto:** Los mensajes de éxito, advertencia o error que saltan en pantalla deben tener un formato amigable: un icono representativo a la izquierda, borde redondeado, color representativo (verde, rojo, amarillo) y texto completamente traducido.
- [ ] **Estados de Carga (Loading)**
  - **Acción:** Implementar efectos de carga amigables (ej. *Shimmer effect*) para evitar bloqueos visuales mientras cargan las imágenes o las peticiones de red.