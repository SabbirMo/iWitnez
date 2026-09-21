import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../model/notification_model.dart';

class NotificationState {
  final List<NotificationModel> notifications;
  final String selectedFilter;

  NotificationState({
    required this.notifications,
    this.selectedFilter = "All",
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    String? selectedFilter,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}

class NotificationController extends StateNotifier<NotificationState> {
  NotificationController() : super(NotificationState(notifications: [])) {
    _loadMockData();
  }

  void _loadMockData() {
    final mockData = [
      NotificationModel(id: '1', title: 'Safety Alert', subtitle: 'Emma (You) triggered SOS.', time: '10:45 AM', type: NotificationType.safetyAlert, isUnread: true, group: 'Today'),
      NotificationModel(id: '2', title: 'Live Location', subtitle: 'Sarah Khan started sharing live location with you.', time: '9:30 AM', type: NotificationType.liveLocation, isUnread: true, group: 'Today'),
      NotificationModel(id: '3', title: 'Check-In Update', subtitle: 'Amit Sharma checked in at Home.', time: '8:15 AM', type: NotificationType.checkIn, isUnread: true, group: 'Today'),
      NotificationModel(id: '4', title: 'Missed Call', subtitle: 'You missed a call from Mom.', time: '9:20 PM', type: NotificationType.missedCall, group: 'Yesterday'),
      NotificationModel(id: '5', title: 'Safety Alert', subtitle: 'Ali Raza triggered SOS.', time: '7:45 PM', type: NotificationType.safetyAlert, group: 'Yesterday'),
      NotificationModel(id: '6', title: 'Scheduled Check-In', subtitle: 'Reminder: You have a check-in scheduled at 10:00 PM.', time: '6:30 PM', type: NotificationType.scheduledCheckIn, group: 'Yesterday'),
      NotificationModel(id: '7', title: 'Trusted Circle Update', subtitle: 'Priya Patel updated the trusted circle.', time: '5:10 PM', type: NotificationType.trustedCircle, group: 'Yesterday'),
      NotificationModel(id: '8', title: 'System Update', subtitle: 'Your app is up to date.', time: 'Mon 3:15 PM', type: NotificationType.systemUpdate, group: 'This Week'),
      NotificationModel(id: '9', title: 'Announcement', subtitle: 'New safety features are now available.', time: 'Mon 11:00 AM', type: NotificationType.announcement, group: 'This Week'),
    ];

    state = state.copyWith(notifications: mockData);
  }

  void changeFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }
}