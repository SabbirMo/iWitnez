class SafetySettingsModel {
  final bool sosAlerts;
  final bool safePlacesAlerts;
  final bool safePlaceSuggestions;
  final bool doNotDisturb;

  SafetySettingsModel({
    required this.sosAlerts,
    required this.safePlacesAlerts,
    required this.safePlaceSuggestions,
    required this.doNotDisturb,
  });

  SafetySettingsModel copyWith({
    bool? sosAlerts,
    bool? safePlacesAlerts,
    bool? safePlaceSuggestions,
    bool? doNotDisturb,
  }) {
    return SafetySettingsModel(
      sosAlerts: sosAlerts ?? this.sosAlerts,
      safePlacesAlerts: safePlacesAlerts ?? this.safePlacesAlerts,
      safePlaceSuggestions: safePlaceSuggestions ?? this.safePlaceSuggestions,
      doNotDisturb: doNotDisturb ?? this.doNotDisturb,
    );
  }
}