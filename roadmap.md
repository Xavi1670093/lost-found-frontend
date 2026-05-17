# Roadmap de Corrección Definitiva - Frontend (Flutter)

## 1. Restricción Matemática en Tiempo Real (Cliente)
**Objetivo:** Evitar que el usuario pueda siquiera enviar una coordenada que roce el límite matemático, actuando como la primera barrera defensiva.
* **Archivos objetivo:** `lib/shared/widgets/map_picker_page.dart` (y servicios de ubicación si aplican).
* **Tareas Atómicas:**
    1.  **Fórmula Haversine en Dart:** Implementar una función `calculateDistance(lat1, lon1, lat2, lon2)` en el controlador del mapa usando la fórmula de Haversine (o usar el paquete `geolocator` si ya expone `distanceBetween`).
    2.  **Validación Reactiva:** En el evento `onCameraIdle` (cuando el usuario deja de mover el mapa) o al mover el pin, calcular la distancia exacta entre el centro del recinto y la posición actual del pin.
    3.  **Bloqueo de UI:** Si la `distanciaCalculada` es mayor que el `radio` del centro (sin tolerancia extra aquí), el botón de "Confirmar Ubicación" debe pasar a estado `disabled` (gris). 
    4.  **Feedback Instantáneo:** Mostrar un aviso en pantalla (texto rojo superpuesto al mapa o banner inferior) que diga explícitamente: "El pin está fuera del área permitida del centro." cuando la distancia exceda el radio.