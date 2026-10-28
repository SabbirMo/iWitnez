import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iwitnez/core/constants/app_string/app_string.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/text_style/custom_text_style.dart';
import 'package:iwitnez/core/services/fcm_service.dart';
import 'package:iwitnez/feature/main_user/Profile_section/Profile/controller/profile_controller.dart';
import 'package:iwitnez/feature/main_user/Profile_section/Profile/model/profile_model.dart';
import 'package:iwitnez/feature/main_user/Profile_section/Profile/provider/profile_provider.dart';
import 'package:iwitnez/feature/main_user/Profile_section/Profile/widget/profile_widget.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with WidgetsBindingObserver {
  final ProfileProvider _provider = ProfileProvider();
  final ProfileController _controller = ProfileController();

  bool _isNotificationEnabled = false;
  bool _isUpdatingNotification = false;

  static final List<ProfileMenuItem> _mainMenu = [
    const ProfileMenuItem(
      action: ProfileMenuAction.personalInformation,
      label: 'Personal Information',
      icon: Icons.person_outline_rounded,
    ),
    const ProfileMenuItem(
      action: ProfileMenuAction.accountSettings,
      label: 'Account Settings',
      icon: Icons.shield_outlined,
    ),
    const ProfileMenuItem(
      action: ProfileMenuAction.safetySettings,
      label: 'Safety Settings',
      icon: Icons.shield_outlined,
    ),
    const ProfileMenuItem(
      action: ProfileMenuAction.notifications,
      label: 'Notifications',
      icon: Icons.notifications_outlined,
    ),
    const ProfileMenuItem(
      action: ProfileMenuAction.trustedCircle,
      label: 'Trusted Circle',
      icon: Icons.person_outline_rounded,
    ),
    const ProfileMenuItem(
      action: ProfileMenuAction.helpSupport,
      label: 'Help & Support',
      icon: Icons.help_outline_rounded,
    ),
  ];

  static const ProfileMenuItem _aboutItem = ProfileMenuItem(
    action: ProfileMenuAction.about,
    label: 'About',
    icon: Icons.info_outline_rounded,
  );

  static const ProfileMenuItem _logOutItem = ProfileMenuItem(
    action: ProfileMenuAction.logOut,
    label: 'Log Out',
    icon: Icons.logout_rounded,
    isDestructive: true,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _provider.fetchProfile();
    _checkNotificationStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _provider.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkNotificationStatus();
    }
  }

  Future<void> _checkNotificationStatus() async {
    final isEnabled = await FcmService.instance.isNotificationEnabled();
    if (mounted) {
      setState(() {
        _isNotificationEnabled = isEnabled;
      });
    }
  }

  Future<void> _toggleNotification(bool value) async {
    if (_isUpdatingNotification) return;
    setState(() => _isUpdatingNotification = true);

    if (value) {
      final isGranted = await FcmService.instance.setNotificationEnabled(true);
      if (mounted) {
        setState(() {
          _isNotificationEnabled = isGranted;
          _isUpdatingNotification = false;
        });

        if (isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notifications enabled successfully'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          final status = await Permission.notification.status;
          if (status.isPermanentlyDenied && mounted) {
            _showPermissionSettingsDialog();
          }
        }
      }
    } else {
      final success = await FcmService.instance.setNotificationEnabled(false);
      if (mounted) {
        setState(() {
          _isNotificationEnabled = !success;
          _isUpdatingNotification = false;
        });
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notifications disabled'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _showPermissionSettingsDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Allow Notifications'),
        content: const Text(
          'Notification permission is disabled in your device settings. Please enable it in Settings to receive alerts and updates.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              openAppSettings();
            },
            child: const Text(
              'Open Settings',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF9023FF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _provider,
          builder: (context, _) {
            if (_provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 16.h,
              ).copyWith(bottom: 68.h + MediaQuery.of(context).padding.bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppString.profile,
                    style: CustomTextStyle.bold30(
                      AppColors.textDark,
                    ).copyWith(fontSize: 24.sp),
                  ),
                  SizedBox(height: 20.h),
                  ProfileHeaderCard(profile: _provider.profile),
                  SizedBox(height: 24.h),
                  ProfileMenuGroup(
                    children: [
                      for (int i = 0; i < _mainMenu.length; i++) ...[
                        () {
                          final item = _mainMenu[i];
                          final isNotification =
                              item.action == ProfileMenuAction.notifications;

                          return ProfileMenuTile(
                            item: item,
                            showDivider: i != _mainMenu.length - 1,
                            trailing: isNotification
                                ? SizedBox(
                                    height: 32.h,
                                    child: Transform.scale(
                                      scale: 0.85,
                                      child: CupertinoSwitch(
                                        activeTrackColor: const Color(
                                          0xFF9023FF,
                                        ),
                                        value: _isNotificationEnabled,
                                        onChanged: _isUpdatingNotification
                                            ? null
                                            : (val) => _toggleNotification(val),
                                      ),
                                    ),
                                  )
                                : null,
                            onTap: isNotification
                                ? () => _toggleNotification(
                                    !_isNotificationEnabled,
                                  )
                                : () => _controller.handleMenuTap(
                                    context,
                                    item.action,
                                  ),
                          );
                        }(),
                      ],
                    ],
                  ),
                  SizedBox(height: 16.h),
                  ProfileMenuGroup(
                    children: [
                      ProfileMenuTile(
                        item: _aboutItem,
                        showDivider: false,
                        onTap: () => _controller.handleMenuTap(
                          context,
                          _aboutItem.action,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  ProfileMenuGroup(
                    children: [
                      ProfileMenuTile(
                        item: _logOutItem,
                        showDivider: false,
                        onTap: () => _controller.handleMenuTap(
                          context,
                          _logOutItem.action,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
