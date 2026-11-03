import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';
import 'package:iwitnez/core/constants/theme/dark_map_style.dart';
import 'package:iwitnez/feature/trusted_contact/Alerts_section/Alerts/model/alert_history_model.dart';
import 'package:iwitnez/feature/trusted_contact/Alerts_section/Alerts/widget/alert_history_media_modal.dart';
import 'package:iwitnez/router/app_route_names.dart';

class AlertHistoryCard extends StatefulWidget {
  final AlertHistoryModel item;

  const AlertHistoryCard({super.key, required this.item});

  @override
  State<AlertHistoryCard> createState() => _AlertHistoryCardState();
}

class _AlertHistoryCardState extends State<AlertHistoryCard> {
  // In-memory cache for probed video durations so we don't re-probe on scroll
  static final Map<String, String> _probedDurationCache = {};

  bool get _hasValidCoords =>
      widget.item.latitude != null &&
      widget.item.longitude != null &&
      widget.item.latitude != 0.0 &&
      widget.item.longitude != 0.0;

  String get _displayDuration {
    final url = widget.item.videoUrl;
    if (url != null && _probedDurationCache.containsKey(url)) {
      return _probedDurationCache[url]!;
    }
    if (widget.item.durationSeconds != null &&
        widget.item.durationSeconds! > 0) {
      final m = (widget.item.durationSeconds! ~/ 60).toString().padLeft(2, '0');
      final s = (widget.item.durationSeconds! % 60).toString().padLeft(2, '0');
      return '$m:$s';
    }
    return widget.item.durationDisplay;
  }

  @override
  void initState() {
    super.initState();
    _probeActualVideoDuration();
  }

  @override
  void didUpdateWidget(covariant AlertHistoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.videoUrl != widget.item.videoUrl) {
      _probeActualVideoDuration();
    }
  }

  Future<void> _probeActualVideoDuration() async {
    final url = widget.item.videoUrl;
    if (url == null || url.isEmpty) return;
    if (_probedDurationCache.containsKey(url)) return;

    try {
      final uri = Uri.tryParse(url);
      if (uri == null) return;
      final ctrl = VideoPlayerController.networkUrl(
        uri,
        httpHeaders: const {'ngrok-skip-browser-warning': 'true'},
      );
      await ctrl.initialize();
      final dur = ctrl.value.duration;
      if (dur > Duration.zero) {
        final m = dur.inMinutes.remainder(60).toString().padLeft(2, '0');
        final s = dur.inSeconds.remainder(60).toString().padLeft(2, '0');
        _probedDurationCache[url] = '$m:$s';
        if (mounted) {
          setState(() {});
        }
      }
      await ctrl.dispose();
    } catch (e) {
      debugPrint('Could not probe video duration for $url: $e');
    }
  }

  Widget _buildThumbnail() {
    final thumb = widget.item.thumbnailUrl;
    if (thumb != null && thumb.isNotEmpty) {
      if (thumb.startsWith('http://') || thumb.startsWith('https://')) {
        return Image.network(
          thumb,
          fit: BoxFit.cover,
          headers: const {'ngrok-skip-browser-warning': 'true'},
          errorBuilder: (_, __, ___) =>
              Image.asset(ImageAssets.historyVideoThumbnail, fit: BoxFit.cover),
        );
      } else if (thumb.startsWith('assets/')) {
        return Image.asset(thumb, fit: BoxFit.cover);
      }
    }
    return Image.asset(ImageAssets.historyVideoThumbnail, fit: BoxFit.cover);
  }

  void _onOpenMediaModal() {
    final resolvedItem = _displayDuration.isNotEmpty
        ? widget.item.copyWith(durationDisplay: _displayDuration)
        : widget.item;
    AlertHistoryMediaModal.show(context, resolvedItem);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final item = widget.item;
    final dur = _displayDuration;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181A26) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? const Color(0xFF262938) : const Color(0xFFF2F4F7),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: _onOpenMediaModal,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(10.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Left: Video Thumbnail Box with Play Button
                SizedBox(
                  width: 86.w,
                  height: 98.h,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: _buildThumbnail(),
                      ),

                      // Bottom Gradient
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 36.h,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(12.r),
                            ),
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.65),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),

                      // Bottom-Left Duration Badge (Real duration, e.g. 00:04)
                      if (dur.isNotEmpty)
                        Positioned(
                          bottom: 6.h,
                          left: 6.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 5.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              dur,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 9.5.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                      // Bottom-Right Circular Red Play Button
                      Positioned(
                        bottom: 6.h,
                        right: 6.w,
                        child: Container(
                          width: 24.r,
                          height: 24.r,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF04438),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFF04438,
                                ).withValues(alpha: 0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 16.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10.w),

                // 2. Middle: Alert Details (Title, Date, Address, Media Badges)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // SOS Alert Title
                      Text(
                        item.title,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFFFF6B6B)
                              : const Color(0xFFF04438),
                        ),
                      ),
                      SizedBox(height: 2.h),

                      // Date / Time
                      Text(
                        item.timestampDisplay,
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                          color: isDark
                              ? const Color(0xFF98A2B3)
                              : const Color(0xFF667085),
                        ),
                      ),
                      SizedBox(height: 4.h),

                      // Location Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 1.h),
                            child: Icon(
                              Icons.location_on_rounded,
                              color: isDark
                                  ? const Color(0xFF9E77ED)
                                  : const Color(0xFF7F56D9),
                              size: 13.sp,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              item.address,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 9.5.sp,
                                fontWeight: FontWeight.w400,
                                color: isDark
                                    ? const Color(0xFFE5E7EB)
                                    : const Color(0xFF667085),
                                height: 1.25,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),

                      // Badges: Video & Audio
                      Row(
                        children: [
                          if (item.hasVideo) ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.5.h,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF261D42)
                                    : const Color(0xFFF4F3FF),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.videocam_rounded,
                                    color: isDark
                                        ? const Color(0xFFD6BBFB)
                                        : const Color(0xFF7F56D9),
                                    size: 12.sp,
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    'Video',
                                    style: GoogleFonts.inter(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? const Color(0xFFD6BBFB)
                                          : const Color(0xFF7F56D9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 6.w),
                          ],
                          if (item.hasAudio) ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.5.h,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF261D42)
                                    : const Color(0xFFF4F3FF),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                'Audio',
                                style: GoogleFonts.inter(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? const Color(0xFFD6BBFB)
                                      : const Color(0xFF7F56D9),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 6.w),

                // 3. Right: Mini Map Snippet (Real Google Map using API lat/lng)
                SizedBox(
                  width: 58.w,
                  height: 84.h,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (_hasValidCoords)
                          IgnorePointer(
                            child: GoogleMap(
                              key: ValueKey(
                                'hist_map_${item.id}_${item.latitude}_${item.longitude}_$isDark',
                              ),
                              initialCameraPosition: CameraPosition(
                                target: LatLng(item.latitude!, item.longitude!),
                                zoom: 14.5,
                              ),
                              markers: const {},
                              style: isDark ? darkMapStyleJson : null,
                              zoomControlsEnabled: false,
                              myLocationButtonEnabled: false,
                              compassEnabled: false,
                              mapToolbarEnabled: false,
                              rotateGesturesEnabled: false,
                              tiltGesturesEnabled: false,
                              scrollGesturesEnabled: false,
                              zoomGesturesEnabled: false,
                            ),
                          )
                        else
                          Image.asset(
                            ImageAssets.liveTrackingMap,
                            fit: BoxFit.cover,
                          ),

                        // Sleek, compact Red Location Pin placed at the center coordinates
                        Center(
                          child: Transform.translate(
                            offset: Offset(0, -6.h),
                            child: Icon(
                              Icons.location_on_rounded,
                              color: const Color(0xFFF04438),
                              size: 19.sp,
                              shadows: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Interactive Tap Overlay navigating to full live location screen
                        Positioned.fill(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                context.push(
                                  AppRouteNames.trustedLiveLocationScreen,
                                );
                              },
                            ),
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
      ),
    );
  }
}
