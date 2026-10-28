import 'package:flutter_riverpod/legacy.dart';
import 'package:iwitnez/feature/main_user/Notifications/repository/notification_repository.dart';
import '../controller/notification_controller.dart';

final notificationControllerProvider =
    StateNotifierProvider<NotificationController, NotificationState>((ref) {
  final repository = ref.read(notificationRepositoryProvider);
  return NotificationController(repository, ref);
});
