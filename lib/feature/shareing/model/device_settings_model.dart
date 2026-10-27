class DeviceSettingsResponse {
  final bool success;
  final String message;
  final DeviceSettingsData? data;

  DeviceSettingsResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory DeviceSettingsResponse.fromJson(Map<String, dynamic> json) {
    return DeviceSettingsResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? DeviceSettingsData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class DeviceSettingsData {
  final bool locationPermissionGranted;
  final bool notificationPermissionGranted;
  final bool cameraPermissionGranted;
  final bool microphonePermissionGranted;
  final String? fcmDeviceToken;
  final String? devicePlatform;
  final dynamic lastLatitude;
  final dynamic lastLongitude;
  final String? lastLocationUpdatedAt;

  DeviceSettingsData({
    required this.locationPermissionGranted,
    required this.notificationPermissionGranted,
    required this.cameraPermissionGranted,
    required this.microphonePermissionGranted,
    this.fcmDeviceToken,
    this.devicePlatform,
    this.lastLatitude,
    this.lastLongitude,
    this.lastLocationUpdatedAt,
  });

  factory DeviceSettingsData.fromJson(Map<String, dynamic> json) {
    return DeviceSettingsData(
      locationPermissionGranted:
          json['location_permission_granted'] as bool? ?? false,
      notificationPermissionGranted:
          json['notification_permission_granted'] as bool? ?? false,
      cameraPermissionGranted:
          json['camera_permission_granted'] as bool? ?? false,
      microphonePermissionGranted:
          json['microphone_permission_granted'] as bool? ?? false,
      fcmDeviceToken: json['fcm_device_token'] as String?,
      devicePlatform: json['device_platform'] as String?,
      lastLatitude: json['last_latitude'],
      lastLongitude: json['last_longitude'],
      lastLocationUpdatedAt: json['last_location_updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location_permission_granted': locationPermissionGranted,
      'notification_permission_granted': notificationPermissionGranted,
      'camera_permission_granted': cameraPermissionGranted,
      'microphone_permission_granted': microphonePermissionGranted,
      if (fcmDeviceToken != null) 'fcm_device_token': fcmDeviceToken,
      if (devicePlatform != null) 'device_platform': devicePlatform,
      if (lastLatitude != null) 'last_latitude': lastLatitude,
      if (lastLongitude != null) 'last_longitude': lastLongitude,
      if (lastLocationUpdatedAt != null)
        'last_location_updated_at': lastLocationUpdatedAt,
    };
  }
}
