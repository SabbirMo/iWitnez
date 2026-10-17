import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/feature/auth/login/model/login_request_model.dart';
import 'package:iwitnez/feature/auth/login/repository/login_repository.dart';

class LoginNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async => null;

  Future<String?> login({
    required String email,
    required String password,
    String? role,
  }) async {
    state = const AsyncValue.loading();

    String? userRole;
    state = await AsyncValue.guard(() async {
      final repository = ref.read(loginRepositoryProvider);
      userRole = await repository.login(
        LoginRequestModel(email: email, password: password, role: role),
      );
      return userRole;
    });

    return state.hasError ? null : userRole;
  }
}

final loginNotifierProvider = AsyncNotifierProvider<LoginNotifier, String?>(
  LoginNotifier.new,
);
