import 'package:flutter/material.dart';

class RouteOption {
  final String duration;
  final String distance;
  final String routeType;
  final String trafficStatus;
  final Color trafficColor;
  final bool hasCurve;
  final bool isFastest;

  const RouteOption({
    required this.duration,
    required this.distance,
    required this.routeType,
    required this.trafficStatus,
    required this.trafficColor,
    required this.hasCurve,
    required this.isFastest,
  });
}

class TransportMode {
  final String title;
  final String duration;
  final IconData icon;

  const TransportMode({
    required this.title,
    required this.duration,
    required this.icon,
  });
}

class GetDirectionsProvider extends ChangeNotifier {
  // Origin & Destination
  String _originTitle = 'Your Location';
  String _originSubtitle = 'Near East 75th Street, Manhattan, NY';
  String _destinationTitle = 'Work';
  String _destinationSubtitle = '10 Wall Street, New York, NY 10005';

  String get originTitle => _originTitle;
  String get originSubtitle => _originSubtitle;
  String get destinationTitle => _destinationTitle;
  String get destinationSubtitle => _destinationSubtitle;

  void swapLocations() {
    final tempTitle = _originTitle;
    final tempSub = _originSubtitle;
    _originTitle = _destinationTitle;
    _originSubtitle = _destinationSubtitle;
    _destinationTitle = tempTitle;
    _destinationSubtitle = tempSub;
    notifyListeners();
  }

  // Transport Modes
  int _selectedTransportIndex = 0;
  int get selectedTransportIndex => _selectedTransportIndex;

  final List<TransportMode> _transportModes = const [
    TransportMode(
      title: 'Drive',
      duration: '24 min',
      icon: Icons.directions_car_rounded,
    ),
    TransportMode(
      title: 'Transit',
      duration: '35 min',
      icon: Icons.directions_bus_rounded,
    ),
    TransportMode(
      title: 'Walk',
      duration: '1 hr 12 min',
      icon: Icons.directions_walk_rounded,
    ),
    TransportMode(
      title: 'Bike',
      duration: '28 min',
      icon: Icons.directions_bike_rounded,
    ),
  ];
  List<TransportMode> get transportModes => _transportModes;

  void selectTransport(int index) {
    if (_selectedTransportIndex != index) {
      _selectedTransportIndex = index;
      _updateRoutesForTransport(index);
      notifyListeners();
    }
  }

  // Routes
  int _selectedRouteIndex = 0;
  int get selectedRouteIndex => _selectedRouteIndex;

  List<RouteOption> _routes = [
    const RouteOption(
      duration: '24 min',
      distance: '8.4 km',
      routeType: 'Fastest route',
      trafficStatus: 'Light traffic',
      trafficColor: Color(0xFF12B76A),
      hasCurve: true,
      isFastest: true,
    ),
    const RouteOption(
      duration: '28 min',
      distance: '9.1 km',
      routeType: 'Alternative route',
      trafficStatus: 'Moderate traffic',
      trafficColor: Color(0xFFF79009),
      hasCurve: true,
      isFastest: false,
    ),
    const RouteOption(
      duration: '32 min',
      distance: '8.7 km',
      routeType: 'Fdr Drive',
      trafficStatus: 'Light traffic',
      trafficColor: Color(0xFF12B76A),
      hasCurve: false,
      isFastest: false,
    ),
  ];
  List<RouteOption> get routes => _routes;
  RouteOption get selectedRoute => _routes[_selectedRouteIndex];

  void selectRoute(int index) {
    if (_selectedRouteIndex != index) {
      _selectedRouteIndex = index;
      notifyListeners();
    }
  }

  void _updateRoutesForTransport(int transportIndex) {
    _selectedRouteIndex = 0;
    switch (transportIndex) {
      case 0: // Drive
        _routes = [
          const RouteOption(
            duration: '24 min',
            distance: '8.4 km',
            routeType: 'Fastest route',
            trafficStatus: 'Light traffic',
            trafficColor: Color(0xFF12B76A),
            hasCurve: true,
            isFastest: true,
          ),
          const RouteOption(
            duration: '28 min',
            distance: '9.1 km',
            routeType: 'Alternative route',
            trafficStatus: 'Moderate traffic',
            trafficColor: Color(0xFFF79009),
            hasCurve: true,
            isFastest: false,
          ),
          const RouteOption(
            duration: '32 min',
            distance: '8.7 km',
            routeType: 'Fdr Drive',
            trafficStatus: 'Light traffic',
            trafficColor: Color(0xFF12B76A),
            hasCurve: false,
            isFastest: false,
          ),
        ];
        break;
      case 1: // Transit
        _routes = [
          const RouteOption(
            duration: '35 min',
            distance: '8.2 km',
            routeType: 'Subway Line 4, 5',
            trafficStatus: 'On time',
            trafficColor: Color(0xFF12B76A),
            hasCurve: true,
            isFastest: true,
          ),
          const RouteOption(
            duration: '42 min',
            distance: '8.9 km',
            routeType: 'Express Bus M15',
            trafficStatus: 'Light delay',
            trafficColor: Color(0xFFF79009),
            hasCurve: false,
            isFastest: false,
          ),
        ];
        break;
      case 2: // Walk
        _routes = [
          const RouteOption(
            duration: '1 hr 12 min',
            distance: '7.8 km',
            routeType: 'Via Broadway',
            trafficStatus: 'Pedestrian friendly',
            trafficColor: Color(0xFF12B76A),
            hasCurve: true,
            isFastest: true,
          ),
        ];
        break;
      case 3: // Bike
        _routes = [
          const RouteOption(
            duration: '28 min',
            distance: '8.1 km',
            routeType: 'East River Greenway',
            trafficStatus: 'Dedicated bike lane',
            trafficColor: Color(0xFF12B76A),
            hasCurve: true,
            isFastest: true,
          ),
        ];
        break;
    }
  }

  // Interactive Map State
  Offset _mapOffset = Offset.zero;
  double _zoomScale = 1.0;
  double _baseScale = 1.0;

  Offset get mapOffset => _mapOffset;
  double get zoomScale => _zoomScale;

  void onScaleStart(ScaleStartDetails details) {
    _baseScale = _zoomScale;
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    _mapOffset += details.focalPointDelta;
    if (details.scale != 1.0) {
      _zoomScale = (_baseScale * details.scale).clamp(0.7, 3.0);
    }
    notifyListeners();
  }

  void resetMap() {
    _mapOffset = Offset.zero;
    _zoomScale = 1.0;
    _baseScale = 1.0;
    notifyListeners();
  }

  void zoomIn() {
    _zoomScale = (_zoomScale + 0.25).clamp(0.7, 3.0);
    _baseScale = _zoomScale;
    notifyListeners();
  }

  void zoomOut() {
    _zoomScale = (_zoomScale - 0.25).clamp(0.7, 3.0);
    _baseScale = _zoomScale;
    notifyListeners();
  }

  // Sheet Extent State
  double _currentSheetExtent = 0.13;
  double get currentSheetExtent => _currentSheetExtent;
  bool get isSheetExpanded => _currentSheetExtent > 0.28;

  void updateSheetExtent(double extent) {
    if ((extent - _currentSheetExtent).abs() > 0.02) {
      _currentSheetExtent = extent;
      notifyListeners();
    }
  }
}
