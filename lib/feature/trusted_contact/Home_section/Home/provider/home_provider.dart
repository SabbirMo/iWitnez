import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/services/fcm_service.dart';
import 'package:iwitnez/feature/trusted_contact/Home_section/Home/model/home_model.dart';

final trustedHomeProvider =
    NotifierProvider<TrustedHomeNotifier, TrustedContactHomeState>(
  TrustedHomeNotifier.new,
);

class TrustedHomeNotifier extends Notifier<TrustedContactHomeState> {
  StreamSubscription<dynamic>? _fcmSubscription;

  @override
  TrustedContactHomeState build() {
    ref.onDispose(() {
      _fcmSubscription?.cancel();
    });

    _fcmSubscription = FcmService.onNotificationReceived.stream.listen((_) {
      state = state.copyWith(hasNotification: true);
    });

    return TrustedContactHomeState.initial();
  }

  void clearNotification() {
    state = state.copyWith(hasNotification: false);
  }

  void updateWardStatus({required String status}) {
    state = state.copyWith(wardStatus: status);
  }
}
