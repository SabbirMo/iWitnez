
import 'package:flutter_riverpod/legacy.dart';
import 'package:iwitnez/feature/main_user/SafetySettings/model/safety_settings_model.dart';
import '../controller/safety_settings_controller.dart';

final safetySettingsControllerProvider =
    StateNotifierProvider<SafetySettingsController, SafetySettingsModel>((ref) {
  return SafetySettingsController();
});