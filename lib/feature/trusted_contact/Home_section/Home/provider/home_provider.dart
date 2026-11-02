import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/network/error/api_error.dart';
import 'package:iwitnez/core/services/fcm_service.dart';
import 'package:iwitnez/feature/main_user/Profile_section/Profile/repository/profile_repository.dart';
import 'package:iwitnez/feature/trusted_contact/Home_section/Home/model/home_model.dart';
import 'package:iwitnez/feature/trusted_contact/Home_section/Home/repository/trusted_home_repository.dart';

final trustedHomeProvider =
    NotifierProvider<TrustedHomeNotifier, TrustedContactHomeState>(
  TrustedHomeNotifier.new,
);

class TrustedHomeNotifier extends Notifier<TrustedContactHomeState> {
  StreamSubscription<dynamic>? _fcmSubscription;
  bool _disposed = false;

  TrustedHomeRepository get _repository =>
      ref.read(trustedHomeRepositoryProvider);

  @override
  TrustedContactHomeState build() {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      _fcmSubscription?.cancel();
    });

    _fcmSubscription = FcmService.onNotificationReceived.stream.listen((_) {
      if (!_disposed) {
        state = state.copyWith(
          hasNotification: true,
          unreadNotificationsCount: state.unreadNotificationsCount + 1,
        );
      }
    });

    // Fetch live dashboard data on initialization
    Future.microtask(() => fetchDashboard());

    return TrustedContactHomeState.initial();
  }

  Future<void> fetchDashboard({bool forceRefresh = false}) async {
    if (forceRefresh || state.monitoredUser == null) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    try {
      // Resolve user's avatar from profile cache or endpoint
      String? userAvatar =
          state.userAvatarUrl.isNotEmpty ? state.userAvatarUrl : null;
      final cachedProfile = ProfileRepository().cachedProfile;
      if (cachedProfile != null &&
          cachedProfile.profile?.avatarUrl.isNotEmpty == true) {
        userAvatar = cachedProfile.profile!.avatarUrl;
      } else {
        ProfileRepository().getProfile().then((profile) {
          if (!_disposed &&
              profile?.profile?.avatarUrl.isNotEmpty == true) {
            state = state.copyWith(userAvatarUrl: profile!.profile!.avatarUrl);
          }
        }).catchError((_) {});
      }

      final response = await _repository.getDashboard();
      if (!_disposed) {
        if (response.success && response.data != null) {
          state = TrustedContactHomeState.fromDashboardData(
            response.data!,
            userAvatarUrl: userAvatar,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            errorMessage: response.message.isNotEmpty
                ? response.message
                : 'Failed to load dashboard',
          );
        }
      }
    } catch (e) {
      debugPrint('[TrustedHomeNotifier] Error fetching dashboard: $e');
      if (!_disposed) {
        final msg = e is ApiError ? e.message : 'Failed to load dashboard data.';
        state = state.copyWith(isLoading: false, errorMessage: msg);
      }
    }
  }

  void clearNotification() {
    state = state.copyWith(hasNotification: false, unreadNotificationsCount: 0);
  }
}
