import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:iwitnez/core/services/fcm_service.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/provider/home_provider.dart';
import 'package:iwitnez/feature/main_user/Notifications/repository/notification_repository.dart';
import '../model/notification_model.dart';

class NotificationState {
  final List<NotificationModel> notifications;
  final Map<String, List<NotificationModel>> sections;
  final int unreadCount;
  final bool isLoading;
  final bool isMarkingAll;

  NotificationState({
    required this.notifications,
    this.sections = const {},
    this.unreadCount = 0,
    this.isLoading = false,
    this.isMarkingAll = false,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    Map<String, List<NotificationModel>>? sections,
    int? unreadCount,
    bool? isLoading,
    bool? isMarkingAll,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      sections: sections ?? this.sections,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      isMarkingAll: isMarkingAll ?? this.isMarkingAll,
    );
  }
}

class NotificationController extends StateNotifier<NotificationState> {
  final NotificationRepository _repository;
  final Ref? _ref;
  StreamSubscription<RemoteMessage>? _fcmSubscription;

  NotificationController(this._repository, [this._ref])
    : super(NotificationState(notifications: [])) {
    fetchNotifications();
    _listenToFcm();
  }

  void _listenToFcm() {
    _fcmSubscription = FcmService.onNotificationReceived.stream.listen((
      message,
    ) {
      debugPrint(
        '[NotificationController] Real-time FCM message received. Refreshing notifications feed...',
      );
      fetchNotifications(isSilent: true);
      // Secondary check after short delay to ensure DB write is propagated
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          fetchNotifications(isSilent: true);
        }
      });
    });
  }

  @override
  void dispose() {
    _fcmSubscription?.cancel();
    super.dispose();
  }

  Future<void> fetchNotifications({bool isSilent = false}) async {
    if (!isSilent && state.notifications.isEmpty) {
      state = state.copyWith(isLoading: true);
    }
    try {
      final data = await _repository.getNotifications();
      final unreadCount = (data['unread_count'] as num?)?.toInt() ?? 0;
      final rawSections = data['sections'];
      final List<NotificationModel> flatList = [];
      final Map<String, List<NotificationModel>> groupedMap = {};

      const orderedKeys = ['today', 'yesterday', 'this_week', 'older'];

      if (rawSections is Map<String, dynamic>) {
        for (final key in orderedKeys) {
          final items = rawSections[key];
          if (items is List && items.isNotEmpty) {
            final groupTitle = _formatGroupName(key);
            final List<NotificationModel> groupItems = [];
            for (final item in items) {
              if (item is Map<String, dynamic>) {
                final model = NotificationModel.fromJson(
                  item,
                  group: groupTitle,
                );
                groupItems.add(model);
                flatList.add(model);
              }
            }
            if (groupItems.isNotEmpty) {
              groupedMap[groupTitle] = groupItems;
            }
          }
        }

        // Add any remaining keys that weren't in orderedKeys
        rawSections.forEach((key, items) {
          if (!orderedKeys.contains(key.toLowerCase()) &&
              items is List &&
              items.isNotEmpty) {
            final groupTitle = _formatGroupName(key);
            final List<NotificationModel> groupItems = [];
            for (final item in items) {
              if (item is Map<String, dynamic>) {
                final model = NotificationModel.fromJson(
                  item,
                  group: groupTitle,
                );
                groupItems.add(model);
                flatList.add(model);
              }
            }
            if (groupItems.isNotEmpty) {
              groupedMap[groupTitle] = groupItems;
            }
          }
        });
      } else if (data['notifications'] is List) {
        final list = data['notifications'] as List;
        final List<NotificationModel> groupItems = [];
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            final model = NotificationModel.fromJson(item, group: 'Today');
            groupItems.add(model);
            flatList.add(model);
          }
        }
        if (groupItems.isNotEmpty) {
          groupedMap['Today'] = groupItems;
        }
      }

      state = state.copyWith(
        notifications: flatList,
        sections: groupedMap,
        unreadCount: unreadCount,
        isLoading: false,
      );

      _ref
          ?.read(homeProvider.notifier)
          .updateUnreadNotificationCount(unreadCount);
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

  Future<void> markAsRead(String id) async {
    // Optimistic update
    final updatedNotifications = state.notifications.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    final updatedSections = <String, List<NotificationModel>>{};
    state.sections.forEach((k, list) {
      updatedSections[k] = list.map((n) {
        if (n.id == id) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();
    });

    final newUnreadCount = state.unreadCount > 0 ? state.unreadCount - 1 : 0;

    state = state.copyWith(
      notifications: updatedNotifications,
      sections: updatedSections,
      unreadCount: newUnreadCount,
    );

    _ref
        ?.read(homeProvider.notifier)
        .updateUnreadNotificationCount(newUnreadCount);

    await _repository.markAsRead(id);
  }

  Future<void> markAllAsRead() async {
    if (state.isMarkingAll ||
        (state.unreadCount == 0 &&
            state.notifications.every((n) => n.isRead))) {
      return;
    }

    state = state.copyWith(isMarkingAll: true);

    final updatedNotifications = state.notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    final updatedSections = <String, List<NotificationModel>>{};
    state.sections.forEach((k, list) {
      updatedSections[k] = list.map((n) => n.copyWith(isRead: true)).toList();
    });

    state = state.copyWith(
      notifications: updatedNotifications,
      sections: updatedSections,
      unreadCount: 0,
    );

    _ref?.read(homeProvider.notifier).clearNotificationBadge();

    try {
      await _repository.markAllAsRead();
    } finally {
      state = state.copyWith(isMarkingAll: false);
    }
  }
}
