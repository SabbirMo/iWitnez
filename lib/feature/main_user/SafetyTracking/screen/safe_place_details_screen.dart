import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iwitnez/feature/main_user/SafetyTracking/model/safe_place_model.dart';
import 'package:iwitnez/feature/main_user/SafetyTracking/provider/safety_tracking_provider.dart';
import 'package:iwitnez/router/app_route_names.dart';

class SafePlaceDetailsScreen extends ConsumerStatefulWidget {
  final String placeId;
  final SafePlaceModel? initialPlace;

  const SafePlaceDetailsScreen({
    super.key,
    required this.placeId,
    this.initialPlace,
  });

  @override
  ConsumerState<SafePlaceDetailsScreen> createState() =>
      _SafePlaceDetailsScreenState();
}

class _SafePlaceDetailsScreenState
    extends ConsumerState<SafePlaceDetailsScreen> {
  SafePlaceModel? _place;
  GoogleMapController? _mapController;
  MapType _mapType = MapType.normal;
  bool _isLoading = false;
  int _selectedRadius = 150;

  @override
  void initState() {
    super.initState();
    _place = widget.initialPlace;
    _selectedRadius = widget.initialPlace?.radius ?? 150;
    _loadPlaceDetails();
  }

  Future<void> _loadPlaceDetails() async {
    if (widget.placeId.isEmpty) return;
    setState(() => _isLoading = _place == null);

    final fetched = await ref
        .read(safetyTrackingProvider.notifier)
        .fetchSafePlaceDetails(widget.placeId);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (fetched != null) {
          _place = fetched;
          _selectedRadius = fetched.radius ?? _selectedRadius;
        }
      });
      if (fetched?.latitude != null && fetched?.longitude != null) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(fetched!.latitude!, fetched.longitude!),
          ),
        );
      }
    }
  }

  void _toggleMapType() {
    setState(() {
      _mapType = _mapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  Future<void> _navigateToEditSafePlace() async {
    if (_place == null) return;

    final updatedPlace = await context.push<SafePlaceModel>(
      AppRouteNames.addSafePlaceScreen,
      extra: _place,
    );

    if (updatedPlace != null && mounted) {
      setState(() {
        _place = updatedPlace;
        _selectedRadius = updatedPlace.radius ?? _selectedRadius;
      });
      if (updatedPlace.latitude != null && updatedPlace.longitude != null) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(updatedPlace.latitude!, updatedPlace.longitude!),
          ),
        );
      }
    } else if (mounted) {
      _loadPlaceDetails();
    }
  }

  Future<void> _confirmRemovePlace() async {
    if (_place == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
          title: Text(
            'Remove Safe Place',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 17.sp,
              color: const Color(0xFF111827),
            ),
          ),
          content: Text(
            'Are you sure you want to remove "${_place!.title}" from your safe places?',
            style: GoogleFonts.inter(
              fontSize: 13.5.sp,
              color: const Color(0xFF4B5563),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                'Remove',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await ref
          .read(safetyTrackingProvider.notifier)
          .deleteSafePlace(_place!.id);

      if (mounted) {
        if (context.canPop()) {
          context.pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final place = _place;
    final lat = place?.latitude ?? 23.8103;
    final lng = place?.longitude ?? 90.4125;
    final targetLatLng = LatLng(lat, lng);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
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
              context.go(AppRouteNames.safetyTrackingScreen);
            }
          },
        ),
        title: Text(
          'Safe Place Details',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading && place == null
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                ),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subtitle
                    Center(
                      child: Text(
                        'View and manage your safe place details\nand alert preferences.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: const Color(0xFF6B7280),
                          height: 1.35,
                        ),
                      ),
                    ),
                    SizedBox(height: 18.h),

                    // Top Summary Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.035),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(14.r),
                      child: Row(
                        children: [
                          // Place Icon Capsule
                          Container(
                            width: 48.r,
                            height: 48.r,
                            decoration: BoxDecoration(
                              color:
                                  place?.displayBackgroundColor ??
                                  const Color(0xFFF3E8FF),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              place?.displayIcon ?? Icons.home_rounded,
                              color:
                                  place?.displayIconColor ??
                                  const Color(0xFF7C3AED),
                              size: 24.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),

                          // Name and Address
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  place?.title ?? 'Safe Place',
                                  style: GoogleFonts.inter(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF111827),
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  place?.address ?? 'No address specified',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF6B7280),
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),

                          // Status Badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: (place?.isInside ?? false)
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Text(
                              place?.displayStatus ?? 'Outside',
                              style: GoogleFonts.inter(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w600,
                                color: (place?.isInside ?? false)
                                    ? const Color(0xFF15803D)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // 2. Location
                    Text(
                      '2. Location',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 10.h),

                    // Map Container
                    Container(
                      height: 220.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: targetLatLng,
                              zoom: 15.5,
                            ),
                            mapType: _mapType,
                            gestureRecognizers:
                                <Factory<OneSequenceGestureRecognizer>>{
                                  Factory<OneSequenceGestureRecognizer>(
                                    () => EagerGestureRecognizer(),
                                  ),
                                },
                            circles: {
                              Circle(
                                circleId: const CircleId(
                                  'safe_place_detail_circle',
                                ),
                                center: targetLatLng,
                                radius: _selectedRadius.toDouble(),
                                fillColor: const Color(
                                  0xFF8B5CF6,
                                ).withValues(alpha: 0.18),
                                strokeColor: const Color(0xFF8B5CF6),
                                strokeWidth: 2,
                              ),
                            },
                            markers: {
                              Marker(
                                markerId: const MarkerId(
                                  'safe_place_detail_marker',
                                ),
                                position: targetLatLng,
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueViolet,
                                ),
                              ),
                            },
                            onMapCreated: (ctrl) => _mapController = ctrl,
                            zoomControlsEnabled: false,
                            myLocationButtonEnabled: false,
                            compassEnabled: false,
                            mapToolbarEnabled: false,
                          ),

                          // Right Floating Map Controls
                          Positioned(
                            right: 12.w,
                            top: 12.h,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildMiniButton(
                                  icon: Icons.my_location_rounded,
                                  onTap: () {
                                    _mapController?.animateCamera(
                                      CameraUpdate.newLatLng(targetLatLng),
                                    );
                                  },
                                ),
                                SizedBox(height: 8.h),
                                _buildMiniButton(
                                  icon: Icons.layers_rounded,
                                  onTap: _toggleMapType,
                                ),
                                SizedBox(height: 8.h),
                                // Zoom Pill
                                Container(
                                  width: 34.r,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.08,
                                        ),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(18.r),
                                        ),
                                        onTap: () {
                                          _mapController?.animateCamera(
                                            CameraUpdate.zoomIn(),
                                          );
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 6.h,
                                          ),
                                          child: Icon(
                                            Icons.add_rounded,
                                            color: const Color(0xFF8B5CF6),
                                            size: 18.sp,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 18.w,
                                        height: 1.h,
                                        color: const Color(0xFFE2E8F0),
                                      ),
                                      InkWell(
                                        borderRadius: BorderRadius.vertical(
                                          bottom: Radius.circular(18.r),
                                        ),
                                        onTap: () {
                                          _mapController?.animateCamera(
                                            CameraUpdate.zoomOut(),
                                          );
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 6.h,
                                          ),
                                          child: Icon(
                                            Icons.remove_rounded,
                                            color: const Color(0xFF8B5CF6),
                                            size: 18.sp,
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
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // Set Radius Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 12.h,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42.r,
                            height: 42.r,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3E8FF),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              Icons.my_location_rounded,
                              color: const Color(0xFF8B5CF6),
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Set Radius',
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF111827),
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  "You'll get alerts when you enter or leave this area.",
                                  style: GoogleFonts.inter(
                                    fontSize: 10.2.sp,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),

                          // Static Radius Display Pill (Read-only from Backend)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 7.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Text(
                              '${_place?.radius ?? _selectedRadius} m',
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF111827),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Action Button 1: Edit Safe Place
                    Container(
                      width: double.infinity,
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26.r),
                        border: Border.all(
                          color: const Color(0xFF8B5CF6),
                          width: 1.5.w,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(26.r),
                          onTap: _navigateToEditSafePlace,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                color: const Color(0xFF8B5CF6),
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Edit Safe Place',
                                style: GoogleFonts.inter(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF8B5CF6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // Action Button 2: Remove Safe Place
                    Container(
                      width: double.infinity,
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26.r),
                        border: Border.all(
                          color: const Color(0xFFEF4444),
                          width: 1.5.w,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(26.r),
                          onTap: _confirmRemovePlace,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                color: const Color(0xFFEF4444),
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Remove Safe Place',
                                style: GoogleFonts.inter(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFEF4444),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildMiniButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 34.r,
      height: 34.r,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10.r),
          onTap: onTap,
          child: Center(
            child: Icon(icon, color: const Color(0xFF8B5CF6), size: 18.sp),
          ),
        ),
      ),
    );
  }
}
