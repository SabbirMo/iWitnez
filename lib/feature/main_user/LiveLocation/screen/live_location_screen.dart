import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iwitnez/core/services/location_service.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/provider/home_provider.dart';
import 'package:iwitnez/feature/main_user/LiveLocation/provider/live_location_screen_provider.dart';
import 'package:iwitnez/feature/main_user/LiveLocation/widget/live_location_bottom_sheet.dart';
import 'package:iwitnez/feature/main_user/LiveLocation/widget/live_location_map_controls.dart';
import 'package:iwitnez/feature/main_user/LiveLocation/widget/live_location_map_view.dart';
import 'package:iwitnez/feature/main_user/LiveLocation/widget/live_location_notice_card.dart';
import 'package:iwitnez/router/app_route_names.dart';

class LiveLocationScreen extends ConsumerStatefulWidget {
  const LiveLocationScreen({super.key});

  @override
  ConsumerState<LiveLocationScreen> createState() => _LiveLocationScreenState();
}

class _LiveLocationScreenState extends ConsumerState<LiveLocationScreen> {
  GoogleMapController? _mapController;
  MapType _mapType = MapType.normal;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _toggleMapType() {
    setState(() {
      if (_mapType == MapType.normal) {
        _mapType = MapType.satellite;
      } else if (_mapType == MapType.satellite) {
        _mapType = MapType.terrain;
      } else {
        _mapType = MapType.normal;
      }
    });
  }

  Future<void> _handleMyLocation() async {
    const locationService = LocationService();

    // 1. Check if GPS / Location services are enabled on device
    final serviceEnabled = await locationService.isServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'Location Services Disabled',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 17.sp,
            ),
          ),
          content: Text(
            'GPS / Location service is turned off. Please enable location on your device to locate your position.',
            style: GoogleFonts.inter(
              fontSize: 13.5.sp,
              color: const Color(0xFF4B5563),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B2CF5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              onPressed: () async {
                Navigator.of(ctx).pop();
                await Geolocator.openLocationSettings();
              },
              child: Text(
                'Turn ON',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }

    // 2. Check and request location permission
    var permission = await locationService.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await locationService.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permission is required to find your position.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'Permission Denied',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 17.sp,
            ),
          ),
          content: Text(
            'Location permission is permanently denied. Please grant permission from App Settings.',
            style: GoogleFonts.inter(
              fontSize: 13.5.sp,
              color: const Color(0xFF4B5563),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B2CF5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              onPressed: () async {
                Navigator.of(ctx).pop();
                await Geolocator.openAppSettings();
              },
              child: Text(
                'Open Settings',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }

    // 3. Obtain real device GPS position
    final result = await locationService.getCurrentLocation();
    if (result.isSuccess && result.position != null) {
      final pos = result.position!;
      final realTarget = LatLng(pos.latitude, pos.longitude);

      // Animate map camera directly to user's real GPS position
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(realTarget, 16.0),
      );

      // Update provider coordinates so user marker sits on actual device location
      ref
          .read(liveLocationScreenProvider.notifier)
          .updateUserCoordinates(pos.latitude, pos.longitude);

      // Ping backend so backend knows user's latest real coordinates
      ref.read(homeProvider.notifier).pingCurrentGpsLocation();
    } else {
      // Fallback to cached state if available
      final state = ref.read(liveLocationScreenProvider);
      if (state.userLatitude != null && state.userLongitude != null) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(state.userLatitude!, state.userLongitude!),
            15.0,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final liveState = ref.watch(liveLocationScreenProvider);
    final trustedCount = liveState.contacts.where((c) => c.id != 'self').length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
            size: 32.sp,
            color: const Color(0xFF111827),
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'Live Location',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111827),
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6.r,
                  height: 6.r,
                  decoration: BoxDecoration(
                    color: liveState.isSharing
                        ? const Color(0xFF10B981)
                        : const Color(0xFF9CA3AF),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 5.w),
                Text(
                  liveState.isSharing ? 'Sharing Live' : 'Sharing Paused',
                  style: GoogleFonts.inter(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                    color: liveState.isSharing
                        ? const Color(0xFF10B981)
                        : const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // 1. Interactive Full-Screen Google Map View
          Positioned.fill(
            child: LiveLocationMapView(
              mapType: _mapType,
              onMapCreated: (controller) {
                _mapController = controller;
              },
              onPersonPinTap: (person) {
                if (person.latitude != null && person.longitude != null) {
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      LatLng(person.latitude!, person.longitude!),
                      15.0,
                    ),
                  );
                }
              },
            ),
          ),

          // 2. Header Banner: "Your location is being shared with {count} trusted contacts"
          Positioned(
            left: 16.w,
            right: 16.w,
            top: 12.h,
            child: LiveLocationNoticeCard(
              contactsCount: trustedCount,
              isSharing: liveState.isSharing,
              onManageTap: () {
                context.push(AppRouteNames.manageSharingScreen);
              },
            ),
          ),

          // 3. Floating Map Controls (Layers, My Location, Zoom In / Out)
          LiveLocationMapControls(
            onLayersTap: _toggleMapType,
            onMyLocationTap: _handleMyLocation,
            onZoomInTap: () =>
                _mapController?.animateCamera(CameraUpdate.zoomIn()),
            onZoomOutTap: () =>
                _mapController?.animateCamera(CameraUpdate.zoomOut()),
          ),

          // 4. Draggable Bottom Sheet with Contacts, Sharing Settings, and Action Button
          LiveLocationBottomSheet(
            onPersonTap: (person) {
              if (person.latitude != null && person.longitude != null) {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    LatLng(person.latitude!, person.longitude!),
                    15.0,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
