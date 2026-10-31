import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:iwitnez/feature/main_user/Profile_section/Profile/repository/profile_repository.dart';
import 'package:iwitnez/feature/main_user/SafetySettings/model/safety_settings_model.dart';
import 'package:iwitnez/feature/main_user/SafetySettings/repository/safety_settings_repository.dart';

class SafetySettingsController extends StateNotifier<SafetySettingsModel> {
  final SafetySettingsRepository _repository;

  SafetySettingsController([SafetySettingsRepository? repository])
      : _repository = repository ?? SafetySettingsRepository(),
        super(_initialState()) {
    loadSettings();
  }

  static SafetySettingsModel _initialState() {
    final cached = ProfileRepository().cachedProfile?.safetySettings;
    if (cached != null) {
      return SafetySettingsModel(
        sosAlerts: cached.sosAlertsEnabled,
        liveLocationEmergency: cached.liveLocationEmergencyEnabled,
        safePlacesAlerts: cached.safePlacesAlertsEnabled,
        safePlaceSuggestions: cached.safePlaceSuggestionsEnabled,
        doNotDisturb: cached.doNotDisturb,
      );
    }
    return const SafetySettingsModel();
  }

  /// Fetches latest safety settings from GET /api/v1/auth/safety-settings/
  Future<void> loadSettings() async {
    try {
      final settings = await _repository.getSafetySettings();
      if (settings != null) {
        state = settings;
      }
    } catch (e) {
      debugPrint('[SafetySettingsController] loadSettings error: $e');
    }
  }

  /// Toggle SOS Alerts immediately on UI, then send PATCH to backend
  void toggleSosAlerts(bool value) async {
    final prev = state.sosAlerts;
    // Optimistic UI update - changes switch immediately
    state = state.copyWith(sosAlerts: value);

    try {
      final updated = await _repository.updateSafetySettings({
        'sos_alerts_enabled': value,
      });
      if (updated != null) {
        state = updated;
      }
    } catch (e) {
      debugPrint('[SafetySettingsController] toggleSosAlerts error: $e');
      // Rollback on failure silently without any snackbar
      state = state.copyWith(sosAlerts: prev);
    }
  }

  /// Toggle Safe Places Alerts immediately on UI, then send PATCH to backend
  void toggleSafePlacesAlerts(bool value) async {
    final prev = state.safePlacesAlerts;
    state = state.copyWith(safePlacesAlerts: value);

    try {
      final updated = await _repository.updateSafetySettings({
        'safe_places_alerts_enabled': value,
      });
      if (updated != null) {
        state = updated;
      }
    } catch (e) {
      debugPrint('[SafetySettingsController] toggleSafePlacesAlerts error: $e');
      state = state.copyWith(safePlacesAlerts: prev);
    }
  }

  /// Toggle Safe Place Suggestions immediately on UI, then send PATCH to backend
  void toggleSafePlaceSuggestions(bool value) async {
    final prev = state.safePlaceSuggestions;
    state = state.copyWith(safePlaceSuggestions: value);

    try {
      final updated = await _repository.updateSafetySettings({
        'safe_place_suggestions_enabled': value,
      });
      if (updated != null) {
        state = updated;
      }
    } catch (e) {
      debugPrint('[SafetySettingsController] toggleSafePlaceSuggestions error: $e');
      state = state.copyWith(safePlaceSuggestions: prev);
    }
  }

  /// Toggle Do Not Disturb immediately on UI, then send PATCH to backend
  void toggleDoNotDisturb(bool value) async {
    final prev = state.doNotDisturb;
    state = state.copyWith(doNotDisturb: value);

    try {
      final updated = await _repository.updateSafetySettings({
        'do_not_disturb': value,
      });
      if (updated != null) {
        state = updated;
      }
    } catch (e) {
      debugPrint('[SafetySettingsController] toggleDoNotDisturb error: $e');
      state = state.copyWith(doNotDisturb: prev);
    }
  }
}
