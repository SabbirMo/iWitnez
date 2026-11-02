import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iwitnez/feature/trusted_contact/LiveLocation/model/directions_model.dart';

class GoogleDirectionsResult {
  final List<RouteOptionItem> routes;
  final String durationText;
  final int durationMinutes;
  final String distanceText;
  final double distanceKm;

  const GoogleDirectionsResult({
    required this.routes,
    required this.durationText,
    required this.durationMinutes,
    required this.distanceText,
    required this.distanceKm,
  });

  static const empty = GoogleDirectionsResult(
    routes: [],
    durationText: '',
    durationMinutes: 0,
    distanceText: '',
    distanceKm: 0.0,
  );
}

class GoogleDirectionsService {
  final Dio _dio;
  final String _apiKey;

  GoogleDirectionsService({Dio? dio, String? apiKey})
      : _dio = dio ?? Dio(),
        _apiKey = apiKey ??
            dotenv.env['GOOGLE_MAPS_API_KEY'] ??
            'AIzaSyBbNXEsdj53mZw0Mzz-k8ZyjOWaL0qmgQ0';

  String _cleanDuration(String text) {
    if (text.isEmpty) return '';
    return text
        .replaceAll('hours', 'hr')
        .replaceAll('hour', 'hr')
        .replaceAll('mins', 'min')
        .replaceAll('minutes', 'min')
        .replaceAll('minute', 'min')
        .trim();
  }

  Future<GoogleDirectionsResult> _queryGoogleMode({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    required String googleMode,
    bool alternatives = false,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'origin': '$originLat,$originLng',
        'destination': '$destLat,$destLng',
        'mode': googleMode,
        'alternatives': alternatives.toString(),
        'key': _apiKey,
      };

      if (googleMode == 'driving') {
        queryParams['departure_time'] = 'now';
      }

      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/directions/json',
        queryParameters: queryParams,
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      final map = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : (response.data is String
              ? jsonDecode(response.data as String) as Map<String, dynamic>
              : null);

      if (map == null || map['status'] != 'OK') {
        return GoogleDirectionsResult.empty;
      }

      final rawRoutes = map['routes'] as List?;
      if (rawRoutes == null || rawRoutes.isEmpty) {
        return GoogleDirectionsResult.empty;
      }

      final routes = <RouteOptionItem>[];
      String firstDuration = '';
      int firstDurationMins = 0;
      String firstDistance = '';
      double firstDistKm = 0.0;

      for (int i = 0; i < rawRoutes.length; i++) {
        final r = rawRoutes[i] as Map<String, dynamic>;
        final legs = r['legs'] as List?;
        final leg = legs != null && legs.isNotEmpty
            ? legs.first as Map<String, dynamic>
            : null;

        final rawDuration = leg?['duration_in_traffic']?['text'] as String? ??
            leg?['duration']?['text'] as String? ??
            '';
        final durText = _cleanDuration(rawDuration);

        final durValSec = (leg?['duration_in_traffic']?['value'] as num?)?.toInt() ??
            (leg?['duration']?['value'] as num?)?.toInt() ??
            0;
        final durMins = (durValSec / 60).round();

        final distText = leg?['distance']?['text'] as String? ?? '';
        final distValM = (leg?['distance']?['value'] as num?)?.toDouble() ?? 0.0;
        final distKm = distValM / 1000.0;

        if (i == 0) {
          firstDuration = durText;
          firstDurationMins = durMins;
          firstDistance = distText;
          firstDistKm = distKm;
        }

        final summary = r['summary'] as String? ?? '';
        final routeType = summary.isNotEmpty
            ? (i == 0 ? '$summary (Fastest)' : summary)
            : (i == 0
                ? 'Fastest route'
                : (i == 1 ? 'Alternative route' : 'Fewer turns'));

        // Traffic status evaluation
        String trafficStatus = '';
        Color trafficColor = const Color(0xFF12B76A);

        if (googleMode == 'driving') {
          final normSec = (leg?['duration']?['value'] as num?)?.toInt() ?? 1;
          final trafSec = (leg?['duration_in_traffic']?['value'] as num?)?.toInt() ?? normSec;
          if (trafSec > normSec * 1.25) {
            trafficStatus = 'Heavy traffic';
            trafficColor = const Color(0xFFF04438);
          } else if (trafSec > normSec * 1.08) {
            trafficStatus = 'Moderate traffic';
            trafficColor = const Color(0xFFF79009);
          } else {
            trafficStatus = 'Light traffic';
            trafficColor = const Color(0xFF12B76A);
          }
        }

        final overviewPolyline =
            r['overview_polyline']?['points'] as String? ?? '';
        final points = PolylineDecoder.decode(overviewPolyline);

        routes.add(
          RouteOptionItem(
            id: 'google_route_${googleMode}_$i',
            routeType: routeType,
            duration: durText,
            distance: distText,
            trafficStatus: trafficStatus,
            trafficColor: trafficColor,
            hasCurve: true,
            points: points,
          ),
        );
      }

      return GoogleDirectionsResult(
        routes: routes,
        durationText: firstDuration,
        durationMinutes: firstDurationMins,
        distanceText: firstDistance,
        distanceKm: firstDistKm,
      );
    } catch (e) {
      debugPrint('GoogleDirectionsService._queryGoogleMode ($googleMode) error: $e');
      return GoogleDirectionsResult.empty;
    }
  }

  Future<DirectionsResponseModel> getDirections(
    DirectionsRequest request,
  ) async {
    final originLat = request.originLatitude;
    final originLng = request.originLongitude;
    final destLat = request.destinationLatitude;
    final destLng = request.destinationLongitude;
    final reqMode = request.mode.toLowerCase();

    // Query 4 modes in parallel
    final driveFuture = _queryGoogleMode(
      originLat: originLat,
      originLng: originLng,
      destLat: destLat,
      destLng: destLng,
      googleMode: 'driving',
      alternatives: reqMode == 'drive',
    );

    final walkFuture = _queryGoogleMode(
      originLat: originLat,
      originLng: originLng,
      destLat: destLat,
      destLng: destLng,
      googleMode: 'walking',
      alternatives: reqMode == 'walk',
    );

    final transitFuture = _queryGoogleMode(
      originLat: originLat,
      originLng: originLng,
      destLat: destLat,
      destLng: destLng,
      googleMode: 'transit',
      alternatives: reqMode == 'transit',
    );

    final bikeFuture = _queryGoogleMode(
      originLat: originLat,
      originLng: originLng,
      destLat: destLat,
      destLng: destLng,
      googleMode: 'bicycling',
      alternatives: reqMode == 'bike',
    );

    final results = await Future.wait([
      driveFuture,
      walkFuture,
      transitFuture,
      bikeFuture,
    ]);

    final driveRes = results[0];
    final walkRes = results[1];
    final transitRes = results[2];
    final bikeRes = results[3];

    // Reference real distance
    final double refDistanceKm = driveRes.distanceKm > 0
        ? driveRes.distanceKm
        : (walkRes.distanceKm > 0
            ? walkRes.distanceKm
            : PolylineDecoder.calculateDistanceKm(
                originLat,
                originLng,
                destLat,
                destLng,
              ));

    // Durations for the 4 modes
    final String driveDur = driveRes.durationText.isNotEmpty
        ? driveRes.durationText
        : PolylineDecoder.formatMinutesToDuration(
            (refDistanceKm / 22.0 * 60).round().clamp(2, 7200),
          );

    final String walkDur = walkRes.durationText.isNotEmpty
        ? walkRes.durationText
        : PolylineDecoder.formatMinutesToDuration(
            (refDistanceKm / 4.8 * 60).round().clamp(3, 14400),
          );

    final String transitDur = transitRes.durationText.isNotEmpty
        ? transitRes.durationText
        : PolylineDecoder.formatMinutesToDuration(
            ((driveRes.durationMinutes > 0
                        ? driveRes.durationMinutes
                        : (refDistanceKm / 22.0 * 60).round()) *
                    1.35 +
                8)
                .round()
                .clamp(5, 7200),
          );

    final String bikeDur = bikeRes.durationText.isNotEmpty
        ? bikeRes.durationText
        : PolylineDecoder.formatMinutesToDuration(
            (refDistanceKm / 14.0 * 60).round().clamp(2, 7200),
          );

    final travelModes = [
      TravelModeItem(
        mode: 'drive',
        title: 'Drive',
        duration: driveDur,
        icon: Icons.directions_car_rounded,
      ),
      TravelModeItem(
        mode: 'transit',
        title: 'Transit',
        duration: transitDur,
        icon: Icons.directions_bus_rounded,
      ),
      TravelModeItem(
        mode: 'walk',
        title: 'Walk',
        duration: walkDur,
        icon: Icons.directions_walk_rounded,
      ),
      TravelModeItem(
        mode: 'bike',
        title: 'Bike',
        duration: bikeDur,
        icon: Icons.directions_bike_rounded,
      ),
    ];

    // Select the active routes list based on requested mode
    List<RouteOptionItem> activeRoutes = [];
    if (reqMode == 'walk' && walkRes.routes.isNotEmpty) {
      activeRoutes = walkRes.routes;
    } else if (reqMode == 'transit' && transitRes.routes.isNotEmpty) {
      activeRoutes = transitRes.routes;
    } else if (reqMode == 'bike' && bikeRes.routes.isNotEmpty) {
      activeRoutes = bikeRes.routes;
    } else if (driveRes.routes.isNotEmpty) {
      activeRoutes = driveRes.routes;
    }

    // If active routes is empty or non-drive mode had zero routes, adapt from drive routes
    if (activeRoutes.isEmpty && driveRes.routes.isNotEmpty) {
      final targetDuration = reqMode == 'walk'
          ? walkDur
          : (reqMode == 'transit'
              ? transitDur
              : (reqMode == 'bike' ? bikeDur : driveDur));

      activeRoutes = driveRes.routes.map((r) {
        return r.copyWith(
          duration: targetDuration,
          trafficStatus: reqMode == 'walk' || reqMode == 'bike'
              ? ''
              : r.trafficStatus,
        );
      }).toList();
    }

    // Fallback if completely no Google routes (e.g. offline)
    if (activeRoutes.isEmpty) {
      final basePoints = PolylineDecoder.generateRealisticPoints(
        originLat,
        originLng,
        destLat,
        destLng,
        0,
      );
      activeRoutes = [
        RouteOptionItem(
          id: 'route_1',
          routeType: 'Fastest route',
          duration: reqMode == 'walk'
              ? walkDur
              : (reqMode == 'transit' ? transitDur : driveDur),
          distance: '${refDistanceKm.toStringAsFixed(1)} km',
          trafficStatus: 'Light traffic',
          trafficColor: const Color(0xFF12B76A),
          hasCurve: true,
          points: basePoints,
        ),
      ];
    }

    final data = DirectionsData(
      originName: request.originName.isNotEmpty
          ? request.originName
          : 'Your Location',
      originAddress: request.originAddress,
      originLatitude: originLat,
      originLongitude: originLng,
      destinationName: request.destinationName.isNotEmpty
          ? request.destinationName
          : 'Destination',
      destinationAddress: request.destinationAddress,
      destinationLatitude: destLat,
      destinationLongitude: destLng,
      mode: reqMode,
      travelModes: travelModes,
      routes: activeRoutes,
    );

    return DirectionsResponseModel(
      success: true,
      message: 'Directions calculated successfully.',
      data: data,
    );
  }
}

