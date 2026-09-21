
import 'package:flutter_riverpod/legacy.dart';

import '../controller/about_us_controller.dart';

final aboutUsControllerProvider =
    StateNotifierProvider<AboutUsController, AboutUsState>((ref) {
  return AboutUsController();
});