import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:iwitnez/core/network/error/api_error_handler.dart';
import 'package:iwitnez/feature/trusted_contact/LiveLocation/model/directions_model.dart';
import 'package:iwitnez/feature/trusted_contact/LiveLocation/model/monitored_live_location_model.dart';
import 'package:iwitnez/feature/trusted_contact/LiveLocation/repository/directions_repository.dart';

final directionsProvider =
    NotifierProvider<DirectionsNotifier, DirectionsState>(
      DirectionsNotifier.new,
    );

class DirectionsNotifier extends Notifier<DirectionsState> {
  bool _disposed = false;
  DirectionsArgs? _args;

  DirectionsRepository get _repository =>
      ref.read(directionsRepositoryProvider);

  @override
  DirectionsState build() {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
    });

    return DirectionsState.initial();
  }

  Future<void> retry() async {
    if (_args != null) {
      await initialize(_args!);
    }
  }

  Future<(double, double)> _resolveCoordinates(
    String address,
    double lat,
    double lng,
  ) async {
    if (lat != 0.0 || lng != 0.0 || address.isEmpty) {
      return (lat, lng);
    }
    try {
      final geocoding = Geocoding();
      final locations = await geocoding.locationFromAddress(address);
      if (locations.isNotEmpty) {
        return (locations.first.latitude, locations.first.longitude);
      }
    } catch (e) {
      debugPrint('Geocoding error for address "$address": $e');
    }
    return (lat, lng);
  }

  Future<void> initialize(DirectionsArgs args) async {
    _args = args;
    state = state.copyWith(isLoading: true, clearError: true);

    double destLat = args.destinationLatitude;
    double destLng = args.destinationLongitude;

    if (destLat == 0.0 && destLng == 0.0 && args.destinationAddress.isNotEmpty) {
      final (resolvedLat, resolvedLng) = await _resolveCoordinates(
        args.destinationAddress,
        0.0,
        0.0,
      );
      destLat = resolvedLat;
      destLng = resolvedLng;
    }

    // If destination coordinates are not known, display initial state without sending 0,0
    if (destLat == 0.0 && destLng == 0.0) {
      state = state.copyWith(
        isLoading: false,
        clearError: true,
        data: DirectionsData(
          originLatitude: args.originLatitude,
          originLongitude: args.originLongitude,
          originName: args.originName,
          originAddress: args.originAddress,
          destinationLatitude: 0.0,
          destinationLongitude: 0.0,
          destinationName: args.destinationName,
          destinationAddress: args.destinationAddress,
          mode: args.mode,
          travelModes: TravelModeItem.defaultModes,
          routes: const [],
        ),
      );
      return;
    }

    final initialReq = DirectionsRequest(
      originLatitude: args.originLatitude,
      originLongitude: args.originLongitude,
      originName: args.originName,
      originAddress: args.originAddress,
      destinationLatitude: destLat,
      destinationLongitude: destLng,
      destinationName: args.destinationName,
      destinationAddress: args.destinationAddress,
      mode: args.mode,
    );

    await fetchDirections(initialReq);
  }

  Future<void> setDestination({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    final currentData = state.data;
    final originLat =
        currentData?.originLatitude ?? _args?.originLatitude ?? 0.0;
    final originLng =
        currentData?.originLongitude ?? _args?.originLongitude ?? 0.0;
    final originName = currentData?.originName.isNotEmpty == true
        ? currentData!.originName
        : (_args?.originName ?? 'Your Location');
    final originAddress = currentData?.originAddress.isNotEmpty == true
        ? currentData!.originAddress
        : (_args?.originAddress ?? '');

    double destLat = latitude;
    double destLng = longitude;

    if (destLat == 0.0 && destLng == 0.0 && address.isNotEmpty) {
      final (resolvedLat, resolvedLng) = await _resolveCoordinates(
        address,
        0.0,
        0.0,
      );
      destLat = resolvedLat;
      destLng = resolvedLng;
    }

    if (destLat == 0.0 && destLng == 0.0) {
      state = state.copyWith(
        errorMessage: 'Unable to find coordinates for this destination. Please select a valid place.',
      );
      return;
    }

    final mode = currentData?.mode ?? _args?.mode ?? 'drive';

    final req = DirectionsRequest(
      originLatitude: originLat,
      originLongitude: originLng,
      originName: originName,
      originAddress: originAddress,
      destinationLatitude: destLat,
      destinationLongitude: destLng,
      destinationName: name.isNotEmpty ? name : 'Destination',
      destinationAddress: address,
      mode: mode,
    );

    await fetchDirections(req);
  }

  Future<void> fetchDirections(DirectionsRequest request) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _repository.getDirections(request);
      if (!_disposed) {
        if (response.success && response.data != null) {
          final modeIndex = _getModeIndex(request.mode);
          state = state.copyWith(
            isLoading: false,
            data: response.data,
            selectedTransportIndex: modeIndex,
            selectedRouteIndex: 0,
            clearError: true,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            errorMessage: response.message.isNotEmpty
                ? response.message
                : 'Failed to retrieve directions.',
          );
        }
      }
    } catch (e) {
      if (!_disposed) {
        final apiError = ApiErrorHandler.handle(e);
        state = state.copyWith(
          isLoading: false,
          errorMessage: apiError.message,
        );
      }
    }
  }

  int _getModeIndex(String mode) {
    switch (mode.toLowerCase()) {
      case 'transit':
      case 'bus':
        return 1;
      case 'walk':
      case 'walking':
        return 2;
      case 'bike':
      case 'bicycling':
      case 'cycling':
        return 3;
      case 'drive':
      case 'driving':
      default:
        return 0;
    }
  }

  String _getModeString(int index) {
    switch (index) {
      case 1:
        return 'transit';
      case 2:
        return 'walk';
      case 3:
        return 'bike';
      case 0:
      default:
        return 'drive';
    }
  }

  Future<void> selectTransport(int index) async {
    final newMode = _getModeString(index);
    state = state.copyWith(
      selectedTransportIndex: index,
      selectedRouteIndex: 0,
    );

    final currentData = state.data;
    final originLat =
        currentData?.originLatitude ?? _args?.originLatitude ?? 0.0;
    final originLng =
        currentData?.originLongitude ?? _args?.originLongitude ?? 0.0;
    final originName = currentData?.originName.isNotEmpty == true
        ? currentData!.originName
        : (_args?.originName ?? '');
    final originAddress = currentData?.originAddress.isNotEmpty == true
        ? currentData!.originAddress
        : (_args?.originAddress ?? '');

    final rawDestLat =
        currentData?.destinationLatitude ?? _args?.destinationLatitude ?? 0.0;
    final rawDestLng =
        currentData?.destinationLongitude ?? _args?.destinationLongitude ?? 0.0;
    final destName = currentData?.destinationName.isNotEmpty == true
        ? currentData!.destinationName
        : (_args?.destinationName ?? '');
    final destAddress = currentData?.destinationAddress.isNotEmpty == true
        ? currentData!.destinationAddress
        : (_args?.destinationAddress ?? '');

    // If destination not selected yet, simply update mode in state
    if (rawDestLat == 0.0 && rawDestLng == 0.0 && destAddress.isEmpty) {
      if (currentData != null) {
        state = state.copyWith(
          data: DirectionsData(
            originName: currentData.originName,
            originAddress: currentData.originAddress,
            originLatitude: currentData.originLatitude,
            originLongitude: currentData.originLongitude,
            destinationName: currentData.destinationName,
            destinationAddress: currentData.destinationAddress,
            destinationLatitude: currentData.destinationLatitude,
            destinationLongitude: currentData.destinationLongitude,
            mode: newMode,
            travelModes: currentData.travelModes,
            routes: currentData.routes,
          ),
        );
      }
      return;
    }

    final (destLat, destLng) = await _resolveCoordinates(
      destAddress,
      rawDestLat,
      rawDestLng,
    );

    final req = DirectionsRequest(
      originLatitude: originLat,
      originLongitude: originLng,
      originName: originName,
      originAddress: originAddress,
      destinationLatitude: destLat,
      destinationLongitude: destLng,
      destinationName: destName,
      destinationAddress: destAddress,
      mode: newMode,
    );

    await fetchDirections(req);
  }

  void selectRoute(int index) {
    if (state.selectedRouteIndex != index) {
      state = state.copyWith(selectedRouteIndex: index);
    }
  }

  Future<void> swapLocations() async {
    final currentData = state.data;
    final originLat =
        currentData?.originLatitude ?? _args?.originLatitude ?? 0.0;
    final originLng =
        currentData?.originLongitude ?? _args?.originLongitude ?? 0.0;
    final originName = currentData?.originName.isNotEmpty == true
        ? currentData!.originName
        : (_args?.originName ?? '');
    final originAddress = currentData?.originAddress.isNotEmpty == true
        ? currentData!.originAddress
        : (_args?.originAddress ?? '');

    final destLat =
        currentData?.destinationLatitude ?? _args?.destinationLatitude ?? 0.0;
    final destLng =
        currentData?.destinationLongitude ?? _args?.destinationLongitude ?? 0.0;
    final destName = currentData?.destinationName.isNotEmpty == true
        ? currentData!.destinationName
        : (_args?.destinationName ?? '');
    final destAddress = currentData?.destinationAddress.isNotEmpty == true
        ? currentData!.destinationAddress
        : (_args?.destinationAddress ?? '');

    if (destLat == 0.0 && destLng == 0.0) return;

    final swappedReq = DirectionsRequest(
      originLatitude: destLat,
      originLongitude: destLng,
      originName: destName,
      originAddress: destAddress,
      destinationLatitude: originLat,
      destinationLongitude: originLng,
      destinationName: originName,
      destinationAddress: originAddress,
      mode: currentData?.mode ?? _getModeString(state.selectedTransportIndex),
    );

    await fetchDirections(swappedReq);
  }

  Future<void> selectDestinationPlace(SafePlaceEtaItem place) async {
    await setDestination(
      name: place.name,
      address: place.address,
      latitude: place.latitude,
      longitude: place.longitude,
    );
  }
}
