import 'package:flutter_riverpod/legacy.dart';
import 'package:iwitnez/feature/main_user/SafetySettings/model/safety_settings_model.dart';
import 'package:iwitnez/feature/main_user/SafetySettings/repository/safety_settings_repository.dart';
import '../controller/safety_settings_controller.dart';

final safetySettingsControllerProvider =
    StateNotifierProvider<SafetySettingsController, SafetySettingsModel>((ref) {
  final repository = ref.watch(safetySettingsRepositoryProvider);
  return SafetySettingsController(repository);
});
