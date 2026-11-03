import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iwitnez/core/services/background_location_service.dart';
import 'package:permission_handler/permission_handler.dart';

/// State model for Live Location Background Tracking.
@immutable
class LocationTrackingState {
  final bool isTracking;
  final double? latitude;
  final double? longitude;
  final double speedKmh;
  final double? accuracy;
  final double? heading;
  final double? altitude;
  final String? error;
  final bool isGpsDisabled;
  final bool isBatteryOptimizationIgnored;
  final DateTime? lastPingTime;

  const LocationTrackingState({
    this.isTracking = false,
    this.latitude,
    this.longitude,
    this.speedKmh = 0.0,
    this.accuracy,
    this.heading,
    this.altitude,
    this.error,
    this.isGpsDisabled = false,
    this.isBatteryOptimizationIgnored = false,
    this.lastPingTime,
  });

  LocationTrackingState copyWith({
    bool? isTracking,
    double? latitude,
    double? longitude,
    double? speedKmh,
    double? accuracy,
    double? heading,
    double? altitude,
    String? error,
    bool? isGpsDisabled,
    bool? isBatteryOptimizationIgnored,
    DateTime? lastPingTime,
  }) {
    return LocationTrackingState(
      isTracking: isTracking ?? this.isTracking,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      speedKmh: speedKmh ?? this.speedKmh,
      accuracy: accuracy ?? this.accuracy,
      heading: heading ?? this.heading,
      altitude: altitude ?? this.altitude,
      error: error,
      isGpsDisabled: isGpsDisabled ?? this.isGpsDisabled,
      isBatteryOptimizationIgnored:
          isBatteryOptimizationIgnored ?? this.isBatteryOptimizationIgnored,
      lastPingTime: lastPingTime ?? this.lastPingTime,
    );
  }
}

/// Provider for managing live location background tracking.
final liveLocationTrackingProvider =
    NotifierProvider<LiveLocationTrackingNotifier, LocationTrackingState>(
  LiveLocationTrackingNotifier.new,
);

class LiveLocationTrackingNotifier extends Notifier<LocationTrackingState> {
  StreamSubscription<Map<String, dynamic>?>? _serviceSubscription;

  @override
  LocationTrackingState build() {
    ref.onDispose(() {
      _serviceSubscription?.cancel();
    });

    // Check initial service state
    Future.microtask(() => checkServiceStatus());

    return const LocationTrackingState();
  }

  /// Checks if background service is already running and binds event listener.
  Future<void> checkServiceStatus() async {
    final isRunning = await BackgroundLocationService.isServiceRunning();
    final isBatteryIgnored =
        await Permission.ignoreBatteryOptimizations.isGranted;
    final isGpsOn = await Geolocator.isLocationServiceEnabled();

    state = state.copyWith(
      isTracking: isRunning,
      isBatteryOptimizationIgnored: isBatteryIgnored,
      isGpsDisabled: !isGpsOn,
    );

    if (isRunning) {
      _bindServiceEvents();
    }
  }

  /// Production-ready start sequence:
  /// 1. Notification permission
  /// 2. Battery optimization ignore permission
  /// 3. Device GPS enabled check
  /// 4. Location permission check & request
  /// 5. Start background service & bind UI events
  Future<bool> startTracking() async {
    state = state.copyWith(error: null);

    // 1. Notification Permission
    final notificationStatus = await Permission.notification.request();
    if (!notificationStatus.isGranted && !notificationStatus.isLimited) {
      state = state.copyWith(
        error: 'Notification permission is required for background live tracking.',
      );
      return false;
    }

    // 2. Request Battery Optimization Exemption (Crucial for Android OS kill-prevention)
    try {
      final batteryStatus =
          await Permission.ignoreBatteryOptimizations.request();
      state = state.copyWith(
        isBatteryOptimizationIgnored: batteryStatus.isGranted,
      );
    } catch (_) {}

    // 3. Device GPS check
    final isGpsEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isGpsEnabled) {
      state = state.copyWith(
        isGpsDisabled: true,
        error: 'Device GPS is turned off. Please enable GPS in device settings.',
      );
      await Geolocator.openLocationSettings();
      return false;
    } else {
      state = state.copyWith(isGpsDisabled: false);
    }

    // 4. Location permissions check (Foreground & Background)
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        state = state.copyWith(
          error: 'Location permission was denied. Cannot start live tracking.',
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      state = state.copyWith(
        error:
            'Location permission is permanently denied. Please enable it in App Settings.',
      );
      await openAppSettings();
      return false;
    }

    // Optional background location check for Android 10+
    try {
      final bgStatus = await Permission.locationAlways.status;
      if (!bgStatus.isGranted) {
        await Permission.locationAlways.request();
      }
    } catch (_) {}

    // 5. Start Background Service
    final started = await BackgroundLocationService.startTracking();
    if (started) {
      state = state.copyWith(isTracking: true, error: null);
      _bindServiceEvents();
      return true;
    } else {
      state = state.copyWith(
        isTracking: false,
        error: 'Failed to start background tracking service.',
      );
      return false;
    }
  }

  /// Stops background tracking cleanly.
  Future<void> stopTracking() async {
    await BackgroundLocationService.stopTracking();
    await _serviceSubscription?.cancel();
    _serviceSubscription = null;
    state = state.copyWith(isTracking: false);
  }

  /// Binds to background isolate 'updateLocation' events.
  void _bindServiceEvents() {
    _serviceSubscription?.cancel();
    final service = FlutterBackgroundService();

    _serviceSubscription = service.on('updateLocation').listen((event) {
      if (event == null) return;

      final lat = (event['latitude'] as num?)?.toDouble();
      final lon = (event['longitude'] as num?)?.toDouble();
      final speedKmh = (event['speed_kmh'] as num?)?.toDouble() ?? 0.0;
      final accuracy = (event['accuracy'] as num?)?.toDouble();
      final heading = (event['heading'] as num?)?.toDouble();
      final altitude = (event['altitude'] as num?)?.toDouble();

      state = state.copyWith(
        isTracking: true,
        latitude: lat ?? state.latitude,
        longitude: lon ?? state.longitude,
        speedKmh: speedKmh,
        accuracy: accuracy ?? state.accuracy,
        heading: heading ?? state.heading,
        altitude: altitude ?? state.altitude,
        lastPingTime: DateTime.now(),
        error: null,
      );
    });
  }

  /// Opens system GPS settings.
  Future<void> openGpsSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Opens app settings for permissions.
  Future<void> openAppSettingsPage() async {
    await openAppSettings();
  }

  /// Requests battery optimization exemption.
  Future<void> requestBatteryExemption() async {
    final status = await Permission.ignoreBatteryOptimizations.request();
    state = state.copyWith(isBatteryOptimizationIgnored: status.isGranted);
  }
}

