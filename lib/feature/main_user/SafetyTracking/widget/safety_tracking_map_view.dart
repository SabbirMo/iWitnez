import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/provider/home_provider.dart';
import 'package:iwitnez/feature/main_user/LiveLocation/widget/map_marker_helper.dart';
import 'package:iwitnez/feature/main_user/SafetyTracking/provider/safety_tracking_provider.dart';

class SafetyTrackingMapView extends ConsumerStatefulWidget {
  const SafetyTrackingMapView({super.key});

  @override
  ConsumerState<SafetyTrackingMapView> createState() =>
      _SafetyTrackingMapViewState();
}

class _SafetyTrackingMapViewState extends ConsumerState<SafetyTrackingMapView> {
  GoogleMapController? _mapController;
  MapType _mapType = MapType.normal;
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};

  @override
  void initState() {
    super.initState();
    _buildMapElements();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  double? _resolveUserLat() {
    final state = ref.read(safetyTrackingProvider);
    final homeLoc = ref.read(homeProvider).value?.liveLocation;
    return state.myLocation?.latitude ?? homeLoc?.latitude;
  }

  double? _resolveUserLng() {
    final state = ref.read(safetyTrackingProvider);
    final homeLoc = ref.read(homeProvider).value?.liveLocation;
    return state.myLocation?.longitude ?? homeLoc?.longitude;
  }

  Future<void> _buildMapElements() async {
    final state = ref.read(safetyTrackingProvider);
    final markers = <Marker>{};
    final circles = <Circle>{};

    final userLat = _resolveUserLat();
    final userLng = _resolveUserLng();

    // 1. User pin (only if real GPS / location exists)
    if (userLat != null && userLng != null) {
      final userLatLng = LatLng(userLat, userLng);
      final userIcon = await MapMarkerHelper.createUserDotIcon();
      markers.add(
        Marker(
          markerId: const MarkerId('user_live_location'),
          position: userLatLng,
          icon: userIcon,
          anchor: const Offset(0.5, 0.5),
          zIndexInt: 999,
          infoWindow: InfoWindow(
            title: 'You are here',
            snippet: state.myLocation?.address ?? 'Current position',
          ),
        ),
      );
    }

    // 2. Safe Places Geofences & Markers
    for (final place in state.safePlaces) {
      if (place.latitude != null && place.longitude != null) {
        final pos = LatLng(place.latitude!, place.longitude!);
        final radius = (place.radius ?? 150).toDouble();

        circles.add(
          Circle(
            circleId: CircleId('circle_${place.id}'),
            center: pos,
            radius: radius,
            fillColor: place.isInside
                ? const Color(0xFF16A34A).withValues(alpha: 0.18)
                : const Color(0xFF8B5CF6).withValues(alpha: 0.15),
            strokeColor: place.isInside
                ? const Color(0xFF16A34A)
                : const Color(0xFF8B5CF6),
            strokeWidth: 2,
          ),
        );

        markers.add(
          Marker(
            markerId: MarkerId('place_${place.id}'),
            position: pos,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              place.isInside
                  ? BitmapDescriptor.hueGreen
                  : BitmapDescriptor.hueViolet,
            ),
            infoWindow: InfoWindow(
              title: '${place.title} (${place.displayStatus})',
              snippet: place.address,
            ),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _markers
          ..clear()
          ..addAll(markers);
        _circles
          ..clear()
          ..addAll(circles);
      });
    }
  }

  void _toggleMapType() {
    setState(() {
      _mapType =
          _mapType == MapType.normal ? MapType.satellite : MapType.normal;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(safetyTrackingProvider, (previous, next) {
      if (previous?.myLocation != next.myLocation ||
          previous?.safePlaces != next.safePlaces ||
          previous?.isLocationSharingActive != next.isLocationSharingActive) {
        _buildMapElements();
      }
    });

    final state = ref.watch(safetyTrackingProvider);
    final notifier = ref.read(safetyTrackingProvider.notifier);

    final userLat = _resolveUserLat();
    final userLng = _resolveUserLng();
    final hasCoords = userLat != null && userLng != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. Google Map View or placeholder if coordinates not available
            Positioned.fill(
              child: hasCoords
                  ? GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(userLat, userLng),
                        zoom: 14.5,
                      ),
                      mapType: _mapType,
                      markers: _markers,
                      circles: _circles,
                      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                        Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer(),
                        ),
                      },
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                      myLocationEnabled: false,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      compassEnabled: false,
                      mapToolbarEnabled: false,
                      rotateGesturesEnabled: true,
                      tiltGesturesEnabled: true,
                      scrollGesturesEnabled: true,
                      zoomGesturesEnabled: true,
                    )
                  : Container(
                      color: const Color(0xFFF8FAFC),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (state.isLoading)
                              const CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF8B2CF5),
                                ),
                              )
                            else
                              Icon(
                                Icons.location_off_rounded,
                                size: 32.sp,
                                color: const Color(0xFF94A3B8),
                              ),
                            SizedBox(height: 12.h),
                            Text(
                              state.isLoading
                                  ? 'Loading live location...'
                                  : 'Location coordinates not available',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF64748B),
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),

            // 2. Floating Top Notice Card: "Location Sharing Active"
            Positioned(
              top: 12.h,
              left: 16.w,
              right: 16.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: const Color(0xFFF1F5F9),
                    width: 1.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Concentric beacon icon
                    Container(
                      width: 34.r,
                      height: 34.r,
                      decoration: BoxDecoration(
                        color: state.isLocationSharingActive
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 12.r,
                          height: 12.r,
                          decoration: BoxDecoration(
                            color: state.isLocationSharingActive
                                ? const Color(0xFF22C55E)
                                : const Color(0xFF94A3B8),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),

                    // Title & description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.isLocationSharingActive
                                ? 'Location Sharing Active'
                                : 'Location Sharing Paused',
                            style: GoogleFonts.inter(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            state.isLocationSharingActive
                                ? 'Your trusted circles can see your location.'
                                : 'Location is hidden from trusted circles.',
                            style: GoogleFonts.inter(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.onboardingDesc,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),

                    // Location Sharing Toggle Switch
                    Transform.scale(
                      scale: 0.85,
                      child: CupertinoSwitch(
                        value: state.isLocationSharingActive,
                        activeTrackColor: const Color(0xFF22C55E),
                        onChanged: (val) {
                          notifier.toggleLocationSharing(val);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Right Side Floating Map Controls (shown when map coordinates available)
            if (hasCoords)
              Positioned(
                right: 14.w,
                top: 76.h,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // My Location Button
                    _buildCircularButton(
                      icon: Icons.my_location_rounded,
                      onTap: () {
                        _mapController?.animateCamera(
                          CameraUpdate.newLatLng(LatLng(userLat, userLng)),
                        );
                      },
                    ),
                    SizedBox(height: 10.h),

                    // Layers Button
                    _buildCircularButton(
                      icon: Icons.layers_rounded,
                      onTap: _toggleMapType,
                    ),
                    SizedBox(height: 10.h),

                    // Zoom Pill (+ / -)
                    Container(
                      width: 38.r,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Zoom in
                          InkWell(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20.r),
                            ),
                            onTap: () {
                              _mapController?.animateCamera(
                                CameraUpdate.zoomIn(),
                              );
                              notifier.zoomIn();
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              child: Icon(
                                Icons.add_rounded,
                                color: const Color(0xFF2563EB),
                                size: 19.sp,
                              ),
                            ),
                          ),
                          // Divider
                          Container(
                            width: 20.w,
                            height: 1.h,
                            color: const Color(0xFFE2E8F0),
                          ),
                          // Zoom out
                          InkWell(
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(20.r),
                            ),
                            onTap: () {
                              _mapController?.animateCamera(
                                CameraUpdate.zoomOut(),
                              );
                              notifier.zoomOut();
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              child: Icon(
                                Icons.remove_rounded,
                                color: const Color(0xFF2563EB),
                                size: 19.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 38.r,
      height: 38.r,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(
            child: Icon(icon, color: const Color(0xFF2563EB), size: 20.sp),
          ),
        ),
      ),
    );
  }
}
