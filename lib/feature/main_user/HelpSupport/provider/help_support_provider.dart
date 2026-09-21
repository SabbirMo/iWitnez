
import 'package:flutter_riverpod/legacy.dart';
import '../controller/help_support_controller.dart';

final helpSupportControllerProvider =
    StateNotifierProvider<HelpSupportController, HelpSupportState>((ref) {
  return HelpSupportController();
});