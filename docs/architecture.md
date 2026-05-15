# Arquitectura del Proyecto - UniLost & Found

Este documento detalla la estructura y decisiones técnicas del frontend de la aplicación móvil UniLost & Found, construida con Flutter y Firebase.

## Estructura de Directorios

El proyecto sigue una arquitectura modular basada en **features** (funcionalidades), lo que permite una escalabilidad limpia y separación de responsabilidades.

```text
lib/
├── core/             # Configuraciones globales y lógica transversal
│   ├── localization/ # Gestión de idiomas (i18n)
│   ├── services/     # Servicios core (Permisos, Errores)
│   ├── settings/     # Controladores de estado global (Tema, Idioma)
│   └── theme/        # Sistema de diseño Material 3
├── features/         # Módulos específicos de la aplicación
│   ├── auth/         # Autenticación (Login/Registro)
│   ├── chats/        # Sistema de mensajería en tiempo real
│   ├── home/         # Feed de objetos y reporte de hallazgos
│   ├── profile/      # Perfil de usuario y gestión de posts propios
│   └── welcome/      # Pantalla de aterrizaje
├── shared/           # Componentes y utilidades reutilizables
│   ├── utils/        # Helpers (Notificaciones, Categorías)
│   └── widgets/      # UI Kit (Botones, Campos de texto, etc.)
└── main.dart         # Punto de entrada de la aplicación
```

## Componentes Core (`lib/core/`)

| Componente | Propósito |
| :--- | :--- |
| `app_settings_controller.dart` | Gestiona el estado persistente de la aplicación (Modo oscuro, idioma actual). |
| `app_strings.dart` | Implementa el sistema de internacionalización para ES, EN y CA sin dependencias externas. |
| `permission_service.dart` | Abstracción para la solicitud y verificación de permisos (Cámara, Ubicación). |
| `error_handler.dart` | Centraliza el mapeo de errores de Firebase a mensajes legibles para el usuario. |
| `app_theme.dart` | Define la paleta de colores, tipografía (Google Fonts) y estilos de componentes Material 3. |

## Módulos de Funcionalidades (`lib/features/`)

- **Auth**: Gestión de usuarios mediante Firebase Auth, restringido a dominios `@uab.cat`.
- **Home**: Implementa un feed dinámico consumiendo Firebase Realtime Database con soporte para búsqueda y filtrado por categorías. Incluye integración con OpenStreetMap (`flutter_map`).
- **Chats**: Comunicación directa entre usuarios utilizando una estructura de datos optimizada en RTDB.
- **Profile**: Permite al usuario gestionar su información, ver sus publicaciones pasadas y cambiar la configuración de la app.

## Sistema de Diseño

Se utiliza un sistema de diseño premium basado en **Material 3**:
- **Tipografía**: Poppins e Inter (vía Google Fonts).
- **Estética**: Uso de gradientes sutiles, micro-animaciones y glassmorphism en componentes seleccionados.
- **Responsividad**: Widgets diseñados para adaptarse a diferentes tamaños de pantalla evitando *overflows*.
