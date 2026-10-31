import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/network/error/api_error_handler.dart';
import 'package:iwitnez/core/services/location_service.dart';
import 'package:iwitnez/core/widgets/custom_snackbar.dart';
import '../model/check_in_page_model.dart';
import '../repository/check_in_repository.dart';

class CheckInState {
  final CheckInPageData pageData;
  final bool isLoadingPage;
  final bool isUpdatingLocation;
  final bool isCheckingIn;

  const CheckInState({
    this.pageData = const CheckInPageData(),
    this.isLoadingPage = false,
    this.isUpdatingLocation = false,
    this.isCheckingIn = false,
  });

  CheckInState copyWith({
    CheckInPageData? pageData,
    bool? isLoadingPage,
    bool? isUpdatingLocation,
    bool? isCheckingIn,
  }) {
    return CheckInState(
      pageData: pageData ?? this.pageData,
      isLoadingPage: isLoadingPage ?? this.isLoadingPage,
      isUpdatingLocation: isUpdatingLocation ?? this.isUpdatingLocation,
      isCheckingIn: isCheckingIn ?? this.isCheckingIn,
    );
  }
}

class CheckInNotifier extends Notifier<CheckInState> {
  CheckInRepository get _repository => ref.read(checkInRepositoryProvider);

  @override
  CheckInState build() {
    Future.microtask(() => loadCheckInPage());
    return const CheckInState(isLoadingPage: true);
  }

  /// Instantly updates the check-in time display on the UI
  void updateCheckInTimeDisplay(String display) {
    if (display.isNotEmpty) {
      state = state.copyWith(
        pageData: state.pageData.copyWith(checkInTimeDisplay: display),
      );
    }
  }

  /// 1. Screen Load (initState): GET /api/v1/emergency/check-ins/page/
  Future<void> loadCheckInPage() async {
    try {
      final pageData = await _repository.getCheckInPage();
      state = state.copyWith(pageData: pageData, isLoadingPage: false);
    } catch (e) {
      debugPrint('[CheckInNotifier] loadCheckInPage error: $e');
      state = state.copyWith(isLoadingPage: false);
    }
  }

  /// 2. ↻ Update Button (Pending screen): Reads GPS -> POST /api/v1/location/ping/
  Future<void> updateCurrentLocation(BuildContext context) async {
    state = state.copyWith(isUpdatingLocation: true);
    try {
      final locResult = await const LocationService().getCurrentLocation();

      if (!locResult.isSuccess || locResult.position == null) {
        state = state.copyWith(isUpdatingLocation: false);
        if (context.mounted) {
          CustomSnackBar.showError(
            context,
            message:
                locResult.message ??
                'Unable to get current GPS location. Please check GPS permissions.',
          );
        }
        return;
      }

      final pos = locResult.position!;
      final updatedLoc = await _repository.pingLocation(
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracy: pos.accuracy,
      );

      if (updatedLoc != null) {
        state = state.copyWith(
          pageData: state.pageData.copyWith(yourLocation: updatedLoc),
          isUpdatingLocation: false,
        );
        if (context.mounted) {
          CustomSnackBar.showSuccess(context, message: 'Location updated.');
        }
      } else {
        state = state.copyWith(isUpdatingLocation: false);
      }
    } catch (e) {
      state = state.copyWith(isUpdatingLocation: false);
      if (context.mounted) {
        CustomSnackBar.showError(
          context,
          message: ApiErrorHandler.getMessage(e),
        );
      }
    }
  }

  /// 3. ✓ Check In Now Button (or 📍 Update Location Button in Complete state):
  /// Calls POST /api/v1/emergency/check-ins/check-in-now/
  Future<void> checkInNow(
    BuildContext context, {
    bool isUpdateLocation = false,
    VoidCallback? onSuccess,
  }) async {
    if (isUpdateLocation) {
      state = state.copyWith(isUpdatingLocation: true);
    } else {
      state = state.copyWith(isCheckingIn: true);
    }

    try {
      double lat = state.pageData.yourLocation.latitude ?? 0.0;
      double lng = state.pageData.yourLocation.longitude ?? 0.0;
      double acc = state.pageData.yourLocation.accuracy ?? 10.0;

      // Always fetch fresh GPS if user tapped "Update Location" or coordinates are missing
      if (isUpdateLocation || lat == 0.0 || lng == 0.0) {
        try {
          final locResult = await const LocationService().getCurrentLocation();
          if (locResult.isSuccess && locResult.position != null) {
            lat = locResult.position!.latitude;
            lng = locResult.position!.longitude;
            acc = locResult.position!.accuracy;
          }
        } catch (_) {}
      }

      final result = await _repository.checkInNow(
        latitude: lat,
        longitude: lng,
        accuracy: acc,
        address: '',
        notes: "I'm Safe",
      );

      CheckInPageData newPageData;
      if (result.pageData != null) {
        newPageData = result.pageData!;
      } else {
        newPageData = state.pageData.copyWith(
          isCheckedInToday: true,
          screenState: 'completed',
          statusBadge: 'Checked In',
        );
      }

      state = state.copyWith(
        pageData: newPageData,
        isCheckingIn: false,
        isUpdatingLocation: false,
      );

      if (context.mounted) {
        CustomSnackBar.showSuccess(context, message: result.message);
      }

      onSuccess?.call();
    } catch (e) {
      state = state.copyWith(isCheckingIn: false, isUpdatingLocation: false);
      if (context.mounted) {
        CustomSnackBar.showError(
          context,
          message: ApiErrorHandler.getMessage(e),
        );
      }
    }
  }
}

final checkInProvider = NotifierProvider<CheckInNotifier, CheckInState>(
  CheckInNotifier.new,
);
