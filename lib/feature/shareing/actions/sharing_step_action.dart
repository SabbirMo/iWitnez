import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iwitnez/core/network/error/api_error_handler.dart';
import 'package:iwitnez/core/services/location_service.dart';
import 'package:iwitnez/core/services/permission_service.dart';
import 'package:iwitnez/feature/shareing/repository/device_settings_repository.dart';

class StepActionResult {
  final bool isSuccess;
  final bool isPermanentlyDenied;
  final String? errorMessage;

  const StepActionResult({
    required this.isSuccess,
    this.isPermanentlyDenied = false,
    this.errorMessage,
  });

  factory StepActionResult.success() => const StepActionResult(isSuccess: true);

  factory StepActionResult.failure(
    String? errorMessage, {
    bool isPermanentlyDenied = false,
  }) => StepActionResult(
    isSuccess: false,
    isPermanentlyDenied: isPermanentlyDenied,
    errorMessage: errorMessage,
  );
}

/// Common contract for step actions (LSP & OCP).
abstract class SharingStepAction {
  const SharingStepAction();

  Future<StepActionResult> execute(Ref ref);
}

/// Action for Step 0: Location Sharing
/// Request location permission, fetch coordinates, and sync to backend.
class LocationStepAction extends SharingStepAction {
  const LocationStepAction();

  @override
  Future<StepActionResult> execute(Ref ref) async {
    final permissionService = ref.read(permissionServiceProvider);
    final result = await permissionService.requestLocation();

    if (!result.isGranted) {
      return StepActionResult.failure(
        result.message,
        isPermanentlyDenied: result.isPermanentlyDenied,
      );
    }

    // Permission granted: Attempt to fetch coordinates
    Position? position;
    try {
      final locResult = await const LocationService().getCurrentLocation();
      if (locResult.isSuccess) {
        position = locResult.position;
      }
    } catch (e) {
      debugPrint('[LocationStepAction] Warning: Could not get exact position: $e');
    }

    double? lat;
    double? lng;
    if (position != null) {
      lat = double.tryParse(position.latitude.toStringAsFixed(6));
      lng = double.tryParse(position.longitude.toStringAsFixed(6));
    }

    final body = <String, dynamic>{
      'location_permission_granted': true,
    };
    if (lat != null) {
      body['last_latitude'] = lat;
    }
    if (lng != null) {
      body['last_longitude'] = lng;
    }

    try {
      await ref
          .read(deviceSettingsRepositoryProvider)
          .updateDeviceSettings(body);
      return StepActionResult.success();
    } catch (e) {
      debugPrint('[LocationStepAction] API Error: $e');
      final message = e is ApiError
          ? e.message
          : 'Failed to sync location settings. Please try again.';
      return StepActionResult.failure(message);
    }
  }
}

/// Action for Step 1: Notifications
/// Request notification permission, fetch FCM token & platform, and sync to backend.
class NotificationStepAction extends SharingStepAction {
  const NotificationStepAction();

  @override
  Future<StepActionResult> execute(Ref ref) async {
    bool isGranted = false;

    // 1. Request notification permission via Firebase Messaging
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      isGranted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      debugPrint('[NotificationStepAction] FirebaseMessaging requestPermission error: $e');
    }

    // 2. Fallback to permission_handler if needed (e.g. Android 13+)
    if (!isGranted) {
      final permResult =
          await ref.read(permissionServiceProvider).requestNotification();
      isGranted = permResult.isGranted;
      if (!isGranted) {
        return StepActionResult.failure(
          permResult.message ?? 'Notification permission was denied.',
          isPermanentlyDenied: permResult.isPermanentlyDenied,
        );
      }
    }

    // 3. Fetch device FCM push token
    String? fcmToken;
    try {
      // ignore: deprecated_member_use
      fcmToken = await FirebaseMessaging.instance.getToken();
      debugPrint('[NotificationStepAction] FCM device token: $fcmToken');
    } catch (e) {
      debugPrint('[NotificationStepAction] Warning: Could not fetch FCM token: $e');
    }

    // 4. Detect device platform ("ios" or "android")
    final platform =
        defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';

    final body = <String, dynamic>{
      'notification_permission_granted': true,
      'fcm_device_token': fcmToken ?? '',
      'device_platform': platform,
    };

    try {
      await ref
          .read(deviceSettingsRepositoryProvider)
          .updateDeviceSettings(body);
      return StepActionResult.success();
    } catch (e) {
      debugPrint('[NotificationStepAction] API Error: $e');
      final message = e is ApiError
          ? e.message
          : 'Failed to sync notification settings. Please try again.';
      return StepActionResult.failure(message);
    }
  }
}

/// Action for Step 2: Camera and Microphone
/// Request camera & microphone permissions and sync flags to backend.
class MediaStepAction extends SharingStepAction {
  const MediaStepAction();

  @override
  Future<StepActionResult> execute(Ref ref) async {
    final permissionService = ref.read(permissionServiceProvider);
    final result = await permissionService.requestCameraAndMicrophone();

    if (!result.isGranted) {
      return StepActionResult.failure(
        result.message,
        isPermanentlyDenied: result.isPermanentlyDenied,
      );
    }

    final body = <String, dynamic>{
      'camera_permission_granted': true,
      'microphone_permission_granted': true,
    };

    try {
      await ref
          .read(deviceSettingsRepositoryProvider)
          .updateDeviceSettings(body);
      return StepActionResult.success();
    } catch (e) {
      debugPrint('[MediaStepAction] API Error: $e');
      final message = e is ApiError
          ? e.message
          : 'Failed to sync camera & microphone settings. Please try again.';
      return StepActionResult.failure(message);
    }
  }
}
