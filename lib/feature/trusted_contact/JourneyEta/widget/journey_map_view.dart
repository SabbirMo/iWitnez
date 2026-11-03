import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iwitnez/core/constants/theme/dark_map_style.dart';
import '../provider/journey_eta_provider.dart';

class JourneyMapView extends ConsumerStatefulWidget {
  const JourneyMapView({super.key});

  @override
  ConsumerState<JourneyMapView> createState() => _JourneyMapViewState();
}

class _JourneyMapViewState extends ConsumerState<JourneyMapView> {
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _fitRouteBounds(List<LatLng> route) {
    if (_mapController == null || route.isEmpty) return;
    if (route.length == 1) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(route.first.latitude, route.first.longitude),
          13,
        ),
      );
      return;
    }

    try {
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

      _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50.0));
    } catch (_) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(route.first.latitude, route.first.longitude),
          13,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(journeyEtaProvider);
    final journey = state.data;
    final route = journey?.route ?? [];

    ref.listen(journeyEtaProvider, (prev, next) {
      if (next.data != null && next.data!.route.isNotEmpty) {
        _fitRouteBounds(next.data!.route);
      }
    });

    if (route.isEmpty) {
      return Container(
        color: isDark ? const Color(0xFF181A26) : const Color(0xFFF1F5F9),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.map_outlined,
                size: 38.sp,
                color: isDark
                    ? const Color(0xFF64748B)
                    : const Color(0xFF94A3B8),
              ),
              SizedBox(height: 8.h),
              Text(
                'No route coordinates available',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final polylines = <Polyline>{
      Polyline(
        polylineId: const PolylineId('journey_route_polyline'),
        points: route,
        color: const Color(0xFF6C48F5),
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
    };

    final markers = <Marker>{
      // Start Marker at route.first
      Marker(
        markerId: const MarkerId('journey_start_marker'),
        position: route.first,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'Start',
          snippet: journey?.timeline.isNotEmpty == true
              ? journey!.timeline.first.address
              : null,
        ),
        zIndexInt: 10,
      ),
    };

    // End Marker at route.last
    if (route.length > 1) {
      markers.add(
        Marker(
          markerId: const MarkerId('journey_end_marker'),
          position: route.last,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'End',
            snippet: journey?.timeline.isNotEmpty == true
                ? journey!.timeline.last.address
                : null,
          ),
          zIndexInt: 10,
        ),
      );
    }

    return Stack(
      children: [
        // 1. Interactive Google Map
        GoogleMap(
          key: ValueKey('journey_map_${route.length}_$isDark'),
          initialCameraPosition: CameraPosition(
            target: route.first,
            zoom: 14.0,
          ),
          style: isDark ? darkMapStyleJson : null,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: false,
          mapToolbarEnabled: false,
          polylines: polylines,
          markers: markers,
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          },
          onMapCreated: (controller) {
            _mapController = controller;
            if (isDark) {
              controller.setMapStyle(darkMapStyleJson);
            }
            Future.delayed(const Duration(milliseconds: 300), () {
              _fitRouteBounds(route);
            });
          },
        ),

        // 2. Controls: Center & Zoom
        Positioned(
          top: 12.h,
          right: 12.w,
          child: Column(
            children: [
              _buildControlButton(
                icon: Icons.filter_center_focus_rounded,
                isDark: isDark,
                onTap: () => _fitRouteBounds(route),
              ),
              SizedBox(height: 10.h),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F2232) : Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: isDark
                      ? Border.all(color: const Color(0xFF2C3044))
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildZoomButton(
                      icon: Icons.add,
                      isDark: isDark,
                      onTap: () =>
                          _mapController?.animateCamera(CameraUpdate.zoomIn()),
                    ),
                    Container(
                      width: 24.w,
                      height: 1.h,
                      color: isDark
                          ? const Color(0xFF2C3044)
                          : const Color(0xFFE2E8F0),
                    ),
                    _buildZoomButton(
                      icon: Icons.remove,
                      isDark: isDark,
                      onTap: () =>
                          _mapController?.animateCamera(CameraUpdate.zoomOut()),
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

  Widget _buildControlButton({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2232) : Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: isDark
            ? Border.all(color: const Color(0xFF2C3044))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.r),
          child: Padding(
            padding: EdgeInsets.all(8.r),
            child: Icon(
              icon,
              size: 20.sp,
              color: isDark ? Colors.white : const Color(0xFF4B5563),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildZoomButton({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Padding(
          padding: EdgeInsets.all(8.r),
          child: Icon(
            icon,
            size: 20.sp,
            color: isDark ? Colors.white : const Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }
}
