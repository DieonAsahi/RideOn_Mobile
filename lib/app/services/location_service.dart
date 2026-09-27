import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Meminta izin lokasi secara proaktif (biasanya saat onboarding / awal aplikasi)
  static Future<LocationPermission> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  /// Memeriksa status izin lokasi
  static Future<bool> isLocationPermissionGranted() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Memeriksa apakah GPS / service lokasi di perangkat aktif
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Membuka pengaturan aplikasi untuk izin lokasi
  static Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Membuka pengaturan GPS perangkat
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Stream status GPS aktif/mati di perangkat
  static Stream<ServiceStatus> getServiceStatusStream() {
    return Geolocator.getServiceStatusStream();
  }
}
