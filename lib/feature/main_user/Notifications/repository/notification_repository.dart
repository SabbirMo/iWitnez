import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/network/api_endpoint/api_end_point.dart';
import 'package:iwitnez/core/network/service/api_services.dart';

class NotificationRepository {
  final ApiServices _apiServices;

  NotificationRepository([ApiServices? apiServices])
    : _apiServices = apiServices ?? ApiServices();

  /// Component 2.1: Fetch Grouped Notifications Feed
  Future<Map<String, dynamic>> getNotifications() async {
    final response = await _apiServices.get(
      ApiEndPoints.notifications,
      requireAuth: true,
    );

    return response.data?['data'] ?? {};
  }

  /// Component 2.2: Mark Single Notification as Read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await _apiServices.post(
        ApiEndPoints.notificationMarkRead(notificationId),
        data: {},
        requireAuth: true,
      );
      return response.data?['success'] == true || response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Component 2.3: Mark All Notifications as Read
  Future<int> markAllAsRead() async {
    try {
      final response = await _apiServices.post(
        ApiEndPoints.notificationsReadAll,
        data: {},
        requireAuth: true,
      );
      final updatedCount = response.data?['data']?['updated_count'];
      return (updatedCount as num?)?.toInt() ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Component 2.4: Fetch Current Toggle Status (GET /api/v1/notifications/toggle/)
  Future<bool> getNotificationToggleStatus() async {
    try {
      final res = await _apiServices.get(
        ApiEndPoints.notificationsToggle,
        requireAuth: true,
      );
      return res.data?['data']?['notifications_enabled'] ?? false;
    } catch (e) {
      debugPrint('[NotificationRepo] Error fetching toggle status: $e');
      return false;
    }
  }

  /// Component 2.5: Turn Push Notifications ON or OFF (POST /api/v1/notifications/toggle/)
  Future<bool> setNotificationEnabled(
    bool enabled, {
    String? fcmDeviceToken,
  }) async {
    try {
      final data = <String, dynamic>{'enabled': enabled};
      if (fcmDeviceToken != null && fcmDeviceToken.isNotEmpty) {
        data['fcm_device_token'] = fcmDeviceToken;
      }
      final res = await _apiServices.post(
        ApiEndPoints.notificationsToggle,
        data: data,
        requireAuth: true,
      );
      return res.data?['data']?['notifications_enabled'] ?? enabled;
    } catch (e) {
      debugPrint('[NotificationRepo] Error updating notification toggle: $e');
      return false;
    }
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ApiServices());
});
