import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';
import 'package:iwitnez/feature/trusted_contact/LiveLocation/provider/get_directions_provider.dart';
import 'package:provider/provider.dart';

class GetDirectionsScreen extends StatelessWidget {
  const GetDirectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GetDirectionsProvider(),
      child: const _GetDirectionsView(),
    );
  }
}

class _GetDirectionsView extends StatefulWidget {
  const _GetDirectionsView();

  @override
  State<_GetDirectionsView> createState() => _GetDirectionsViewState();
}

class _GetDirectionsViewState extends State<_GetDirectionsView> {
  late final DraggableScrollableController _sheetController;

  @override
  void initState() {
    super.initState();
    _sheetController = DraggableScrollableController();

    _sheetController.addListener(() {
      if (mounted) {
        context.read<GetDirectionsProvider>().updateSheetExtent(
          _sheetController.size,
        );
      }
    });
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  void _toggleSheet(GetDirectionsProvider provider) {
    if (!_sheetController.isAttached) return;
    if (provider.currentSheetExtent < 0.3) {
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GetDirectionsProvider>();
    final selectedRoute = provider.selectedRoute;
    final isExpanded = provider.isSheetExpanded;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
            size: 32.sp,
            color: const Color(0xFF111827),
          ),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        centerTitle: true,
        title: Text(
          'Get Directions',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
      ),
      body: Stack(
        children: [
          // 1. Moveable & Zoomable Map Canvas (Pan in any direction with finger)
          Positioned.fill(
            child: ClipRect(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onScaleStart: provider.onScaleStart,
                onScaleUpdate: provider.onScaleUpdate,
                child: Transform.translate(
                  offset: provider.mapOffset,
                  child: Transform.scale(
                    scale: provider.zoomScale,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Base Live Tracking Map
                        Image.asset(
                          ImageAssets.liveTrackingMap,
                          fit: BoxFit.cover,
                        ),

                        // Aligned Traffic Route Overlay
                        Positioned(
                          left: 16.w,
                          right: 16.w,
                          top: 170.h,
                          bottom: 120.h,
                          child: IgnorePointer(
                            child: Image.asset(
                              ImageAssets.traffic,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. Floating Map Quick Controls (Recenter & Zoom in/out)
          Positioned(
            right: 16.w,
            top: 215.h,
            child: Column(
              children: [
                // Recenter to Route Button
                _buildCircleButton(
                  icon: Icons.my_location_rounded,
                  tooltip: 'Recenter route',
                  onTap: () {
                    provider.resetMap();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Centered on destination route'),
                        duration: Duration(milliseconds: 1000),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                SizedBox(height: 10.h),

                // Zoom In / Zoom Out Controls Pill
                Container(
                  width: 38.r,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(19.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: provider.zoomIn,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(19.r),
                        ),
                        child: SizedBox(
                          height: 36.h,
                          child: Center(
                            child: Icon(
                              Icons.add,
                              size: 20.sp,
                              color: const Color(0xFF4B5563),
                            ),
                          ),
                        ),
                      ),
                      const Divider(
                        height: 1,
                        thickness: 0.8,
                        color: Color(0xFFE5E7EB),
                      ),
                      InkWell(
                        onTap: provider.zoomOut,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(19.r),
                        ),
                        child: SizedBox(
                          height: 36.h,
                          child: Center(
                            child: Icon(
                              Icons.remove,
                              size: 20.sp,
                              color: const Color(0xFF4B5563),
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

          // 3. Top Floating Location Card & Transport Mode Selector
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 14.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Origin / Destination Box
                  _buildLocationsBox(provider),
                  SizedBox(height: 12.h),

                  // Mode of Transport Selector
                  _buildTransportModesRow(provider),
                ],
              ),
            ),
          ),

          // 4. Draggable Pull-Up Bottom Sheet for Route Options
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.13,
            minChildSize: 0.11,
            maxChildSize: 0.65,
            snap: true,
            snapSizes: const [0.13, 0.65],
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(22.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Drag Handle (Tap or pull to expand/collapse)
                        Center(
                          child: GestureDetector(
                            onTap: () => _toggleSheet(provider),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              width: 44.w,
                              height: 5.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD0D5DD),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),

                        // Selected Route Compact Teaser Header
                        GestureDetector(
                          onTap: () => _toggleSheet(provider),
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                            children: [
                              // Car Icon Badge
                              Container(
                                width: 38.r,
                                height: 38.r,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF4F3FF),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.directions_car_rounded,
                                  color: const Color(0xFF7F56D9),
                                  size: 20.sp,
                                ),
                              ),
                              SizedBox(width: 10.w),

                              // Quick Summary Text
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          selectedRoute.duration,
                                          style: GoogleFonts.inter(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF111827),
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          '• ${selectedRoute.distance}',
                                          style: GoogleFonts.inter(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF667085),
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 6.w,
                                            vertical: 2.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: selectedRoute.trafficColor
                                                .withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(
                                              6.r,
                                            ),
                                          ),
                                          child: Text(
                                            selectedRoute.trafficStatus,
                                            style: GoogleFonts.inter(
                                              fontSize: 10.5.sp,
                                              fontWeight: FontWeight.w600,
                                              color: selectedRoute.trafficColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      isExpanded
                                          ? 'Tap to collapse'
                                          : 'Pull up for ${provider.routes.length} route choices & start',
                                      style: GoogleFonts.inter(
                                        fontSize: 11.5.sp,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF7F56D9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Up / Down Arrow Toggle
                              Container(
                                padding: EdgeInsets.all(6.r),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF9FAFB),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_down_rounded
                                      : Icons.keyboard_arrow_up_rounded,
                                  color: const Color(0xFF667085),
                                  size: 22.sp,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Expanded Section (Recommended Routes & Start Button)
                        SizedBox(height: 16.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Select Route',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF344054),
                              ),
                            ),
                            Text(
                              '${provider.routes.length} routes found',
                              style: GoogleFonts.inter(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF667085),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),

                        // Route Cards List
                        for (int i = 0; i < provider.routes.length; i++) ...[
                          if (i > 0) SizedBox(height: 10.h),
                          _buildRouteCard(
                            index: i,
                            route: provider.routes[i],
                            isSelected: provider.selectedRouteIndex == i,
                            onTap: () => provider.selectRoute(i),
                          ),
                        ],
                        SizedBox(height: 16.h),

                        // Start Navigation Button
                        _buildStartNavigationButton(context),
                        SizedBox(height: 10.h),
                      ],
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
    return Container(
      width: 38.r,
      height: 38.r,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
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
            child: Icon(icon, size: 20.sp, color: const Color(0xFF4B5563)),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationsBox(GetDirectionsProvider provider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(width: 1.w, color: const Color(0xFFF2F4F7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFF8B2CF5),
                    width: 2.5.w,
                  ),
                ),
              ),
              Container(
                width: 1.5.w,
                height: 28.h,
                color: const Color(0xFFD0D5DD),
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
                // Origin
                Text(
                  provider.originTitle,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  provider.originSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF667085),
                  ),
                ),
                SizedBox(height: 12.h),

                // Destination
                Text(
                  provider.destinationTitle,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  provider.destinationSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF667085),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),

          // Swap Icon
          InkWell(
            onTap: () {
              provider.swapLocations();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Swapped origin and destination'),
                  duration: Duration(milliseconds: 1000),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.all(6.r),
              child: Icon(
                Icons.swap_vert_rounded,
                color: const Color(0xFF667085),
                size: 22.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportModesRow(GetDirectionsProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(provider.transportModes.length, (index) {
        final mode = provider.transportModes[index];
        final isSelected = provider.selectedTransportIndex == index;

        const activeColor = Color(0xFF7F56D9);
        const inactiveColor = Color(0xFF667085);

        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            child: InkWell(
              onTap: () => provider.selectTransport(index),
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFF4F3FF) : Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: isSelected
                        ? activeColor.withValues(alpha: 0.35)
                        : const Color(0xFFF2F4F7),
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
                    Text(
                      mode.duration,
                      textAlign: TextAlign.center,
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

  Widget _buildStartNavigationButton(BuildContext context) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Starting turn-by-turn navigation...'),
            duration: Duration(milliseconds: 1500),
            behavior: SnackBarBehavior.floating,
          ),
        );
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
    required RouteOption route,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final borderColor = isSelected
        ? const Color(0xFF7F56D9)
        : const Color(0xFFF2F4F7);
    final iconBg = isSelected
        ? const Color(0xFFF4F3FF)
        : const Color(0xFFF9FAFB);
    final iconColor = isSelected
        ? const Color(0xFF7F56D9)
        : const Color(0xFF667085);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            width: isSelected ? 1.5.w : 1.w,
            color: borderColor,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF7F56D9).withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Mode Icon
            Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(
                Icons.directions_car_rounded,
                color: iconColor,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),

            // Route Details
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
                      color: const Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${route.distance} • ${route.routeType}',
                    style: GoogleFonts.inter(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF667085),
                    ),
                  ),
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
              ),
            ),
            SizedBox(width: 8.w),

            // Right Curve Sparkline & Chevron
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomPaint(
                  size: Size(36.w, 14.h),
                  painter: _MiniRouteCurvePainter(
                    color: isSelected
                        ? const Color(0xFF7F56D9)
                        : const Color(0xFF98A2B3),
                    isCurved: route.hasCurve,
                  ),
                ),
                SizedBox(width: 6.w),
                Icon(
                  Icons.chevron_right_rounded,
                  color: const Color(0xFF98A2B3),
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

/// Mini elevation/traffic curve painter for route cards
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
