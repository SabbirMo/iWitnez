import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/check_in_status_model.dart';

class CheckInStatusNotifier extends Notifier<CheckInStatusData> {
  @override
  CheckInStatusData build() {
    return const CheckInStatusData();
  }

  void setStatusType(CheckInStatusType type) {
    state = state.copyWith(statusType: type);
  }
}

final checkInStatusProvider =
    NotifierProvider<CheckInStatusNotifier, CheckInStatusData>(
  CheckInStatusNotifier.new,
);
