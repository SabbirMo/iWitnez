
import 'package:flutter_riverpod/legacy.dart';
import '../model/safety_settings_model.dart';

class SafetySettingsController extends StateNotifier<SafetySettingsModel> {
  SafetySettingsController()
      : super(
          SafetySettingsModel(
            sosAlerts: true,
            safePlacesAlerts: true,
            safePlaceSuggestions: false,
            doNotDisturb: false,
          ),
        );

  void toggleSosAlerts(bool value) {
    state = state.copyWith(sosAlerts: value);
  }

  void toggleSafePlacesAlerts(bool value) {
    state = state.copyWith(safePlacesAlerts: value);
  }

  void toggleSafePlaceSuggestions(bool value) {
    state = state.copyWith(safePlaceSuggestions: value);
  }

  void toggleDoNotDisturb(bool value) {
    state = state.copyWith(doNotDisturb: value);
  }
}