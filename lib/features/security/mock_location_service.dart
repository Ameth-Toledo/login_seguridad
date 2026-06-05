import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class MockLocationService {
  static Future<bool> isFakeGpsInstalled() async {
    final status = await Permission.location.request();
    if (status.isDenied || status.isPermanentlyDenied) return false;

    try {
      // Solicita una ubicación FRESCA (no caché) y verifica si es simulada
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      ).timeout(const Duration(seconds: 5));

      return position.isMocked;
    } catch (_) {
      return false;
    }
  }
}
