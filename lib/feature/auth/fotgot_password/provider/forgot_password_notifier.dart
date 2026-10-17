import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/feature/auth/fotgot_password/model/forgot_password_request_model.dart';
import 'package:iwitnez/feature/auth/fotgot_password/repository/forgot_password_repository.dart';

class ForgotPasswordNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    return;
  }

  Future<bool> sendResetOtp({required String email}) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(forgotPasswordRepositoryProvider);
      final request = ForgotPasswordRequestModel(email: email);
      await repository.forgotPassword(request);
    });

    return !state.hasError;
  }
}

final forgotPasswordNotifierProvider =
    AsyncNotifierProvider<ForgotPasswordNotifier, void>(
      ForgotPasswordNotifier.new,
    );
