import 'package:flutter_riverpod/legacy.dart';
import 'package:iwitnez/feature/main_user/Notifications/repository/notification_repository.dart';
import '../model/notification_model.dart';

class NotificationState {
  final List<NotificationModel> notifications;
  final String selectedFilter;
  final bool isLoading;

  NotificationState({
    required this.notifications,
    this.selectedFilter = "All",
    this.isLoading = false,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    String? selectedFilter,
    bool? isLoading,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NotificationController extends StateNotifier<NotificationState> {
  final NotificationRepository _repository;

  NotificationController(this._repository)
      : super(NotificationState(notifications: [])) {
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _repository.getNotifications();
      final sections = data['sections'];
      final List<NotificationModel> parsed = [];

      if (sections is Map<String, dynamic>) {
        sections.forEach((key, value) {
          final groupTitle = _formatGroupName(key);
          if (value is List) {
            for (var item in value) {
              if (item is Map<String, dynamic>) {
                parsed.add(
                  NotificationModel.fromJson(item, group: groupTitle),
                );
              }
            }
          }
        });
      }

      state = state.copyWith(
        notifications: parsed,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  String _formatGroupName(String key) {
    switch (key.toLowerCase()) {
      case 'today':
        return 'Today';
      case 'yesterday':
        return 'Yesterday';
      case 'this_week':
        return 'This Week';
      case 'older':
        return 'Older';
      default:
        return key.isNotEmpty
            ? '${key[0].toUpperCase()}${key.substring(1)}'
            : 'Other';
    }
  }

  void changeFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }
}
