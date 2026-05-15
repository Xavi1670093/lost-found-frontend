## Correcciones de Emergencia: Fallo en Selección de Ubicación y Ajustes del Mapa

Las siguientes tareas deben ser abordadas de inmediato para solucionar un cierre inesperado (`Crash`) al intentar abrir el selector de mapas y para mejorar la experiencia de navegación geográfica. El agente debe mantener el código seguro (Null-Safety) y asegurar el funcionamiento en los 3 idiomas.

### 1. Corregir `NoSuchMethodError` en `_openMapPicker` (Formulario de Publicación)
**Objetivo:** Solucionar el error `The method '+' was called on null` detectado en la línea 152 de `lib/features/home/presentation/pages/found_form_screen.dart`, que impide abrir el mapa.
* **Archivos implicados:** `lib/features/home/presentation/pages/found_form_screen.dart`.
* **Instrucciones:**
  1. Localizar la función `_openMapPicker` alrededor de la línea 152.
  2. Identificar la variable que está siendo operada con el símbolo `+` (probablemente el cálculo de límites geográficos `bounds` o el `offset` utilizando la ubicación del centro/universidad).
  3. Implementar comprobaciones de nulidad (`null checks`). Si las coordenadas del centro no están disponibles en el estado actual, mostrar un `SnackBar` de error ("No se pudo cargar la ubicación del centro", traducido a ES, CA, EN) y abortar la apertura del mapa en lugar de procesar la suma.
  4. Proveer coordenadas de respaldo (fallback) seguras por si la ubicación inicial es nula, asegurando que `LatLng` nunca reciba valores nulos.

### 2. Ampliar los Límites de Paneo del Mapa Principal y Selector
**Objetivo:** Permitir al usuario explorar un área más amplia alrededor del centro en todos los mapas interactivos de la aplicación.
* **Archivos implicados:** `lib/shared/widgets/map_picker_page.dart` y el widget del mapa principal (ej. `lib/features/home/presentation/pages/home_page.dart` o componentes equivalentes).
* **Instrucciones:**
  1. Localizar la propiedad `cameraTargetBounds` en el widget `GoogleMap` (o el paquete de mapas correspondiente).
  2. Modificar el cálculo del `LatLngBounds` sumando un `offset` mayor (por ejemplo, incrementar en `0.01` o `0.02` grados tanto a la latitud como a la longitud) para generar un cuadro delimitador más ancho.
  3. Asegurar de nuevo que los cálculos matemáticos para los límites suroeste (`southwest`) y noreste (`northeast`) manejen variables no nulas.
  4. Comprobar que al compilar, el usuario pueda arrastrar el mapa hacia las calles adyacentes a la universidad sin ser bloqueado abruptamente.

### 3. Reparar Lógica de Validación GPS en Tiempo Real
**Objetivo:** Garantizar que la validación de ubicación actual funcione correctamente, deteniendo la publicación si el usuario está fuera de la universidad.
* **Archivos implicados:** `lib/features/home/presentation/pages/found_form_screen.dart`, `lib/core/services/location_service.dart`.
* **Instrucciones:**
  1. Revisar la función vinculada al botón "Usar ubicación actual" en el formulario.
  2. Envolver la llamada al GPS en un bloque `try-catch`. 
  3. Calcular la distancia usando una función de Haversine local segura.
  4. Si la distancia es mayor al radio permitido (ej. 1.5 km), lanzar una alerta visual inmediata (Diálogo o Snackbar) usando la clave de traducción existente para el error de "Ubicación fuera de rango".
  5. Evitar que las coordenadas fuera de rango sobreescriban el estado de la ubicación seleccionada.

### 4. Restaurar Selección Manual de Marcador en el Mapa
**Objetivo:** Permitir que el toque del usuario en el mapa actualice el marcador visual.
* **Archivos implicados:** `lib/shared/widgets/map_picker_page.dart`.
* **Instrucciones:**
  1. Verificar que el parámetro `onTap` del mapa está asignado a un método que actualice el estado.
  2. Confirmar que dentro del `onTap(LatLng coord)`, se ejecuta `setState(() { selectedLocation = coord; })`.
  3. Asegurarse de que la capa de marcadores (`Set<Marker>`) se esté redibujando con un marcador cuya posición sea `selectedLocation`.