class ApiBaseUrl {
  static const String _baseUrl = "https://clubby-andy-irksomely.ngrok-free.dev";

  static String get baseUrl => _baseUrl;

  static String get wsBaseUrl {
    if (_baseUrl.startsWith("https://")) {
      return _baseUrl.replaceFirst("https://", "wss://");
    } else if (_baseUrl.startsWith("http://")) {
      return _baseUrl.replaceFirst("http://", "ws://");
    }
    return "wss://clubby-andy-irksomely.ngrok-free.dev";
  }
}
