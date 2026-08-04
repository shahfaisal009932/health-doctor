import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  PermissionHelper._();

  /// Request Camera Permission
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      return true;
    }
    return false;
  }

  /// Request Microphone Permission
  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      return true;
    }
    return false;
  }

  /// Request Camera + Microphone
  static Future<bool> requestVideoCallPermissions() async {
    final permissions = await [
      Permission.camera,
      Permission.microphone,
    ].request();
    final camera = permissions[Permission.camera];
    final microphone = permissions[Permission.microphone];
    return camera?.isGranted == true && microphone?.isGranted == true;
  }

  /// Notification Permission
  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Storage Permission
  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  /// Open App Settings
  static Future<void> openSettings() async {
    await openAppSettings();
  }

  /// Check Camera Permission
  static Future<bool> isCameraGranted() async {
    return await Permission.camera.isGranted;
  }

  /// Check Microphone Permission
  static Future<bool> isMicrophoneGranted() async {
    return await Permission.microphone.isGranted;
  }
}
