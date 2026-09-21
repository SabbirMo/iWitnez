import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../model/verification_state.dart';
import '../model/verification_type.dart';

class VerificationNotifier extends Notifier<VerificationState> {
  Timer? _timer;
  late final PinInputController pinController;

  @override
  VerificationState build() {
    pinController = PinInputController();

    ref.onDispose(() {
      _timer?.cancel();
      pinController.dispose();
    });

    _startPeriodicTimer();
    return const VerificationState(secondsRemaining: 45, canResend: false);
  }

  void init({String? email, VerificationType? type, int? codeLength}) {
    state = state.copyWith(
      email: (email != null && email.isNotEmpty) ? email : state.email,
      type: type ?? state.type,
      codeLength: codeLength ?? state.codeLength,
    );
  }

  void onPinChanged(String value) {
    state = state.copyWith(otp: value, clearError: true);
  }

  void _startPeriodicTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.secondsRemaining > 0) {
        state = state.copyWith(secondsRemaining: state.secondsRemaining - 1);
      } else {
        state = state.copyWith(canResend: true);
        timer.cancel();
      }
    });
  }

  void restartTimer() {
    _timer?.cancel();
    state = state.copyWith(secondsRemaining: 45, canResend: false);
    _startPeriodicTimer();
  }

  Future<void> resendCode({VoidCallback? onResent}) async {
    if (!state.canResend || state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);

    // Simulate network delay or call API
    await Future.delayed(const Duration(milliseconds: 600));

    pinController.clear();
    state = state.copyWith(
      otp: '',
      isLoading: false,
      secondsRemaining: 45,
      canResend: false,
    );
    _startPeriodicTimer();
    onResent?.call();
  }

  Future<bool> verifyCode({
    VoidCallback? onSuccess,
    ValueChanged<String>? onError,
  }) async {
    final enteredCode = pinController.text.trim();
    if (enteredCode.length != state.codeLength) {
      pinController.triggerError();
      final errorMsg =
          'Please enter the complete ${state.codeLength}-digit code';
      state = state.copyWith(errorMessage: errorMsg);
      onError?.call(errorMsg);
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    // Simulate API verification call
    await Future.delayed(const Duration(milliseconds: 800));

    state = state.copyWith(isLoading: false, isSuccess: true);
    onSuccess?.call();
    return true;
  }

  void clear() {
    pinController.clear();
    state = state.copyWith(otp: '', clearError: true);
  }
}

final verificationProvider =
    NotifierProvider.autoDispose<VerificationNotifier, VerificationState>(
      VerificationNotifier.new,
    );
