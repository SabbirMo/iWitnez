import 'safe_place_model.dart';

class SafetyTrackingResponse {
  final bool success;
  final String message;
  final SafetyTrackingData? data;

  SafetyTrackingResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory SafetyTrackingResponse.fromJson(Map<String, dynamic> json) {
    return SafetyTrackingResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] is Map<String, dynamic>
          ? SafetyTrackingData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SafetyTrackingData {
  final bool isLocationSharingActive;
  final MyLocationModel? myLocation;
  final List<SafePlaceModel> safePlaces;
  final bool alertsEnabled;

  SafetyTrackingData({
    this.isLocationSharingActive = true,
    this.myLocation,
    this.safePlaces = const [],
    this.alertsEnabled = true,
  });

  factory SafetyTrackingData.fromJson(Map<String, dynamic> json) {
    final placesRaw = json['safe_places'];
    final List<SafePlaceModel> places = [];
    if (placesRaw is List) {
      for (final item in placesRaw) {
        if (item is Map<String, dynamic>) {
          places.add(SafePlaceModel.fromJson(item));
        }
      }
    }

    return SafetyTrackingData(
      isLocationSharingActive:
          json['is_location_sharing_active'] as bool? ?? true,
      myLocation: json['my_location'] is Map<String, dynamic>
          ? MyLocationModel.fromJson(json['my_location'] as Map<String, dynamic>)
          : null,
      safePlaces: places,
      alertsEnabled: json['alerts_enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_location_sharing_active': isLocationSharingActive,
      'my_location': myLocation?.toJson(),
      'safe_places': safePlaces.map((p) => p.toJson()).toList(),
      'alerts_enabled': alertsEnabled,
    };
  }
}

class MyLocationModel {
  final double? latitude;
  final double? longitude;
  final String address;

  MyLocationModel({
    this.latitude,
    this.longitude,
    this.address = '',
  });

  factory MyLocationModel.fromJson(Map<String, dynamic> json) {
    return MyLocationModel(
      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),
      address: json['address'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude?.toString(),
      'longitude': longitude?.toString(),
      'address': address,
    };
  }
}

