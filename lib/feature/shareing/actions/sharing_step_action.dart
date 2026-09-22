import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/services/permission_service.dart';
import 'package:iwitnez/feature/shareing/provider/live_location_provider.dart';

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
  }) =>
      StepActionResult(
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
    final liveLocationNotifier = ref.read(liveLocationProvider.notifier);
    final success = await liveLocationNotifier.startLiveLocationSharing();

    if (success) {
      return StepActionResult.success();
    }

    final state = ref.read(liveLocationProvider);
    // If settings are opened directly by location service, do not show redundant message
    if (state.isServiceDisabled || state.isPermissionPermanentlyDenied) {
      return const StepActionResult(isSuccess: false);
    }

    return StepActionResult.failure(
      state.errorMessage ?? 'Unable to access location.',
      isPermanentlyDenied: state.isPermissionPermanentlyDenied,
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
