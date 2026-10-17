import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/services/permission_service.dart';

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
class LocationStepAction extends SharingStepAction {
  const LocationStepAction();

  @override
  Future<StepActionResult> execute(Ref ref) async {
    final permissionService = ref.read(permissionServiceProvider);
    final result = await permissionService.requestLocation();

    if (result.isGranted) {
      return StepActionResult.success();
    }

    return StepActionResult.failure(
      result.message,
      isPermanentlyDenied: result.isPermanentlyDenied,
    );
  }
}

/// Action for Step 1: Notifications
class NotificationStepAction extends SharingStepAction {
  const NotificationStepAction();

  @override
  Future<StepActionResult> execute(Ref ref) async {
    final permissionService = ref.read(permissionServiceProvider);
    final result = await permissionService.requestNotification();

    if (result.isGranted) {
      return StepActionResult.success();
    }

    return StepActionResult.failure(
      result.message,
      isPermanentlyDenied: result.isPermanentlyDenied,
    );
  }
}

/// Action for Step 2: Camera and Microphone
class MediaStepAction extends SharingStepAction {
  const MediaStepAction();

  @override
  Future<StepActionResult> execute(Ref ref) async {
    final permissionService = ref.read(permissionServiceProvider);
    final result = await permissionService.requestCameraAndMicrophone();

    if (result.isGranted) {
      return StepActionResult.success();
    }

    return StepActionResult.failure(
      result.message,
      isPermanentlyDenied: result.isPermanentlyDenied,
    );
  }
}
