import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationResult {
  final bool isSuccess;
  final Position? position;
  final String? message;
  final bool isServiceDisabled;
  final bool isPermissionPermanentlyDenied;

  const LocationResult({
    required this.isSuccess,
    this.position,
    this.message,
    this.isServiceDisabled = false,
    this.isPermissionPermanentlyDenied = false,
  });

  factory LocationResult.success(Position position) => LocationResult(
        isSuccess: true,
        position: position,
      );

  factory LocationResult.failure(
    String message, {
    bool isServiceDisabled = false,
    bool isPermissionPermanentlyDenied = false,
  }) =>
      LocationResult(
        isSuccess: false,
        message: message,
        isServiceDisabled: isServiceDisabled,
        isPermissionPermanentlyDenied: isPermissionPermanentlyDenied,
      );
}

class LocationService {
  const LocationService();

  /// Checks whether GPS / Location service is enabled on the device.
  Future<bool> isServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Checks current location permission.
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Requests location permission.
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Verifies permissions & enables location, then returns the current position.
  Future<LocationResult> getCurrentLocation() async {
    try {
      final serviceEnabled = await isServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult.failure(
          'Location services are disabled. Please enable GPS on your device.',
          isServiceDisabled: true,
        );
      }

      var permission = await checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationResult.failure('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationResult.failure(
          'Location permissions are permanently denied. Please enable them in app settings.',
          isPermissionPermanentlyDenied: true,
        );
      }

      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      );

      final position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      return LocationResult.success(position);
    } catch (e) {
      debugPrint('Error getting location: $e');
      return LocationResult.failure('Failed to get location: $e');
    }
  }

  /// Streams real-time position updates.
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 5,
  }) {
    final locationSettings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// Opens the device settings to enable location services.
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Opens app-specific system settings for permissions.
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }
}
