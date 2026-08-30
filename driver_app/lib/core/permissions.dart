import 'package:permission_handler/permission_handler.dart';

class AppPermissions {
  AppPermissions._();

  static Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> requestLocation() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }
}