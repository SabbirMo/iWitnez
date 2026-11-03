import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iwitnez/core/constants/theme/dark_map_style.dart';
import 'package:iwitnez/feature/trusted_contact/LiveLocation/model/directions_model.dart';
import 'package:iwitnez/feature/trusted_contact/LiveLocation/model/monitored_live_location_model.dart';
import 'package:iwitnez/feature/trusted_contact/LiveLocation/provider/get_directions_provider.dart';
import 'package:iwitnez/feature/trusted_contact/LiveLocation/provider/monitored_live_location_provider.dart';

class GetDirectionsScreen extends ConsumerStatefulWidget {
  const GetDirectionsScreen({super.key, this.args});

  final DirectionsArgs? args;

  @override
  ConsumerState<GetDirectionsScreen> createState() =>
      _GetDirectionsScreenState();
}

class _GetDirectionsScreenState extends ConsumerState<GetDirectionsScreen> {
  late final DraggableScrollableController _sheetController;
  GoogleMapController? _mapController;
  bool _isNavigating = false;

  bool get _isSheetExpanded =>
      _sheetController.isAttached && _sheetController.size > 0.28;

  @override
  void initState() {
    super.initState();
    _sheetController = DraggableScrollableController();

    _sheetController.addListener(() {
      if (mounted) setState(() {});
    });

    Future.microtask(() {
      if (widget.args != null) {
        ref.read(directionsProvider.notifier).initialize(widget.args!);
      } else {
        final monitoredData = ref.read(monitoredLiveLocationProvider).data;
        if (monitoredData != null && monitoredData.location != null) {
          final loc = monitoredData.location!;
          final user = monitoredData.monitoredUser;
          final safePlaces = monitoredData.safePlaces;
          SafePlaceEtaItem? destPlace;
          for (final p in safePlaces) {
            if (p.badge.toLowerCase().contains('eta') ||
                p.name.toLowerCase() == 'work') {
              destPlace = p;
              break;
            }
          }
          destPlace ??= safePlaces.isNotEmpty ? safePlaces.first : null;

          final fallbackArgs = DirectionsArgs(
            originLatitude: loc.latitude,
            originLongitude: loc.longitude,
            originName: user?.name.isNotEmpty == true
                ? "${user!.name}'s Location"
                : 'Your Location',
            originAddress: loc.address,
            destinationLatitude: destPlace?.latitude ?? 0.0,
            destinationLongitude: destPlace?.longitude ?? 0.0,
            destinationName: destPlace?.name ?? '',
            destinationAddress: destPlace?.address ?? '',
            mode: 'drive',
            availableDestinations: safePlaces,
          );
          ref.read(directionsProvider.notifier).initialize(fallbackArgs);
        }
      }
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  void _toggleSheet() {
    if (!_sheetController.isAttached) return;
    if (_sheetController.size < 0.3) {
      _sheetController.animateTo(
        0.65,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      _sheetController.animateTo(
        0.13,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _fitRouteBounds(List<LatLng> points, LatLng? origin, LatLng? dest) {
    if (_mapController == null) return;

    final allCoords = <LatLng>[
      ...points,
      if (origin != null && origin.latitude != 0.0) origin,
      if (dest != null && dest.latitude != 0.0) dest,
    ];

    if (allCoords.isEmpty) return;

    if (allCoords.length == 1) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(allCoords.first, 15),
      );
      return;
    }

    double minLat = allCoords.first.latitude;
    double maxLat = allCoords.first.latitude;
    double minLng = allCoords.first.longitude;
    double maxLng = allCoords.first.longitude;

    for (final p in allCoords) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 64.0));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(directionsProvider);
    final notifier = ref.read(directionsProvider.notifier);
    final data = state.data;
    final selectedRoute = state.selectedRoute;
    final isExpanded = _isSheetExpanded;

    final polylines = <Polyline>{};
    final markers = <Marker>{};

    LatLng? originLatLng;
    LatLng? destLatLng;

    if (data != null) {
      if (data.originLatitude != 0.0 && data.originLongitude != 0.0) {
        originLatLng = LatLng(data.originLatitude, data.originLongitude);
        markers.add(
          Marker(
            markerId: const MarkerId('direction_origin'),
            position: originLatLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
            infoWindow: InfoWindow(
              title: data.originName.isNotEmpty
                  ? data.originName
                  : 'Start Location',
              snippet: data.originAddress,
            ),
          ),
        );
      }

      if (data.destinationLatitude != 0.0 && data.destinationLongitude != 0.0) {
        destLatLng = LatLng(
          data.destinationLatitude,
          data.destinationLongitude,
        );
        markers.add(
          Marker(
            markerId: const MarkerId('direction_destination'),
            position: destLatLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueViolet,
            ),
            infoWindow: InfoWindow(
              title: data.destinationName.isNotEmpty
                  ? data.destinationName
                  : 'Destination',
              snippet: data.destinationAddress,
            ),
          ),
        );
      }

      final activeRoutes = state.routes;
      for (int i = 0; i < activeRoutes.length; i++) {
        final r = activeRoutes[i];
        final isSelected = (i == state.selectedRouteIndex);

        if (r.points.isNotEmpty) {
          polylines.add(
            Polyline(
              polylineId: PolylineId(r.id),
              points: r.points,
              color: isSelected
                  ? const Color(0xFF7F56D9)
                  : const Color(0xFF98A2B3),
              width: isSelected ? 6 : 4,
              zIndex: isSelected ? 10 : 2,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
              jointType: JointType.round,
              onTap: () {
                notifier.selectRoute(i);
                _fitRouteBounds(r.points, originLatLng, destLatLng);
              },
            ),
          );
        }
      }

      if (polylines.isEmpty && originLatLng != null && destLatLng != null) {
        polylines.add(
          Polyline(
            polylineId: const PolylineId('fallback_route'),
            points: [originLatLng, destLatLng],
            color: const Color(0xFF7F56D9),
            width: 5,
            zIndex: 10,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
        );
      }
    }

    ref.listen(directionsProvider, (prev, next) {
      if (next.data != null &&
          (prev?.data != next.data ||
              prev?.selectedRouteIndex != next.selectedRouteIndex)) {
        final pts = next.selectedRoute?.points ?? [];
        _fitRouteBounds(pts, originLatLng, destLatLng);
      }
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final initialCenter =
        originLatLng ?? destLatLng ?? const LatLng(23.8103, 90.4125);

    final hasDestination =
        data != null &&
        data.destinationLatitude != 0.0 &&
        data.destinationLongitude != 0.0;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0E15) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0D0E15) : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
            size: 32.sp,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
          onPressed: () {
            if (_isNavigating) {
              setState(() {
                _isNavigating = false;
              });
              final pts = selectedRoute?.points ?? [];
              _fitRouteBounds(pts, originLatLng, destLatLng);
            } else if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        centerTitle: true,
        title: Text(
          _isNavigating ? 'Navigation' : 'Get Directions',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
        ),
        actions: [
          if (state.isLoading)
            Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF7F56D9),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Real Google Map with Route Polylines and Markers
          Positioned.fill(
            child: GoogleMap(
              key: ValueKey('directions_map_$isDark'),
              style: isDark ? darkMapStyleJson : null,
              initialCameraPosition: CameraPosition(
                target: initialCenter,
                zoom: 14.0,
              ),
              polylines: polylines,
              markers: markers,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              compassEnabled: false,
              mapToolbarEnabled: false,
              onMapCreated: (controller) {
                _mapController = controller;
                if (isDark) {
                  controller.setMapStyle(darkMapStyleJson);
                }
                final pts = selectedRoute?.points ?? [];
                _fitRouteBounds(pts, originLatLng, destLatLng);
              },
            ),
          ),

          // 2. Floating Map Quick Controls (Recenter & Zoom in/out)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeInOutCubic,
            right: 16.w,
            top: _isNavigating ? 80.h : 240.h,
            child: Column(
              children: [
                _buildCircleButton(
                  icon: Icons.my_location_rounded,
                  tooltip: 'Recenter route',
                  onTap: () {
                    final pts = selectedRoute?.points ?? [];
                    _fitRouteBounds(pts, originLatLng, destLatLng);
                  },
                ),
                SizedBox(height: 10.h),
                Container(
                  width: 38.r,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF181A26) : Colors.white,
                    borderRadius: BorderRadius.circular(19.r),
                    border: isDark
                        ? Border.all(color: const Color(0xFF262938))
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => _mapController?.animateCamera(
                          CameraUpdate.zoomIn(),
                        ),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(19.r),
                        ),
                        child: SizedBox(
                          height: 36.h,
                          child: Center(
                            child: Icon(
                              Icons.add,
                              size: 20.sp,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF4B5563),
                            ),
                          ),
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 0.8,
                        color: isDark
                            ? const Color(0xFF262938)
                            : const Color(0xFFE5E7EB),
                      ),
                      InkWell(
                        onTap: () => _mapController?.animateCamera(
                          CameraUpdate.zoomOut(),
                        ),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(19.r),
                        ),
                        child: SizedBox(
                          height: 36.h,
                          child: Center(
                            child: Icon(
                              Icons.remove,
                              size: 20.sp,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF4B5563),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Top Floating Location Card & Transport Mode Selector (Hides during navigation)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeInOutCubic,
            left: 0,
            right: 0,
            top: _isNavigating ? -360.h : 0,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF181A26) : Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20.r),
                ),
                border: isDark
                    ? Border(
                        bottom: BorderSide(
                          color: const Color(0xFF262938),
                          width: 1,
                        ),
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 14.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLocationsBox(data, notifier),
                  SizedBox(height: 12.h),
                  _buildTransportModesRow(data, state, notifier),
                ],
              ),
            ),
          ),

          // 4. Active Navigation Floating Header (Appears when navigating)
          if (_isNavigating && selectedRoute != null)
            Positioned(
              left: 16.w,
              right: 16.w,
              top: 10.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36.r,
                      height: 36.r,
                      decoration: const BoxDecoration(
                        color: Color(0xFF7F56D9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.navigation_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            data?.destinationName.isNotEmpty == true
                                ? data!.destinationName
                                : 'Heading to destination',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '${selectedRoute.duration} • ${selectedRoute.distance}${selectedRoute.trafficStatus.isNotEmpty ? " • ${selectedRoute.trafficStatus}" : ""}',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF94A3B8),
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isNavigating = false;
                        });
                        final pts = selectedRoute.points;
                        _fitRouteBounds(pts, originLatLng, destLatLng);
                      },
                      borderRadius: BorderRadius.circular(20.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 15,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'End',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Error Overlay if directions failed
          if (state.errorMessage != null && !state.isLoading && !_isNavigating)
            Positioned(
              left: 16.w,
              right: 16.w,
              top: 240.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3F2),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFFECDCA)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: const Color(0xFFD92D20),
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        state.errorMessage!,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: const Color(0xFFB42318),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => notifier.retry(),
                      child: Text(
                        'Retry',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF7F56D9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 5. Draggable Pull-Up Bottom Sheet for Route Options (Hidden during navigation)
          if (!_isNavigating)
            DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.13,
              minChildSize: 0.11,
              maxChildSize: 0.65,
              snap: true,
              snapSizes: const [0.13, 0.65],
              builder: (context, scrollController) {
                final routes = state.routes;
                final currentMode =
                    data?.travelModes != null &&
                        state.selectedTransportIndex < data!.travelModes.length
                    ? data.travelModes[state.selectedTransportIndex].mode
                    : (data?.mode ?? 'drive');

                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF181A26) : Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(22.r),
                    ),
                    border: isDark
                        ? Border(
                            top: BorderSide(
                              color: const Color(0xFF262938),
                              width: 1,
                            ),
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                        blurRadius: 18,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      physics: const ClampingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Drag Handle
                            Center(
                              child: GestureDetector(
                                onTap: _toggleSheet,
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  width: 44.w,
                                  height: 5.h,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF33374B)
                                        : const Color(0xFFD0D5DD),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),

                            // Selected Route Compact Teaser Header
                            if (selectedRoute != null)
                              GestureDetector(
                                onTap: _toggleSheet,
                                behavior: HitTestBehavior.opaque,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38.r,
                                      height: 38.r,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF2B1D45)
                                            : const Color(0xFFF4F3FF),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        TravelModeItem.getIconForMode(
                                          currentMode,
                                        ),
                                        color: const Color(0xFF7F56D9),
                                        size: 20.sp,
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                selectedRoute.duration,
                                                style: GoogleFonts.inter(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w700,
                                                  color: isDark
                                                      ? Colors.white
                                                      : const Color(
                                                          0xFF111827,
                                                        ),
                                                ),
                                              ),
                                              if (selectedRoute
                                                  .distance
                                                  .isNotEmpty) ...[
                                                SizedBox(width: 8.w),
                                                Text(
                                                  '• ${selectedRoute.distance}',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 13.sp,
                                                    fontWeight: FontWeight.w500,
                                                    color: isDark
                                                        ? const Color(
                                                            0xFF98A2B3,
                                                          )
                                                        : const Color(
                                                            0xFF667085,
                                                          ),
                                                  ),
                                                ),
                                              ],
                                              if (selectedRoute
                                                  .trafficStatus
                                                  .isNotEmpty) ...[
                                                SizedBox(width: 8.w),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 6.w,
                                                    vertical: 2.h,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: selectedRoute
                                                        .trafficColor
                                                        .withValues(
                                                          alpha: 0.12,
                                                        ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6.r,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    selectedRoute.trafficStatus,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 10.5.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: selectedRoute
                                                          .trafficColor,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          SizedBox(height: 2.h),
                                          Text(
                                            isExpanded
                                                ? 'Tap to collapse'
                                                : 'Pull up for ${routes.length} route choices & start',
                                            style: GoogleFonts.inter(
                                              fontSize: 11.5.sp,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF7F56D9),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(6.r),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF1F2232)
                                            : const Color(0xFFF9FAFB),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isExpanded
                                            ? Icons.keyboard_arrow_down_rounded
                                            : Icons.keyboard_arrow_up_rounded,
                                        color: isDark
                                            ? const Color(0xFF98A2B3)
                                            : const Color(0xFF667085),
                                        size: 22.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else if (state.isLoading)
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF7F56D9),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Text(
                                    'Calculating Google Maps travel times...',
                                    style: GoogleFonts.inter(
                                      fontSize: 13.sp,
                                      color: isDark
                                          ? const Color(0xFF98A2B3)
                                          : const Color(0xFF667085),
                                    ),
                                  ),
                                ],
                              )
                            else if (!hasDestination)
                              InkWell(
                                onTap: () =>
                                    _showDestinationPicker(context, notifier),
                                borderRadius: BorderRadius.circular(12.r),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4.h),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36.r,
                                        height: 36.r,
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? const Color(0xFF2B1D45)
                                              : const Color(0xFFF4F3FF),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.search_rounded,
                                          color: Color(0xFF7F56D9),
                                          size: 20,
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Select Destination',
                                              style: GoogleFonts.inter(
                                                fontSize: 14.5.sp,
                                                fontWeight: FontWeight.w700,
                                                color: isDark
                                                    ? Colors.white
                                                    : const Color(0xFF111827),
                                              ),
                                            ),
                                            Text(
                                              'Search a place or address to see Google Maps travel times',
                                              style: GoogleFonts.inter(
                                                fontSize: 11.5.sp,
                                                color: isDark
                                                    ? const Color(0xFF98A2B3)
                                                    : const Color(0xFF667085),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // Expanded Section (Recommended Routes & Start Button)
                            if (routes.isNotEmpty) ...[
                              SizedBox(height: 16.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Select Route',
                                    style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF344054),
                                    ),
                                  ),
                                  Text(
                                    '${routes.length} routes found',
                                    style: GoogleFonts.inter(
                                      fontSize: 11.5.sp,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? const Color(0xFF98A2B3)
                                          : const Color(0xFF667085),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h),

                              for (int i = 0; i < routes.length; i++) ...[
                                if (i > 0) SizedBox(height: 10.h),
                                _buildRouteCard(
                                  index: i,
                                  route: routes[i],
                                  isSelected: state.selectedRouteIndex == i,
                                  mode: currentMode,
                                  onTap: () {
                                    notifier.selectRoute(i);
                                    _fitRouteBounds(
                                      routes[i].points,
                                      originLatLng,
                                      destLatLng,
                                    );
                                  },
                                ),
                              ],
                              SizedBox(height: 16.h),

                              _buildStartNavigationButton(selectedRoute),
                              SizedBox(height: 10.h),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 38.r,
      height: 38.r,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181A26) : Colors.white,
        shape: BoxShape.circle,
        border: isDark ? Border.all(color: const Color(0xFF262938)) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(19.r),
          child: Center(
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

  Widget _buildLocationsBox(DirectionsData? data, DirectionsNotifier notifier) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final originTitle = data?.originName.isNotEmpty == true
        ? data!.originName
        : (widget.args?.originName ?? 'Your Location');
    final originSubtitle = data?.originAddress.isNotEmpty == true
        ? data!.originAddress
        : (widget.args?.originAddress ?? '');

    final destinationTitle = data?.destinationName.isNotEmpty == true
        ? data!.destinationName
        : (widget.args?.destinationName.isNotEmpty == true
              ? widget.args!.destinationName
              : 'Choose Destination');
    final destinationSubtitle = data?.destinationAddress.isNotEmpty == true
        ? data!.destinationAddress
        : (widget.args?.destinationAddress.isNotEmpty == true
              ? widget.args!.destinationAddress
              : 'Tap to search destination place');

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2232) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          width: 1.w,
          color: isDark ? const Color(0xFF2C3044) : const Color(0xFFF2F4F7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Dots & Connecting Line
          Column(
            children: [
              Container(
                width: 12.r,
                height: 12.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF1F2232) : Colors.white,
                  border: Border.all(
                    color: const Color(0xFF8B2CF5),
                    width: 2.5.w,
                  ),
                ),
              ),
              Container(
                width: 1.5.w,
                height: 28.h,
                color: isDark ? const Color(0xFF33374B) : const Color(0xFFD0D5DD),
              ),
              Icon(
                Icons.location_on,
                color: const Color(0xFF8B2CF5),
                size: 18.sp,
              ),
            ],
          ),
          SizedBox(width: 12.w),

          // Location Labels
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  originTitle,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  originSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w400,
                    color: isDark
                        ? const Color(0xFF98A2B3)
                        : const Color(0xFF667085),
                  ),
                ),
                SizedBox(height: 12.h),

                InkWell(
                  onTap: () => _showDestinationPicker(context, notifier),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              destinationTitle,
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF111827),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              destinationSubtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w400,
                                color: isDark
                                    ? const Color(0xFF98A2B3)
                                    : const Color(0xFF667085),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2B1D45)
                              : const Color(0xFFF4F3FF),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.search_rounded,
                          color: const Color(0xFF7F56D9),
                          size: 18.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),

          // Swap Icon
          InkWell(
            onTap: () => notifier.swapLocations(),
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.all(6.r),
              child: Icon(
                Icons.swap_vert_rounded,
                color: isDark
                    ? const Color(0xFF98A2B3)
                    : const Color(0xFF667085),
                size: 22.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDestinationPicker(
    BuildContext context,
    DirectionsNotifier notifier,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF181A26) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
      ),
      builder: (ctx) {
        return _DestinationSearchSheet(
          safePlaces: widget.args?.availableDestinations ?? const [],
          onSelectPlace: (name, address, lat, lng) {
            notifier.setDestination(
              name: name,
              address: address,
              latitude: lat,
              longitude: lng,
            );
          },
        );
      },
    );
  }

  Widget _buildTransportModesRow(
    DirectionsData? data,
    DirectionsState state,
    DirectionsNotifier notifier,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final modes = data?.travelModes ?? TravelModeItem.defaultModes;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(modes.length, (index) {
        final mode = modes[index];
        final isSelected = state.selectedTransportIndex == index;

        final activeColor =
            isDark ? const Color(0xFFA855F7) : const Color(0xFF7F56D9);
        final inactiveColor =
            isDark ? const Color(0xFF98A2B3) : const Color(0xFF667085);

        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            child: InkWell(
              onTap: () => notifier.selectTransport(index),
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                          ? const Color(0xFF2B1D45)
                          : const Color(0xFFF4F3FF))
                      : (isDark ? const Color(0xFF1F2232) : Colors.white),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: isSelected
                        ? activeColor.withValues(alpha: 0.35)
                        : (isDark
                            ? const Color(0xFF2C3044)
                            : const Color(0xFFF2F4F7)),
                    width: 1.w,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      mode.icon,
                      size: 20.sp,
                      color: isSelected ? activeColor : inactiveColor,
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      mode.title,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected ? activeColor : inactiveColor,
                      ),
                    ),
                    if (mode.duration.isNotEmpty)
                      Text(
                        mode.duration,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.w400,
                          color: isSelected
                              ? activeColor
                              : inactiveColor.withValues(alpha: 0.8),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStartNavigationButton(RouteOptionItem? route) {
    return InkWell(
      onTap: () {
        setState(() {
          _isNavigating = true;
        });

        if (route != null && route.points.isNotEmpty) {
          _mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: route.points.first,
                zoom: 17.5,
                tilt: 45.0,
              ),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(100.r),
      child: Container(
        width: double.infinity,
        height: 48.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100.r),
          gradient: const LinearGradient(
            colors: [Color(0xFF7F56D9), Color(0xFF2E90FA)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7F56D9).withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.navigation_rounded, color: Colors.white, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              'Start Navigation',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteCard({
    required int index,
    required RouteOptionItem route,
    required bool isSelected,
    required String mode,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final borderColor = isSelected
        ? const Color(0xFF7F56D9)
        : (isDark ? const Color(0xFF2C3044) : const Color(0xFFF2F4F7));
    final iconBg = isSelected
        ? (isDark ? const Color(0xFF2B1D45) : const Color(0xFFF4F3FF))
        : (isDark ? const Color(0xFF252839) : const Color(0xFFF9FAFB));
    final iconColor = isSelected
        ? (isDark ? const Color(0xFFA855F7) : const Color(0xFF7F56D9))
        : (isDark ? const Color(0xFF98A2B3) : const Color(0xFF667085));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2232) : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            width: isSelected ? 1.5.w : 1.w,
            color: borderColor,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF7F56D9).withValues(alpha: isDark ? 0.2 : 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(
                TravelModeItem.getIconForMode(mode),
                color: iconColor,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    route.duration,
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF111827),
                    ),
                  ),
                  if (route.distance.isNotEmpty ||
                      route.routeType.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      route.distance.isNotEmpty
                          ? '${route.distance} • ${route.routeType}'
                          : route.routeType,
                      style: GoogleFonts.inter(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w400,
                        color: isDark
                            ? const Color(0xFF98A2B3)
                            : const Color(0xFF667085),
                      ),
                    ),
                  ],
                  if (route.trafficStatus.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      route.trafficStatus,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: route.trafficColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomPaint(
                  size: Size(36.w, 14.h),
                  painter: _MiniRouteCurvePainter(
                    color: isSelected
                        ? const Color(0xFF7F56D9)
                        : (isDark
                            ? const Color(0xFF667085)
                            : const Color(0xFF98A2B3)),
                    isCurved: route.hasCurve,
                  ),
                ),
                SizedBox(width: 6.w),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark
                      ? const Color(0xFF667085)
                      : const Color(0xFF98A2B3),
                  size: 20.sp,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniRouteCurvePainter extends CustomPainter {
  final Color color;
  final bool isCurved;

  const _MiniRouteCurvePainter({required this.color, required this.isCurved});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (isCurved) {
      path.moveTo(0, size.height * 0.6);
      path.quadraticBezierTo(
        size.width * 0.4,
        0,
        size.width * 0.7,
        size.height * 0.5,
      );
      path.lineTo(size.width, size.height * 0.5);
    } else {
      path.moveTo(0, size.height * 0.5);
      path.lineTo(size.width, size.height * 0.5);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MiniRouteCurvePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isCurved != isCurved;
}

class _SearchPlaceResult {
  final String name;
  final String address;
  final double lat;
  final double lng;

  const _SearchPlaceResult({
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
  });
}

class _DestinationSearchSheet extends StatefulWidget {
  final List<SafePlaceEtaItem> safePlaces;
  final void Function(String name, String address, double lat, double lng)
  onSelectPlace;

  const _DestinationSearchSheet({
    required this.safePlaces,
    required this.onSelectPlace,
  });

  @override
  State<_DestinationSearchSheet> createState() =>
      _DestinationSearchSheetState();
}

class _DestinationSearchSheetState extends State<_DestinationSearchSheet> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;
  bool _isSearching = false;
  List<_SearchPlaceResult> _suggestions = [];

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _suggestions = [];
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _executeSearch(query.trim());
    });
  }

  Future<void> _executeSearch(String query) async {
    setState(() => _isSearching = true);

    try {
      final dio = Dio();
      final res = await dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': 6,
          'accept-language': 'en',
          'addressdetails': 1,
        },
        options: Options(
          headers: {'User-Agent': 'iWitnezApp/1.0'},
          receiveTimeout: const Duration(seconds: 4),
          sendTimeout: const Duration(seconds: 4),
        ),
      );

      if (res.data is List && (res.data as List).isNotEmpty) {
        final list = <_SearchPlaceResult>[];
        for (final item in (res.data as List)) {
          if (item is Map<String, dynamic>) {
            final lat = double.tryParse(item['lat']?.toString() ?? '') ?? 0.0;
            final lon = double.tryParse(item['lon']?.toString() ?? '') ?? 0.0;
            final fullName = item['display_name'] as String? ?? '';
            final shortName = fullName.split(',').first.trim();
            if (lat != 0.0 && lon != 0.0) {
              list.add(
                _SearchPlaceResult(
                  name: shortName,
                  address: fullName,
                  lat: lat,
                  lng: lon,
                ),
              );
            }
          }
        }
        if (mounted && list.isNotEmpty) {
          setState(() {
            _suggestions = list;
            _isSearching = false;
          });
          return;
        }
      }
    } catch (_) {}

    try {
      final geocoding = Geocoding();
      final locations = await geocoding.locationFromAddress(query);
      if (locations.isNotEmpty) {
        final list = <_SearchPlaceResult>[];
        for (final loc in locations.take(5)) {
          String addr = query;
          try {
            final placemarks = await geocoding.placemarkFromCoordinates(
              loc.latitude,
              loc.longitude,
            );
            if (placemarks.isNotEmpty) {
              final p = placemarks.first;
              final parts =
                  [p.name, p.street, p.subLocality, p.locality, p.country]
                      .where((s) => s != null && s.trim().isNotEmpty)
                      .map((s) => s!)
                      .toList();
              if (parts.isNotEmpty) addr = parts.join(', ');
            }
          } catch (_) {}

          list.add(
            _SearchPlaceResult(
              name: addr.split(',').first.trim(),
              address: addr,
              lat: loc.latitude,
              lng: loc.longitude,
            ),
          );
        }
        if (mounted) {
          setState(() {
            _suggestions = list;
            _isSearching = false;
          });
          return;
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, bottomInset + 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF33374B) : const Color(0xFFD0D5DD),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            'Search Destination',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 12.h),

          // Search Field
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2232) : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isDark ? const Color(0xFF2C3044) : const Color(0xFFE5E7EB),
              ),
            ),
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _onSearchChanged,
              onSubmitted: _executeSearch,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: isDark ? Colors.white : const Color(0xFF111827),
              ),
              decoration: InputDecoration(
                hintText: 'Type place name, street or area...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: isDark ? const Color(0xFF667085) : const Color(0xFF98A2B3),
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF7F56D9),
                  size: 20,
                ),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          size: 18,
                          color: isDark
                              ? const Color(0xFF667085)
                              : const Color(0xFF98A2B3),
                        ),
                        onPressed: () {
                          _controller.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 12.h,
                  horizontal: 12.w,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),

          if (_isSearching)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF7F56D9),
                  ),
                ),
              ),
            ),

          // Search Results List
          if (_suggestions.isNotEmpty)
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: isDark ? const Color(0xFF262938) : const Color(0xFFF2F4F7)),
                itemBuilder: (ctx, index) {
                  final place = _suggestions[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 36.r,
                      height: 36.r,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2B1D45) : const Color(0xFFF4F3FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFF7F56D9),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      place.name,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                    subtitle: Text(
                      place.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11.5.sp,
                        color: isDark ? const Color(0xFF98A2B3) : const Color(0xFF667085),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      widget.onSelectPlace(
                        place.name,
                        place.address,
                        place.lat,
                        place.lng,
                      );
                    },
                  );
                },
              ),
            )
          else if (!_isSearching &&
              _controller.text.isEmpty &&
              widget.safePlaces.isNotEmpty) ...[
            Text(
              'Saved Places',
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFF98A2B3) : const Color(0xFF667085),
              ),
            ),
            SizedBox(height: 8.h),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.safePlaces.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: isDark ? const Color(0xFF262938) : const Color(0xFFF2F4F7)),
                itemBuilder: (ctx, index) {
                  final p = widget.safePlaces[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 36.r,
                      height: 36.r,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2B1D45) : const Color(0xFFF4F3FF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        p.icon.toLowerCase() == 'home'
                            ? Icons.home_rounded
                            : Icons.business_center_rounded,
                        color: const Color(0xFF7F56D9),
                        size: 20.sp,
                      ),
                    ),
                    title: Text(
                      p.name,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                    subtitle: Text(
                      p.address.isNotEmpty ? p.address : p.timeDisplay,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: isDark ? const Color(0xFF98A2B3) : const Color(0xFF667085),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      if (p.latitude != 0.0 && p.longitude != 0.0) {
                        widget.onSelectPlace(
                          p.name,
                          p.address,
                          p.latitude,
                          p.longitude,
                        );
                      } else {
                        // If safe place coordinates not stored, search its address/name
                        widget.onSelectPlace(
                          p.name,
                          p.address.isNotEmpty ? p.address : p.name,
                          0.0,
                          0.0,
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
