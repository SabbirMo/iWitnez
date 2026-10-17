import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/network/api_endpoint/api_end_point.dart';
import 'package:iwitnez/core/network/service/api_services.dart';
import 'package:iwitnez/feature/auth/create_account/model/create_account_request_model.dart';

class CreateAccountRepository {
  final ApiServices _apiServices;

  CreateAccountRepository(this._apiServices);

  Future<void> createAccount(CreateAccountRequestModel request) async {
    await _apiServices.post(
      ApiEndPoints.register,
      data: request.toFormData(),
      requireAuth: false,
    );
  }
}

final createAccountRepositoryProvider = Provider<CreateAccountRepository>(
  (ref) => CreateAccountRepository(ApiServices()),
);
