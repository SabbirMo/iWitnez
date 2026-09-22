import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/model/home_model.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/provider/home_provider.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/widget/home_widget.dart';
import 'package:iwitnez/router/app_route_names.dart';

class HomeController {
  HomeController();

  void onNotificationTap(BuildContext context, WidgetRef ref) {
    ref.read(homeProvider.notifier).clearNotificationBadge();
    context.push(AppRouteNames.notificationScreen);
  }

  void onViewFullMapTap(BuildContext context) {
    FullMapBottomSheet.show(context);
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
        FullMapBottomSheet.show(context);
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
    debugPrint('Open Trusted Circle: ${kind.name}');
  }

  void onViewAllTrustedCirclesTap(BuildContext context) {
    debugPrint('View all trusted circles');
  }

  void onSosTap(BuildContext context) {
    debugPrint('SOS triggered');
  }
}