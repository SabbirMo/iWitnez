class SafetySettingsModel {
  final bool sosAlerts;
  final bool safePlacesAlerts;
  final bool safePlaceSuggestions;
  final bool doNotDisturb;
  final bool liveLocationEmergency;

  const SafetySettingsModel({
    this.sosAlerts = true,
    this.safePlacesAlerts = true,
    this.safePlaceSuggestions = false,
    this.doNotDisturb = false,
    this.liveLocationEmergency = true,
  });

  static bool _toBool(dynamic val, bool fallback) {
    if (val is bool) return val;
    if (val is num) return val == 1;
    if (val is String) {
      final lower = val.toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    return fallback;
  }

  factory SafetySettingsModel.fromJson(Map<String, dynamic> json) {
    return SafetySettingsModel(
      sosAlerts: _toBool(
        json['sos_alerts_enabled'] ?? json['sos_alerts'],
        true,
      ),
      safePlacesAlerts: _toBool(
        json['safe_places_alerts_enabled'] ?? json['safe_places_alerts'],
        true,
      ),
      safePlaceSuggestions: _toBool(
        json['safe_place_suggestions_enabled'] ?? json['safe_place_suggestions'],
        false,
      ),
      doNotDisturb: _toBool(
        json['do_not_disturb'],
        false,
      ),
      liveLocationEmergency: _toBool(
        json['live_location_emergency_enabled'] ?? json['live_location_sharing'],
        true,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sos_alerts_enabled': sosAlerts,
      'live_location_emergency_enabled': liveLocationEmergency,
      'safe_places_alerts_enabled': safePlacesAlerts,
      'safe_place_suggestions_enabled': safePlaceSuggestions,
      'do_not_disturb': doNotDisturb,
    };
  }

  SafetySettingsModel copyWith({
    bool? sosAlerts,
    bool? safePlacesAlerts,
    bool? safePlaceSuggestions,
    bool? doNotDisturb,
    bool? liveLocationEmergency,
  }) {
    return SafetySettingsModel(
      sosAlerts: sosAlerts ?? this.sosAlerts,
      safePlacesAlerts: safePlacesAlerts ?? this.safePlacesAlerts,
      safePlaceSuggestions: safePlaceSuggestions ?? this.safePlaceSuggestions,
      doNotDisturb: doNotDisturb ?? this.doNotDisturb,
      liveLocationEmergency:
          liveLocationEmergency ?? this.liveLocationEmergency,
    );
  }
}
