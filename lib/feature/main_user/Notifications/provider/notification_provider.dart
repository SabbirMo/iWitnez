import 'package:flutter_riverpod/legacy.dart';
import '../controller/notification_controller.dart';

// Provider definition moved to its own file
final notificationControllerProvider =
    StateNotifierProvider<NotificationController, NotificationState>((ref) {
      return NotificationController();
    });
