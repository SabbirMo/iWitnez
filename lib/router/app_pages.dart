import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iwitnez/core/constants/user_role/user_role.dart';
import 'package:iwitnez/core/widgets/app_shell_scaffold.dart';
import 'package:iwitnez/feature/AboutUs/screen/about_us_screen.dart';
import 'package:iwitnez/feature/AboutUs/screen/who_we_are_screen.dart';
import 'package:iwitnez/feature/AboutUs/screen/privacy_policy_screen.dart';
import 'package:iwitnez/feature/AboutUs/screen/terms_of_service_screen.dart';
import 'package:iwitnez/feature/OurMission/screen/our_mission_screen.dart';
import 'package:iwitnez/feature/auth/create_account/screen/create_account_screen.dart';
import 'package:iwitnez/feature/auth/fotgot_password/screen/forgot_password_screen.dart';
import 'package:iwitnez/feature/auth/fotgot_password/screen/new_password_screen.dart';
import 'package:iwitnez/feature/auth/login/screen/login_screen.dart';
import 'package:iwitnez/feature/auth/verification/model/verification_type.dart';
import 'package:iwitnez/feature/auth/verification/screen/verification_screen.dart';
import 'package:iwitnez/feature/shareing/screen/sharing_screen.dart';
import 'package:iwitnez/feature/call/model/call_session_model.dart';
import 'package:iwitnez/feature/call/screen/audio_call_screen.dart';
import 'package:iwitnez/feature/call/screen/video_call_screen.dart';
import 'package:iwitnez/feature/main_user/AccountSettings/screen/account_settings_screen.dart';
import 'package:iwitnez/feature/main_user/AccountSettings/screen/change_password_screen.dart';
import 'package:iwitnez/feature/main_user/Calls_section/Calls/screen/calls_screen.dart'
    as main_user_calls;
import 'package:iwitnez/feature/main_user/Chat_section/Chat/screen/chat_screen.dart'
    as main_user_chat;
import 'package:iwitnez/feature/main_user/TrustedCircle/screen/trusted_circle_screen.dart';
import 'package:iwitnez/feature/main_user/TrustedCircle/screen/circle_details_screen.dart';
import 'package:iwitnez/feature/main_user/TrustedCircle/model/trusted_circle_model.dart';
import 'package:iwitnez/feature/main_user/Sos_section/screen/sos_countdown_screen.dart';
import 'package:iwitnez/feature/main_user/Sos_section/screen/sos_active_camera_screen.dart';
import 'package:iwitnez/feature/main_user/Sos_section/screen/sos_video_stopped_screen.dart';
import 'package:iwitnez/feature/main_user/Chat_section/ChatDetails/screen/chat_details_screen.dart';
import 'package:iwitnez/feature/main_user/Chat_section/ChatDetails/screen/chat_profile_details_screen.dart';
import 'package:iwitnez/feature/main_user/HelpSupport/screen/help_support_screen.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/screen/home_screen.dart'
    as main_user_home;
import 'package:iwitnez/feature/main_user/LiveLocation/screen/live_location_screen.dart';
import 'package:iwitnez/feature/main_user/LiveLocation/screen/stop_sharing_location_screen.dart';
import 'package:iwitnez/feature/main_user/LiveLocation/screen/manage_sharing_screen.dart';
import 'package:iwitnez/feature/main_user/Notifications/screen/notification_screen.dart';
import 'package:iwitnez/feature/main_user/PersonalInformation/screen/personal_info_screen.dart';
import 'package:iwitnez/feature/main_user/Profile_section/Profile/screen/profile_screen.dart'
    as main_user_profile;
import 'package:iwitnez/feature/main_user/SafetySettings/screen/safety_settings_screen.dart';
import 'package:iwitnez/feature/main_user/SafetyTracking/screen/safety_tracking_screen.dart';
import 'package:iwitnez/feature/main_user/SafetyTracking/screen/add_safe_place_screen.dart';
import 'package:iwitnez/feature/main_user/ScheduledTimer/screen/scheduled_timer_screen.dart';
import 'package:iwitnez/feature/main_user/CheckIn/screen/check_in_screen.dart';
import 'package:iwitnez/feature/onboarding/onboarding_start_screen.dart';
import 'package:iwitnez/feature/onboarding/screen/onboarding_screen.dart';
import 'package:iwitnez/feature/splash/screen/splash_screen.dart';
import 'package:iwitnez/feature/trusted_contact/Alerts_section/Alerts/screen/alerts_screen.dart'
    as trusted_alerts;
import 'package:iwitnez/feature/trusted_contact/Calls_section/Calls/screen/calls_screen.dart'
    as trusted_calls;
import 'package:iwitnez/feature/trusted_contact/Chat_section/Chat/screen/chat_screen.dart'
    as trusted_chat;
import 'package:iwitnez/feature/trusted_contact/Home_section/Home/screen/home_screen.dart'
    as trusted_home;
import 'package:iwitnez/feature/trusted_contact/LiveLocation/screen/trusted_live_location_screen.dart';
import 'package:iwitnez/feature/trusted_contact/LiveLocation/screen/get_directions_screen.dart';
import 'package:iwitnez/feature/trusted_contact/Profile_section/Profile/screen/profile_screen.dart'
    as trusted_profile;
import 'package:iwitnez/feature/trusted_contact/Notifications/screen/trusted_notification_screen.dart';
import 'package:iwitnez/feature/trusted_contact/JourneyEta/screen/trusted_journey_eta_screen.dart';
import 'package:iwitnez/feature/trusted_contact/CheckInStatus/screen/trusted_check_in_status_screen.dart';
import 'package:iwitnez/feature/add_trusted_contact/screen/add_trusted_contact.dart';
import 'package:iwitnez/feature/add_trusted_contact/model/trusted_contact_model.dart';
import 'package:iwitnez/feature/add_trusted_contact/widget/add_trusted_field_widget.dart';
import 'package:iwitnez/feature/add_trusted_contact/screen/trusted_contact_success_screen.dart';
import 'package:iwitnez/router/app_route_names.dart';

final appPages = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: AppRouteNames.splashScreen,
    routes: [
      GoRoute(
        path: AppRouteNames.splashScreen,
        pageBuilder: (context, state) =>
            CupertinoPage(child: const SplashScreen()),
      ),

      GoRoute(
        path: AppRouteNames.onBoardingStartScreen,
        pageBuilder: (context, state) =>
            CupertinoPage(child: const OnboardingStartScreen()),
      ),
      GoRoute(
        path: AppRouteNames.onBoardingScreen,
        pageBuilder: (context, state) =>
            CupertinoPage(child: const OnboardingScreen()),
      ),

      //Account Routes
      GoRoute(
        path: AppRouteNames.createAccountScreen,
        pageBuilder: (context, state) =>
            CupertinoPage(child: const CreateAccountScreen()),
      ),
      GoRoute(
        path: AppRouteNames.loginScreen,
        pageBuilder: (context, state) =>
            CupertinoPage(child: const LoginScreen()),
      ),
      GoRoute(
        path: AppRouteNames.forgotPasswordScreen,
        pageBuilder: (context, state) =>
            CupertinoPage(child: const ForgotPasswordScreen()),
      ),

      GoRoute(
        path: AppRouteNames.verificationScreen,
        pageBuilder: (context, state) {
          final extra = state.extra as VerificationAgrs?;

          return CupertinoPage(
            child: VerificationScreen(
              email: extra?.email,
              type: extra?.type ?? VerificationType.createAccount,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRouteNames.newPasswordScreen,
        pageBuilder: (context, state) {
          final email = state.extra as String?;
          return CupertinoPage(child: NewPasswordScreen(email: email));
        },
      ),
      GoRoute(
        path: AppRouteNames.shareingScreen,
        pageBuilder: (context, state) =>
            CupertinoPage(child: const SharingScreen()),
      ),
      GoRoute(
        path: AppRouteNames.accountSettingsScreen,
        pageBuilder: (context, state) =>
            CupertinoPage(child: const AccountSettingsScreen()),
      ),
      GoRoute(
        path: AppRouteNames.changePasswordScreen,
        pageBuilder: (context, state) =>
            CupertinoPage(child: const ChangePasswordScreen()),
      ),

      //trusted contact
      GoRoute(
        path: AppRouteNames.addTrustedContactScreen,
        pageBuilder: (context, state) =>
            CupertinoPage(child: const AddTrustedContactScreen()),
      ),
      GoRoute(
        path: AppRouteNames.addTrustedFieldWidget,
        pageBuilder: (context, state) {
          final extra = state.extra;
          if (extra is Map) {
            return CupertinoPage(
              child: AddTrustedFieldWidget(
                contact: extra['contact'] as TrustedContactModel?,
                circleMember: extra['member'] as CircleMember?,
                circleTitle: extra['circleTitle'] as String?,
                isEditMember: extra['isEdit'] == true,
              ),
            );
          }
          if (extra is TrustedContactModel) {
            return CupertinoPage(child: AddTrustedFieldWidget(contact: extra));
          }
          return CupertinoPage(child: const AddTrustedFieldWidget());
        },
      ),
      GoRoute(
        path: AppRouteNames.trustedContactSuccessScreen,
        pageBuilder: (context, state) {
          final contactName = state.extra as String?;
          return CupertinoPage(
            child: TrustedContactSuccessScreen(contactName: contactName),
          );
        },
      ),
      GoRoute(
        path: AppRouteNames.chatDetailsScreen,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          debugPrint('ChatDetails extra: $extra');
          return CupertinoPage(
            child: ChatDetailsScreen(
              chatId: extra?['chatId'] ?? '',
              contactName: extra?['contactName'] ?? '',
              avatarUrl: extra?['avatarUrl'] ?? '',
              isOnline: extra?['isOnline'] ?? false,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRouteNames.chatProfileDetailsScreen,
        pageBuilder: (context, state) => CupertinoPage(
          child: ChatProfileDetailsScreen.fromExtra(state.extra),
        ),
      ),
      GoRoute(
        path: AppRouteNames.trustedCircleScreen,
        pageBuilder: (context, state) =>
            CupertinoPage(child: const TrustedCircleScreen()),
      ),
      GoRoute(
        path: AppRouteNames.circleDetailsScreen,
        pageBuilder: (context, state) {
          final circle = state.extra as TrustedCircleItem?;
          return CupertinoPage(child: CircleDetailsScreen(circle: circle));
        },
      ),
      GoRoute(
        path: AppRouteNames.sosCountdownScreen,
        pageBuilder: (context, state) =>
            CupertinoPage(child: const SosCountdownScreen()),
      ),
      GoRoute(
        path: AppRouteNames.sosActiveCameraScreen,
        pageBuilder: (context, state) =>
            CupertinoPage(child: const SosActiveCameraScreen()),
      ),
      GoRoute(
        path: AppRouteNames.sosVideoStoppedScreen,
        pageBuilder: (context, state) =>
            CupertinoPage(child: const SosVideoStoppedScreen()),
      ),
      // Main User Shell (bottom nav: Home / Chat / Calls / Profile)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShellScaffold(
          navigationShell: navigationShell,
          role: UserRole.mainUser,
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteNames.mainUserHome,
                pageBuilder: (context, state) =>
                    CupertinoPage(child: const main_user_home.HomeScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteNames.mainUserChat,
                pageBuilder: (context, state) =>
                    CupertinoPage(child: const main_user_chat.ChatScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteNames.mainUserCalls,
                pageBuilder: (context, state) =>
                    CupertinoPage(child: const main_user_calls.CallsScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteNames.mainUserProfile,
                pageBuilder: (context, state) => CupertinoPage(
                  child: const main_user_profile.ProfileScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
      // Notifications Screen
      GoRoute(
        path: AppRouteNames.notificationScreen,
        pageBuilder: (context, state) =>
            CupertinoPage(child: const NotificationScreen()),
      ),
      // Trusted Notifications Screen
      GoRoute(
        path: AppRouteNames.trustedNotificationScreen,
        pageBuilder: (context, state) =>
            CupertinoPage(child: const TrustedNotificationScreen()),
      ),
      // Personal Information Screen
      GoRoute(
        path: AppRouteNames.personalInfoScreen,
        pageBuilder: (context, state) =>
            CupertinoPage(child: const PersonalInfoScreen()),
      ),
      // Safety Settings Screen
      GoRoute(
        path: AppRouteNames.safetySettingsScreen,
        pageBuilder: (context, state) =>
            CupertinoPage(child: const SafetySettingsScreen()),
      ),
      // Help Support Screen
      GoRoute(
        path: AppRouteNames.helpSupportScreen,
        pageBuilder: (context, state) =>
            CupertinoPage(child: const HelpSupportScreen()),
      ),
      // About Us Screen
      GoRoute(
        path: AppRouteNames.aboutUsScreen,
        pageBuilder: (context, state) =>
            CupertinoPage(child: const AboutUsScreen()),
      ),
      // Our Mission Screen
      GoRoute(
        path: AppRouteNames.ourMissionScreen,
        pageBuilder: (context, state) =>
            CupertinoPage(child: const OurMissionScreen()),
      ),
      // Live Location Screen
      GoRoute(
        path: AppRouteNames.liveLocationScreen,
        pageBuilder: (context, state) =>
            CupertinoPage(child: const LiveLocationScreen()),
      ),
      // Stop Sharing Location Screen
      GoRoute(
        path: AppRouteNames.stopSharingLocationScreen,
        pageBuilder: (context, state) =>
            CupertinoPage(child: const StopSharingLocationScreen()),
      ),
      // Manage Sharing Screen
      GoRoute(
        path: AppRouteNames.manageSharingScreen,
        pageBuilder: (context, state) =>
            CupertinoPage(child: const ManageSharingScreen()),
      ),
      // Safety Tracking Screen
      GoRoute(
        path: AppRouteNames.safetyTrackingScreen,
        pageBuilder: (context, state) =>
            CupertinoPage(child: const SafetyTrackingScreen()),
      ),
      // Add Safe Place Screen
      GoRoute(
        path: AppRouteNames.addSafePlaceScreen,
        pageBuilder: (context, state) =>
            CupertinoPage(child: const AddSafePlaceScreen()),
      ),
      // Scheduled Timer Screen
      GoRoute(
        path: AppRouteNames.scheduledTimerScreen,
        pageBuilder: (context, state) =>
            CupertinoPage(child: const ScheduledTimerScreen()),
      ),
      // Check-In Screen
      GoRoute(
        path: AppRouteNames.checkInScreen,
        pageBuilder: (context, state) =>
            CupertinoPage(child: const CheckInScreen()),
      ),
      // Trusted Contact Live Location Screen
      GoRoute(
        path: AppRouteNames.trustedLiveLocationScreen,
        pageBuilder: (context, state) =>
            CupertinoPage(child: const TrustedLiveLocationScreen()),
      ),
      // Get Directions Screen
      GoRoute(
        path: AppRouteNames.getDirectionsScreen,
        pageBuilder: (context, state) =>
            CupertinoPage(child: const GetDirectionsScreen()),
      ),
      // Trusted Contact Journey & ETA Screen
      GoRoute(
        path: AppRouteNames.trustedJourneyEtaScreen,
        pageBuilder: (context, state) =>
            CupertinoPage(child: const TrustedJourneyEtaScreen()),
      ),
      // Trusted Contact Check In Status Screen
      GoRoute(
        path: AppRouteNames.trustedCheckInStatusScreen,
        pageBuilder: (context, state) =>
            CupertinoPage(child: const TrustedCheckInStatusScreen()),
      ),

      // Trusted Contact Shell (bottom nav: Home / Alerts / Chat / Calls / Profile)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShellScaffold(
          navigationShell: navigationShell,
          role: UserRole.trustedContact,
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteNames.trustedHome,
                pageBuilder: (context, state) =>
                    CupertinoPage(child: const trusted_home.HomeScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteNames.trustedAlerts,
                pageBuilder: (context, state) =>
                    CupertinoPage(child: const trusted_alerts.AlertsScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteNames.trustedChat,
                pageBuilder: (context, state) =>
                    CupertinoPage(child: const trusted_chat.ChatScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteNames.trustedCalls,
                pageBuilder: (context, state) =>
                    CupertinoPage(child: const trusted_calls.CallsScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteNames.trustedProfile,
                pageBuilder: (context, state) =>
                    CupertinoPage(child: const trusted_profile.ProfileScreen()),
              ),
            ],
          ),
        ],
      ),

      // ── About Us sub-screens ──
      GoRoute(
        path: AppRouteNames.whoWeAreScreen,
        pageBuilder: (context, state) =>
            CupertinoPage(child: const WhoWeAreScreen()),
      ),
      GoRoute(
        path: AppRouteNames.privacyPolicyScreen,
        pageBuilder: (context, state) =>
            CupertinoPage(child: const PrivacyPolicyScreen()),
      ),
      GoRoute(
        path: AppRouteNames.termsOfServiceScreen,
        pageBuilder: (context, state) =>
            CupertinoPage(child: const TermsOfServiceScreen()),
      ),

      // ── Call Feature screens ──
      GoRoute(
        path: AppRouteNames.audioCallScreen,
        pageBuilder: (context, state) {
          final args =
              state.extra as CallArguments? ??
              const CallArguments(
                contactName: 'Unknown',
                avatarUrl: '',
                callType: CallType.voice,
              );
          return CupertinoPage(child: AudioCallScreen(arguments: args));
        },
      ),
      GoRoute(
        path: AppRouteNames.videoCallScreen,
        pageBuilder: (context, state) {
          final args =
              state.extra as CallArguments? ??
              const CallArguments(
                contactName: 'Unknown',
                avatarUrl: '',
                callType: CallType.video,
              );
          return CupertinoPage(child: VideoCallScreen(arguments: args));
        },
      ),
    ],

    //if page not found show this message
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text("Page Not Found: ${state.error}"))),
  ),
);
