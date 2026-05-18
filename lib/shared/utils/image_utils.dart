import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageUtils {
  /// Reescalar imagen a un max de 1080px en cualquier dimensión (manteniendo aspect ratio)
  /// y convertirla a formato WebP.
  static Future<File?> compressAndGetWebp(File file) async {
    final tempDir = Directory.systemTemp;
    final targetPath = '${tempDir.path}/img_${DateTime.now().microsecondsSinceEpoch}.webp';

    try {
      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        format: CompressFormat.webp,
        minWidth: 1080,
        minHeight: 1080,
        quality: 80,
      );

      if (result != null) {
        debugPrint('ULF_DEBUG: Imagen comprimida con éxito. Ruta: ${result.path}');
        return File(result.path);
      }
    } catch (e) {
      debugPrint('ULF_DEBUG: Error al comprimir imagen: $e');
    }
    return null;
  }
}
