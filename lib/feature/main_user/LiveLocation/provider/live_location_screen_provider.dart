import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/provider/home_provider.dart';
import 'package:iwitnez/feature/main_user/LiveLocation/model/live_sharing_model.dart';
import 'package:iwitnez/feature/main_user/LiveLocation/repository/live_location_repository.dart';

const List<Color> _contactColors = [
  Color(0xFFFDA4AF), // Pink
  Color(0xFF60A5FA), // Blue
  Color(0xFFFB923C), // Orange
  Color(0xFF34D399), // Mint
  Color(0xFFA78BFA), // Purple
];

class LiveLocationScreenState {
  final bool isLoading;
  final bool isSharing;
  final String? durationType;
  final String selectedDuration;
  final double? userLatitude;
  final double? userLongitude;
  final String? userAddress;
  final String? userName;
  final List<SharingPersonModel> contacts;

  const LiveLocationScreenState({
    this.isLoading = false,
    this.isSharing = true,
    this.durationType = 'until_off',
    this.selectedDuration = 'Until I turn it off',
    this.userLatitude,
    this.userLongitude,
    this.userAddress,
    this.userName,
    this.contacts = const [],
  });

  LiveLocationScreenState copyWith({
    bool? isLoading,
    bool? isSharing,
    String? durationType,
    String? selectedDuration,
    double? userLatitude,
    double? userLongitude,
    String? userAddress,
    String? userName,
    List<SharingPersonModel>? contacts,
  }) {
    return LiveLocationScreenState(
      isLoading: isLoading ?? this.isLoading,
      isSharing: isSharing ?? this.isSharing,
      durationType: durationType ?? this.durationType,
      selectedDuration: selectedDuration ?? this.selectedDuration,
      userLatitude: userLatitude ?? this.userLatitude,
      userLongitude: userLongitude ?? this.userLongitude,
      userAddress: userAddress ?? this.userAddress,
      userName: userName ?? this.userName,
      contacts: contacts ?? this.contacts,
    );
  }
}

class LiveLocationScreenNotifier extends Notifier<LiveLocationScreenState> {
  @override
  LiveLocationScreenState build() {
    // Read cached values from homeProvider if available for instant display
    final homeLoc = ref.read(homeProvider).value?.liveLocation;
    final homeUser = ref.read(homeProvider).value?.userProfile;

    // Start fetching latest from GET /api/v1/location/live/
    Future.microtask(() => fetchLiveLocation());

    if (homeLoc != null) {
      return _buildStateFromModel(homeLoc, fallbackUserName: homeUser?.fullName);
    }
    return const LiveLocationScreenState(isLoading: true);
  }

  LiveLocationScreenState _buildStateFromModel(
    dynamic liveModel, {
    String? fallbackUserName,
  }) {
    final myName = liveModel.userName ?? fallbackUserName ?? 'You';
    final contactsList = <SharingPersonModel>[];

    // 1. Self as first person: "Emma (You)"
    contactsList.add(
      SharingPersonModel(
        id: 'self',
        name: '$myName (You)',
        subtitle: 'Now',
        imageUrl: '',
        isLive: liveModel.isSharingLive,
        fallbackColor: const Color(0xFFC084FC),
        latitude: liveModel.latitude,
        longitude: liveModel.longitude,
      ),
    );

    // 2. People sharing with you
    final people = liveModel.peopleSharing;
    if (people != null) {
      for (int i = 0; i < people.length; i++) {
        final p = people[i];
        if (p.isSelf) continue;

        contactsList.add(
          SharingPersonModel(
            id: p.id ?? 'contact_$i',
            name: p.name ?? 'Trusted Contact',
            subtitle: p.distanceDisplay ?? 'Live location',
            imageUrl: p.avatarUrl ?? '',
            isLive: p.isLive,
            fallbackColor: _contactColors[i % _contactColors.length],
            latitude: p.latitude,
            longitude: p.longitude,
          ),
        );
      }
    }

    return LiveLocationScreenState(
      isLoading: false,
      isSharing: liveModel.isSharingLive,
      durationType: liveModel.durationType ?? 'until_off',
      selectedDuration: liveModel.durationDisplay ?? 'Until I turn it off',
      userLatitude: liveModel.latitude,
      userLongitude: liveModel.longitude,
      userAddress: liveModel.address,
      userName: myName,
      contacts: contactsList,
    );
  }

  /// 1. Page Load API: GET /api/v1/location/live/
  Future<void> fetchLiveLocation() async {
    try {
      final repo = ref.read(liveLocationRepositoryProvider);
      final liveModel = await repo.getLiveLocation();
      if (liveModel != null) {
        state = _buildStateFromModel(liveModel);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Update Sharing Duration: POST /api/v1/location/live/
  /// {"duration_type": "until_off" | "1_hour" | "8_hours"}
  Future<bool> updateDuration(String durationType) async {
    try {
      final repo = ref.read(liveLocationRepositoryProvider);
      final updated = await repo.updateSharingDuration(durationType);

      String display;
      switch (durationType) {
        case '1_hour':
          display = 'For 1 hour';
          break;
        case '8_hours':
          display = 'For 8 hours';
          break;
        case 'until_off':
        default:
          display = 'Until I turn it off';
          break;
      }

      state = state.copyWith(
        durationType: durationType,
        selectedDuration: updated?.durationDisplay ?? display,
      );

      // Refresh Home Provider in background so both screens stay in sync
      ref.read(homeProvider.notifier).fetchHomeData();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Confirm Stop Sharing: DELETE /api/v1/location/live/
  Future<bool> stopSharing() async {
    try {
      final repo = ref.read(liveLocationRepositoryProvider);
      final success = await repo.stopSharingLocation();

      if (success) {
        state = state.copyWith(
          isSharing: false,
          contacts: state.contacts.map((c) => c.copyWith(isLive: false)).toList(),
        );

        // Update homeProvider so home badge changes to grey dot ("Sharing is OFF")
        // and contact markers are removed from the home map
        ref.read(homeProvider.notifier).setSharing(false);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> startSharing({String durationType = 'until_off'}) async {
    try {
      final repo = ref.read(liveLocationRepositoryProvider);
      final updated = await repo.updateSharingDuration(durationType);

      // Re-fetch fresh live location data so all contacts and markers become active immediately
      await fetchLiveLocation();

      state = state.copyWith(
        isSharing: true,
        durationType: durationType,
        selectedDuration: updated?.durationDisplay ?? state.selectedDuration,
      );

      ref.read(homeProvider.notifier).setSharing(true);
      ref.read(homeProvider.notifier).fetchHomeData();
      return true;
    } catch (_) {
      return false;
    }
  }

  void updateUserCoordinates(double lat, double lng) {
    state = state.copyWith(
      userLatitude: lat,
      userLongitude: lng,
    );
  }

  void toggleContactSharing(String id) {
    state = state.copyWith(
      contacts: state.contacts.map((contact) {
        if (contact.id == id) {
          return contact.copyWith(isSharingWith: !contact.isSharingWith);
        }
        return contact;
      }).toList(),
    );
  }
}

final liveLocationScreenProvider =
    NotifierProvider.autoDispose<
      LiveLocationScreenNotifier,
      LiveLocationScreenState
    >(LiveLocationScreenNotifier.new);
