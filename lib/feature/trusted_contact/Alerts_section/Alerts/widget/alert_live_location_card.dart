import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';
import 'package:iwitnez/feature/main_user/LiveLocation/widget/map_marker_helper.dart';
import 'package:iwitnez/feature/trusted_contact/Alerts_section/Alerts/model/active_alert_model.dart';
import 'package:iwitnez/router/app_route_names.dart';

class AlertLiveLocationCard extends StatefulWidget {
  final AlertLocationModel location;
  final String userName;

  const AlertLiveLocationCard({
    super.key,
    required this.location,
    required this.userName,
  });

  @override
  State<AlertLiveLocationCard> createState() => _AlertLiveLocationCardState();
}

class _AlertLiveLocationCardState extends State<AlertLiveLocationCard> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

  bool get _hasValidCoords =>
      widget.location.latitude != 0.0 && widget.location.longitude != 0.0;

  @override
  void initState() {
    super.initState();
    _initMarker();
  }

  @override
  void didUpdateWidget(covariant AlertLiveLocationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location.latitude != widget.location.latitude ||
        oldWidget.location.longitude != widget.location.longitude ||
        oldWidget.userName != widget.userName) {
      _initMarker();
      if (_hasValidCoords && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(widget.location.latitude, widget.location.longitude),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initMarker() async {
    if (!_hasValidCoords) return;

    final pos = LatLng(widget.location.latitude, widget.location.longitude);
    try {
      final markerIcon = await MapMarkerHelper.createAvatarMarker(
        name: widget.userName,
        avatarUrl: '',
        fallbackColor: const Color(0xFFF04438),
        isLive: true,
        size: 40.0,
      );

      if (mounted) {
        setState(() {
          _markers
            ..clear()
            ..add(
              Marker(
                markerId: const MarkerId('active_alert_location_marker'),
                position: pos,
                icon: markerIcon,
                anchor: const Offset(0.5, 0.5),
              ),
            );
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.userName;
    final addressText = widget.location.address;
    final isSos = widget.location.isSosActivated;

    return Container(
      width: double.infinity,
      height: 146.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFEAECF0), width: 1.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left Info Details Column
          Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.fromLTRB(12.w, 10.h, 6.w, 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title Row
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: const Color(0xFF8B2CF5),
                        size: 16.sp,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          name.isNotEmpty
                              ? "$name's\nLive Location"
                              : "Live Location",
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                            height: 1.15,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Status: Online • Sos Activated
                  Row(
                    children: [
                      Container(
                        width: 5.r,
                        height: 5.r,
                        decoration: const BoxDecoration(
                          color: Color(0xFF12B76A),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Online',
                        style: GoogleFonts.inter(
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF12B76A),
                        ),
                      ),
                      if (isSos) ...[
                        SizedBox(width: 6.w),
                        Text(
                          'Sos Activated',
                          style: GoogleFonts.inter(
                            fontSize: 9.5.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFD92D20),
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Real Address from API
                  Text(
                    addressText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 9.5.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF667085),
                      height: 1.25,
                    ),
                  ),

                  // "View Full Map" Red Button
                  InkWell(
                    onTap: () {
                      context.push(AppRouteNames.trustedLiveLocationScreen);
                    },
                    borderRadius: BorderRadius.circular(100.r),
                    child: Container(
                      width: double.infinity,
                      height: 28.h,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF4D4F), Color(0xFFF04438)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(100.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFF04438,
                            ).withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'View Full Map',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right Map: Real Google Map if coords available, else radar visual
          Expanded(
            flex: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.horizontal(
                right: Radius.circular(15.r),
              ),
              child: _hasValidCoords
                  ? GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          widget.location.latitude,
                          widget.location.longitude,
                        ),
                        zoom: 15,
                      ),
                      markers: _markers,
                      onMapCreated: (ctrl) => _mapController = ctrl,
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                      compassEnabled: false,
                      mapToolbarEnabled: false,
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          ImageAssets.liveTrackingMap,
                          fit: BoxFit.cover,
                        ),
                        Center(
                          child: Icon(
                            Icons.location_on_rounded,
                            color: const Color(0xFFF04438),
                            size: 28.sp,
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
}
