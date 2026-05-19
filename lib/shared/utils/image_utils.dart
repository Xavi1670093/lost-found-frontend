import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unilost_found/core/services/permission_service.dart';

class ImageUtils {
  /// Selecciona una imagen desde la cámara o galería, verifica permisos de cámara
  /// si es necesario, y la procesa a WebP con reescalado.
  static Future<File?> pickAndProcessImage({
    required ImageSource source,
    int imageQuality = 80,
  }) async {
    if (source == ImageSource.camera) {
      final hasPermission = await PermissionService.requestCamera();
      if (!hasPermission) return null;
    }

    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: imageQuality,
      );

      if (pickedFile == null) return null;

      final file = File(pickedFile.path);
      return await compressAndGetWebp(file);
    } catch (e) {
      debugPrint('ULF_DEBUG: Error al seleccionar/procesar la imagen: $e');
      return null;
    }
  }

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
