import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';
import 'package:iwitnez/feature/main_user/SafetyTracking/model/safe_place_model.dart';
import 'package:iwitnez/feature/main_user/SafetyTracking/provider/safety_tracking_provider.dart';
import 'package:iwitnez/feature/main_user/SafetyTracking/widget/safe_place_saved_bottom_sheet.dart';
import 'package:iwitnez/router/app_route_names.dart';

class AddSafePlaceScreen extends ConsumerStatefulWidget {
  const AddSafePlaceScreen({super.key});

  @override
  ConsumerState<AddSafePlaceScreen> createState() => _AddSafePlaceScreenState();
}

class _AddSafePlaceScreenState extends ConsumerState<AddSafePlaceScreen> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();

  int _selectedIconIndex = 0;
  int _selectedRadius = 150;
  double _zoomLevel = 1.0;

  static const List<IconData> _icons = [
    Icons.home_rounded,
    Icons.business_center_rounded,
    Icons.school_rounded,
    Icons.favorite_rounded,
    Icons.star_rounded,
  ];

  static const List<SafePlaceType> _placeTypes = [
    SafePlaceType.home,
    SafePlaceType.work,
    SafePlaceType.university,
    SafePlaceType.favorite,
    SafePlaceType.star,
  ];

  static const List<int> _radiusOptions = [50, 100, 150, 200, 300, 500];

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final rawName = _nameController.text.trim();
    final location = _locationController.text.trim();

    final defaultTitles = [
      'Home',
      'Work',
      'University',
      'Favorite Place',
      'Safe Place',
    ];
    final title = rawName.isNotEmpty
        ? rawName
        : defaultTitles[_selectedIconIndex.clamp(0, defaultTitles.length - 1)];

    final selectedType =
        _placeTypes[_selectedIconIndex.clamp(0, _placeTypes.length - 1)];

    final newPlace = SafePlaceModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      address: location.isEmpty ? '1200 Park Ave, New York, NY' : location,
      isInside: false,
      type: selectedType,
      customIcon: _icons[_selectedIconIndex],
      radius: _selectedRadius,
    );

    ref.read(safetyTrackingProvider.notifier).addSafePlace(newPlace);

    // Show Bottom Sheet confirmation
    await SafePlaceSavedBottomSheet.show(context, place: newPlace);

    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRouteNames.safetyTrackingScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
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
        centerTitle: true,
        title: Text(
          'Add Safe place',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header subtitles
              Center(
                child: Column(
                  children: [
                    Text(
                      'Add a place where you feel safe.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "You'll get alerts when you arrive or leave.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // 1. Place Name Card
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
                padding: EdgeInsets.all(14.r),
                child: Row(
                  children: [
                    // Icon container
                    Container(
                      width: 44.r,
                      height: 44.r,
                      decoration: BoxDecoration(
                        color: _placeTypes[_selectedIconIndex].backgroundColor,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        _icons[_selectedIconIndex],
                        color: _placeTypes[_selectedIconIndex].iconColor,
                        size: 22.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),

                    // Inputs
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '1. Place Name',
                            style: GoogleFonts.inter(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Container(
                            height: 40.h,
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: TextField(
                              controller: _nameController,

                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                color: const Color(0xFF111827),
                              ),
                              decoration: InputDecoration(
                                hintText: 'e.g. Home, Office, Gym',
                                hintStyle: GoogleFonts.inter(
                                  fontSize: 12.5.sp,
                                  color: const Color(0xFF9CA3AF),
                                ),

                                focusedBorder: InputBorder.none,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.h,
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
              SizedBox(height: 18.h),

              // 2. Location
              Text(
                '2. Location',
                style: GoogleFonts.inter(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
              SizedBox(height: 8.h),

              // Search or enter address box
              Container(
                height: 46.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Row(
                  children: [
                    Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E8FF),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.location_on_outlined,
                        color: const Color(0xFF8B5CF6),
                        size: 18.sp,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: TextField(
                        controller: _locationController,
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          color: const Color(0xFF111827),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search or enter an address',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 12.5.sp,
                            color: const Color(0xFF6B7280),
                          ),
                          focusedBorder: InputBorder.none,
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),

              // Map Preview with Live Tracking Map Image
              Container(
                height: 195.h,
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
                    // Base Map Image
                    Positioned.fill(
                      child: ClipRect(
                        child: Transform.scale(
                          scale: _zoomLevel,
                          child: Image.asset(
                            ImageAssets.liveTrackingMap,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    // Center Radius Halo and Pin
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer Radius Halo
                          Container(
                            width: (70 + _selectedRadius * 0.35).r,
                            height: (70 + _selectedRadius * 0.35).r,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF8B5CF6,
                              ).withValues(alpha: 0.16),
                              shape: BoxShape.circle,
                            ),
                          ),
                          // Inner Radius Halo
                          Container(
                            width: (45 + _selectedRadius * 0.20).r,
                            height: (45 + _selectedRadius * 0.20).r,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF8B5CF6,
                              ).withValues(alpha: 0.24),
                              shape: BoxShape.circle,
                            ),
                          ),
                          // Center Purple Map Pin
                          Padding(
                            padding: EdgeInsets.only(bottom: 14.h),
                            child: Icon(
                              Icons.location_on_rounded,
                              size: 34.sp,
                              color: const Color(0xFF8B5CF6),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Right Floating Controls
                    Positioned(
                      right: 12.w,
                      top: 12.h,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Target button
                          _buildMapMiniButton(
                            icon: Icons.my_location_rounded,
                            onTap: () {
                              setState(() => _zoomLevel = 1.0);
                            },
                          ),
                          SizedBox(height: 8.h),
                          // Layers button
                          _buildMapMiniButton(
                            icon: Icons.layers_rounded,
                            onTap: () {},
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
                                  color: Colors.black.withValues(alpha: 0.08),
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
                                    setState(() {
                                      _zoomLevel = (_zoomLevel + 0.15).clamp(
                                        0.7,
                                        1.8,
                                      );
                                    });
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
                                    setState(() {
                                      _zoomLevel = (_zoomLevel - 0.15).clamp(
                                        0.7,
                                        1.8,
                                      );
                                    });
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
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
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

                    // Radius Dropdown Pill
                    PopupMenuButton<int>(
                      initialValue: _selectedRadius,
                      onSelected: (val) {
                        setState(() => _selectedRadius = val);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      itemBuilder: (context) {
                        return _radiusOptions.map((radius) {
                          return PopupMenuItem<int>(
                            value: radius,
                            child: Text(
                              '$radius m',
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                fontWeight: _selectedRadius == radius
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: _selectedRadius == radius
                                    ? const Color(0xFF8B5CF6)
                                    : const Color(0xFF111827),
                              ),
                            ),
                          );
                        }).toList();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$_selectedRadius m',
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18.sp,
                              color: const Color(0xFF6B7280),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18.h),

              // 3. Choose an Icon (optional)
              Row(
                children: [
                  Text(
                    '3. Choose an Icon',
                    style: GoogleFonts.inter(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    '(optional)',
                    style: GoogleFonts.inter(
                      fontSize: 11.5.sp,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Icons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (int i = 0; i < _icons.length; i++)
                    _buildIconOption(
                      icon: _icons[i],
                      isSelected: _selectedIconIndex == i,
                      onTap: () {
                        setState(() => _selectedIconIndex = i);
                      },
                    ),
                ],
              ),
              SizedBox(height: 28.h),

              // Save Safe Place Button
              Container(
                width: double.infinity,
                height: 52.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26.r),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF7E22CE), // Purple
                      Color(0xFF2563EB), // Blue
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7E22CE).withValues(alpha: 0.30),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(26.r),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(26.r),
                    onTap: _onSave,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 22.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Save Safe place',
                          style: GoogleFonts.inter(
                            fontSize: 15.5.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapMiniButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 34.r,
      height: 34.r,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
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
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(
            child: Icon(icon, color: const Color(0xFF8B5CF6), size: 18.sp),
          ),
        ),
      ),
    );
  }

  Widget _buildIconOption({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 52.r,
            height: 52.r,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF7E22CE)
                    : const Color(0xFFE5E7EB),
                width: isSelected ? 2.2.w : 1.w,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                color: isSelected
                    ? const Color(0xFF7E22CE)
                    : const Color(0xFF94A3B8),
                size: 24.sp,
              ),
            ),
          ),
          if (isSelected)
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 18.r,
                height: 18.r,
                decoration: const BoxDecoration(
                  color: Color(0xFF7E22CE),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(Icons.check, color: Colors.white, size: 12.sp),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
