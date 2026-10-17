import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/feature/auth/create_account/model/create_account_request_model.dart';
import 'package:iwitnez/feature/auth/create_account/repository/create_account_repository.dart';

class CreateAccountNotifer extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    return;
  }

  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required bool terms,
    required String role,
  }) async {
    state = const AsyncValue.loading();

    //use repository
    state = await AsyncValue.guard(() async {
      final repository = ref.read(createAccountRepositoryProvider);

      final requestModel = CreateAccountRequestModel(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        terms: terms,
        role: role,
      );

      //The repository was instructed to send data to the server.
      await repository.createAccount(requestModel);
    });

    return !state.hasError;
  }
}

final createAccountNotiferProvider =
    AsyncNotifierProvider<CreateAccountNotifer, void>(CreateAccountNotifer.new);
