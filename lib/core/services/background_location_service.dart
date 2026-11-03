import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iwitnez/core/network/base_url/api_base_url.dart';
import 'package:iwitnez/core/utils/token_storage.dart';

/// Production-ready Background Location Tracking Service for iWitnez.
///
/// Keeps location tracking alive across app minimize, backgrounding, and kill.
/// Runs in an isolated background process, updates a persistent foreground
/// notification with live speed and coordinates, and pings the backend API.
@pragma('vm:entry-point')
class BackgroundLocationService {
  static const String notificationChannelId = 'live_location_tracking_uber_v5';
  static const String notificationChannelName = 'iWitnez Live Safety Tracking';
  static const int notificationId = 888;
  static DateTime? _lastPingTime;

  /// Initializes the background service and notification channel.
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        notificationChannelId,
        notificationChannelName,
        description:
            'Continuous foreground location tracking for safety sharing',
        importance: Importance.defaultImportance,
        playSound: false,
        enableVibration: false,
        showBadge: true,
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: backgroundLocationServiceOnStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: notificationChannelId,
        initialNotificationTitle: 'iWitnez Live Safety • Connecting GPS 🛰️',
        initialNotificationContent:
            'Acquiring satellite & live location fix...',
        foregroundServiceNotificationId: notificationId,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: backgroundLocationServiceOnStart,
        onBackground: backgroundLocationServiceOnIosBackground,
      ),
    );
  }

  /// iOS background callback.
  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    return true;
  }

  /// Background isolate entry point.
  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    final FlutterLocalNotificationsPlugin fln =
        FlutterLocalNotificationsPlugin();

    StreamSubscription<Position>? positionStreamSubscription;
    Timer? periodicTimer;

    if (service is AndroidServiceInstance) {
      service.setAsForegroundService();

      try {
        await fln.initialize(
          settings: const InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          ),
        );

        await _showUberNotification(
          fln: fln,
          title: 'iWitnez Live Safety • Connecting GPS 🛰️',
          body: 'Acquiring satellite & live location fix...',
        );
      } catch (e) {
        debugPrint('Error initializing background fln: $e');
      }
    }

    service.on('stopService').listen((event) async {
      periodicTimer?.cancel();
      await positionStreamSubscription?.cancel();
      try {
        await fln.cancel(id: notificationId);
      } catch (_) {}
      service.stopSelf();
    });

    // 1. Fetch initial position immediately on startup
    await _fetchAndProcessLocation(service, fln);

    // 2. Continuous location stream
    final LocationSettings locationSettings = Platform.isAndroid
        ? AndroidSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 0,
            intervalDuration: const Duration(seconds: 4),
          )
        : const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 0,
          );

    try {
      positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) async {
          await _processPositionUpdate(service, fln, position);
        },
        onError: (error) {
          debugPrint('Background location stream error: $error');
        },
      );
    } catch (e) {
      debugPrint('Error starting background location stream: $e');
    }

    // 3. Periodic fallback timer: ensures coordinates & notification refresh even when stationary
    periodicTimer = Timer.periodic(const Duration(seconds: 8), (_) async {
      await _fetchAndProcessLocation(service, fln);
    });
  }

  /// Fetches current GPS location or last known position safely.
  static Future<void> _fetchAndProcessLocation(
    ServiceInstance service,
    FlutterLocalNotificationsPlugin fln,
  ) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
      await _processPositionUpdate(service, fln, position);
    } catch (_) {
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) {
          await _processPositionUpdate(service, fln, last);
        }
      } catch (_) {}
    }
  }

  /// Displays an Uber-style persistent notification with animated indeterminate progress bar.
  static Future<void> _showUberNotification({
    required FlutterLocalNotificationsPlugin fln,
    required String title,
    required String body,
  }) async {
    try {
      await fln.show(
        id: notificationId,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            notificationChannelId,
            notificationChannelName,
            channelDescription:
                'Continuous foreground location tracking for safety sharing',
            importance: Importance.defaultImportance,
            priority: Priority.high,
            ongoing: true,
            autoCancel: false,
            onlyAlertOnce: true,
            showProgress: true,
            indeterminate: true,
            color: Color(0xFF6C5CE7),
            subText: 'Safety Sharing Active',
            showWhen: true,
            visibility: NotificationVisibility.public,
            icon: '@mipmap/ic_launcher',
            category: AndroidNotificationCategory.navigation,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error rendering Uber-style notification: $e');
    }
  }

  /// Processes position fix: updates notification, notifies UI isolate, pings backend.
  static Future<void> _processPositionUpdate(
    ServiceInstance service,
    FlutterLocalNotificationsPlugin fln,
    Position position,
  ) async {
    final speedKmh = (position.speed * 3.6).clamp(0.0, 300.0);

    final String modeIndicator;
    if (speedKmh > 18.0) {
      modeIndicator = '🚗 ${speedKmh.toStringAsFixed(1)} km/h';
    } else if (speedKmh >= 1.5) {
      modeIndicator = '🏃 ${speedKmh.toStringAsFixed(1)} km/h';
    } else {
      modeIndicator = 'Active 🟢';
    }

    final notificationTitle = 'iWitnez Live Safety • $modeIndicator';
    final notificationContent =
        '📍 ${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)} • Live Tracking';

    // 1. Update Persistent Foreground Notification on Android natively and via Uber notification
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: notificationTitle,
        content: notificationContent,
      );

      await _showUberNotification(
        fln: fln,
        title: notificationTitle,
        body: notificationContent,
      );
    }

    // 2. Broadcast coordinates to Main UI Isolate
    service.invoke('updateLocation', {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'speed': position.speed,
      'speed_kmh': speedKmh,
      'accuracy': position.accuracy,
      'heading': position.heading,
      'altitude': position.altitude,
      'timestamp': position.timestamp.toIso8601String(),
    });

    // 3. Ping Backend API directly from Background Isolate (throttled to at least 4s)
    final now = DateTime.now();
    if (_lastPingTime == null ||
        now.difference(_lastPingTime!) >= const Duration(seconds: 4)) {
      _lastPingTime = now;
      await _sendLocationPing(
        latitude: position.latitude,
        longitude: position.longitude,
        speed: position.speed,
        heading: position.heading,
        accuracy: position.accuracy,
      );
    }
  }

  /// Sends location ping to backend API directly from the background isolate.
  static Future<void> _sendLocationPing({
    required double latitude,
    required double longitude,
    required double speed,
    required double heading,
    required double accuracy,
  }) async {
    try {
      final token = await TokenStorage.getAccessToken();
      if (token == null || token.isEmpty) return;

      final url = Uri.parse('${ApiBaseUrl.baseUrl}/api/v1/location/ping/');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);

      final request = await client.postUrl(url);
      request.headers.set('content-type', 'application/json');
      request.headers.set('authorization', 'Bearer $token');

      final body = jsonEncode({
        'latitude': double.tryParse(latitude.toStringAsFixed(6)) ?? latitude,
        'longitude': double.tryParse(longitude.toStringAsFixed(6)) ?? longitude,
        'accuracy': accuracy,
        'speed': speed,
        'heading': heading,
        'address': '',
      });

      request.add(utf8.encode(body));
      final response = await request.close();
      await response.drain();
      client.close();
    } catch (e) {
      debugPrint('Background API location ping failed: $e');
    }
  }

  /// Helper to check if service is currently running.
  static Future<bool> isServiceRunning() async {
    return await FlutterBackgroundService().isRunning();
  }

  /// Helper to start the background service from anywhere.
  static Future<bool> startTracking() async {
    final service = FlutterBackgroundService();
    final isRunning = await service.isRunning();
    if (!isRunning) {
      return await service.startService();
    }
    return true;
  }

  /// Helper to stop the background service from anywhere.
  static Future<void> stopTracking() async {
    FlutterBackgroundService().invoke('stopService');
  }
}

/// Top-level background isolate entry point for FlutterBackgroundService.
/// Annotated with `@pragma('vm:entry-point')` so native Android/iOS can invoke it directly.
@pragma('vm:entry-point')
void backgroundLocationServiceOnStart(ServiceInstance service) async {
  BackgroundLocationService.onStart(service);
}

/// Top-level iOS background callback.
/// Annotated with `@pragma('vm:entry-point')` so native iOS can invoke it directly.
@pragma('vm:entry-point')
Future<bool> backgroundLocationServiceOnIosBackground(
  ServiceInstance service,
) async {
  return BackgroundLocationService.onIosBackground(service);
}
