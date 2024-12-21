import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position?> fetchCurrentLocation() async {
    try {
      // Check if location services are enabled
      if (!(await Geolocator.isLocationServiceEnabled())) {
        throw Exception('Location services are disabled.');
      }

      // Request location permissions
      final LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final LocationPermission requestedPermission =
            await Geolocator.requestPermission();

        if (requestedPermission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }

        if (requestedPermission == LocationPermission.deniedForever) {
          throw Exception(
            'Location permissions are permanently denied. Please enable them in settings.',
          );
        }
      } else if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permissions are permanently denied. Please enable them in settings.',
        );
      }

      // Fetch the current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      return position;
    } catch (e) {
      throw Exception('Failed to get location: ${e.toString()}');
    }
  }
}
