import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/theme/dark_map_style.dart';
import 'package:iwitnez/feature/main_user/SafetyTracking/provider/safety_tracking_provider.dart';

class SafetyHistoryMapView extends ConsumerStatefulWidget {
  const SafetyHistoryMapView({super.key});

  @override
  ConsumerState<SafetyHistoryMapView> createState() =>
      _SafetyHistoryMapViewState();
}

class _SafetyHistoryMapViewState extends ConsumerState<SafetyHistoryMapView> {
  GoogleMapController? _mapController;
  final MapType _mapType = MapType.normal;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _fitRouteBounds(List<LatLng> route) {
    if (_mapController == null || route.isEmpty) return;
    if (route.length == 1) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(route.first, 15),
      );
      return;
    }

    double minLat = route.first.latitude;
    double maxLat = route.first.latitude;
    double minLng = route.first.longitude;
    double maxLng = route.first.longitude;

    for (final point in route) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 48.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(safetyTrackingProvider);
    final history = state.historyData;
    final route = history?.route ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(safetyTrackingProvider, (prev, next) {
      if (prev?.historyData != next.historyData &&
          next.historyData != null &&
          next.historyData!.route.isNotEmpty) {
        _fitRouteBounds(next.historyData!.route);
      }
    });

    final polylines = <Polyline>{};
    final markers = <Marker>{};

    if (route.isNotEmpty) {
      // 1. Purple route polyline
      polylines.add(
        Polyline(
          polylineId: const PolylineId('history_route_polyline'),
          points: route,
          color: const Color(0xFF6C48F5),
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
        ),
      );

      // 2. Green Marker at data.route.first (Start)
      final startPoint = route.first;
      markers.add(
        Marker(
          markerId: const MarkerId('history_start_marker'),
          position: startPoint,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: 'Start',
            snippet: history?.timeline.isNotEmpty == true
                ? history!.timeline.first.address
                : 'Journey start',
          ),
        ),
      );

      // 3. Red Marker at data.route.last (End)
      if (route.length > 1) {
        final endPoint = route.last;
        markers.add(
          Marker(
            markerId: const MarkerId('history_end_marker'),
            position: endPoint,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(
              title: 'End',
              snippet: history?.timeline.isNotEmpty == true
                  ? history!.timeline.last.address
                  : 'Journey destination',
            ),
          ),
        );
      }
    }

    final initialCenter = route.isNotEmpty
        ? route.first
        : const LatLng(40.7580, -73.9855); // NYC Times Square fallback

    return Stack(
      children: [
        // 1. Google Map View
        GoogleMap(
          key: ValueKey('history_map_${route.length}_$isDark'),
          style: isDark ? darkMapStyleJson : null,
          initialCameraPosition: CameraPosition(
            target: initialCenter,
            zoom: 13.0,
          ),
          mapType: _mapType,
          polylines: polylines,
          markers: markers,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: false,
          mapToolbarEnabled: false,
          rotateGesturesEnabled: true,
          scrollGesturesEnabled: true,
          tiltGesturesEnabled: false,
          zoomGesturesEnabled: true,
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          },
          onMapCreated: (controller) {
            _mapController = controller;
            if (route.isNotEmpty) {
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) _fitRouteBounds(route);
              });
            }
          },
        ),

        // 2. Loading indicator if fetching history
        if (state.isLoadingHistory)
          Positioned(
            top: 14.h,
            left: 16.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF181A26).withValues(alpha: 0.95)
                    : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isDark ? const Color(0xFF262938) : Colors.transparent,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 14.r,
                    height: 14.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isDark ? const Color(0xFFA855F7) : const Color(0xFF6C48F5),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Loading route...',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isDark ? Colors.white : const Color(0xFF4B5563),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // 3. Floating Map Controls (Recenter bounds, Zoom In, Zoom Out)
        Positioned(
          right: 14.w,
          top: 14.h,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Fit Route / Recenter
              _buildMapButton(
                icon: Icons.center_focus_strong_rounded,
                isDark: isDark,
                onTap: () {
                  if (route.isNotEmpty) {
                    _fitRouteBounds(route);
                  }
                },
              ),
              SizedBox(height: 8.h),

              // Zoom In & Out Box
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF181A26) : Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: isDark ? const Color(0xFF262938) : Colors.transparent,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildZoomSubButton(
                      icon: Icons.add,
                      isDark: isDark,
                      onTap: () {
                        _mapController?.animateCamera(CameraUpdate.zoomIn());
                      },
                    ),
                    Container(
                      width: 22.w,
                      height: 1,
                      color: isDark ? const Color(0xFF262938) : const Color(0xFFE5E7EB),
                    ),
                    _buildZoomSubButton(
                      icon: Icons.remove,
                      isDark: isDark,
                      onTap: () {
                        _mapController?.animateCamera(CameraUpdate.zoomOut());
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: isDark ? const Color(0xFF181A26) : Colors.white,
      shape: CircleBorder(
        side: isDark
            ? const BorderSide(color: Color(0xFF262938))
            : BorderSide.none,
      ),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.3 : 0.18),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 38.r,
          height: 38.r,
          child: Icon(
            icon,
            size: 20.sp,
            color: isDark ? const Color(0xFFA855F7) : AppColors.callsPurple,
          ),
        ),
      ),
    );
  }

  Widget _buildZoomSubButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: SizedBox(
        width: 38.r,
        height: 32.r,
        child: Icon(
          icon,
          size: 18.sp,
          color: isDark ? Colors.white : const Color(0xFF374151),
        ),
      ),
    );
  }
}
