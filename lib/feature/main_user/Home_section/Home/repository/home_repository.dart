import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/network/api_endpoint/api_end_point.dart';
import 'package:iwitnez/core/network/service/api_services.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/model/live_location_model.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/model/trusted_circles_response_model.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/model/user_profile_response_model.dart';

class HomeRepository {
  final ApiServices _apiServices;

  HomeRepository(this._apiServices);

  Future<UserData?> getProfile() async {
    try {
      final response = await _apiServices.get(
        ApiEndPoints.getProfile,
        requireAuth: true,
      );

      final data = response.data?['data'];
      if (data is Map<String, dynamic>) {
        return UserData.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<int> getUnreadNotificationCount() async {
    try {
      final response = await _apiServices.get(
        ApiEndPoints.notifications,
        requireAuth: true,
      );

      final data = response.data?['data'];
      return (data?['unread_count'] as num?)?.toInt() ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<LiveLocationModel?> getLiveLocation() async {
    try {
      final response = await _apiServices.get(
        ApiEndPoints.liveLocation,
        requireAuth: true,
      );

      final data = response.data?['data'];
      if (data is Map<String, dynamic>) {
        return LiveLocationModel.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<TrustedCirclesResponseModel?> getTrustedCircles() async {
    try {
      final response = await _apiServices.get(
        ApiEndPoints.trustedCircles,
        requireAuth: true,
      );

      final data = response.data?['data'];
      if (data is Map<String, dynamic>) {
        return TrustedCirclesResponseModel.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> pingLocation({
    required double latitude,
    required double longitude,
    String? address,
    double? accuracy,
    double? speed,
    double? heading,
  }) async {
    await _apiServices.post(
      ApiEndPoints.pingLocation,
      data: {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy ?? 5.0,
        'speed': speed ?? 0,
        'heading': heading ?? 0,
        'address': address ?? '',
      },
      requireAuth: true,
    );
  }
}

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ApiServices());
});
