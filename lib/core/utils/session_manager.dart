import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/providers/live_location_tracking_provider.dart'
    show liveLocationTrackingProvider;
import 'package:iwitnez/feature/add_trusted_contact/provider/add_trusted_contact_provider.dart'
    show addTrustedContactProvider, trustedContactsProvider;
import 'package:iwitnez/feature/main_user/AccountSettings/provider/account_settings_provider.dart'
    show accountSettingsProvider;
import 'package:iwitnez/feature/main_user/CheckIn/provider/check_in_provider.dart'
    show checkInProvider;
import 'package:iwitnez/feature/main_user/Home_section/Home/provider/home_provider.dart'
    show homeProvider;
import 'package:iwitnez/feature/main_user/Notifications/provider/notification_provider.dart'
    show notificationControllerProvider;
import 'package:iwitnez/feature/main_user/PersonalInformation/provider/personal_info_provider.dart'
    show personalInfoControllerProvider;
import 'package:iwitnez/feature/main_user/Profile_section/Profile/repository/profile_repository.dart';
import 'package:iwitnez/feature/main_user/SafetySettings/provider/safety_settings_provider.dart'
    show safetySettingsControllerProvider;
import 'package:iwitnez/feature/main_user/SafetyTracking/provider/safety_tracking_provider.dart'
    show safetyTrackingProvider;
import 'package:iwitnez/feature/main_user/ScheduledTimer/provider/scheduled_timer_provider.dart'
    show scheduledTimerProvider;
import 'package:iwitnez/feature/main_user/TrustedCircle/provider/trusted_circle_provider.dart'
    show trustedCircleProvider;
import 'package:iwitnez/feature/shareing/provider/live_location_provider.dart'
    show liveLocationProvider;
import 'package:iwitnez/feature/trusted_contact/CheckInStatus/provider/check_in_status_provider.dart'
    show checkInStatusProvider;
import 'package:iwitnez/feature/trusted_contact/Home_section/Home/provider/home_provider.dart'
    show trustedHomeProvider;
import 'package:iwitnez/feature/trusted_contact/JourneyEta/provider/journey_eta_provider.dart'
    show journeyEtaProvider;
import 'package:iwitnez/feature/trusted_contact/LiveLocation/provider/monitored_live_location_provider.dart'
    show monitoredLiveLocationProvider;

class AppSessionManager {
  /// Completely resets all cached in-memory user data, profile cache,
  /// and Riverpod providers across the entire app.
  static void resetSession(WidgetRef ref) {
    // 1. Clear in-memory singleton profile cache
    ProfileRepository().clearCache();

    // 2. Invalidate home providers
    ref.invalidate(homeProvider);
    ref.invalidate(trustedHomeProvider);

    // 3. Invalidate user circle, notification, personal info & settings providers
    ref.invalidate(trustedCircleProvider);
    ref.invalidate(notificationControllerProvider);
    ref.invalidate(personalInfoControllerProvider);
    ref.invalidate(accountSettingsProvider);
    ref.invalidate(safetySettingsControllerProvider);
    ref.invalidate(trustedContactsProvider);
    ref.invalidate(addTrustedContactProvider);

    // 4. Invalidate tracking, live location & check-in providers
    ref.invalidate(checkInProvider);
    ref.invalidate(safetyTrackingProvider);
    ref.invalidate(scheduledTimerProvider);
    ref.invalidate(monitoredLiveLocationProvider);
    ref.invalidate(checkInStatusProvider);
    ref.invalidate(journeyEtaProvider);
    ref.invalidate(liveLocationTrackingProvider);
    ref.invalidate(liveLocationProvider);
  }
}
