import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../controller/personal_info_controller.dart';

final personalInfoControllerProvider =
    StateNotifierProvider<PersonalInfoController, PersonalInfoState>((ref) {
  return PersonalInfoController();
});