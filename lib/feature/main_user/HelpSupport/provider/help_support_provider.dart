import 'package:flutter_riverpod/legacy.dart';
import '../controller/help_support_controller.dart';
import '../repository/help_support_repository.dart';

final helpSupportControllerProvider = StateNotifierProvider.autoDispose<
    HelpSupportController, HelpSupportState>((ref) {
  final repository = ref.watch(helpSupportRepositoryProvider);
  return HelpSupportController(repository);
});
