import 'package:permission_handler/permission_handler.dart';

/// [PermissionService] centraliza la solicitud y verificación de permisos sensibles del sistema operativo.
///
/// Abstrae la comunicación con el subsistema nativo (iOS y Android) a través de `permission_handler`
/// para garantizar el correcto funcionamiento de características de hardware como la cámara o el GPS.
class PermissionService {
  /// Solicita acceso al hardware de la cámara del dispositivo móvil.
  /// Retorna `true` si el estudiante otorga el permiso de uso.
  static Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Solicita permisos para acceder a los servicios de geolocalización fina/coherente del dispositivo.
  /// Retorna `true` si el estudiante otorga el permiso de uso.
  static Future<bool> requestLocation() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// Solicita permisos para recibir notificaciones push en el dispositivo.
  /// Retorna `true` si el estudiante otorga el permiso de uso.
  static Future<bool> requestNotification() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }
}