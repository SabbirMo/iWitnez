import 'package:flutter_riverpod/flutter_riverpod.dart';

class CheckInState {
  final String address;
  final String accuracy;
  final String checkInTime;
  final bool isCheckedIn;

  const CheckInState({
    this.address = '1200 Park Ave,\nNew York, NY 10028, USA',
    this.accuracy = '±10 m',
    this.checkInTime = 'Today, 10:30 AM',
    this.isCheckedIn = false,
  });

  CheckInState copyWith({
    String? address,
    String? accuracy,
    String? checkInTime,
    bool? isCheckedIn,
  }) {
    return CheckInState(
      address: address ?? this.address,
      accuracy: accuracy ?? this.accuracy,
      checkInTime: checkInTime ?? this.checkInTime,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
    );
  }
}

class CheckInNotifier extends Notifier<CheckInState> {
  @override
  CheckInState build() {
    return const CheckInState();
  }

  void updateLocation(String address, String accuracy) {
    state = state.copyWith(address: address, accuracy: accuracy);
  }

  void checkIn() {
    state = state.copyWith(isCheckedIn: true);
  }
}

final checkInProvider = NotifierProvider<CheckInNotifier, CheckInState>(
  CheckInNotifier.new,
);
