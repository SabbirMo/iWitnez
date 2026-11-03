import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iwitnez/feature/main_user/LiveLocation/widget/map_marker_helper.dart';

class TrustedLiveLocationCard extends StatefulWidget {
  const TrustedLiveLocationCard({
    super.key,
    required this.wardName,
    required this.wardStatus,
    required this.address,
    required this.wardAvatarUrl,
    this.isOnline = true,
    this.latitude,
    this.longitude,
    this.isDark,
    this.onViewFullMapTap,
  });

  final String wardName;
  final String wardStatus;
  final String address;
  final String wardAvatarUrl;
  final bool isOnline;
  final double? latitude;
  final double? longitude;
  final bool? isDark;
  final VoidCallback? onViewFullMapTap;

  @override
  State<TrustedLiveLocationCard> createState() =>
      _TrustedLiveLocationCardState();
}

class _TrustedLiveLocationCardState extends State<TrustedLiveLocationCard> {
  final Set<Marker> _markers = {};
  GoogleMapController? _mapController;

  static const String _darkMapStyle = '''[
  {"elementType": "geometry", "stylers": [{"color": "#242f3e"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#746855"}]},
  {"elementType": "labels.text.stroke", "stylers": [{"color": "#242f3e"}]},
  {"featureType": "administrative.locality", "elementType": "labels.text.fill", "stylers": [{"color": "#d59563"}]},
  {"featureType": "poi", "elementType": "labels.text.fill", "stylers": [{"color": "#d59563"}]},
  {"featureType": "poi.park", "elementType": "geometry", "stylers": [{"color": "#263c3f"}]},
  {"featureType": "poi.park", "elementType": "labels.text.fill", "stylers": [{"color": "#6b9a76"}]},
  {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#38414e"}]},
  {"featureType": "road", "elementType": "geometry.stroke", "stylers": [{"color": "#212a37"}]},
  {"featureType": "road", "elementType": "labels.text.fill", "stylers": [{"color": "#9ca5b3"}]},
  {"featureType": "road.highway", "elementType": "geometry", "stylers": [{"color": "#746855"}]},
  {"featureType": "road.highway", "elementType": "geometry.stroke", "stylers": [{"color": "#1f2835"}]},
  {"featureType": "road.highway", "elementType": "labels.text.fill", "stylers": [{"color": "#f3d19c"}]},
  {"featureType": "transit", "elementType": "geometry", "stylers": [{"color": "#2f3948"}]},
  {"featureType": "transit.station", "elementType": "labels.text.fill", "stylers": [{"color": "#d59563"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#17263c"}]},
  {"featureType": "water", "elementType": "labels.text.fill", "stylers": [{"color": "#515c6d"}]},
  {"featureType": "water", "elementType": "labels.text.stroke", "stylers": [{"color": "#17263c"}]}
]''';

  @override
  void initState() {
    super.initState();
    _buildMarkers();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TrustedLiveLocationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDark != widget.isDark && _mapController != null) {
      final dark = widget.isDark ?? (Theme.of(context).brightness == Brightness.dark);
      _mapController!.setMapStyle(dark ? _darkMapStyle : null);
    }
    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude ||
        oldWidget.wardName != widget.wardName ||
        oldWidget.wardAvatarUrl != widget.wardAvatarUrl ||
        oldWidget.isOnline != widget.isOnline) {
      _buildMarkers();
      if (widget.latitude != null &&
          widget.longitude != null &&
          _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(widget.latitude!, widget.longitude!),
          ),
        );
      }
    }
  }

  Future<void> _buildMarkers() async {
    if (widget.latitude == null || widget.longitude == null) return;
    if (widget.latitude == 0.0 && widget.longitude == 0.0) return;

    final pos = LatLng(widget.latitude!, widget.longitude!);

    final markerIcon = await MapMarkerHelper.createAvatarMarker(
      name: widget.wardName.isNotEmpty ? widget.wardName : 'User',
      avatarUrl: widget.wardAvatarUrl,
      fallbackColor: const Color(0xFF8B2CF5),
      isLive: widget.isOnline,
      size: 48.0,
    );

    if (mounted) {
      setState(() {
        _markers
          ..clear()
          ..add(
            Marker(
              markerId: const MarkerId('monitored_user_marker'),
              position: pos,
              icon: markerIcon,
              anchor: const Offset(0.5, 0.5),
            ),
          );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.isDark ?? (Theme.of(context).brightness == Brightness.dark);
    final hasValidCoords = widget.latitude != null &&
        widget.longitude != null &&
        (widget.latitude != 0.0 || widget.longitude != 0.0);

    return Container(
      width: double.infinity,
      height: 172.h,
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF181A26) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          width: 1.w,
          color: dark ? const Color(0xFF262938) : const Color(0xFFF1F5F9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.35 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Row(
          children: [
            // Left Panel — Live Location details & View Full Map button
            Container(
              width: 140.w,
              padding: EdgeInsets.fromLTRB(12.w, 12.h, 10.w, 12.h),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF181A26) : Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Pin icon + Live Location
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: const Color(0xFF8B2CF5),
                            size: 17.sp,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              widget.wardName.isNotEmpty
                                  ? "${widget.wardName}'s\nLive Location"
                                  : "Live Location",
                              style: GoogleFonts.inter(
                                color: dark ? Colors.white : const Color(0xFF111827),
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (widget.wardStatus.isNotEmpty) ...[
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Container(
                              width: 6.r,
                              height: 6.r,
                              decoration: BoxDecoration(
                                color: widget.isOnline
                                    ? const Color(0xFF22C55E)
                                    : const Color(0xFF9CA3AF),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                widget.wardStatus,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  color: widget.isOnline
                                      ? (dark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A))
                                      : (dark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (widget.address.isNotEmpty) ...[
                        SizedBox(height: 10.h),
                        Text(
                          widget.address,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: dark ? const Color(0xFFE5E7EB) : const Color(0xFF111827),
                            fontSize: 8.6.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ],
                  ),

                  // "View Full Map" Pill Button
                  InkWell(
                    onTap: widget.onViewFullMapTap,
                    borderRadius: BorderRadius.circular(100.r),
                    child: Container(
                      width: double.infinity,
                      height: 28.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B2CF5),
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      child: Center(
                        child: Text(
                          'View Full Map',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Right Panel — Real Google Map Preview with user avatar marker
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
                child: hasValidCoords
                    ? Stack(
                        children: [
                          GoogleMap(
                            key: ValueKey(
                              '${widget.latitude}_${widget.longitude}_$dark',
                            ),
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                widget.latitude!,
                                widget.longitude!,
                              ),
                              zoom: 15.0,
                            ),
                            markers: _markers,
                            style: dark ? _darkMapStyle : null,
                            liteModeEnabled: false,
                            zoomControlsEnabled: false,
                            myLocationButtonEnabled: false,
                            compassEnabled: false,
                            mapToolbarEnabled: false,
                            rotateGesturesEnabled: false,
                            tiltGesturesEnabled: false,
                            scrollGesturesEnabled: false,
                            zoomGesturesEnabled: false,
                            onMapCreated: (controller) {
                              _mapController = controller;
                              if (dark) {
                                controller.setMapStyle(_darkMapStyle);
                              }
                            },
                          ),

                          // Transparent tap overlay to trigger onViewFullMapTap
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: widget.onViewFullMapTap,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(
                        color: dark ? const Color(0xFF181A26) : const Color(0xFFF8FAFC),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Color(0xFF8B2CF5),
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
