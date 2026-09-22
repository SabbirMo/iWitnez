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
import 'package:iwitnez/feature/auth/login/screen/login_screen.dart';
import 'package:iwitnez/feature/auth/verification/model/verification_type.dart';
import 'package:iwitnez/feature/auth/verification/screen/verification_screen.dart';
import 'package:iwitnez/feature/shareing/screen/sharing_screen.dart';
import 'package:iwitnez/feature/call/model/call_session_model.dart';
import 'package:iwitnez/feature/call/screen/audio_call_screen.dart';
import 'package:iwitnez/feature/call/screen/video_call_screen.dart';
import 'package:iwitnez/feature/main_user/AccountSettings/screen/account_settings_screen.dart';
import 'package:iwitnez/feature/main_user/Calls_section/Calls/screen/calls_screen.dart'
    as main_user_calls;
import 'package:iwitnez/feature/main_user/Chat_section/Chat/screen/chat_screen.dart'
    as main_user_chat;
import 'package:iwitnez/feature/main_user/Chat_section/ChatDetails/screen/chat_details_screen.dart';
import 'package:iwitnez/feature/main_user/HelpSupport/screen/help_support_screen.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/screen/home_screen.dart'
    as main_user_home;
import 'package:iwitnez/feature/main_user/Notifications/screen/notification_screen.dart';
import 'package:iwitnez/feature/main_user/PersonalInformation/screen/personal_info_screen.dart';
import 'package:iwitnez/feature/main_user/Profile_section/Profile/screen/profile_screen.dart'
    as main_user_profile;
import 'package:iwitnez/feature/main_user/SafetySettings/screen/safety_settings_screen.dart';
import 'package:iwitnez/feature/onboarding/onboarding_start_screen.dart';
import 'package:iwitnez/feature/onboarding/screen/onboarding_screen.dart';
import 'package:iwitnez/feature/splash/screen/splash_screen.dart';
import 'package:iwitnez/feature/trusted_contact/Calls_section/Calls/screen/calls_screen.dart'
    as trusted_calls;
import 'package:iwitnez/feature/trusted_contact/Chat_section/Chat/screen/chat_screen.dart'
    as trusted_chat;
import 'package:iwitnez/feature/trusted_contact/Home_section/Home/screen/home_screen.dart'
    as trusted_home;
import 'package:iwitnez/feature/trusted_contact/Profile_section/Profile/screen/profile_screen.dart'
    as trusted_profile;
import 'package:iwitnez/feature/trusted_contact/add_trusted_contact/screen/add_trusted_contact.dart';
import 'package:iwitnez/feature/trusted_contact/add_trusted_contact/model/trusted_contact_model.dart';
import 'package:iwitnez/feature/trusted_contact/add_trusted_contact/widget/add_trusted_field_widget.dart';
import 'package:iwitnez/feature/trusted_contact/add_trusted_contact/screen/trusted_contact_success_screen.dart';
import 'package:iwitnez/router/app_route_names.dart';

final appPages = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: AppRouteNames.splashScreen,
    routes: [
      GoRoute(
        path: AppRouteNames.splashScreen,
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: AppRouteNames.onBoardingStartScreen,
        builder: (context, state) => const OnboardingStartScreen(),
      ),
      GoRoute(
        path: AppRouteNames.onBoardingScreen,
        builder: (context, state) => const OnboardingScreen(),
      ),

      //Account Routes
      GoRoute(
        path: AppRouteNames.createAccountScreen,
        builder: (context, state) => const CreateAccountScreen(),
      ),
      GoRoute(
        path: AppRouteNames.loginScreen,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRouteNames.forgotPasswordScreen,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      GoRoute(
        path: AppRouteNames.verificationScreen,
        builder: (context, state) {
          final extra = state.extra as VerificationAgrs?;

          return VerificationScreen(
            email: extra?.email,
            type: extra?.type ?? VerificationType.createAccount,
          );
        },
      ),
      GoRoute(
        path: AppRouteNames.shareingScreen,
        builder: (context, state) => const SharingScreen(),
      ),
      GoRoute(
        path: AppRouteNames.accountSettingsScreen,
        builder: (context, state) => const AccountSettingsScreen(),
      ),

      //trusted contact
      GoRoute(
        path: AppRouteNames.addTrustedContactScreen,
        builder: (context, state) => const AddTrustedContactScreen(),
      ),
      GoRoute(
        path: AppRouteNames.addTrustedFieldWidget,
        builder: (context, state) {
          final contact = state.extra as TrustedContactModel?;
          return AddTrustedFieldWidget(contact: contact);
        },
      ),
      GoRoute(
        path: AppRouteNames.trustedContactSuccessScreen,
        builder: (context, state) {
          final contactName = state.extra as String?;
          return TrustedContactSuccessScreen(contactName: contactName);
        },
      ),
      GoRoute(
        path: AppRouteNames.chatDetailsScreen,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          debugPrint('ChatDetails extra: $extra');
          return ChatDetailsScreen(
            chatId: extra?['chatId'] ?? '',
            contactName: extra?['contactName'] ?? '',
            avatarUrl: extra?['avatarUrl'] ?? '',
            isOnline: extra?['isOnline'] ?? false,
          );
        },
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
                builder: (context, state) => const main_user_home.HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteNames.mainUserChat,
                builder: (context, state) => const main_user_chat.ChatScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteNames.mainUserCalls,
                builder: (context, state) =>
                    const main_user_calls.CallsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteNames.mainUserProfile,
                builder: (context, state) =>
                    const main_user_profile.ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      // Notifications Screen
      GoRoute(
        path: AppRouteNames.notificationScreen,
        builder: (context, state) => const NotificationScreen(),
      ),
      // Personal Information Screen
      GoRoute(
        path: AppRouteNames.personalInfoScreen,
        builder: (context, state) => const PersonalInfoScreen(),
      ),
      // Safety Settings Screen
      GoRoute(
        path: AppRouteNames.safetySettingsScreen,
        builder: (context, state) => const SafetySettingsScreen(),
      ),
      // Help Support Screen
      GoRoute(
        path: AppRouteNames.helpSupportScreen,
        builder: (context, state) => const HelpSupportScreen(),
      ),
      // About Us Screen
      GoRoute(
        path: AppRouteNames.aboutUsScreen,
        builder: (context, state) => const AboutUsScreen(),
      ),
      // Our Mission Screen
      GoRoute(
        path: AppRouteNames.ourMissionScreen,
        builder: (context, state) => const OurMissionScreen(),
      ),

      // Trusted Contact Shell (bottom nav: Home / Chat / Calls / Profile)
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
                builder: (context, state) => const trusted_home.HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteNames.trustedChat,
                builder: (context, state) => const trusted_chat.ChatScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteNames.trustedCalls,
                builder: (context, state) => const trusted_calls.CallsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteNames.trustedProfile,
                builder: (context, state) =>
                    const trusted_profile.ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // ── About Us sub-screens ──
      GoRoute(
        path: AppRouteNames.ourMissionScreen,
        builder: (context, state) => const OurMissionScreen(),
      ),
      GoRoute(
        path: AppRouteNames.whoWeAreScreen,
        builder: (context, state) => const WhoWeAreScreen(),
      ),
      GoRoute(
        path: AppRouteNames.privacyPolicyScreen,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: AppRouteNames.termsOfServiceScreen,
        builder: (context, state) => const TermsOfServiceScreen(),
      ),

      // ── Standalone screens ──
      GoRoute(
        path: AppRouteNames.notificationScreen,
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        path: AppRouteNames.personalInfoScreen,
        builder: (context, state) => const PersonalInfoScreen(),
      ),
      GoRoute(
        path: AppRouteNames.safetySettingsScreen,
        builder: (context, state) => const SafetySettingsScreen(),
      ),
      GoRoute(
        path: AppRouteNames.helpSupportScreen,
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: AppRouteNames.aboutUsScreen,
        builder: (context, state) => const AboutUsScreen(),
      ),

      // ── Call Feature screens ──
      GoRoute(
        path: AppRouteNames.audioCallScreen,
        builder: (context, state) {
          final args =
              state.extra as CallArguments? ??
              const CallArguments(
                contactName: 'Unknown',
                avatarUrl: '',
                callType: CallType.voice,
              );
          return AudioCallScreen(arguments: args);
        },
      ),
      GoRoute(
        path: AppRouteNames.videoCallScreen,
        builder: (context, state) {
          final args =
              state.extra as CallArguments? ??
              const CallArguments(
                contactName: 'Unknown',
                avatarUrl: '',
                callType: CallType.video,
              );
          return VideoCallScreen(arguments: args);
        },
      ),
    ],

    //if page not found show this message
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text("Page Not Found: ${state.error}"))),
  ),
);
