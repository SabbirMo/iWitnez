import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';

/// =====================================================================
/// LIVE LOCATION / MAP CARD
/// =====================================================================
class LiveLocationCard extends StatefulWidget {
  const LiveLocationCard({
    super.key,
    this.onViewFullMapTap,
    this.onToggleSharing,
    this.isSharing = true,
    this.address = '1200 Park Ave,\nNew York, NY 10028, USA',
  });

  final VoidCallback? onViewFullMapTap;
  final VoidCallback? onToggleSharing;
  final bool isSharing;
  final String address;

  @override
  State<LiveLocationCard> createState() => _LiveLocationCardState();
}

class _LiveLocationCardState extends State<LiveLocationCard>
    with SingleTickerProviderStateMixin {
  late bool _isSharing;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _isSharing = widget.isSharing;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOut,
    );
  }

  @override
  void didUpdateWidget(covariant LiveLocationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSharing != widget.isSharing) {
      _isSharing = widget.isSharing;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleToggle() {
    setState(() {
      _isSharing = !_isSharing;
    });
    widget.onToggleSharing?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 182.h,
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
              width: 142.w,
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
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5.h),

                      // "Sharing is ON" pill badge
                      InkWell(
                        onTap: _handleToggle,
                        borderRadius: BorderRadius.circular(100.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            vertical: 2.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: _isSharing
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
                                  color: _isSharing
                                      ? const Color(0xFF22C55E)
                                      : const Color(0xFF9CA3AF),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                _isSharing ? 'Sharing is ON' : 'Sharing is OFF',
                                style: GoogleFonts.inter(
                                  color: _isSharing
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
                      SizedBox(height: 10.h),

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
                                'Your Location is being shared with trusted contacts',
                                style: GoogleFonts.inter(
                                  color: AppColors.buttonGradientStart,
                                  fontSize: 7.sp,
                                  fontWeight: FontWeight.w500,
                                  height: 1.22,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.h),

                      // Address
                      Text(
                        '1200 Park Ave, New York, Ny 10028, USA',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF111827),
                          fontSize: 8.5.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
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

            // Right Panel — Detailed Interactive Dummy Map
            Expanded(
              child: InkWell(
                onTap: widget.onViewFullMapTap,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16.r),
                    bottomRight: Radius.circular(16.r),
                  ),
                  child: Stack(
                    children: [
                      // Vector-styled map matching Manhattan grid layout
                      Positioned.fill(
                        child: CustomPaint(
                          painter: const _DetailedMapPainter(),
                        ),
                      ),

                      // User Location (pulsing halo + vibrant blue dot)
                      Positioned(
                        left: 36.w,
                        bottom: 22.h,
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            final wave = _pulseAnimation.value;
                            return Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                // Outer pulse halo
                                Container(
                                  width: (34 + wave * 16).r,
                                  height: (34 + wave * 16).r,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF3B82F6,
                                    ).withValues(alpha: (1.0 - wave) * 0.35),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                // Static halo ring
                                Container(
                                  width: 30.r,
                                  height: 30.r,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF93C5FD,
                                    ).withValues(alpha: 0.45),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                // Center blue circle with white border
                                Container(
                                  width: 17.r,
                                  height: 17.r,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF007AFF),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.2.w,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF007AFF,
                                        ).withValues(alpha: 0.4),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      // Avatar 1 (Woman - top left / middle)
                      Positioned(
                        left: 18.w,
                        top: 14.h,
                        child: _buildMapAvatar(
                          imageUrl:
                              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
                          fallbackName: 'Sarah',
                          fallbackColor: const Color(0xFFFDA4AF),
                        ),
                      ),

                      // Avatar 2 (Young man - top right)
                      Positioned(
                        right: 36.w,
                        top: 12.h,
                        child: _buildMapAvatar(
                          imageUrl:
                              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
                          fallbackName: 'Alex',
                          fallbackColor: const Color(0xFF60A5FA),
                        ),
                      ),

                      // Avatar 3 (Man with beard - middle right)
                      Positioned(
                        right: 12.w,
                        top: 60.h,
                        child: _buildMapAvatar(
                          imageUrl:
                              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
                          fallbackName: 'John',
                          fallbackColor: const Color(0xFFFB923C),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapAvatar({
    required String imageUrl,
    required String fallbackName,
    required Color fallbackColor,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 32.r,
          height: 32.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.2.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: fallbackColor,
                  child: Center(
                    child: Text(
                      fallbackName.isNotEmpty ? fallbackName[0] : '?',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 9.r,
            height: 9.r,
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5.w),
            ),
          ),
        ),
      ],
    );
  }
}

/// Renders a vector-styled Manhattan map matching the reference design:
/// angled avenues, cross-streets, green park patches, water feature, FDR Dr,
/// and street name labels.
class _DetailedMapPainter extends CustomPainter {
  const _DetailedMapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Base land background (light map grey)
    final basePaint = Paint()..color = const Color(0xFFF1F3F5);
    canvas.drawRect(Offset.zero & size, basePaint);

    // 2. Water at bottom right (East River)
    final waterPaint = Paint()..color = const Color(0xFF9FD3FB);
    final waterPath = Path()
      ..moveTo(size.width * 0.72, size.height)
      ..lineTo(size.width, size.height * 0.28)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(waterPath, waterPaint);

    // Shoreline accent / FDR highway yellow edge line
    final fdrYellowPaint = Paint()
      ..color = const Color(0xFFFCD34D)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.72, size.height),
      Offset(size.width, size.height * 0.28),
      fdrYellowPaint,
    );

    // FDR Road border (white line)
    final fdrRoadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.70, size.height),
      Offset(size.width, size.height * 0.26),
      fdrRoadPaint,
    );

    // 3. Green park patches
    final parkPaint = Paint()..color = const Color(0xFFDCFCE7);

    // Park 1 (top-left edge)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-6, -4, size.width * 0.20, size.height * 0.35),
        const Radius.circular(6),
      ),
      parkPaint,
    );

    // Park 2 (mid right)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.46, size.height * 0.58, 22, 16),
        const Radius.circular(4),
      ),
      parkPaint,
    );

    // Park 3 (bottom right near FDR)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.58, size.height * 0.74, 18, 14),
        const Radius.circular(4),
      ),
      parkPaint,
    );

    // 4. Angled street grid lines in white
    final avenuePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.square;

    final crossStreetPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.square;

    // Avenues (running from bottom-left to top-center/right)
    canvas.drawLine(
      Offset(-10, size.height * 0.50),
      Offset(size.width * 0.45, -10),
      avenuePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.15, size.height + 10),
      Offset(size.width * 0.75, -10),
      avenuePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.42, size.height + 10),
      Offset(size.width * 1.05, -10),
      avenuePaint,
    );

    // Cross streets (running perpendicular from top-left to bottom-right)
    canvas.drawLine(
      Offset(-10, size.height * 0.15),
      Offset(size.width * 0.85, size.height + 10),
      crossStreetPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.08, -10),
      Offset(size.width * 0.95, size.height * 0.78),
      crossStreetPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.35, -10),
      Offset(size.width * 1.10, size.height * 0.60),
      crossStreetPaint,
    );

    // 5. Street Labels rotated along roads
    _drawAngledText(
      canvas,
      'Madison Ave',
      Offset(size.width * 0.06, size.height * 0.36),
      -0.72,
    );
    _drawAngledText(
      canvas,
      'E 86th St',
      Offset(size.width * 0.38, size.height * 0.16),
      0.70,
    );
    _drawAngledText(
      canvas,
      '1st Ave',
      Offset(size.width * 0.55, size.height * 0.38),
      -0.72,
    );
    _drawAngledText(
      canvas,
      'FDR Dr',
      Offset(size.width * 0.74, size.height * 0.78),
      -0.72,
    );
    _drawAngledText(canvas, 'nd St', Offset(-2, size.height * 0.82), 0.70);
  }

  void _drawAngledText(
    Canvas canvas,
    String text,
    Offset position,
    double radians,
  ) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(radians);

    final textSpan = TextSpan(
      text: text,
      style: GoogleFonts.inter(
        color: const Color(0xFF64748B),
        fontSize: 7.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    );

    final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset.zero);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
