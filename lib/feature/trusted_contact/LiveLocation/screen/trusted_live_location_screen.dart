import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iwitnez/core/constants/theme/dark_map_style.dart';
import 'package:iwitnez/core/widgets/shimmer_loading.dart';
import 'package:iwitnez/feature/main_user/LiveLocation/widget/map_marker_helper.dart';
import 'package:iwitnez/feature/trusted_contact/LiveLocation/model/directions_model.dart';
import 'package:iwitnez/feature/trusted_contact/LiveLocation/model/monitored_live_location_model.dart';
import 'package:iwitnez/feature/trusted_contact/LiveLocation/provider/monitored_live_location_provider.dart';
import 'package:iwitnez/router/app_route_names.dart';

class TrustedLiveLocationScreen extends ConsumerStatefulWidget {
  const TrustedLiveLocationScreen({super.key});

  @override
  ConsumerState<TrustedLiveLocationScreen> createState() =>
      _TrustedLiveLocationScreenState();
}

class _TrustedLiveLocationScreenState
    extends ConsumerState<TrustedLiveLocationScreen> {
  GoogleMapController? _mapController;
  MapType _mapType = MapType.normal;
  final Set<Marker> _markers = {};

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

  void _zoomIn() {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  IconData _getBatteryIcon(int level) {
    if (level >= 90) return Icons.battery_full_rounded;
    if (level >= 70) return Icons.battery_6_bar_rounded;
    if (level >= 50) return Icons.battery_4_bar_rounded;
    if (level >= 30) return Icons.battery_2_bar_rounded;
    if (level >= 15) return Icons.battery_1_bar_rounded;
    return Icons.battery_alert_rounded;
  }

  Future<void> _updateMarkers(
    MonitoredUserLiveLocation? user,
    MonitoredLocationData? location,
  ) async {
    if (location == null) return;
    if (location.latitude == 0.0 && location.longitude == 0.0) return;

    final userPos = LatLng(location.latitude, location.longitude);

    final avatarIcon = await MapMarkerHelper.createAvatarMarker(
      name: user?.name.isNotEmpty == true ? user!.name : 'User',
      avatarUrl: user?.avatarUrl,
      fallbackColor: const Color(0xFF8B2CF5),
      isLive: user?.isOnline ?? true,
    );

    if (mounted) {
      setState(() {
        _markers
          ..clear()
          ..add(
            Marker(
              markerId: const MarkerId('monitored_user_marker'),
              position: userPos,
              icon: avatarIcon,
              anchor: const Offset(0.5, 0.5),
            ),
          );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(monitoredLiveLocationProvider);
    final data = state.data;
    final monitoredUser = data?.monitoredUser;
    final location = data?.location;
    final safePlaces = data?.safePlaces ?? const [];

    final hasValidCoords =
        location != null &&
        (location.latitude != 0.0 || location.longitude != 0.0);

    // Trigger marker update when valid coordinates are present
    if (hasValidCoords) {
      _updateMarkers(monitoredUser, location);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        centerTitle: true,
        title: Text(
          'Live Location',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              size: 22.sp,
              color: isDark ? Colors.white : const Color(0xFF4B5563),
            ),
            onPressed: () => ref
                .read(monitoredLiveLocationProvider.notifier)
                .fetchLiveLocation(forceRefresh: true),
          ),
        ],
      ),
      body: state.isLoading && data == null
          ? const LiveLocationMapShimmer()
          : state.errorMessage != null && data == null
          ? Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48.sp,
                      color: const Color(0xFF98A2B3),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      state.errorMessage!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: const Color(0xFF667085),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => ref
                          .read(monitoredLiveLocationProvider.notifier)
                          .fetchLiveLocation(forceRefresh: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B2CF5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                      ),
                      child: Text(
                        'Retry',
                        style: GoogleFonts.inter(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : !hasValidCoords
          ? const Center(child: Text('No location coordinates available'))
          : Stack(
              children: [
                // 1. Real Google Map Background
                Positioned.fill(
                  child: GoogleMap(
                    key: ValueKey('${location.latitude}_${location.longitude}_$isDark'),
                    initialCameraPosition: CameraPosition(
                      target: LatLng(location.latitude, location.longitude),
                      zoom: 15.0,
                    ),
                    style: isDark ? darkMapStyleJson : null,
                    mapType: _mapType,
                    markers: _markers,
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    compassEnabled: false,
                    rotateGesturesEnabled: true,
                    scrollGesturesEnabled: true,
                    zoomGesturesEnabled: true,
                    tiltGesturesEnabled: true,
                    onMapCreated: (controller) {
                      _mapController = controller;
                      if (isDark) {
                        controller.setMapStyle(darkMapStyleJson);
                      }
                    },
                  ),
                ),

                // 2. Map Floating Controls on Right
                Positioned(
                  right: 16.w,
                  top: 130.h,
                  child: Column(
                    children: [
                      _buildCircleMapButton(
                        icon: Icons.my_location_rounded,
                        isDark: isDark,
                        onTap: () {
                          if (_mapController != null) {
                            _mapController!.animateCamera(
                              CameraUpdate.newLatLng(
                                LatLng(location.latitude, location.longitude),
                              ),
                            );
                          }
                        },
                      ),
                      SizedBox(height: 10.h),
                      _buildCircleMapButton(
                        icon: Icons.layers_rounded,
                        isDark: isDark,
                        onTap: _toggleMapType,
                      ),
                      SizedBox(height: 10.h),
                      Container(
                        width: 38.r,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1F2232) : Colors.white,
                          borderRadius: BorderRadius.circular(19.r),
                          border: isDark
                              ? Border.all(color: const Color(0xFF2C3044))
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
                              onTap: _zoomIn,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(19.r),
                              ),
                              child: SizedBox(
                                height: 36.h,
                                child: Center(
                                  child: Icon(
                                    Icons.add,
                                    size: 19.sp,
                                    color: isDark ? Colors.white : const Color(0xFF4B5563),
                                  ),
                                ),
                              ),
                            ),
                            Divider(
                              height: 1,
                              thickness: 0.8,
                              color: isDark ? const Color(0xFF2C3044) : const Color(0xFFE5E7EB),
                            ),
                            InkWell(
                              onTap: _zoomOut,
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(19.r),
                              ),
                              child: SizedBox(
                                height: 36.h,
                                child: Center(
                                  child: Icon(
                                    Icons.remove,
                                    size: 19.sp,
                                    color: isDark ? Colors.white : const Color(0xFF4B5563),
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

                // 3. Top Floating Card (Monitored User status & battery)
                if (monitoredUser != null)
                  Positioned(
                    left: 16.w,
                    right: 16.w,
                    top: 10.h,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF181A26) : Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          width: 1.w,
                          color: isDark
                              ? const Color(0xFF262938)
                              : const Color(0xFFF2F4F7),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.3 : 0.06,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Avatar with status dot
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 44.r,
                                height: 44.r,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.10,
                                      ),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: monitoredUser.avatarUrl.isNotEmpty
                                      ? Image.network(
                                          monitoredUser.avatarUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  _buildAvatarFallback(
                                                    monitoredUser.name,
                                                  ),
                                        )
                                      : _buildAvatarFallback(
                                          monitoredUser.name,
                                        ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 10.r,
                                  height: 10.r,
                                  decoration: BoxDecoration(
                                    color: monitoredUser.isOnline
                                        ? const Color(0xFF22C55E)
                                        : const Color(0xFF9CA3AF),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark
                                          ? const Color(0xFF181A26)
                                          : Colors.white,
                                      width: 1.8.w,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 12.w),

                          // Name & Status
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  monitoredUser.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF111827),
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  monitoredUser.movementStatus.isNotEmpty
                                      ? monitoredUser.movementStatus
                                      : (monitoredUser.isOnline
                                            ? 'Online'
                                            : 'Offline'),
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: monitoredUser.isOnline
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFF6B7280),
                                  ),
                                ),
                                if (monitoredUser.updatedAgo.isNotEmpty ||
                                    (location.updatedAgo.isNotEmpty)) ...[
                                  SizedBox(height: 2.h),
                                  Text(
                                    monitoredUser.updatedAgo.isNotEmpty
                                        ? monitoredUser.updatedAgo
                                        : location.updatedAgo,
                                    style: GoogleFonts.inter(
                                      fontSize: 11.5.sp,
                                      fontWeight: FontWeight.w400,
                                      color: isDark
                                          ? const Color(0xFF98A2B3)
                                          : const Color(0xFF667085),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Battery Indicator
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getBatteryIcon(monitoredUser.batteryLevel),
                                size: 20.sp,
                                color: isDark
                                    ? const Color(0xFFD0D5DD)
                                    : const Color(0xFF344054),
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                '${monitoredUser.batteryLevel}%',
                                style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? const Color(0xFFD0D5DD)
                                      : const Color(0xFF344054),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                // 4. Bottom Overlay Cards: Current Location + Safe Places ETA
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Card A: Current street address + Get Directions
                          if (location.address.isNotEmpty)
                            _buildCurrentLocationCard(
                              context,
                              isDark,
                              location,
                              monitoredUser,
                              safePlaces,
                            ),
                          if (safePlaces.isNotEmpty) ...[
                            SizedBox(height: 12.h),
                            // Card B: Safe Places ETA
                            _buildSafePlacesEtaCard(
                              context,
                              isDark,
                              safePlaces,
                              location,
                              monitoredUser,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAvatarFallback(String name) {
    return Container(
      color: const Color(0xFFFDA4AF),
      child: Center(
        child: name.isNotEmpty
            ? Text(
                name[0].toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              )
            : Icon(Icons.person_rounded, size: 22.sp, color: Colors.white),
      ),
    );
  }

  Widget _buildCircleMapButton({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100.r),
      child: Container(
        width: 38.r,
        height: 38.r,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2232) : Colors.white,
          shape: BoxShape.circle,
          border: isDark ? Border.all(color: const Color(0xFF2C3044)) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.white : const Color(0xFF4B5563),
          size: 19.sp,
        ),
      ),
    );
  }

  Widget _buildCurrentLocationCard(
    BuildContext context,
    bool isDark,
    MonitoredLocationData location,
    MonitoredUserLiveLocation? user,
    List<SafePlaceEtaItem> safePlaces,
  ) {
    final parts = location.address.split(',');
    final line1 = parts.isNotEmpty ? parts.first.trim() : location.address;
    final line2 = parts.length > 1 ? parts.sublist(1).join(',').trim() : '';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181A26) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          width: 1.w,
          color: isDark ? const Color(0xFF262938) : const Color(0xFFF2F4F7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Purple location icon container
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF261D42) : const Color(0xFFF4F3FF),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.location_on,
              color: isDark ? const Color(0xFFD6BBFB) : const Color(0xFF8B2CF5),
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),

          // Address lines
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  line1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                ),
                if (line2.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    line2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: isDark
                          ? const Color(0xFF98A2B3)
                          : const Color(0xFF667085),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.w),

          // "Get Directions" Pill Button
          InkWell(
            onTap: () {
              SafePlaceEtaItem? destPlace;
              for (final p in safePlaces) {
                if (p.badge.toLowerCase().contains('eta') ||
                    p.name.toLowerCase() == 'work') {
                  destPlace = p;
                  break;
                }
              }
              destPlace ??= safePlaces.isNotEmpty ? safePlaces.first : null;

              context.push(
                AppRouteNames.getDirectionsScreen,
                extra: DirectionsArgs(
                  originLatitude: location.latitude,
                  originLongitude: location.longitude,
                  originName: user?.name.isNotEmpty == true
                      ? "${user!.name}'s Location"
                      : 'Your Location',
                  originAddress: location.address,
                  destinationLatitude: destPlace?.latitude ?? 0.0,
                  destinationLongitude: destPlace?.longitude ?? 0.0,
                  destinationName: destPlace?.name ?? '',
                  destinationAddress: destPlace?.address ?? '',
                  mode: 'drive',
                  availableDestinations: safePlaces,
                ),
              );
            },
            borderRadius: BorderRadius.circular(100.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2232) : Colors.white,
                borderRadius: BorderRadius.circular(100.r),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF9E77ED)
                      : const Color(0xFF8B2CF5),
                  width: 1.2.w,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.near_me_outlined,
                    size: 16.sp,
                    color: isDark
                        ? const Color(0xFFD6BBFB)
                        : const Color(0xFF8B2CF5),
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    'Get Directions',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFFD6BBFB)
                          : const Color(0xFF8B2CF5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafePlacesEtaCard(
    BuildContext context,
    bool isDark,
    List<SafePlaceEtaItem> safePlaces,
    MonitoredLocationData location,
    MonitoredUserLiveLocation? user,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181A26) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          width: 1.w,
          color: isDark ? const Color(0xFF262938) : const Color(0xFFF2F4F7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < safePlaces.length; i++) ...[
            if (i > 0) _buildDottedConnector(),
            InkWell(
              onTap: () {
                final place = safePlaces[i];
                context.push(
                  AppRouteNames.getDirectionsScreen,
                  extra: DirectionsArgs(
                    originLatitude: location.latitude,
                    originLongitude: location.longitude,
                    originName: user?.name.isNotEmpty == true
                        ? "${user!.name}'s Location"
                        : 'Your Location',
                    originAddress: location.address,
                    destinationLatitude: place.latitude,
                    destinationLongitude: place.longitude,
                    destinationName: place.name,
                    destinationAddress: place.address,
                    mode: 'drive',
                    availableDestinations: safePlaces,
                  ),
                );
              },
              child: _buildSafePlaceRow(safePlaces[i], isDark),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDottedConnector() {
    return Padding(
      padding: EdgeInsets.only(left: 20.w),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          height: 22.h,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              4,
              (index) => Container(
                width: 2.5.r,
                height: 2.5.r,
                decoration: BoxDecoration(
                  color: const Color(0xFF7F56D9).withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSafePlaceRow(SafePlaceEtaItem place, bool isDark) {
    final isHome = place.icon.toLowerCase() == 'home';
    final isWork = place.icon.toLowerCase() == 'work';

    final iconData = isHome
        ? Icons.home_rounded
        : (isWork ? Icons.business_center_rounded : Icons.place_rounded);

    final Color badgeBg;
    final Color badgeTextColor;

    switch (place.badgeColor.toLowerCase()) {
      case 'green':
        badgeBg = isDark ? const Color(0xFF132B1D) : const Color(0xFFECFDF3);
        badgeTextColor = isDark ? const Color(0xFF4ADE80) : const Color(0xFF12B76A);
        break;
      case 'purple':
        badgeBg = isDark ? const Color(0xFF261D42) : const Color(0xFFF4F3FF);
        badgeTextColor = isDark ? const Color(0xFFD6BBFB) : const Color(0xFF7F56D9);
        break;
      case 'blue':
        badgeBg = isDark ? const Color(0xFF102847) : const Color(0xFFEFF8FF);
        badgeTextColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF007AFF);
        break;
      case 'red':
        badgeBg = isDark ? const Color(0xFF35161E) : const Color(0xFFFFE4E6);
        badgeTextColor = isDark ? const Color(0xFFFB7185) : const Color(0xFFE11D48);
        break;
      default:
        badgeBg = isDark ? const Color(0xFF261D42) : const Color(0xFFF4F3FF);
        badgeTextColor = isDark ? const Color(0xFFD6BBFB) : const Color(0xFF7F56D9);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 42.r,
          height: 42.r,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF261D42) : const Color(0xFFF4F3FF),
            shape: BoxShape.circle,
          ),
          child: Icon(
            iconData,
            color: isDark ? const Color(0xFFD6BBFB) : const Color(0xFF7F56D9),
            size: 22.sp,
          ),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                place.name,
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
              if (place.timeDisplay.isNotEmpty) ...[
                SizedBox(height: 3.h),
                Text(
                  place.timeDisplay,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: isDark
                        ? const Color(0xFF98A2B3)
                        : const Color(0xFF667085),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (place.badge.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(100.r),
            ),
            child: Text(
              place.badge,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: badgeTextColor,
              ),
            ),
          ),
      ],
    );
  }
}
