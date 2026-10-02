import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

class AlertShareBottomSheet extends StatelessWidget {
  final String mediaType;
  final String title;
  final String timestamp;
  final String shareUrl;

  const AlertShareBottomSheet({
    super.key,
    required this.mediaType,
    required this.title,
    required this.timestamp,
    required this.shareUrl,
  });

  /// Opens the clean Share Options Bottom Sheet
  static Future<void> show(
    BuildContext context, {
    required String mediaType,
    String title = 'Emma',
    String timestamp = 'Today, 10:32 AM',
    String? shareUrl,
  }) {
    final defaultUrl =
        'https://iwitnez.app/alerts/emma-sos-${mediaType.toLowerCase().replaceAll(' ', '-')}';

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => AlertShareBottomSheet(
        mediaType: mediaType,
        title: title,
        timestamp: timestamp,
        shareUrl: shareUrl ?? defaultUrl,
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    Clipboard.setData(ClipboardData(text: shareUrl));
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 10.w),
            const Expanded(child: Text('Recording link copied to clipboard')),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareViaSystem(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : null;

    nav.pop();

    try {
      await SharePlus.instance.share(
        ShareParams(
          text:
              '⚠️ Emergency Alert $mediaType from $title ($timestamp):\n$shareUrl',
          subject: 'Emergency Alert Recording - $title',
          sharePositionOrigin: origin,
        ),
      );
    } catch (e) {
      debugPrint('SharePlus fallback: $e');
      await Clipboard.setData(ClipboardData(text: shareUrl));
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.copy_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8.w),
              const Expanded(child: Text('Recording link copied to clipboard')),
            ],
          ),
          backgroundColor: const Color(0xFF7F56D9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Grabber Handle
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAECF0),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 18.h),

            // Header Row: Icon, Title & Close Button
            Row(
              children: [
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F3FF),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.share_rounded,
                    color: const Color(0xFF7F56D9),
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Share $mediaType',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Recorded by $title • $timestamp',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF667085),
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(16.r),
                  child: Container(
                    padding: EdgeInsets.all(5.r),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF2F4F7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18.sp,
                      color: const Color(0xFF667085),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.h),

            // Link Copy Box
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FC),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: const Color(0xFFEAECF0), width: 1.w),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.link_rounded,
                    color: const Color(0xFF7F56D9),
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      shareUrl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: const Color(0xFF475467),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  InkWell(
                    onTap: () => _copyToClipboard(context),
                    borderRadius: BorderRadius.circular(6.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7F56D9),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.copy_rounded,
                            size: 13.sp,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Copy',
                            style: GoogleFonts.inter(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Primary Share via Apps Button
            SizedBox(
              width: double.infinity,
              height: 46.h,
              child: ElevatedButton.icon(
                onPressed: () => _shareViaSystem(context),
                icon: Icon(Icons.share_rounded, size: 18.sp),
                label: Text(
                  'Share via Apps',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7F56D9),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
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
