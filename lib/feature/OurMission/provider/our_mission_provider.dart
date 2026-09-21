
import 'package:flutter_riverpod/legacy.dart';
import '../controller/our_mission_controller.dart';

final ourMissionControllerProvider =
    StateNotifierProvider<OurMissionController, OurMissionState>((ref) {
  return OurMissionController();
});