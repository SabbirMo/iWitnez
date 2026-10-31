import 'package:flutter_riverpod/legacy.dart';
import 'package:iwitnez/feature/main_user/Profile_section/Profile/repository/profile_repository.dart';
import '../controller/personal_info_controller.dart';

final personalInfoControllerProvider =
    StateNotifierProvider<PersonalInfoController, PersonalInfoState>((ref) {
      final repository = ref.watch(profileRepositoryProvider);
      return PersonalInfoController(repository);
    });
