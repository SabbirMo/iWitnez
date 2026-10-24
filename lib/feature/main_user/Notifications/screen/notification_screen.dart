import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iwitnez/core/constants/user_role/user_role.dart';
import 'package:iwitnez/feature/trusted_contact/Notifications/screen/trusted_notification_screen.dart';
import '../controller/notification_controller.dart';
import '../model/notification_model.dart';
import '../provider/notification_provider.dart';
import '../widget/notification_card.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  static const List<String> _filterTabs = [
    'All',
    'Today',
    'Yesterday',
    'This Week',
    'Older',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(userRoleProvider);
    if (role == UserRole.trustedContact) {
      return const TrustedNotificationScreen();
    }

    final state = ref.watch(notificationControllerProvider);
    final notifier = ref.read(notificationControllerProvider.notifier);

    final filteredNotifications = state.selectedFilter == 'All'
        ? state.notifications
        : state.notifications
              .where(
                (n) =>
                    n.group.toLowerCase() == state.selectedFilter.toLowerCase(),
              )
              .toList();

    final groupedNotifications = <String, List<NotificationModel>>{};
    for (final notif in filteredNotifications) {
      groupedNotifications.putIfAbsent(notif.group, () => []).add(notif);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.fetchNotifications(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Filter Tabs Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    for (final tab in _filterTabs) ...[
                      _buildFilterChip(tab, state.selectedFilter, notifier),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              if (state.isLoading && state.notifications.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (filteredNotifications.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Text(
                      state.selectedFilter == 'All'
                          ? 'No notifications yet'
                          : 'No notifications for ${state.selectedFilter}',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              else
                for (final entry in groupedNotifications.entries)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12, top: 8),
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      for (final notif in entry.value)
                        NotificationCard(notification: notif),
                      const SizedBox(height: 10),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String tab,
    String selectedFilter,
    NotificationController notifier,
  ) {
    final isSelected = selectedFilter == tab;
    return GestureDetector(
      onTap: () => notifier.changeFilter(tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.deepPurple : const Color(0xFFE5E7EB),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.deepPurple.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          tab,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
