import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iwitnez/core/network/service/api_services.dart';
import 'package:iwitnez/feature/auth/login/repository/login_repository.dart';
import 'package:iwitnez/feature/main_user/Profile_section/Profile/model/profile_model.dart';
import 'package:iwitnez/router/app_route_names.dart';

class ProfileController {
  ProfileController();

  Future<void> handleMenuTap(
    BuildContext context,
    ProfileMenuAction action,
  ) async {
    switch (action) {
      case ProfileMenuAction.personalInformation:
        await context.push(AppRouteNames.personalInfoScreen);
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
        context.push(AppRouteNames.trustedCircleScreen);
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
    bool isLoggingOut = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Log Out'),
          content: isLoggingOut
              ? const SizedBox(
                  height: 48,
                  child: Center(child: CircularProgressIndicator()),
                )
              : const Text('Are you sure you want to log out?'),
          actions: isLoggingOut
              ? null
              : [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      setDialogState(() => isLoggingOut = true);
                      await LoginRepository(ApiServices()).logout();
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                      if (context.mounted) {
                        context.go(AppRouteNames.loginScreen);
                      }
                    },
                    child: const Text(
                      'Log Out',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
        ),
      ),
    );
  }
}
