import 'package:iwitnez/core/network/base_url/api_base_url.dart';

class ApiEndPoints {
  // authentication Endpoints
  static const String login = '/api/v1/auth/login/';
  static const String register = '/api/v1/auth/register/';
  static const String logout = '/api/v1/auth/logout/';
  static const String refreshToken = '/api/v1/auth/token/refresh/';
  static const String verifyEmail = '/api/v1/auth/verify-email/';
  static const String resendOtp = '/api/v1/auth/resend-otp/';
  static const String forgotPassword = '/api/v1/auth/password/forgot/';
  static const String verifyPasswordOtp = '/api/v1/auth/password/verify-otp/';
  static const String resetPassword = '/api/v1/auth/password/reset/';
  static const String getProfile = '/api/v1/auth/me/';
  static const String deviceSettings = '/api/v1/auth/device-settings/';
  static const String safetySettings = '/api/v1/auth/safety-settings/';
  static const String notifications = '/api/v1/notifications/';
  static const String notificationsToggle = '/api/v1/notifications/toggle/';
  static String notificationMarkRead(String id) =>
      '/api/v1/notifications/$id/read/';
  static const String notificationsReadAll = '/api/v1/notifications/read-all/';
  static const String liveLocation = '/api/v1/location/live/';
  static const String pingLocation = '/api/v1/location/ping/';
  static const String safetyTracking = '/api/v1/location/safety-tracking/';
  static const String safePlaces = '/api/v1/location/safe-places/';
  static const String locationHistory = '/api/v1/location/history/';
  static const String contacts = '/api/v1/contacts/';
  static const String trustedCircles = '/api/v1/contacts/circles/';

  // Chat Endpoints
  static const String chatConversations = '/api/v1/chat/conversations/';
  static String chatMessages(String conversationId) =>
      '/api/v1/chat/conversations/$conversationId/messages/';
  static String chatMarkRead(String conversationId) =>
      '/api/v1/chat/conversations/$conversationId/read/';
  static String chatDirect(String targetUserId) =>
      '/api/v1/chat/conversations/direct/$targetUserId/';
  static String chatWebSocketUrl(String conversationId, String token) =>
      '${ApiBaseUrl.wsBaseUrl}/ws/chat/$conversationId/?token=$token';

  // Call Signaling Endpoints
  static const String calls = '/api/v1/calls/';
  static const String callsInitiate = '/api/v1/calls/initiate/';
  static String callRespond(String callId) => '/api/v1/calls/$callId/respond/';
  static String callToken(String callId) => '/api/v1/calls/$callId/token/';
  static String callEnd(String callId) => '/api/v1/calls/$callId/end/';

  // Contact Profile & Actions
  static String contactDetails(String contactId) => '/api/v1/contacts/$contactId/';
  static String contactMove(String contactId) => '/api/v1/contacts/$contactId/move/';
  static const String locationManageSharing = '/api/v1/location/manage-sharing/';

  // Emergency SOS Endpoints
  static const String sosStart = '/api/v1/emergency/sos/start/';
  static String sosActivate(String id) => '/api/v1/emergency/sos/$id/activate/';
  static String sosCancel(String id) => '/api/v1/emergency/sos/$id/cancel/';
  static const String sosActive = '/api/v1/emergency/sos/active/';
  static String sosStop(String id) => '/api/v1/emergency/sos/$id/stop/';
  static String sosUploadRecording(String id) => '/api/v1/emergency/sos/$id/recording/';
}
