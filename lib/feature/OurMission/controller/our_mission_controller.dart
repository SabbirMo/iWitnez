import 'package:flutter_riverpod/legacy.dart';
import '../model/our_mission_model.dart';

class OurMissionState {
  final OurMissionModel missionData;

  OurMissionState({
    required this.missionData,
  });

  OurMissionState copyWith({
    OurMissionModel? missionData,
  }) {
    return OurMissionState(
      missionData: missionData ?? this.missionData,
    );
  }
}

class OurMissionController extends StateNotifier<OurMissionState> {
  OurMissionController()
      : super(
          OurMissionState(
            missionData: OurMissionModel(
              title: 'Making Safety Simple\nand Accessible for Everyone',
              description:
                  'Our mission is to empower individuals and communities with smart safety tools that help them stay protected and connected in every situation.',
            ),
          ),
        );

  // Method to update text if needed in the future
  void updateMission(String newTitle, String newDescription) {
    state = state.copyWith(
      missionData: state.missionData.copyWith(
        title: newTitle,
        description: newDescription,
      ),
    );
  }
}