import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/provider/home_provider.dart';
import 'package:iwitnez/feature/main_user/LiveLocation/model/manage_sharing_model.dart';
import 'package:iwitnez/feature/main_user/LiveLocation/provider/live_location_screen_provider.dart';
import 'package:iwitnez/feature/main_user/LiveLocation/repository/live_location_repository.dart';

class ManageSharingState {
  final bool isLoading;
  final List<ManageSharingContactModel> contacts;
  final String? errorMessage;

  const ManageSharingState({
    this.isLoading = false,
    this.contacts = const [],
    this.errorMessage,
  });

  ManageSharingState copyWith({
    bool? isLoading,
    List<ManageSharingContactModel>? contacts,
    String? errorMessage,
  }) {
    return ManageSharingState(
      isLoading: isLoading ?? this.isLoading,
      contacts: contacts ?? this.contacts,
      errorMessage: errorMessage,
    );
  }
}

class ManageSharingNotifier extends Notifier<ManageSharingState> {
  @override
  ManageSharingState build() {
    Future.microtask(() => fetchContacts());
    return const ManageSharingState(isLoading: true);
  }

  /// 1. Fetch Contact Visibility Toggle List: GET /api/v1/location/manage-sharing/
  Future<void> fetchContacts() async {
    state = state.copyWith(isLoading: true);
    try {
      final repo = ref.read(liveLocationRepositoryProvider);
      final contacts = await repo.getManageSharingContacts();
      state = state.copyWith(isLoading: false, contacts: contacts);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 2. Toggle Individual Contact Visibility: POST /api/v1/location/manage-sharing/
  Future<bool> toggleContact(String contactId, bool isSharingEnabled) async {
    final previousContacts = state.contacts;

    // Optimistic UI update
    state = state.copyWith(
      contacts: state.contacts.map((c) {
        if (c.id == contactId) {
          return c.copyWith(isSharingEnabled: isSharingEnabled);
        }
        return c;
      }).toList(),
    );

    try {
      final repo = ref.read(liveLocationRepositoryProvider);
      final success = await repo.toggleContactSharing(
        contactId: contactId,
        isSharingEnabled: isSharingEnabled,
      );

      if (!success) {
        // Revert on failure
        state = state.copyWith(contacts: previousContacts);
        return false;
      }

      // Sync Screen 2 and Home Screen in background
      ref.read(liveLocationScreenProvider.notifier).fetchLiveLocation();
      ref.read(homeProvider.notifier).fetchHomeData();
      return true;
    } catch (_) {
      state = state.copyWith(contacts: previousContacts);
      return false;
    }
  }
}

final manageSharingProvider =
    NotifierProvider.autoDispose<ManageSharingNotifier, ManageSharingState>(
  ManageSharingNotifier.new,
);
