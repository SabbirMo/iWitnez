import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iwitnez/feature/trusted_contact/LiveLocation/model/monitored_live_location_model.dart';

class DirectionsArgs {
  final double originLatitude;
  final double originLongitude;
  final String originName;
  final String originAddress;
  final double destinationLatitude;
  final double destinationLongitude;
  final String destinationName;
  final String destinationAddress;
  final String mode;
  final List<SafePlaceEtaItem> availableDestinations;

  const DirectionsArgs({
    required this.originLatitude,
    required this.originLongitude,
    required this.originName,
    required this.originAddress,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.destinationName,
    required this.destinationAddress,
    this.mode = 'drive',
    this.availableDestinations = const [],
  });
}

class DirectionsRequest {
  final double originLatitude;
  final double originLongitude;
  final String originName;
  final String originAddress;
  final double destinationLatitude;
  final double destinationLongitude;
  final String destinationName;
  final String destinationAddress;
  final String mode;

  const DirectionsRequest({
    required this.originLatitude,
    required this.originLongitude,
    required this.originName,
    required this.originAddress,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.destinationName,
    required this.destinationAddress,
    this.mode = 'drive',
  });

  static double _round6(double val) => double.parse(val.toStringAsFixed(6));

  Map<String, dynamic> toJson() => {
    'origin_latitude': _round6(originLatitude),
    'origin_longitude': _round6(originLongitude),
    'origin_name': originName,
    'origin_address': originAddress,
    'destination_latitude': _round6(destinationLatitude),
    'destination_longitude': _round6(destinationLongitude),
    'destination_name': destinationName,
    'destination_address': destinationAddress,
    'mode': mode,
  };
}

class TravelModeItem {
  final String mode;
  final String title;
  final String duration;
  final IconData icon;

  const TravelModeItem({
    required this.mode,
    required this.title,
    required this.duration,
    required this.icon,
  });

  static const List<TravelModeItem> defaultModes = [
    TravelModeItem(
      mode: 'drive',
      title: 'Drive',
      duration: '',
      icon: Icons.directions_car_rounded,
    ),
    TravelModeItem(
      mode: 'transit',
      title: 'Transit',
      duration: '',
      icon: Icons.directions_bus_rounded,
    ),
    TravelModeItem(
      mode: 'walk',
      title: 'Walk',
      duration: '',
      icon: Icons.directions_walk_rounded,
    ),
    TravelModeItem(
      mode: 'bike',
      title: 'Bike',
      duration: '',
      icon: Icons.directions_bike_rounded,
    ),
  ];

  static IconData getIconForMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'transit':
      case 'bus':
        return Icons.directions_bus_rounded;
      case 'walk':
      case 'walking':
        return Icons.directions_walk_rounded;
      case 'bike':
      case 'bicycling':
      case 'cycling':
        return Icons.directions_bike_rounded;
      case 'drive':
      case 'driving':
      default:
        return Icons.directions_car_rounded;
    }
  }

  static String getTitleForMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'transit':
      case 'bus':
        return 'Transit';
      case 'walk':
      case 'walking':
        return 'Walk';
      case 'bike':
      case 'bicycling':
      case 'cycling':
        return 'Bike';
      case 'drive':
      case 'driving':
      default:
        return 'Drive';
    }
  }
}

class RouteOptionItem {
  final String id;
  final String routeType;
  final String duration;
  final String distance;
  final String trafficStatus;
  final Color trafficColor;
  final bool hasCurve;
  final List<LatLng> points;

  const RouteOptionItem({
    required this.id,
    required this.routeType,
    required this.duration,
    required this.distance,
    required this.trafficStatus,
    required this.trafficColor,
    required this.hasCurve,
    required this.points,
  });

  RouteOptionItem copyWith({
    String? id,
    String? routeType,
    String? duration,
    String? distance,
    String? trafficStatus,
    Color? trafficColor,
    bool? hasCurve,
    List<LatLng>? points,
  }) {
    return RouteOptionItem(
      id: id ?? this.id,
      routeType: routeType ?? this.routeType,
      duration: duration ?? this.duration,
      distance: distance ?? this.distance,
      trafficStatus: trafficStatus ?? this.trafficStatus,
      trafficColor: trafficColor ?? this.trafficColor,
      hasCurve: hasCurve ?? this.hasCurve,
      points: points ?? this.points,
    );
  }

  factory RouteOptionItem.fromJson(Map<String, dynamic> json, int index) {
    final routeType =
        json['route_name'] as String? ??
        (index == 0 ? 'Fastest route' : 'Alternative route');

    final duration =
        json['duration_display'] as String? ??
        (json['duration_minutes'] != null
            ? '${json['duration_minutes']} min'
            : '');

    final distance =
        json['distance_display'] as String? ??
        (json['distance_km'] != null ? '${json['distance_km']} km' : '');

    final trafficStatus = json['traffic_status'] as String? ?? '';
    final trafficColor = _parseTrafficColor(
      json['traffic_color'] as String? ?? '',
      trafficStatus,
    );

    final points = PolylineDecoder.parsePoints(json['polyline']);

    return RouteOptionItem(
      id: json['id'] as String? ?? 'route_${index + 1}',
      routeType: routeType,
      duration: duration,
      distance: distance,
      trafficStatus: trafficStatus,
      trafficColor: trafficColor,
      hasCurve: index % 2 == 0,
      points: points,
    );
  }

  static Color _parseTrafficColor(String raw, String status) {
    final s = status.toLowerCase();
    final c = raw.toLowerCase();

    if (c.startsWith('#') && (c.length == 7 || c.length == 9)) {
      final hex = c.replaceFirst('#', '');
      return Color(int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16));
    }

    if (c.contains('green') || s.contains('light') || s.contains('clear')) {
      return const Color(0xFF12B76A);
    }
    if (c.contains('orange') ||
        c.contains('yellow') ||
        s.contains('moderate')) {
      return const Color(0xFFF79009);
    }
    if (c.contains('red') || s.contains('heavy') || s.contains('delay')) {
      return const Color(0xFFF04438);
    }

    return const Color(0xFF12B76A);
  }
}

class DirectionsData {
  final String originName;
  final String originAddress;
  final double originLatitude;
  final double originLongitude;
  final String destinationName;
  final String destinationAddress;
  final double destinationLatitude;
  final double destinationLongitude;
  final String mode;
  final List<TravelModeItem> travelModes;
  final List<RouteOptionItem> routes;

  const DirectionsData({
    this.originName = '',
    this.originAddress = '',
    this.originLatitude = 0.0,
    this.originLongitude = 0.0,
    this.destinationName = '',
    this.destinationAddress = '',
    this.destinationLatitude = 0.0,
    this.destinationLongitude = 0.0,
    this.mode = 'drive',
    this.travelModes = const [],
    this.routes = const [],
  });

  factory DirectionsData.fromJson(
    Map<String, dynamic> json, {
    DirectionsRequest? initialRequest,
  }) {
    final originMap = json['origin'] as Map<String, dynamic>?;
    final destMap = json['destination'] as Map<String, dynamic>?;

    final rawOriginLat =
        (originMap?['latitude'] as num?)?.toDouble() ??
        (json['origin_latitude'] as num?)?.toDouble() ??
        0.0;
    final rawOriginLng =
        (originMap?['longitude'] as num?)?.toDouble() ??
        (json['origin_longitude'] as num?)?.toDouble() ??
        0.0;

    final reqOriginLat = initialRequest?.originLatitude ?? 0.0;
    final reqOriginLng = initialRequest?.originLongitude ?? 0.0;
    final reqDestLat = initialRequest?.destinationLatitude ?? 0.0;
    final reqDestLng = initialRequest?.destinationLongitude ?? 0.0;

    // Detect if backend returned mock/dummy New York coordinates when user is elsewhere
    bool isBackendDummy = false;
    if (reqOriginLat != 0.0 && reqOriginLng != 0.0 && rawOriginLat != 0.0) {
      final dist = PolylineDecoder.calculateDistanceKm(
        reqOriginLat,
        reqOriginLng,
        rawOriginLat,
        rawOriginLng,
      );
      if (dist > 150.0) {
        isBackendDummy = true;
      }
    }

    final double originLatitude;
    final double originLongitude;
    final String originName;
    final String originAddress;
    final double destinationLatitude;
    final double destinationLongitude;
    final String destinationName;
    final String destinationAddress;

    if (isBackendDummy && reqOriginLat != 0.0 && reqDestLat != 0.0) {
      originLatitude = reqOriginLat;
      originLongitude = reqOriginLng;
      originName = initialRequest?.originName.isNotEmpty == true
          ? initialRequest!.originName
          : 'Your Location';
      originAddress = initialRequest?.originAddress ?? '';
      destinationLatitude = reqDestLat;
      destinationLongitude = reqDestLng;
      destinationName = initialRequest?.destinationName.isNotEmpty == true
          ? initialRequest!.destinationName
          : 'Destination';
      destinationAddress = initialRequest?.destinationAddress ?? '';
    } else {
      originLatitude = rawOriginLat != 0.0 ? rawOriginLat : reqOriginLat;
      originLongitude = rawOriginLng != 0.0 ? rawOriginLng : reqOriginLng;
      originName = originMap?['name'] as String? ??
          json['origin_name'] as String? ??
          initialRequest?.originName ??
          '';
      originAddress = originMap?['address'] as String? ??
          json['origin_address'] as String? ??
          initialRequest?.originAddress ??
          '';

      final rawDestLat =
          (destMap?['latitude'] as num?)?.toDouble() ??
          (json['destination_latitude'] as num?)?.toDouble() ??
          0.0;
      final rawDestLng =
          (destMap?['longitude'] as num?)?.toDouble() ??
          (json['destination_longitude'] as num?)?.toDouble() ??
          0.0;

      destinationLatitude = rawDestLat != 0.0 ? rawDestLat : reqDestLat;
      destinationLongitude = rawDestLng != 0.0 ? rawDestLng : reqDestLng;
      destinationName = destMap?['name'] as String? ??
          json['destination_name'] as String? ??
          initialRequest?.destinationName ??
          '';
      destinationAddress = destMap?['address'] as String? ??
          json['destination_address'] as String? ??
          initialRequest?.destinationAddress ??
          '';
    }

    final mode =
        json['selected_mode'] as String? ??
        json['mode'] as String? ??
        initialRequest?.mode ??
        'drive';

    final travelModes = <TravelModeItem>[];

    // If backend returned dummy mock New York data, calculate real travel times based on real distance
    if (isBackendDummy && originLatitude != 0.0 && destinationLatitude != 0.0) {
      final realDistKm = (PolylineDecoder.calculateDistanceKm(
                originLatitude,
                originLongitude,
                destinationLatitude,
                destinationLongitude,
              ) *
              1.35)
          .clamp(0.5, 50000.0);

      final driveMins = (realDistKm / 22.0 * 60).round().clamp(2, 7200);
      final transitMins = (realDistKm / 16.0 * 60 + 8).round().clamp(5, 7200);
      final walkMins = (realDistKm / 4.8 * 60).round().clamp(3, 14400);
      final bikeMins = (realDistKm / 14.0 * 60).round().clamp(2, 7200);

      travelModes.addAll([
        TravelModeItem(
          mode: 'drive',
          title: 'Drive',
          duration: PolylineDecoder.formatMinutesToDuration(driveMins),
          icon: Icons.directions_car_rounded,
        ),
        TravelModeItem(
          mode: 'transit',
          title: 'Transit',
          duration: PolylineDecoder.formatMinutesToDuration(transitMins),
          icon: Icons.directions_bus_rounded,
        ),
        TravelModeItem(
          mode: 'walk',
          title: 'Walk',
          duration: PolylineDecoder.formatMinutesToDuration(walkMins),
          icon: Icons.directions_walk_rounded,
        ),
        TravelModeItem(
          mode: 'bike',
          title: 'Bike',
          duration: PolylineDecoder.formatMinutesToDuration(bikeMins),
          icon: Icons.directions_bike_rounded,
        ),
      ]);
    } else {
      final rawModes = json['modes'];
      if (rawModes is List) {
        for (final item in rawModes) {
          if (item is Map<String, dynamic>) {
            final m = (item['mode'] as String? ?? 'drive').toLowerCase();
            final dur =
                item['duration_display'] as String? ??
                (item['duration_minutes'] != null
                    ? '${item['duration_minutes']} min'
                    : '');
            final title =
                item['label'] as String? ?? TravelModeItem.getTitleForMode(m);
            travelModes.add(
              TravelModeItem(
                mode: m,
                title: title,
                duration: dur,
                icon: TravelModeItem.getIconForMode(m),
              ),
            );
          }
        }
      }

      if (travelModes.isEmpty) {
        travelModes.addAll(TravelModeItem.defaultModes);
      }
    }

    final routes = <RouteOptionItem>[];

    if (isBackendDummy && originLatitude != 0.0 && destinationLatitude != 0.0) {
      final realDistKm = (PolylineDecoder.calculateDistanceKm(
                originLatitude,
                originLongitude,
                destinationLatitude,
                destinationLongitude,
              ) *
              1.35)
          .clamp(0.5, 50000.0);

      final activeMins = mode == 'walk'
          ? (realDistKm / 4.8 * 60).round()
          : (mode == 'transit'
              ? (realDistKm / 16.0 * 60 + 8).round()
              : (mode == 'bike'
                  ? (realDistKm / 14.0 * 60).round()
                  : (realDistKm / 22.0 * 60).round()));

      final basePoints = PolylineDecoder.generateRealisticPoints(
        originLatitude,
        originLongitude,
        destinationLatitude,
        destinationLongitude,
        0,
      );
      final altPoints = PolylineDecoder.generateRealisticPoints(
        originLatitude,
        originLongitude,
        destinationLatitude,
        destinationLongitude,
        1,
      );
      final altPoints2 = PolylineDecoder.generateRealisticPoints(
        originLatitude,
        originLongitude,
        destinationLatitude,
        destinationLongitude,
        2,
      );

      routes.addAll([
        RouteOptionItem(
          id: 'route_1',
          routeType: 'Fastest route',
          duration: PolylineDecoder.formatMinutesToDuration(activeMins),
          distance: '${realDistKm.toStringAsFixed(1)} km',
          trafficStatus: 'Light traffic',
          trafficColor: const Color(0xFF12B76A),
          hasCurve: true,
          points: basePoints,
        ),
        RouteOptionItem(
          id: 'route_2',
          routeType: 'Alternative route',
          duration: PolylineDecoder.formatMinutesToDuration(
            (activeMins * 1.15).round(),
          ),
          distance: '${(realDistKm * 1.1).toStringAsFixed(1)} km',
          trafficStatus: 'Moderate traffic',
          trafficColor: const Color(0xFFF79009),
          hasCurve: false,
          points: altPoints,
        ),
        RouteOptionItem(
          id: 'route_3',
          routeType: 'Fewer turns',
          duration: PolylineDecoder.formatMinutesToDuration(
            (activeMins * 1.25).round(),
          ),
          distance: '${(realDistKm * 1.05).toStringAsFixed(1)} km',
          trafficStatus: 'Light traffic',
          trafficColor: const Color(0xFF12B76A),
          hasCurve: true,
          points: altPoints2,
        ),
      ]);
    } else {
      final rawRoutes = json['routes'];
      if (rawRoutes is List) {
        for (int i = 0; i < rawRoutes.length; i++) {
          final r = rawRoutes[i];
          if (r is Map<String, dynamic>) {
            routes.add(RouteOptionItem.fromJson(r, i));
          }
        }
      }
    }

    return DirectionsData(
      originName: originName,
      originAddress: originAddress,
      originLatitude: originLatitude,
      originLongitude: originLongitude,
      destinationName: destinationName,
      destinationAddress: destinationAddress,
      destinationLatitude: destinationLatitude,
      destinationLongitude: destinationLongitude,
      mode: mode,
      travelModes: travelModes,
      routes: routes,
    );
  }

  /// Returns routes with durations dynamically synchronized with the selected transport mode
  List<RouteOptionItem> getRoutesForMode(int selectedTransportIndex) {
    if (travelModes.isEmpty ||
        selectedTransportIndex < 0 ||
        selectedTransportIndex >= travelModes.length ||
        routes.isEmpty) {
      return routes;
    }

    final activeMode = travelModes[selectedTransportIndex];
    final activeDuration = activeMode.duration;
    if (activeDuration.isEmpty) return routes;

    final activeMinutes =
        PolylineDecoder.parseDurationToMinutes(activeDuration);
    if (activeMinutes <= 0) return routes;

    final baseDriveMinutes =
        PolylineDecoder.parseDurationToMinutes(routes.first.duration);

    return List.generate(routes.length, (i) {
      final r = routes[i];
      if (i == 0) {
        return r.copyWith(duration: activeDuration);
      }

      final thisMinutes = PolylineDecoder.parseDurationToMinutes(r.duration);
      if (baseDriveMinutes > 0 && thisMinutes > baseDriveMinutes) {
        final ratio = thisMinutes / baseDriveMinutes;
        final scaled = (activeMinutes * ratio).round();
        return r.copyWith(
          duration: PolylineDecoder.formatMinutesToDuration(scaled),
        );
      }

      return r.copyWith(duration: activeDuration);
    });
  }
}

class DirectionsResponseModel {
  final bool success;
  final String message;
  final DirectionsData? data;

  const DirectionsResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory DirectionsResponseModel.fromJson(
    Map<String, dynamic> json, {
    DirectionsRequest? request,
  }) {
    return DirectionsResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? DirectionsData.fromJson(
              json['data'] as Map<String, dynamic>,
              initialRequest: request,
            )
          : null,
    );
  }
}

class DirectionsState {
  final bool isLoading;
  final String? errorMessage;
  final DirectionsData? data;
  final int selectedTransportIndex;
  final int selectedRouteIndex;

  const DirectionsState({
    this.isLoading = false,
    this.errorMessage,
    this.data,
    this.selectedTransportIndex = 0,
    this.selectedRouteIndex = 0,
  });

  static DirectionsState initial() => const DirectionsState(
    isLoading: true,
    selectedTransportIndex: 0,
    selectedRouteIndex: 0,
  );

  List<RouteOptionItem> get routes {
    if (data == null || data!.routes.isEmpty) return const [];
    return data!.getRoutesForMode(selectedTransportIndex);
  }

  RouteOptionItem? get selectedRoute {
    final list = routes;
    if (list.isEmpty) return null;
    if (selectedRouteIndex >= 0 && selectedRouteIndex < list.length) {
      return list[selectedRouteIndex];
    }
    return list.first;
  }

  DirectionsState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    DirectionsData? data,
    int? selectedTransportIndex,
    int? selectedRouteIndex,
  }) {
    return DirectionsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      data: data ?? this.data,
      selectedTransportIndex:
          selectedTransportIndex ?? this.selectedTransportIndex,
      selectedRouteIndex: selectedRouteIndex ?? this.selectedRouteIndex,
    );
  }
}

class PolylineDecoder {
  static int parseDurationToMinutes(String durationStr) {
    if (durationStr.isEmpty) return 0;
    final str = durationStr.toLowerCase().trim();
    int totalMinutes = 0;

    final hrMatch = RegExp(r'(\d+)\s*(?:hr|hour|h)').firstMatch(str);
    if (hrMatch != null) {
      totalMinutes += (int.tryParse(hrMatch.group(1) ?? '') ?? 0) * 60;
    }

    final minMatch = RegExp(r'(\d+)\s*(?:min|m)').firstMatch(str);
    if (minMatch != null) {
      totalMinutes += int.tryParse(minMatch.group(1) ?? '') ?? 0;
    }

    if (totalMinutes == 0) {
      totalMinutes =
          int.tryParse(RegExp(r'\d+').firstMatch(str)?.group(0) ?? '') ?? 0;
    }

    return totalMinutes;
  }

  static String formatMinutesToDuration(int minutes) {
    if (minutes <= 0) return '';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0 && mins > 0) {
      return '$hours hr $mins min';
    } else if (hours > 0) {
      return '$hours hr';
    } else {
      return '$mins min';
    }
  }

  static double calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295; // math.pi / 180
    final a = 0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) *
            math.cos(lat2 * p) *
            (1 - math.cos((lon2 - lon1) * p)) /
            2;
    return 12742 * math.asin(math.sqrt(a.clamp(0.0, 1.0)));
  }

  static List<LatLng> generateRealisticPoints(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
    int variant,
  ) {
    final points = <LatLng>[LatLng(lat1, lng1)];
    const count = 16;
    final dLat = lat2 - lat1;
    final dLng = lng2 - lng1;

    final perpLat = -dLng;
    final perpLng = dLat;

    final curveStrength = variant == 0 ? 0.08 : (variant == 1 ? -0.12 : 0.04);

    for (int i = 1; i < count; i++) {
      final t = i / count;
      final offset = 4 * t * (1 - t) * curveStrength;
      final curLat = lat1 + dLat * t + perpLat * offset;
      final curLng = lng1 + dLng * t + perpLng * offset;
      points.add(LatLng(curLat, curLng));
    }

    points.add(LatLng(lat2, lng2));
    return points;
  }

  static List<LatLng> parsePoints(dynamic raw) {
    if (raw == null) return const [];

    if (raw is List) {
      final list = <LatLng>[];
      for (final item in raw) {
        if (item is Map) {
          final lat =
              (item['latitude'] ?? item['lat'] as num?)?.toDouble() ?? 0.0;
          final lng =
              (item['longitude'] ?? item['lng'] as num?)?.toDouble() ?? 0.0;
          if (lat != 0.0 || lng != 0.0) {
            list.add(LatLng(lat, lng));
          }
        }
      }
      if (list.isNotEmpty) return list;
    }

    if (raw is String) {
      return decode(raw);
    }

    return const [];
  }

  static List<LatLng> decode(String encoded) {
    if (encoded.isEmpty) return const [];
    final points = <LatLng>[];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    try {
      while (index < len) {
        int b, shift = 0, result = 0;
        do {
          b = encoded.codeUnitAt(index++) - 63;
          result |= (b & 0x1f) << shift;
          shift += 5;
        } while (b >= 0x20);
        int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
        lat += dlat;

        shift = 0;
        result = 0;
        do {
          b = encoded.codeUnitAt(index++) - 63;
          result |= (b & 0x1f) << shift;
          shift += 5;
        } while (b >= 0x20);
        int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
        lng += dlng;

        points.add(LatLng(lat / 1E5, lng / 1E5));
      }
    } catch (_) {}
    return points;
  }
}
