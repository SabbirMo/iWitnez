import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/model/home_model.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/repository/home_repository.dart';

final homeProvider = AsyncNotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);

class HomeNotifier extends AsyncNotifier<HomeState> {
  @override
  Future<HomeState> build() async {
    final repository = ref.read(homeRepositoryProvider);
    final initial = HomeState.initial();

    try {
      final userData = await repository.getProfile();
      final unreadCount = await repository.getUnreadNotificationCount();

      return initial.copyWith(
        isProtected: userData.isProtected,
        userProfile: userData,
        greeting: initial.greeting.copyWith(
          userName: userData.fullName,
          subtitle: 'Stay Safe, Stay Connected',
          avatarUrl: userData.avatarUrl,
          hasUnreadNotification: unreadCount > 0,
        ),
      );
    } catch (_) {
      return initial;
    }
  }

  Future<void> fetchHomeData() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(homeRepositoryProvider);
      final current = state.value ?? HomeState.initial();

      final userData = await repository.getProfile();
      final unreadCount = await repository.getUnreadNotificationCount();

      return current.copyWith(
        isProtected: userData.isProtected,
        userProfile: userData,
        greeting: current.greeting.copyWith(
          userName: userData.fullName,
          subtitle: 'Stay Safe, Stay Connected',
          avatarUrl: userData.avatarUrl,
          hasUnreadNotification: unreadCount > 0,
        ),
      );
    });
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
