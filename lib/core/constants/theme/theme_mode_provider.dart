import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/utils/theme_storage.dart';

class ThemeModeProvider extends Notifier<ThemeMode> {
  final ThemeMode initialTheme;

  ThemeModeProvider({this.initialTheme = ThemeMode.light});

  @override
  ThemeMode build() => initialTheme;

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await ThemeStorage.saveThemeMode(mode);
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = newMode;
    await ThemeStorage.saveThemeMode(newMode);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeProvider, ThemeMode>(
  ThemeModeProvider.new,
);
