import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iwitnez/feature/main_user/Profile_section/Profile/model/profile_model.dart';
import 'package:iwitnez/router/app_route_names.dart';

class ProfileController {
  ProfileController();

  void handleMenuTap(BuildContext context, ProfileMenuAction action) {
    switch (action) {
      case ProfileMenuAction.personalInformation:
        context.push(AppRouteNames.personalInfoScreen);
        break;
      case ProfileMenuAction.accountSettings:
        context.push(AppRouteNames.accountSettingsScreen);
        break;
      case ProfileMenuAction.safetySettings:
        context.push(AppRouteNames.safetySettingsScreen);
        break;
      case ProfileMenuAction.notifications:
        context.push(AppRouteNames.notificationScreen);
        break;
      case ProfileMenuAction.trustedCircle:
        debugPrint('Open Trusted Circle');
        break;
      case ProfileMenuAction.helpSupport:
        context.push(AppRouteNames.helpSupportScreen);
        break;
      case ProfileMenuAction.about:
        context.push(AppRouteNames.aboutUsScreen);
        break;
      case ProfileMenuAction.logOut:
        _confirmLogOut(context);
        break;
    }
  }

  void _confirmLogOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // TODO: clear auth/session then redirect
              context.go(AppRouteNames.loginScreen);
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}