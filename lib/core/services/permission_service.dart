import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionResult {
  final bool isGranted;
  final bool isPermanentlyDenied;
  final String? message;

  const PermissionResult({
    required this.isGranted,
    this.isPermanentlyDenied = false,
    this.message,
  });

  factory PermissionResult.granted() => const PermissionResult(isGranted: true);

  factory PermissionResult.denied({
    String? message,
    bool isPermanentlyDenied = false,
  }) => PermissionResult(
    isGranted: false,
    isPermanentlyDenied: isPermanentlyDenied,
    message: message,
  );
}

abstract class IPermissionService {
  Future<PermissionResult> requestNotification();
  Future<PermissionResult> requestCameraAndMicrophone();
  Future<bool> openSettings();
}

class PermissionService implements IPermissionService {
  const PermissionService();

  @override
  Future<PermissionResult> requestNotification() async {
    try {
      final status = await Permission.notification.request();
      if (status.isGranted) {
        return PermissionResult.granted();
      } else if (status.isPermanentlyDenied) {
        return PermissionResult.denied(
          message:
              'Notification permission is permanently denied. Please enable it in app settings.',
          isPermanentlyDenied: true,
        );
      } else {
        return PermissionResult.denied(
          message: 'Notification permission denied.',
        );
      }
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return PermissionResult.denied(
        message: 'Error requesting notification permission: $e',
      );
    }
  }

  @override
  Future<PermissionResult> requestCameraAndMicrophone() async {
    try {
      final statuses = await [
        Permission.camera,
        Permission.microphone,
      ].request();

      final cameraStatus = statuses[Permission.camera];
      final micStatus = statuses[Permission.microphone];

      final isCameraGranted =
          cameraStatus?.isGranted == true || cameraStatus?.isLimited == true;
      final isMicGranted =
          micStatus?.isGranted == true || micStatus?.isLimited == true;

      if (isCameraGranted && isMicGranted) {
        return PermissionResult.granted();
      } else if (cameraStatus?.isPermanentlyDenied == true ||
          micStatus?.isPermanentlyDenied == true) {
        return PermissionResult.denied(
          message:
              'Camera or Microphone permission is permanently denied. Please enable them in app settings.',
          isPermanentlyDenied: true,
        );
      } else {
        String msg = 'Camera and Microphone permissions are required.';
        if (!isCameraGranted && isMicGranted) {
          msg = 'Camera permission is required.';
        } else if (isCameraGranted && !isMicGranted) {
          msg = 'Microphone permission is required.';
        }
        return PermissionResult.denied(message: msg);
      }
    } catch (e) {
      debugPrint('Error requesting media permissions: $e');
      return PermissionResult.denied(
        message: 'Error requesting media permissions: $e',
      );
    }
  }

  @override
  Future<bool> openSettings() async {
    return await openAppSettings();
  }
}

final permissionServiceProvider = Provider<IPermissionService>((ref) {
  return const PermissionService();
});
