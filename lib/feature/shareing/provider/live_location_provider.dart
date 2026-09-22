import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iwitnez/core/services/location_service.dart';

class LiveLocationState {
  final Position? currentPosition;
  final bool isSharing;
  final bool isLoading;
  final String? errorMessage;
  final bool isServiceDisabled;
  final bool isPermissionPermanentlyDenied;

  const LiveLocationState({
    this.currentPosition,
    this.isSharing = false,
    this.isLoading = false,
    this.errorMessage,
    this.isServiceDisabled = false,
    this.isPermissionPermanentlyDenied = false,
  });

  String get formattedCoordinates {
    if (currentPosition == null) return 'Location unavailable';
    final lat = currentPosition!.latitude.toStringAsFixed(5);
    final lng = currentPosition!.longitude.toStringAsFixed(5);
    return 'Lat: $lat, Lng: $lng';
  }

  LiveLocationState copyWith({
    Position? currentPosition,
    bool? isSharing,
    bool? isLoading,
    String? errorMessage,
    bool? isServiceDisabled,
    bool? isPermissionPermanentlyDenied,
    bool clearError = false,
  }) {
    return LiveLocationState(
      currentPosition: currentPosition ?? this.currentPosition,
      isSharing: isSharing ?? this.isSharing,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isServiceDisabled: isServiceDisabled ?? this.isServiceDisabled,
      isPermissionPermanentlyDenied:
          isPermissionPermanentlyDenied ?? this.isPermissionPermanentlyDenied,
    );
  }
}

final locationServiceProvider = Provider<LocationService>((ref) {
  return const LocationService();
});

class LiveLocationNotifier extends Notifier<LiveLocationState> {
  StreamSubscription<Position>? _positionSubscription;

  @override
  LiveLocationState build() {
    ref.onDispose(() {
      _positionSubscription?.cancel();
    });
    return const LiveLocationState();
  }

  LocationService get _locationService => ref.read(locationServiceProvider);

  /// Requests permission, fetches initial location, and begins streaming live position updates.
  Future<bool> startLiveLocationSharing() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      isServiceDisabled: false,
      isPermissionPermanentlyDenied: false,
    );

    final result = await _locationService.getCurrentLocation();

    if (!result.isSuccess) {
      debugPrint('⚠️ [LiveLocation] Failed: ${result.message}');

      state = state.copyWith(
        isLoading: false,
        isSharing: false,
        errorMessage: result.message ?? 'Failed to access location.',
        isServiceDisabled: result.isServiceDisabled,
        isPermissionPermanentlyDenied: result.isPermissionPermanentlyDenied,
      );

      // Automatically redirect to location/GPS settings if service is turned off
      if (result.isServiceDisabled) {
        debugPrint('⚙️ [LiveLocation] Location is OFF. Redirecting to device location settings...');
        await _locationService.openLocationSettings();
      } else if (result.isPermissionPermanentlyDenied) {
        debugPrint('⚙️ [LiveLocation] Permission permanently denied. Redirecting to app settings...');
        await _locationService.openAppSettings();
      }

      return false;
    }

    final initialPos = result.position;
    if (initialPos != null) {
      debugPrint('====================================================');
      debugPrint('📍 [LiveLocation] Initial Coordinates:');
      debugPrint('   Latitude : ${initialPos.latitude}');
      debugPrint('   Longitude: ${initialPos.longitude}');
      debugPrint('   Accuracy : ${initialPos.accuracy.toStringAsFixed(2)} m');
      debugPrint('====================================================');
    }

    // Cancel existing stream if any
    await _positionSubscription?.cancel();

    // Start live location stream
    _positionSubscription = _locationService
        .getPositionStream(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5, // Update every 5 meters moved
        )
        .listen(
          (position) {
            debugPrint(
              '📡 [LiveLocation Stream] Lat: ${position.latitude}, Lng: ${position.longitude}',
            );
            state = state.copyWith(currentPosition: position, isSharing: true);
          },
          onError: (error) {
            debugPrint('❌ [LiveLocation Stream Error]: $error');
            state = state.copyWith(
              errorMessage: 'Live location stream error: $error',
            );
          },
        );

    state = state.copyWith(
      isLoading: false,
      isSharing: true,
      currentPosition: result.position,
      clearError: true,
    );

    return true;
  }

  /// Stops streaming live location.
  Future<void> stopLiveLocationSharing() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    state = state.copyWith(isSharing: false);
  }

  Future<bool> openAppSettings() async {
    return await _locationService.openAppSettings();
  }

  Future<bool> openLocationSettings() async {
    return await _locationService.openLocationSettings();
  }
}

final liveLocationProvider =
    NotifierProvider<LiveLocationNotifier, LiveLocationState>(
      LiveLocationNotifier.new,
    );
