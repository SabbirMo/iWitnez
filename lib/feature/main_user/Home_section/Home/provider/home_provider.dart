import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iwitnez/core/services/fcm_service.dart';
import 'package:iwitnez/core/services/location_service.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/model/home_model.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/model/live_location_model.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/model/trusted_circles_response_model.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/model/user_profile_response_model.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/repository/home_repository.dart';
import 'package:iwitnez/feature/main_user/TrustedCircle/provider/trusted_circle_provider.dart';

final homeProvider = AsyncNotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);

class HomeNotifier extends AsyncNotifier<HomeState> {
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<dynamic>? _fcmSubscription;
  Timer? _pingTimer;

  @override
  FutureOr<HomeState> build() {
    ref.onDispose(() {
      _positionSubscription?.cancel();
      _pingTimer?.cancel();
      _fcmSubscription?.cancel();
    });

    _fcmSubscription = FcmService.onNotificationReceived.stream.listen((_) async {
      try {
        final repository = ref.read(homeRepositoryProvider);
        final unreadCount = await repository.getUnreadNotificationCount();
        updateUnreadNotificationCount(unreadCount);
      } catch (_) {}
    });

    // Start background fetching without blocking initial render
    Future.microtask(() => fetchHomeData());

    return HomeState.initial();
  }

  Future<void> _startLocationTracking() async {
    _positionSubscription?.cancel();
    _pingTimer?.cancel();

    try {
      final permission = await const LocationService().checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      // Initial GPS ping on start
      pingCurrentGpsLocation();

      // Periodic timer: ping every 30 seconds while sharing is active
      _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
        await pingCurrentGpsLocation();
      });

      // Stream updates: ping whenever phone moves >= 10 meters
      _positionSubscription = const LocationService()
          .getPositionStream(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          )
          .listen((position) async {
            try {
              final repository = ref.read(homeRepositoryProvider);
              await repository.pingLocation(
                latitude: position.latitude,
                longitude: position.longitude,
                accuracy: position.accuracy,
                speed: position.speed,
                heading: position.heading,
                address: state.value?.liveLocation?.address,
              );

              final current = state.value;
              if (current != null && current.liveLocation != null) {
                state = AsyncValue.data(
                  current.copyWith(
                    liveLocation: current.liveLocation!.copyWith(
                      latitude: position.latitude,
                      longitude: position.longitude,
                    ),
                  ),
                );
              }
            } catch (_) {}
          }, onError: (_) {});
    } catch (_) {}
  }

  void _stopLocationTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  Future<void> fetchHomeData() async {
    final repository = ref.read(homeRepositoryProvider);
    final current = state.value ?? HomeState.initial();

    // Ensure FCM token is synced with backend if user previously permitted
    FcmService.instance.syncDeviceTokenIfPermitted();

    try {
      final results = await Future.wait([
        repository.getProfile(),
        repository.getUnreadNotificationCount(),
        repository.getLiveLocation(),
        repository.getTrustedCircles(),
      ]);

      final userData = results[0] as UserData?;
      final unreadCount = results[1] as int;
      final liveLoc = results[2] as LiveLocationModel?;
      final circles = results[3] as TrustedCirclesResponseModel?;

      if (liveLoc?.isSharingLive == true) {
        _startLocationTracking();
      } else {
        _stopLocationTracking();
      }

      if (circles != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(trustedCircleProvider.notifier)
              .setCircles(circles.toCircleItems());
        });
      }

      state = AsyncValue.data(
        current.copyWith(
          isProtected: userData?.isProtected ?? current.isProtected,
          userProfile: userData ?? current.userProfile,
          liveLocation: liveLoc ?? current.liveLocation,
          trustedCircles: circles?.toSummaries() ?? current.trustedCircles,
          greeting: current.greeting.copyWith(
            userName: userData?.fullName ?? current.greeting.userName,
            subtitle: 'Stay Safe, Stay Connected',
            avatarUrl: userData?.avatarUrl ?? current.greeting.avatarUrl,
            hasUnreadNotification: unreadCount > 0,
            unreadCount: unreadCount,
          ),
        ),
      );
    } catch (_) {
      // Keep existing data on error
    }
  }

  Future<void> toggleSharing() async {
    final current = state.value;
    if (current == null) return;
    final currentSharing = current.liveLocation?.isSharingLive ?? false;
    final newSharing = !currentSharing;

    // Optimistically update UI
    state = AsyncValue.data(
      current.copyWith(
        liveLocation: current.liveLocation != null
            ? current.liveLocation!.copyWith(isSharingLive: newSharing)
            : LiveLocationModel(isSharingLive: newSharing),
      ),
    );

    final repository = ref.read(homeRepositoryProvider);

    if (newSharing) {
      _startLocationTracking();
      pingCurrentGpsLocation();

      // Persist to backend: POST /api/v1/location/live/
      try {
        final updated = await repository.startSharingLocation();
        if (updated != null) {
          final latest = state.value;
          if (latest != null) {
            state = AsyncValue.data(
              latest.copyWith(
                liveLocation: latest.liveLocation != null
                    ? latest.liveLocation!.copyWith(
                        isSharingLive: true,
                        durationType: updated.durationType,
                        durationDisplay: updated.durationDisplay,
                        peopleSharing: updated.peopleSharing,
                      )
                    : updated,
              ),
            );
          }
        }
      } catch (_) {}
    } else {
      _stopLocationTracking();

      // Persist to backend: DELETE /api/v1/location/live/
      try {
        await repository.stopSharingLocation();
        final latest = state.value;
        if (latest != null) {
          state = AsyncValue.data(
            latest.copyWith(
              liveLocation: latest.liveLocation?.copyWith(
                isSharingLive: false,
                peopleSharing: const [],
              ),
            ),
          );
        }
      } catch (_) {}
    }
  }

  void setSharing(bool isSharing) {
    final current = state.value;
    if (current == null) return;

    state = AsyncValue.data(
      current.copyWith(
        liveLocation: current.liveLocation != null
            ? current.liveLocation!.copyWith(
                isSharingLive: isSharing,
                peopleSharing: isSharing
                    ? current.liveLocation!.peopleSharing
                    : const [],
              )
            : LiveLocationModel(isSharingLive: isSharing),
      ),
    );

    if (isSharing) {
      _startLocationTracking();
      pingCurrentGpsLocation();
    } else {
      _stopLocationTracking();
    }
  }

  Future<void> pingCurrentGpsLocation() async {
    try {
      final locResult = await const LocationService().getCurrentLocation();
      if (locResult.isSuccess && locResult.position != null) {
        final pos = locResult.position!;
        final repository = ref.read(homeRepositoryProvider);
        await repository.pingLocation(
          latitude: pos.latitude,
          longitude: pos.longitude,
          accuracy: pos.accuracy,
          speed: pos.speed,
          heading: pos.heading,
          address: state.value?.liveLocation?.address,
        );

        final current = state.value;
        if (current != null && current.liveLocation != null) {
          state = AsyncValue.data(
            current.copyWith(
              liveLocation: current.liveLocation!.copyWith(
                latitude: pos.latitude,
                longitude: pos.longitude,
              ),
            ),
          );
        }
      }
    } catch (_) {
      // Ignore if GPS or network fails
    }
  }

  void clearNotificationBadge() {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(
      current.copyWith(
        greeting: current.greeting.copyWith(
          hasUnreadNotification: false,
          unreadCount: 0,
        ),
      ),
    );
  }

  void updateUnreadNotificationCount(int count) {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(
      current.copyWith(
        greeting: current.greeting.copyWith(
          hasUnreadNotification: count > 0,
          unreadCount: count,
        ),
      ),
    );
  }
}
