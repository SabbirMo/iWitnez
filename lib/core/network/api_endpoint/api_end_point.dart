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
  static const String notifications = '/api/v1/notifications/';
  static const String liveLocation = '/api/v1/location/live/';
  static const String pingLocation = '/api/v1/location/ping/';
  static const String contacts = '/api/v1/contacts/';
  static const String trustedCircles = '/api/v1/contacts/circles/';
}
