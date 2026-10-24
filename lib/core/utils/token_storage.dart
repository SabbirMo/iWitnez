import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();

  static const String _accessTokenKey = "accessToken";
  static const String _refreshTokenKey = "refreshToken";

  static Future<void> saveAccessToken(String token) async {
    try {
      await _storage.write(key: _accessTokenKey, value: token);
    } catch (e) {
      debugPrint("TokenStorage.saveAccessToken error: $e");
    }
  }

  static Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: token);
    } catch (e) {
      debugPrint("TokenStorage.saveRefreshToken error: $e");
    }
  }

  static Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      debugPrint("TokenStorage.getAccessToken error: $e");
      return null;
    }
  }

  static Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      debugPrint("TokenStorage.getRefreshToken error: $e");
      return null;
    }
  }

  static const String _userRoleKey = "userRole";

  static Future<void> saveUserRole(String role) async {
    try {
      await _storage.write(key: _userRoleKey, value: role);
    } catch (e) {
      debugPrint("TokenStorage.saveUserRole error: $e");
    }
  }

  static Future<String?> getUserRole() async {
    try {
      return await _storage.read(key: _userRoleKey);
    } catch (e) {
      debugPrint("TokenStorage.getUserRole error: $e");
      return null;
    }
  }

  static Future<void> clearTokens() async {
    try {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _userRoleKey);
    } catch (e) {
      debugPrint("TokenStorage.clearTokens error: $e");
    }
  }

  static Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    if (token == null || token.trim().isEmpty) {
      return false;
    }

    try {
      final parts = token.split('.');
      if (parts.length == 3) {
        final normalized = base64Url.normalize(parts[1]);
        final decoded = utf8.decode(base64Url.decode(normalized));
        final Map<String, dynamic> payload = json.decode(decoded);
        if (payload['exp'] is int) {
          final exp = payload['exp'] as int;
          final expDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
          if (DateTime.now().isAfter(expDate)) {
            // Access token has expired; check if refresh token exists to renew it
            final refreshToken = await getRefreshToken();
            return refreshToken != null && refreshToken.trim().isNotEmpty;
          }
        }
      }
    } catch (_) {
      // If token decoding fails (e.g. non-JWT token), assume valid based on existence
    }

    return true;
  }
}
