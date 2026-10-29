import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/model/live_location_model.dart';

const List<Color> _contactAvatarColors = [
  Color(0xFFFDA4AF), // Pink
  Color(0xFF60A5FA), // Blue
  Color(0xFFFB923C), // Orange
  Color(0xFF34D399), // Mint
  Color(0xFFA78BFA), // Purple
];

/// =====================================================================
/// LIVE LOCATION / MINI MAP CARD (Home Screen)
/// =====================================================================
class LiveLocationCard extends StatefulWidget {
  const LiveLocationCard({
    super.key,
    this.onViewFullMapTap,
    this.onToggleSharing,
    this.isSharing = false,
    this.address = '',
    this.latitude,
    this.longitude,
    this.peopleSharing = const [],
  });

  final VoidCallback? onViewFullMapTap;
  final VoidCallback? onToggleSharing;
  final bool isSharing;
  final String address;
  final double? latitude;
  final double? longitude;
  final List<PeopleSharingModel> peopleSharing;

  @override
  State<LiveLocationCard> createState() => _LiveLocationCardState();
}

class _LiveLocationCardState extends State<LiveLocationCard> {
  final Set<Marker> _markers = {};
  BitmapDescriptor? _userDotIcon;
  final Map<String, BitmapDescriptor> _avatarMarkerCache = {};

  @override
  void initState() {
    super.initState();
    _buildMarkers();
  }

  @override
  void didUpdateWidget(covariant LiveLocationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude ||
        oldWidget.peopleSharing != widget.peopleSharing) {
      _buildMarkers();
    }
  }

  Future<void> _buildMarkers() async {
    final markers = <Marker>{};

    if (widget.latitude != null && widget.longitude != null) {
      final userLatLng = LatLng(widget.latitude!, widget.longitude!);

      // 1. User Location: Small glowing blue dot marker
      _userDotIcon ??= await _createSmallUserDotIcon();
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: userLatLng,
          icon: _userDotIcon!,
          anchor: const Offset(0.5, 0.5),
        ),
      );

      // 2. Trusted Contacts: Profile picture markers placed at their REAL coordinates
      final others = widget.peopleSharing.where((p) => !p.isSelf).toList();
      for (int i = 0; i < others.length; i++) {
        final person = others[i];
        // ONLY place marker if the person has real latitude and longitude
        if (person.latitude != null && person.longitude != null) {
          final cacheKey =
              '${person.id ?? person.name}_${person.avatarUrl ?? ''}';
          if (!_avatarMarkerCache.containsKey(cacheKey)) {
            _avatarMarkerCache[cacheKey] = await _createAvatarMarker(
              name: person.name ?? 'Contact',
              avatarUrl: person.avatarUrl,
              fallbackColor:
                  _contactAvatarColors[i % _contactAvatarColors.length],
              isLive: person.isLive,
            );
          }

          markers.add(
            Marker(
              markerId: MarkerId(person.id ?? 'contact_$i'),
              position: LatLng(person.latitude!, person.longitude!),
              icon: _avatarMarkerCache[cacheKey]!,
              anchor: const Offset(0.5, 0.5),
            ),
          );
        }
      }
    }

    if (mounted) {
      setState(() {
        _markers
          ..clear()
          ..addAll(markers);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCoordinates = widget.latitude != null && widget.longitude != null;
    final userLatLng = hasCoordinates
        ? LatLng(widget.latitude!, widget.longitude!)
        : null;

    return Container(
      width: double.infinity,
      height: 186.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(width: 1.w, color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              width: 152.w,
              padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 10.h),
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Pin icon + Live Location
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: const Color(0xFF8B2CF5),
                            size: 16.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Live Location',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF111827),
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5.h),

                      // "Sharing is ON / OFF" pill badge
                      InkWell(
                        onTap: widget.onToggleSharing,
                        borderRadius: BorderRadius.circular(100.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            vertical: 2.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: widget.isSharing
                                ? const Color(0xFFE8FDF0)
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(100.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5.5.r,
                                height: 5.5.r,
                                decoration: BoxDecoration(
                                  color: widget.isSharing
                                      ? const Color(0xFF22C55E)
                                      : const Color(0xFF9CA3AF),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                widget.isSharing
                                    ? 'Sharing is ON'
                                    : 'Sharing is OFF',
                                style: GoogleFonts.inter(
                                  color: widget.isSharing
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFF6B7280),
                                  fontSize: 8.8.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // Shield notice box
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF5FF),
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color: const Color(0xFFEDE4FE),
                            width: 0.8.w,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.verified_user_rounded,
                              color: AppColors.buttonGradientStart,
                              size: 13.sp,
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                widget.isSharing
                                    ? 'Your Location is being shared with trusted contacts'
                                    : 'Location sharing is turned off',
                                style: GoogleFonts.inter(
                                  color: AppColors.buttonGradientStart,
                                  fontSize: 7.2.sp,
                                  fontWeight: FontWeight.w500,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 6.h),

                      // Address Label
                      Text(
                        widget.address.isNotEmpty
                            ? widget.address
                            : 'Fetching location...',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF374151),
                          fontSize: 8.2.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
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
                        color: AppColors.buttonGradientStart,
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

            // Right Panel — Real Google Map Preview with True Geographic Coordinates
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
                child: hasCoordinates
                    ? Stack(
                        children: [
                          GoogleMap(
                            key: ValueKey(
                              '${widget.latitude}_${widget.longitude}',
                            ),
                            initialCameraPosition: CameraPosition(
                              target: userLatLng!,
                              zoom: 15.0,
                            ),
                            markers: _markers,
                            liteModeEnabled: true,
                            zoomControlsEnabled: false,
                            myLocationButtonEnabled: false,
                            compassEnabled: false,
                            mapToolbarEnabled: false,
                            rotateGesturesEnabled: false,
                            tiltGesturesEnabled: false,
                            scrollGesturesEnabled: false,
                            zoomGesturesEnabled: false,
                          ),

                          // Tap overlay to navigate to Full Map (Screen 2)
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(onTap: widget.onViewFullMapTap),
                            ),
                          ),
                        ],
                      )
                    : Container(
                        color: const Color(0xFFF8FAFC),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 22.r,
                                height: 22.r,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF8B2CF5),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Locating...',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF94A3B8),
                                  fontSize: 9.5.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
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

  // Small blue user dot marker (NO big teardrop pin)
  Future<BitmapDescriptor> _createSmallUserDotIcon() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = 36.0;

    // Outer soft glow
    final glowPaint = Paint()..color = const Color(0x40007AFF);
    canvas.drawCircle(const Offset(size / 2, size / 2), 16, glowPaint);

    // White border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(size / 2, size / 2), 11, borderPaint);

    // Vibrant Blue center
    final dotPaint = Paint()..color = const Color(0xFF007AFF);
    canvas.drawCircle(const Offset(size / 2, size / 2), 8.5, dotPaint);

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      return BitmapDescriptor.bytes(byteData.buffer.asUint8List());
    }
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
  }

  // Circular profile picture marker for trusted contacts (at their real GPS coordinates)
  Future<BitmapDescriptor> _createAvatarMarker({
    required String name,
    String? avatarUrl,
    Color fallbackColor = const Color(0xFF8B2CF5),
    bool isLive = true,
  }) async {
    const size = 68.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // 1. Drop shadow
    final shadowPaint = Paint()
      ..color = const Color(0x33000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(
      const Offset(size / 2, size / 2 + 2),
      size / 2 - 6,
      shadowPaint,
    );

    // 2. White border circle
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 2 - 5,
      borderPaint,
    );

    // 3. Avatar Image or Initial letter
    ui.Image? loadedImage;
    if (avatarUrl != null &&
        avatarUrl.isNotEmpty &&
        avatarUrl.startsWith('http')) {
      try {
        final cleanUrl = avatarUrl.startsWith('http://')
            ? avatarUrl.replaceFirst('http://', 'https://')
            : avatarUrl;
        final uri = Uri.parse(cleanUrl);
        final request = await HttpClient().getUrl(uri);
        final response = await request.close().timeout(
          const Duration(seconds: 3),
        );
        if (response.statusCode == 200) {
          final bytes = await consolidateHttpClientResponseBytes(response);
          final codec = await ui.instantiateImageCodec(
            bytes,
            targetWidth: (size - 14).toInt(),
            targetHeight: (size - 14).toInt(),
          );
          final frame = await codec.getNextFrame();
          loadedImage = frame.image;
        }
      } catch (_) {
        // Fallback to initial
      }
    }

    final clipPath = Path()
      ..addOval(
        Rect.fromCircle(
          center: const Offset(size / 2, size / 2),
          radius: size / 2 - 8,
        ),
      );
    canvas.save();
    canvas.clipPath(clipPath);

    if (loadedImage != null) {
      canvas.drawImage(
        loadedImage,
        Offset((size - loadedImage.width) / 2, (size - loadedImage.height) / 2),
        Paint(),
      );
    } else {
      // Fallback background color
      final bgPaint = Paint()..color = fallbackColor;
      canvas.drawCircle(
        const Offset(size / 2, size / 2),
        size / 2 - 8,
        bgPaint,
      );

      // Initial letter
      final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
      final textPainter = TextPainter(
        text: TextSpan(
          text: initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
      );
    }
    canvas.restore();

    // 4. Live green dot on bottom-right
    if (isLive) {
      const dotOffset = Offset(size - 13, size - 13);
      final dotBg = Paint()..color = Colors.white;
      canvas.drawCircle(dotOffset, 7.5, dotBg);
      final dotPaint = Paint()..color = const Color(0xFF22C55E);
      canvas.drawCircle(dotOffset, 5.5, dotPaint);
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      return BitmapDescriptor.bytes(byteData.buffer.asUint8List());
    }
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose);
  }
}
