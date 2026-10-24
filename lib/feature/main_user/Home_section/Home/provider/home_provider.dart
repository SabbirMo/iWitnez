import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iwitnez/core/services/location_service.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/model/home_model.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/model/live_location_model.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/model/user_profile_response_model.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/repository/home_repository.dart';

final homeProvider = AsyncNotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);

class HomeNotifier extends AsyncNotifier<HomeState> {
  StreamSubscription<Position>? _positionSubscription;

  @override
  FutureOr<HomeState> build() {
    ref.onDispose(() {
      _positionSubscription?.cancel();
    });

    // Start background fetching without blocking initial render
    Future.microtask(() => fetchHomeData());

    return HomeState.initial();
  }

  Future<void> _startLocationTracking() async {
    _positionSubscription?.cancel();
    try {
      final permission = await const LocationService().checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

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
  }

  Future<void> fetchHomeData() async {
    final repository = ref.read(homeRepositoryProvider);
    final current = state.value ?? HomeState.initial();

    try {
      final results = await Future.wait([
        repository.getProfile(),
        repository.getUnreadNotificationCount(),
        repository.getLiveLocation(),
      ]);

      final userData = results[0] as UserData?;
      final unreadCount = results[1] as int;
      final liveLoc = results[2] as LiveLocationModel?;

      if (liveLoc?.isSharingLive == true) {
        _startLocationTracking();
      } else {
        _stopLocationTracking();
      }

      state = AsyncValue.data(
        current.copyWith(
          isProtected: userData?.isProtected ?? current.isProtected,
          userProfile: userData ?? current.userProfile,
          liveLocation: liveLoc ?? current.liveLocation,
          greeting: current.greeting.copyWith(
            userName: userData?.fullName ?? current.greeting.userName,
            subtitle: 'Stay Safe, Stay Connected',
            avatarUrl: userData?.avatarUrl ?? current.greeting.avatarUrl,
            hasUnreadNotification: unreadCount > 0,
          ),
        ),
      );
    } catch (_) {
      // Keep existing data on error
    }
  }

  void toggleSharing() {
    final current = state.value;
    if (current == null) return;
    final currentSharing = current.liveLocation?.isSharingLive ?? false;
    final newSharing = !currentSharing;

    state = AsyncValue.data(
      current.copyWith(
        liveLocation: current.liveLocation != null
            ? current.liveLocation!.copyWith(isSharingLive: newSharing)
            : LiveLocationModel(isSharingLive: newSharing),
      ),
    );

    if (newSharing) {
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
        greeting: current.greeting.copyWith(hasUnreadNotification: false),
      ),
    );
  }
}
