import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/feature/trusted_contact/Home_section/Home/model/home_model.dart';

final trustedHomeProvider =
    NotifierProvider<TrustedHomeNotifier, TrustedContactHomeState>(
  TrustedHomeNotifier.new,
);

class TrustedHomeNotifier extends Notifier<TrustedContactHomeState> {
  @override
  TrustedContactHomeState build() {
    return TrustedContactHomeState.initial();
  }

  void clearNotification() {
    state = state.copyWith(hasNotification: false);
  }

  void updateWardStatus({required String status}) {
    state = state.copyWith(wardStatus: status);
  }
}
