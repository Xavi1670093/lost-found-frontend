import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// [CustomCacheManager] es un gestor de caché personalizado encargado de optimizar
/// la descarga, almacenamiento local y entrega de recursos multimedia en la aplicación.
///
/// Configura y controla el almacenamiento en caché de imágenes procedentes de Firebase Storage,
/// definiendo políticas eficientes de caducidad (7 días) y un límite máximo de elementos (200 objetos)
/// para optimizar el rendimiento y minimizar el consumo de datos de red móvil de los estudiantes.
class CustomCacheManager {
  /// Clave identificadora única para la base de datos de la caché local de imágenes.
  static const key = 'unilost_cache';
  
  /// Instancia única y compartida de `CacheManager` configurada con políticas de rendimiento optimizadas.
  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7), // Mantener las imágenes almacenadas por un período máximo de 7 días.
      maxNrOfCacheObjects: 200, // Almacenar en caché hasta un límite de 200 imágenes concurrentes.
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );
}
