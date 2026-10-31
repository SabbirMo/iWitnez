import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeStorage {
  static const _storage = FlutterSecureStorage();
  static const String _themeModeKey = "app_theme_mode";

  static Future<void> saveThemeMode(ThemeMode mode) async {
    try {
      final value = mode == ThemeMode.dark ? 'dark' : 'light';
      await _storage.write(key: _themeModeKey, value: value);
    } catch (e) {
      debugPrint("ThemeStorage.saveThemeMode error: $e");
    }
  }

  static Future<ThemeMode> getThemeMode() async {
    try {
      final value = await _storage.read(key: _themeModeKey);
      if (value == 'dark') {
        return ThemeMode.dark;
      }
      return ThemeMode.light;
    } catch (e) {
      debugPrint("ThemeStorage.getThemeMode error: $e");
      return ThemeMode.light;
    }
  }
}

