import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeModeProvider extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.light;

  void set(ThemeMode mode) {
    state = mode;
  }

  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeProvider, ThemeMode>(
  ThemeModeProvider.new,
);
