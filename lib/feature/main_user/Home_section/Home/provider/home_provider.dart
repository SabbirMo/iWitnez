import 'package:flutter_riverpod/legacy.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/model/home_model.dart';

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>(
  (ref) => HomeNotifier()..fetchHomeData(),
);

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(HomeState.initial());

  Future<void> fetchHomeData() async {
    state = state.copyWith(isLoading: true);

    await Future.delayed(const Duration(milliseconds: 300));

    state = state.copyWith(isLoading: false);
  }

  void clearNotificationBadge() {
    state = state.copyWith(
      greeting: state.greeting.copyWith(hasUnreadNotification: false),
    );
  }
}
