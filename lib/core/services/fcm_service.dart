import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:iwitnez/feature/call/model/call_session_model.dart';
import 'package:iwitnez/feature/main_user/Notifications/repository/notification_repository.dart';
import 'package:iwitnez/feature/shareing/repository/device_settings_repository.dart';
import 'package:iwitnez/firebase_options.dart';
import 'package:iwitnez/router/app_pages.dart';
import 'package:iwitnez/router/app_route_names.dart';
import 'package:permission_handler/permission_handler.dart';

/// Top-level background message handler required by Firebase Messaging.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}
  debugPrint(
    '[FCM Background] Handling message: ${message.messageId}, type: ${message.data['type']}',
  );

  final type = message.data['type']?.toString().toLowerCase();
  if (type == 'incoming_call') {
    await _showBackgroundCallNotification(message);
  }
}

@pragma('vm:entry-point')
Future<void> _showBackgroundCallNotification(RemoteMessage message) async {
  try {
    final fln = FlutterLocalNotificationsPlugin();
    const androidInitSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidInitSettings);
    await fln.initialize(settings: initSettings);

    const callChannel = AndroidNotificationChannel(
      'incoming_calls_channel',
      'Incoming Calls',
      description: 'Channel for incoming audio and video calls',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('call_ring'),
      enableVibration: true,
    );

    await fln
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(callChannel);

    final callerName =
        message.data['caller_name']?.toString() ?? 'Incoming Call';
    final callType = message.data['call_type']?.toString().toLowerCase();
    final isVideo = callType == 'video';

    final androidDetails = AndroidNotificationDetails(
      callChannel.id,
      callChannel.name,
      channelDescription: callChannel.description,
      importance: Importance.max,
      priority: Priority.max,
      category: AndroidNotificationCategory.call,
      fullScreenIntent: true,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('call_ring'),
      enableVibration: true,
      ongoing: true,
      autoCancel: false,
      audioAttributesUsage: AudioAttributesUsage.notificationRingtone,
      visibility: NotificationVisibility.public,
    );

    await fln.show(
      id: 8888,
      title: callerName,
      body: isVideo ? 'Incoming Video Call...' : 'Incoming Audio Call...',
      notificationDetails: NotificationDetails(android: androidDetails),
      payload: jsonEncode(message.data),
    );
  } catch (e) {
    debugPrint('[FCM Background] Error showing call notification: $e');
  }
}

class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  /// Broadcast stream controller so app components (feed, badge, alerts) update instantly in real-time
  static final StreamController<RemoteMessage> onNotificationReceived =
      StreamController<RemoteMessage>.broadcast();

  /// Flag indicating app was launched by clicking a notification from terminated state
  static bool hasPendingNotificationTap = false;
  static Map<String, dynamic>? pendingInitialPayload;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final DeviceSettingsRepository _deviceSettingsRepo =
      DeviceSettingsRepository();
  final NotificationRepository _notificationRepo = NotificationRepository();
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _highImportanceChannel =
      AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description:
            'This channel is used for important notifications and alerts.',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

  static const AndroidNotificationChannel _callChannel =
      AndroidNotificationChannel(
        'incoming_calls_channel',
        'Incoming Calls',
        description: 'Channel for incoming audio and video calls',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('call_ring'),
        enableVibration: true,
      );

  bool _isInitialized = false;
  String? _currentFcmToken;

  String? get currentFcmToken => _currentFcmToken;

  /// Initialize Firebase Messaging listeners without requesting permission on app start
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // 1. Initialize local notifications for foreground phone system notification display
    try {
      const androidInitSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const darwinInitSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const initSettings = InitializationSettings(
        android: androidInitSettings,
        iOS: darwinInitSettings,
      );

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (response.payload != null && response.payload!.isNotEmpty) {
            try {
              final Map<String, dynamic> data =
                  jsonDecode(response.payload!) as Map<String, dynamic>;
              handleNotificationPayload(data);
            } catch (e) {
              debugPrint('[FCM] Error parsing notification payload: $e');
            }
          }
        },
      );

      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.createNotificationChannel(_highImportanceChannel);
      await androidPlugin?.createNotificationChannel(_callChannel);
    } catch (e) {
      debugPrint('[FCM] Error initializing flutter_local_notifications: $e');
    }

    // 2. Set presentation options for foreground messages (iOS)
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Listen to incoming messages in foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 3. Handle tap on notification when app was in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
        '[FCM onMessageOpenedApp] Notification tapped outside app: data=${message.data}, notifTitle=${message.notification?.title}',
      );
      onNotificationReceived.add(message);
      handleNotificationPayload(message.data);
    });

    // 4. Handle initial message if app was terminated and opened via notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint(
        '[FCM getInitialMessage] Opened from terminated state: ${initialMessage.data}',
      );
      hasPendingNotificationTap = true;
      pendingInitialPayload = initialMessage.data;
      onNotificationReceived.add(initialMessage);
      // Fallback delay in case splash screen is bypassed or short
      Future.delayed(const Duration(milliseconds: 3200), () {
        if (hasPendingNotificationTap) {
          hasPendingNotificationTap = false;
          handleNotificationPayload(pendingInitialPayload);
        }
      });
    }

    // 5. Token refresh listener
    // ignore: deprecated_member_use
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('[FCM] Token refreshed: $newToken');
      _currentFcmToken = newToken;
      syncDeviceToken(newToken);
    });

    // Note: Permission is NOT requested here. It is requested when the user
    // taps 'Allow Notifications' on the onboarding/permission screen.
  }

  /// Check if user has already granted permission and sync token silently (without showing popup)
  Future<void> syncDeviceTokenIfPermitted() async {
    try {
      final settings = await _messaging.getNotificationSettings();
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        await fetchAndSyncToken();
      }
    } catch (e) {
      debugPrint('[FCM] Error checking permission settings: $e');
    }
  }

  /// Check if push notifications are enabled on backend & device
  Future<bool> isNotificationEnabled() async {
    try {
      final status = await Permission.notification.status;
      if (!status.isGranted) return false;
      return await _notificationRepo.getNotificationToggleStatus();
    } catch (_) {
      final status = await Permission.notification.status;
      return status.isGranted;
    }
  }

  /// Enable or disable notifications from Profile settings
  /// Hitting POST /api/v1/notifications/toggle/
  Future<bool> setNotificationEnabled(bool enabled) async {
    if (enabled) {
      final isGranted = await requestNotificationPermission();
      if (!isGranted) return false;

      String? token = _currentFcmToken;
      try {
        // ignore: deprecated_member_use
        token ??= await _messaging.getToken();
      } catch (e) {
        debugPrint('[FCM] Error obtaining token during enable toggle: $e');
      }

      final success = await _notificationRepo.setNotificationEnabled(
        true,
        fcmDeviceToken: token,
      );

      if (token != null) {
        _currentFcmToken = token;
        unawaited(syncDeviceToken(token));
      }

      return success;
    } else {
      final success = await _notificationRepo.setNotificationEnabled(false);
      try {
        await _deviceSettingsRepo.updateDeviceSettings({
          'notification_permission_granted': false,
        });
      } catch (_) {}
      return success;
    }
  }

  /// Request notification permission and sync token to backend (called on user action)
  Future<bool> requestPermissionAndSyncToken() async {
    final isGranted = await requestNotificationPermission();
    if (isGranted) {
      await fetchAndSyncToken();
    }
    return isGranted;
  }

  /// Request push notification permissions
  Future<bool> requestNotificationPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );
      final isGranted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      debugPrint('[FCM] Permission status: ${settings.authorizationStatus}');
      return isGranted;
    } catch (e) {
      debugPrint('[FCM] Error requesting permission: $e');
      return false;
    }
  }

  /// Step 1.1: Fetch device push token and sync to backend
  Future<void> fetchAndSyncToken() async {
    try {
      // ignore: deprecated_member_use
      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        _currentFcmToken = token;
        debugPrint('[FCM] Device Token: $token');
        await syncDeviceToken(token);
      }
    } catch (e) {
      debugPrint('[FCM] Error fetching device token: $e');
    }
  }

  /// Register Device Token with Backend
  /// PATCH /api/v1/auth/device-settings/
  Future<void> syncDeviceToken([String? token]) async {
    final pushToken = token ?? _currentFcmToken;
    if (pushToken == null || pushToken.isEmpty) return;

    final platform = defaultTargetPlatform == TargetPlatform.iOS
        ? 'ios'
        : 'android';

    final body = <String, dynamic>{
      'notification_permission_granted': true,
      'fcm_device_token': pushToken,
      'device_platform': platform,
    };

    try {
      debugPrint('[FCM] Syncing push token to backend: $body');
      await _deviceSettingsRepo.updateDeviceSettings(body);
      debugPrint('[FCM] Device token synced successfully with backend.');
    } catch (e) {
      // If user is not yet authenticated, this will safely catch and retry after login
      debugPrint(
        '[FCM] Note: Could not sync token to backend (User may not be logged in yet): $e',
      );
    }
  }

  /// Step 1.2: Handle Foreground Push Notifications
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint(
      '[FCM onMessage] Foreground message received: title=${message.notification?.title}, data=${message.data}',
    );
    onNotificationReceived.add(message);

    final data = message.data;
    final type = data['type']?.toString().toLowerCase();

    // If incoming call arrives while app is open, directly navigate to the call screen
    if (type == 'incoming_call') {
      _navigateToIncomingCall(data);
      return;
    }

    final title =
        message.notification?.title ??
        data['title']?.toString() ??
        (type == 'sos_alert' ? 'EMERGENCY ALERT 🚨' : 'New Notification');
    final body =
        message.notification?.body ??
        data['body']?.toString() ??
        data['message']?.toString() ??
        (data['sender_name'] != null
            ? '${data['sender_name']} sent an update'
            : '');

    // 1. Show notification in phone's system notification bar (drawer / heads-up)
    showLocalNotification(
      id:
          message.messageId?.hashCode ??
          (DateTime.now().millisecondsSinceEpoch ~/ 1000),
      title: title,
      body: body,
      payload: data,
      isSos: type == 'sos_alert',
    );
  }

  /// Display notification in phone's system notification bar (drawer / heads-up)
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    Map<String, dynamic>? payload,
    bool isSos = false,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        _highImportanceChannel.id,
        _highImportanceChannel.name,
        channelDescription: _highImportanceChannel.description,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: isSos ? const Color(0xFFD92D20) : const Color(0xFF9023FF),
        playSound: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(
          body,
          contentTitle: title,
          htmlFormatContent: false,
          htmlFormatContentTitle: false,
        ),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: payload != null ? jsonEncode(payload) : null,
      );
    } catch (e) {
      debugPrint('[FCM] Error showing local notification: $e');
    }
  }

  /// Step 1.2: Parse data['type'] and decide what screen to open
  void handleNotificationPayload([Map<String, dynamic>? data]) {
    final payload = data ?? const <String, dynamic>{};
    final type = payload['type']?.toString().toLowerCase();
    debugPrint(
      '[FCM Action] Processing payload type: $type, payload: $payload',
    );

    // If incoming call arrives, open full call screen
    if (type == 'incoming_call') {
      _navigateToIncomingCall(payload);
      return;
    }

    // If SOS alert arrives with alert_id, open active SOS map screen
    if (type == 'sos_alert' && payload['alert_id'] != null) {
      final context = rootNavigatorKey.currentContext;
      if (context != null) {
        _navigateToSosAlert(context, payload);
        return;
      }
    }

    // If chat message arrives with conversation_id, open chat thread
    if (type == 'chat_message' && payload['conversation_id'] != null) {
      final context = rootNavigatorKey.currentContext;
      if (context != null) {
        _navigateToChatMessage(context, payload);
        return;
      }
    }

    // Default & for any notification clicked from outside the app: open Notification Screen
    _navigateToNotificationScreen();
  }

  /// Reliable navigation to NotificationScreen using global router or context with retry
  void _navigateToNotificationScreen({int attempt = 0}) {
    if (attempt > 15) {
      debugPrint('[FCM Navigation] Max navigation attempts reached.');
      return;
    }

    // 1. Try globalAppRouter first (bypasses BuildContext lookup issues)
    final router = globalAppRouter;
    if (router != null) {
      try {
        debugPrint(
          '[FCM Navigation] Navigating to notificationScreen via globalAppRouter',
        );
        router.push(AppRouteNames.notificationScreen);
        return;
      } catch (e) {
        debugPrint('[FCM Navigation] globalAppRouter.push failed: $e');
      }
    }

    // 2. Try rootNavigatorKey context
    final context = rootNavigatorKey.currentContext;
    if (context != null && context.mounted) {
      try {
        debugPrint(
          '[FCM Navigation] Navigating to notificationScreen via context.push',
        );
        context.push(AppRouteNames.notificationScreen);
        return;
      } catch (e) {
        debugPrint('[FCM Navigation] context.push failed: $e');
      }
    }

    // 3. Retry after delay if router/context is not ready yet
    debugPrint(
      '[FCM Navigation] Router/context not ready yet (attempt $attempt). Retrying in 250ms...',
    );
    Future.delayed(const Duration(milliseconds: 250), () {
      _navigateToNotificationScreen(attempt: attempt + 1);
    });
  }

  /// 1. 🚨 Emergency SOS Alert (type: "sos_alert")
  /// Action: Open Active SOS Map screen (/emergency/alerts/active/) focused on the sender's live coordinates.
  void _navigateToSosAlert(BuildContext context, Map<String, dynamic> data) {
    try {
      final extra = {
        'alertId': data['alert_id'],
        'senderName': data['sender_name'],
        'latitude': data['latitude'],
        'longitude': data['longitude'],
        'address': data['address'],
        'notificationId': data['notification_id'],
      };

      // Navigate to the Active SOS Map screen
      context.push(AppRouteNames.activeSosMap, extra: extra);
    } catch (e) {
      debugPrint('[FCM Navigation] SOS alert navigation error: $e');
      // Fallback to trusted alerts if active map fails
      try {
        context.push(AppRouteNames.trustedLiveLocationScreen);
      } catch (_) {}
    }
  }

  /// 2. 📞 Incoming Audio/Video Call (type: "incoming_call")
  /// Action: Open full-screen Incoming Call screen with Accept / Decline buttons.
  void _navigateToIncomingCall(Map<String, dynamic> data, {int attempt = 0}) {
    // Dismiss ongoing incoming call notification banner
    try {
      unawaited(_localNotifications.cancel(id: 8888));
    } catch (_) {}

    if (attempt > 15) {
      debugPrint(
        '[FCM Navigation] Max incoming call navigation attempts reached.',
      );
      return;
    }

    final callId = data['call_id']?.toString() ?? '';
    final callerName = data['caller_name']?.toString() ?? 'Caller';
    final callTypeStr = data['call_type']?.toString().toLowerCase();
    final isVideo = callTypeStr == 'video';

    final args = CallArguments(
      contactName: callerName,
      avatarUrl: data['caller_avatar']?.toString() ?? '',
      callType: isVideo ? CallType.video : CallType.voice,
      direction: CallDirection.incoming,
      callId: callId,
      agoraAppId:
          data['agora_app_id']?.toString() ??
          '57a5f1d2e0dc4d8e985065d9c86afb0f',
      agoraChannelName: data['agora_channel_name']?.toString(),
      agoraRtcToken: data['agora_rtc_token']?.toString(),
    );

    // 1. Try globalAppRouter first
    final router = globalAppRouter;
    if (router != null) {
      try {
        debugPrint('[FCM Navigation] Navigating to call via globalAppRouter');
        if (isVideo) {
          router.push(AppRouteNames.videoCallScreen, extra: args);
        } else {
          router.push(AppRouteNames.audioCallScreen, extra: args);
        }
        return;
      } catch (e) {
        debugPrint('[FCM Navigation] globalAppRouter call push failed: $e');
      }
    }

    // 2. Try rootNavigatorKey context
    final context = rootNavigatorKey.currentContext;
    if (context != null && context.mounted) {
      try {
        debugPrint('[FCM Navigation] Navigating to call via context.push');
        if (isVideo) {
          context.push(AppRouteNames.videoCallScreen, extra: args);
        } else {
          context.push(AppRouteNames.audioCallScreen, extra: args);
        }
        return;
      } catch (e) {
        debugPrint('[FCM Navigation] context call push failed: $e');
      }
    }

    // 3. Retry after delay if router/context is not ready yet
    Future.delayed(const Duration(milliseconds: 200), () {
      _navigateToIncomingCall(data, attempt: attempt + 1);
    });
  }

  /// 3. 💬 New Chat Message (type: "chat_message")
  /// Action: Open the 1-on-1 Chat Thread screen for conversation_id.
  void _navigateToChatMessage(BuildContext context, Map<String, dynamic> data) {
    final conversationId = data['conversation_id']?.toString() ?? '';
    final senderName = data['sender_name']?.toString() ?? 'Contact';
    final senderId = data['sender_id']?.toString() ?? '';

    try {
      context.push(
        AppRouteNames.chatDetailsScreen,
        extra: {
          'chatId': conversationId,
          'contactName': senderName,
          'receiverId': senderId,
        },
      );
    } catch (e) {
      debugPrint('[FCM Navigation] Chat message navigation error: $e');
    }
  }
}
