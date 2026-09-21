import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iwitnez/core/constants/app_string/app_string.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/text_style/custom_text_style.dart';
import 'package:iwitnez/feature/main_user/Profile_section/Profile/controller/profile_controller.dart';
import 'package:iwitnez/feature/main_user/Profile_section/Profile/model/profile_model.dart';
import 'package:iwitnez/feature/main_user/Profile_section/Profile/provider/profile_provider.dart';
import 'package:iwitnez/feature/main_user/Profile_section/Profile/widget/profile_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileProvider _provider = ProfileProvider();
  final ProfileController _controller = ProfileController();

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
    _provider.fetchProfile();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
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
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppString.profile,
                    style: CustomTextStyle.bold30(AppColors.textDark)
                        .copyWith(fontSize: 24.sp),
                  ),
                  SizedBox(height: 20.h),
                  ProfileHeaderCard(profile: _provider.profile),
                  SizedBox(height: 24.h),
                  ProfileMenuGroup(
                    children: [
                      for (int i = 0; i < _mainMenu.length; i++)
                        ProfileMenuTile(
                          item: _mainMenu[i],
                          showDivider: i != _mainMenu.length - 1,
                          onTap: () => _controller.handleMenuTap(
                            context,
                            _mainMenu[i].action,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  ProfileMenuGroup(
                    children: [
                      ProfileMenuTile(
                        item: _aboutItem,
                        showDivider: false,
                        onTap: () =>
                            _controller.handleMenuTap(context, _aboutItem.action),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  ProfileMenuGroup(
                    children: [
                      ProfileMenuTile(
                        item: _logOutItem,
                        showDivider: false,
                        onTap: () =>
                            _controller.handleMenuTap(context, _logOutItem.action),
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