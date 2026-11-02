import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/network/api_endpoint/api_end_point.dart';
import 'package:iwitnez/core/network/service/api_services.dart';
import 'package:iwitnez/feature/trusted_contact/Home_section/Home/model/home_model.dart';

final trustedHomeRepositoryProvider = Provider<TrustedHomeRepository>((ref) {
  return TrustedHomeRepository();
});

class TrustedHomeRepository {
  final ApiServices _apiServices;

  TrustedHomeRepository([ApiServices? apiServices])
      : _apiServices = apiServices ?? ApiServices();

  /// GET /api/v1/contacts/monitored/dashboard/
  Future<TrustedDashboardResponseModel> getDashboard() async {
    final response = await _apiServices.get(
      ApiEndPoints.trustedDashboard,
      requireAuth: true,
    );

    if (response.data is Map<String, dynamic>) {
      return TrustedDashboardResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    }

    return const TrustedDashboardResponseModel(
      success: false,
      message: 'Invalid response from server',
    );
  }
}

