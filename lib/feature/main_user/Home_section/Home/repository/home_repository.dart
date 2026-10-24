import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/network/api_endpoint/api_end_point.dart';
import 'package:iwitnez/core/network/service/api_services.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/model/user_profile_response_model.dart';

class HomeRepository {
  final ApiServices _apiServices;

  HomeRepository(this._apiServices);

  Future<UserData> getProfile() async {
    final response = await _apiServices.get(
      ApiEndPoints.getProfile,
      requireAuth: true,
    );

    return UserData.fromJson(response.data['data']);
  }
}

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ApiServices());
});
