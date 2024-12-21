import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Request a specific permission and return its status.
  Future<PermissionStatus> requestPermission(Permission permission) async {
    final status = await permission.request();
    _handlePermissionResult(permission, status);
    return status;
  }

  // Request multiple permissions at once.
  Future<Map<Permission, PermissionStatus>> requestMultiplePermissions(
      List<Permission> permissions) async {
    final statuses = await permissions.request();
    statuses.forEach(_handlePermissionResult);
    return statuses;
  }

  // Check if a permission is granted.
  Future<bool> isPermissionGranted(Permission permission) async {
    return await permission.isGranted;
  }

  // Handle different permission results and provide appropriate responses.
  void _handlePermissionResult(Permission permission, PermissionStatus status) {
    switch (status) {
      case PermissionStatus.permanentlyDenied:
        openAppSettings(); // Redirect to settings if permission is permanently denied.
        break;
      case PermissionStatus.restricted:
        print('Permission restricted for $permission.');
        break;
      case PermissionStatus.limited:
        print('Limited permission for $permission.');
        break;
      case PermissionStatus.denied:
        print('Permission denied for $permission.');
        break;
      case PermissionStatus.granted:
        print('Permission granted for $permission.');
        break;
      case PermissionStatus.provisional:
        print('Provisional permission granted for $permission.');
        break;
      default:
        print('Unexpected status: $status for $permission.');
    }
  }

  // Check if location services are enabled.
  Future<bool> isLocationServiceEnabled() async {
    final isEnabled = await Permission.locationWhenInUse.isGranted &&
        await Permission.locationWhenInUse.serviceStatus.isEnabled;
    return isEnabled;
  }
}
