import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iwitnez/feature/trusted_contact/Home_section/Home/model/home_model.dart';
import 'package:iwitnez/feature/trusted_contact/Home_section/Home/provider/home_provider.dart';
import 'package:iwitnez/router/app_route_names.dart';

class TrustedHomeController {
  const TrustedHomeController();

  void onNotificationTap(BuildContext context, WidgetRef ref) {
    ref.read(trustedHomeProvider.notifier).clearNotification();
    context.push(AppRouteNames.notificationScreen);
  }

  void onViewFullMapTap(BuildContext context) {
    context.push(AppRouteNames.trustedLiveLocationScreen);
  }

  void onCheckInStatusTap(BuildContext context) {
    context.push(AppRouteNames.checkInScreen);
  }

  void onJourneyEtaTap(BuildContext context) {
    context.push(AppRouteNames.safetyTrackingScreen);
  }

  void onViewAllActivityTap(BuildContext context) {
    context.go(AppRouteNames.trustedAlerts);
  }

  void onActivityItemTap(BuildContext context, TrustedActivityItem item) {
    context.go(AppRouteNames.trustedAlerts);
  }
}
