import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unilost_found/core/services/permission_service.dart';

class ImageUtils {
  static String? postImageUrlFrom(Map<dynamic, dynamic> post) {
    const imageKeys = [
      'postImageUrl',
      'post_image_url',
      'imageUrl',
      'photo_url',
      'photoUrl',
    ];

    for (final key in imageKeys) {
      final value = post[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }

    return null;
  }

  /// Retorna la URL de la miniatura de la imagen del post si existe,
  /// o genera una a partir de la URL de la imagen principal.
  static String? postThumbnailUrlFrom(Map<dynamic, dynamic> post) {
    const thumbKeys = [
      'thumbnailUrl',
      'thumbnail_url',
      'postThumbnailUrl',
      'post_thumbnail_url',
      'thumbUrl',
      'thumb_url',
    ];

    for (final key in thumbKeys) {
      final value = post[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }

    final imageUrl = postImageUrlFrom(post);
    if (imageUrl != null) {
      final queryIndex = imageUrl.indexOf('?');
      final pathPart = queryIndex == -1 ? imageUrl : imageUrl.substring(0, queryIndex);
      if (pathPart.endsWith('.webp')) {
        final prefix = pathPart.substring(0, pathPart.length - 5);
        final suffix = queryIndex == -1 ? '' : imageUrl.substring(queryIndex);
        return '${prefix}_200x200.webp$suffix';
      }
    }

    return null;
  }

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
