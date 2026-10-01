import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/model/home_model.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/provider/home_provider.dart';
import 'package:iwitnez/feature/main_user/Sos_section/screen/sos_countdown_screen.dart';
import 'package:iwitnez/router/app_route_names.dart';

class HomeController {
  HomeController();

  void onNotificationTap(BuildContext context, WidgetRef ref) {
    ref.read(homeProvider.notifier).clearNotificationBadge();
    context.push(AppRouteNames.notificationScreen);
  }

  void onViewFullMapTap(BuildContext context) {
    context.push(AppRouteNames.liveLocationScreen);
  }

  void onToggleSharing(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Live location sharing updated'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void onQuickActionTap(BuildContext context, QuickActionType type) {
    switch (type) {
      case QuickActionType.safety:
        context.push(AppRouteNames.safetyTrackingScreen);
        break;
      case QuickActionType.checkIn:
        debugPrint('Open Check In');
        break;
      case QuickActionType.scheduledTimer:
        debugPrint('Open Scheduled & Timer');
        break;
    }
  }

  void onTrustedCircleTap(BuildContext context, TrustedCircleKind kind) {
    context.push(AppRouteNames.trustedCircleScreen);
  }

  void onViewAllTrustedCirclesTap(BuildContext context) {
    context.push(AppRouteNames.trustedCircleScreen);
  }

  void onSosTap(BuildContext context) {
    try {
      context.push(AppRouteNames.sosCountdownScreen);
    } catch (_) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SosCountdownScreen()),
      );
    }
  }
}