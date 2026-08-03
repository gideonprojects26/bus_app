import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Call this once, early in the app (e.g. right after splash, before
  // Home loads), to request the key permissions up front rather than
  // waiting for each feature to individually prompt later.
  static Future<void> requestInitialPermissions() async {
    await [
      Permission.location,
      Permission.notification,
      Permission.storage,
      Permission.photos, // covers storage access on newer Android/iOS
    ].request();
  }

  static Future<bool> hasLocationPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  static Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }
}