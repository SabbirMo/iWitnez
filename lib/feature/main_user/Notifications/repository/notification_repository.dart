import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/network/api_endpoint/api_end_point.dart';
import 'package:iwitnez/core/network/service/api_services.dart';

class NotificationRepository {
  final ApiServices _apiServices;

  NotificationRepository(this._apiServices);

  Future<Map<String, dynamic>> getNotifications() async {
    final response = await _apiServices.get(
      ApiEndPoints.notifications,
      requireAuth: true,
    );

    return response.data?['data'] ?? {};
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ApiServices());
});
