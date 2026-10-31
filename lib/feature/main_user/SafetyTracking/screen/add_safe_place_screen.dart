import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/provider/home_provider.dart';
import 'package:iwitnez/feature/main_user/SafetyTracking/model/safe_place_model.dart';
import 'package:iwitnez/feature/main_user/SafetyTracking/provider/safety_tracking_provider.dart';
import 'package:iwitnez/feature/main_user/SafetyTracking/widget/safe_place_saved_bottom_sheet.dart';
import 'package:iwitnez/router/app_route_names.dart';

class LocationSuggestion {
  final String title;
  final String subtitle;
  final String fullAddress;
  final double latitude;
  final double longitude;

  const LocationSuggestion({
    required this.title,
    required this.subtitle,
    required this.fullAddress,
    required this.latitude,
    required this.longitude,
  });

  factory LocationSuggestion.fromJson(Map<String, dynamic> json) {
    final displayName = json['display_name'] as String? ?? '';
    final name = (json['name'] as String?)?.trim();
    final address = json['address'] as Map<String, dynamic>? ?? {};

    // Smart title determination
    final title = (name != null && name.isNotEmpty)
        ? name
        : (displayName.contains(',')
              ? displayName.split(',').first.trim()
              : displayName);

    // Smart clean subtitle: Road, Suburb, City, Division/State, Country
    final city =
        address['city'] ??
        address['town'] ??
        address['village'] ??
        address['county'] ??
        address['state_district'];
    final state = address['state'];
    final country = address['country'];
    final suburb = address['suburb'] ?? address['neighbourhood'];

    final subParts = <String>[];
    if (suburb != null && suburb.toString().trim() != title) {
      subParts.add(suburb.toString().trim());
    }
    if (city != null && city.toString().trim() != title) {
      subParts.add(city.toString().trim());
    }
    if (state != null && state.toString().trim() != city?.toString().trim()) {
      subParts.add(state.toString().trim());
    }
    if (country != null) {
      subParts.add(country.toString().trim());
    }

    final subtitle = subParts.isNotEmpty
        ? subParts.join(', ')
        : (displayName.contains(',')
              ? displayName.substring(displayName.indexOf(',') + 1).trim()
              : '');

    final lat = double.tryParse(json['lat']?.toString() ?? '') ?? 0.0;
    final lon = double.tryParse(json['lon']?.toString() ?? '') ?? 0.0;

    return LocationSuggestion(
      title: title,
      subtitle: subtitle,
      fullAddress: displayName.isNotEmpty ? displayName : title,
      latitude: lat,
      longitude: lon,
    );
  }
}

class AddSafePlaceScreen extends ConsumerStatefulWidget {
  final SafePlaceModel? placeToEdit;

  const AddSafePlaceScreen({super.key, this.placeToEdit});

  @override
  ConsumerState<AddSafePlaceScreen> createState() => _AddSafePlaceScreenState();
}

class _AddSafePlaceScreenState extends ConsumerState<AddSafePlaceScreen> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _geocoding = Geocoding();

  int _selectedIconIndex = 0;
  int _selectedRadius = 150;
  bool _isSaving = false;
  bool _isSearchingSuggestions = false;
  bool _showSuggestions = false;

  Timer? _debounceTimer;
  List<LocationSuggestion> _suggestions = [];

  GoogleMapController? _mapController;
  LatLng? _selectedLatLng;

  static const List<IconData> _icons = [
    Icons.home_rounded,
    Icons.business_center_rounded,
    Icons.school_rounded,
    Icons.favorite_rounded,
    Icons.star_rounded,
  ];

  static const List<String> _iconKeys = [
    'home',
    'work',
    'school',
    'heart',
    'star',
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
  void initState() {
    super.initState();
    final edit = widget.placeToEdit;
    if (edit != null) {
      _nameController.text = edit.title;
      _locationController.text = edit.address;
      _selectedRadius = edit.radius ?? 150;
      if (edit.latitude != null && edit.longitude != null) {
        _selectedLatLng = LatLng(edit.latitude!, edit.longitude!);
      }
      final key = (edit.iconString != null && edit.iconString!.isNotEmpty)
          ? edit.iconString!.toLowerCase().trim()
          : edit.type.iconKey;
      final foundIndex = _iconKeys.indexOf(key);
      if (foundIndex != -1) {
        _selectedIconIndex = foundIndex;
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _mapController?.dispose();
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  /// Triggered as user types in the location search field
  void _onLocationQueryChanged(String query) {
    _debounceTimer?.cancel();
    final trimmed = query.trim();

    if (trimmed.length < 2) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
        _isSearchingSuggestions = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 280), () {
      _fetchLocationSuggestions(trimmed);
    });
  }

  /// Fetches matching location suggestions via OpenStreetMap Nominatim with local BD priority and global support
  Future<void> _fetchLocationSuggestions(String query) async {
    setState(() {
      _isSearchingSuggestions = true;
      _showSuggestions = true;
    });

    try {
      final dio = Dio();
      final headers = {'User-Agent': 'iwitnez_app/1.0'};

      // Fetch prioritized local (Bangladesh) matches and global matches concurrently
      final responses = await Future.wait([
        dio
            .get(
              'https://nominatim.openstreetmap.org/search',
              queryParameters: {
                'q': query,
                'format': 'json',
                'limit': 6,
                'countrycodes': 'bd',
                'accept-language': 'en',
                'addressdetails': 1,
              },
              options: Options(
                headers: headers,
                receiveTimeout: const Duration(seconds: 4),
                sendTimeout: const Duration(seconds: 4),
              ),
            )
            .catchError(
              (_) => Response(requestOptions: RequestOptions(), data: []),
            ),
        dio
            .get(
              'https://nominatim.openstreetmap.org/search',
              queryParameters: {
                'q': query,
                'format': 'json',
                'limit': 6,
                'accept-language': 'en',
                'addressdetails': 1,
              },
              options: Options(
                headers: headers,
                receiveTimeout: const Duration(seconds: 4),
                sendTimeout: const Duration(seconds: 4),
              ),
            )
            .catchError(
              (_) => Response(requestOptions: RequestOptions(), data: []),
            ),
      ]);

      final List<Map<String, dynamic>> combined = [];
      final Set<String> seen = {};

      for (final res in responses) {
        if (res.data is List) {
          for (final item in (res.data as List)) {
            if (item is Map<String, dynamic>) {
              final lat = (item['lat']?.toString() ?? '');
              final lon = (item['lon']?.toString() ?? '');
              final key =
                  '${lat.length > 5 ? lat.substring(0, 5) : lat},${lon.length > 5 ? lon.substring(0, 5) : lon}';
              if (!seen.contains(key)) {
                seen.add(key);
                combined.add(item);
              }
            }
          }
        }
      }

      if (combined.isNotEmpty) {
        final list = combined
            .map((item) => LocationSuggestion.fromJson(item))
            .where((item) => item.latitude != 0.0 && item.longitude != 0.0)
            .toList();

        if (mounted) {
          setState(() {
            _suggestions = list;
            _isSearchingSuggestions = false;
          });
        }
        return;
      }
    } catch (_) {}

    // Fallback to native geocoder if network search returned nothing
    try {
      final locations = await _geocoding.locationFromAddress(query);
      if (locations.isNotEmpty) {
        final suggestions = <LocationSuggestion>[];
        for (final loc in locations.take(5)) {
          String addr = query;
          try {
            final placemarks = await _geocoding.placemarkFromCoordinates(
              loc.latitude,
              loc.longitude,
            );
            if (placemarks.isNotEmpty) {
              final p = placemarks.first;
              final parts = <String>[
                if (p.street != null && p.street!.trim().isNotEmpty) p.street!,
                if (p.subLocality != null && p.subLocality!.trim().isNotEmpty)
                  p.subLocality!,
                if (p.locality != null && p.locality!.trim().isNotEmpty)
                  p.locality!,
                if (p.country != null && p.country!.trim().isNotEmpty)
                  p.country!,
              ];
              if (parts.isNotEmpty) addr = parts.join(', ');
            }
          } catch (_) {}

          suggestions.add(
            LocationSuggestion(
              title: addr.split(',').first.trim(),
              subtitle: addr.contains(',')
                  ? addr.substring(addr.indexOf(',') + 1).trim()
                  : '',
              fullAddress: addr,
              latitude: loc.latitude,
              longitude: loc.longitude,
            ),
          );
        }

        if (mounted) {
          setState(() {
            _suggestions = suggestions;
            _isSearchingSuggestions = false;
          });
        }
        return;
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _suggestions = [];
        _isSearchingSuggestions = false;
      });
    }
  }

  /// User taps on a suggestion from the list
  void _onSelectSuggestion(LocationSuggestion suggestion) {
    FocusScope.of(context).unfocus();

    final targetLatLng = LatLng(suggestion.latitude, suggestion.longitude);

    setState(() {
      _showSuggestions = false;
      _suggestions = [];
      _locationController.text = suggestion.fullAddress;
      _selectedLatLng = targetLatLng;

      // If Place Name is empty, conveniently pre-fill with the short place title
      if (_nameController.text.trim().isEmpty) {
        _nameController.text = suggestion.title;
      }
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(targetLatLng, 16.0),
    );
  }

  /// Reverse-geocode coordinates when tapping directly on the map
  Future<void> _onMapTapped(LatLng latLng) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _showSuggestions = false;
      _selectedLatLng = latLng;
    });

    _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));

    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = <String>[
          if (p.street != null && p.street!.trim().isNotEmpty) p.street!,
          if (p.subLocality != null && p.subLocality!.trim().isNotEmpty)
            p.subLocality!,
          if (p.locality != null && p.locality!.trim().isNotEmpty) p.locality!,
          if (p.country != null && p.country!.trim().isNotEmpty) p.country!,
        ];

        if (parts.isNotEmpty) {
          final formatted = parts.join(', ');
          setState(() {
            _locationController.text = formatted;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _onSave() async {
    if (_isSaving) return;

    final rawName = _nameController.text.trim();
    final location = _locationController.text.trim();

    if (rawName.isEmpty && location.isEmpty && _selectedLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please search or select a location on the map'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final defaultTitles = [
      'Home',
      'Work',
      'School',
      'Favorite Place',
      'Safe Place',
    ];
    final title = rawName.isNotEmpty
        ? rawName
        : (location.isNotEmpty
              ? location.split(',').first.trim()
              : defaultTitles[_selectedIconIndex.clamp(
                  0,
                  defaultTitles.length - 1,
                )]);

    final selectedType =
        _placeTypes[_selectedIconIndex.clamp(0, _placeTypes.length - 1)];
    final iconKey =
        _iconKeys[_selectedIconIndex.clamp(0, _iconKeys.length - 1)];

    final lat = _selectedLatLng?.latitude ?? 0.0;
    final lng = _selectedLatLng?.longitude ?? 0.0;

    setState(() => _isSaving = true);

    // If in Edit Mode, update via PATCH /api/v1/location/safe-places/{id}/
    if (widget.placeToEdit != null) {
      final updated = await ref
          .read(safetyTrackingProvider.notifier)
          .updateSafePlace(
            widget.placeToEdit!.id,
            name: title,
            address: location,
            latitude: lat,
            longitude: lng,
            radiusMeters: _selectedRadius,
            icon: iconKey,
            alertsEnabled: true,
          );

      setState(() => _isSaving = false);

      final resultPlace =
          updated ??
          widget.placeToEdit!.copyWith(
            title: title,
            address: location,
            latitude: lat,
            longitude: lng,
            radius: _selectedRadius,
            iconString: iconKey,
            type: selectedType,
          );

      if (!mounted) return;
      if (context.canPop()) {
        context.pop(resultPlace);
      } else {
        context.go(AppRouteNames.safetyTrackingScreen);
      }
      return;
    }

    // Call Save Safe Place API: POST /api/v1/location/safe-places/
    final createdPlace = await ref
        .read(safetyTrackingProvider.notifier)
        .createSafePlace(
          name: title,
          address: location,
          latitude: lat,
          longitude: lng,
          radiusMeters: _selectedRadius,
          icon: iconKey,
          alertsEnabled: true,
        );

    setState(() => _isSaving = false);

    final placeToDisplay =
        createdPlace ??
        SafePlaceModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          address: location,
          latitude: lat,
          longitude: lng,
          radius: _selectedRadius,
          isInside: true,
          type: selectedType,
          iconString: iconKey,
          customIcon: _icons[_selectedIconIndex],
          statusDisplay: 'Inside',
        );

    // If server call didn't create it locally, add it to provider
    if (createdPlace == null) {
      ref.read(safetyTrackingProvider.notifier).addSafePlace(placeToDisplay);
    }

    if (!mounted) return;

    // Show SCREEN 5D: Safe Place Saved Modal
    await SafePlaceSavedBottomSheet.show(
      context,
      place: placeToDisplay,
      onRefresh: () {
        if (mounted) {
          ref.read(safetyTrackingProvider.notifier).fetchSafetyTracking();
        }
      },
    );

    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRouteNames.safetyTrackingScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeLoc = ref.watch(homeProvider).value?.liveLocation;
    final cameraLat = homeLoc?.latitude ?? 23.8103;
    final cameraLng = homeLoc?.longitude ?? 90.4125;

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
          widget.placeToEdit != null ? 'Edit Safe place' : 'Add Safe place',
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
                      widget.placeToEdit != null
                          ? 'Edit your safe place details and geofence.'
                          : 'Add a place where you feel safe.',
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
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: _showSuggestions
                        ? const Color(0xFF8B5CF6)
                        : const Color(0xFFE5E7EB),
                    width: _showSuggestions ? 1.4.w : 1.w,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
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
                        onChanged: _onLocationQueryChanged,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            _fetchLocationSuggestions(value.trim());
                          }
                        },
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
                    if (_isSearchingSuggestions)
                      SizedBox(
                        width: 18.r,
                        height: 18.r,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF8B5CF6),
                          ),
                        ),
                      )
                    else if (_locationController.text.isNotEmpty)
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          Icons.close_rounded,
                          color: const Color(0xFF94A3B8),
                          size: 20.sp,
                        ),
                        onPressed: () {
                          _locationController.clear();
                          setState(() {
                            _suggestions = [];
                            _showSuggestions = false;
                            _selectedLatLng = null;
                          });
                        },
                      )
                    else
                      Icon(
                        Icons.search_rounded,
                        color: const Color(0xFF8B5CF6),
                        size: 22.sp,
                      ),
                  ],
                ),
              ),

              // Suggestions Dropdown List
              if (_isSearchingSuggestions)
                Container(
                  margin: EdgeInsets.only(top: 6.h),
                  padding: EdgeInsets.symmetric(
                    vertical: 12.h,
                    horizontal: 14.w,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 15.r,
                        height: 15.r,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF8B5CF6),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'Searching matching locations...',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                )
              else if (_suggestions.isNotEmpty && _showSuggestions)
                Container(
                  margin: EdgeInsets.only(top: 6.h),
                  constraints: BoxConstraints(maxHeight: 220.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    itemCount: _suggestions.length,
                    separatorBuilder: (context, index) =>
                        Divider(color: const Color(0xFFF1F5F9), height: 1.h),
                    itemBuilder: (context, index) {
                      final item = _suggestions[index];
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _onSelectSuggestion(item),
                          borderRadius: BorderRadius.circular(8.r),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 10.h,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 28.r,
                                  height: 28.r,
                                  margin: EdgeInsets.only(top: 2.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3E8FF),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Icon(
                                    Icons.location_on_outlined,
                                    color: const Color(0xFF8B5CF6),
                                    size: 16.sp,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        item.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontSize: 13.5.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF111827),
                                        ),
                                      ),
                                      if (item.subtitle.isNotEmpty) ...[
                                        SizedBox(height: 2.h),
                                        Text(
                                          item.subtitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                            fontSize: 11.5.sp,
                                            color: const Color(0xFF6B7280),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 13.sp,
                                  color: const Color(0xFFCBD5E1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              SizedBox(height: 12.h),

              // Map Preview with Radius Geofence Circle Overlay
              Container(
                height: 225.h,
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
                    // Base Map: Interactive GoogleMap or graphic fallback
                    Positioned.fill(
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target:
                              _selectedLatLng ?? LatLng(cameraLat, cameraLng),
                          zoom: _selectedLatLng != null ? 15.5 : 13.5,
                        ),
                        gestureRecognizers:
                            <Factory<OneSequenceGestureRecognizer>>{
                              Factory<OneSequenceGestureRecognizer>(
                                () => EagerGestureRecognizer(),
                              ),
                            },
                        circles: _selectedLatLng != null
                            ? {
                                Circle(
                                  circleId: const CircleId('geofence_circle'),
                                  center: _selectedLatLng!,
                                  radius: _selectedRadius.toDouble(),
                                  fillColor: const Color(
                                    0xFF8B5CF6,
                                  ).withValues(alpha: 0.18),
                                  strokeColor: const Color(0xFF8B5CF6),
                                  strokeWidth: 2,
                                ),
                              }
                            : {},
                        markers: _selectedLatLng != null
                            ? {
                                Marker(
                                  markerId: const MarkerId('safe_place_target'),
                                  position: _selectedLatLng!,
                                  icon: BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueViolet,
                                  ),
                                ),
                              }
                            : {},
                        onMapCreated: (ctrl) {
                          _mapController = ctrl;
                          if (_selectedLatLng != null) {
                            ctrl.animateCamera(
                              CameraUpdate.newLatLngZoom(
                                _selectedLatLng!,
                                15.5,
                              ),
                            );
                          }
                        },
                        onTap: _onMapTapped,
                        zoomControlsEnabled: false,
                        myLocationButtonEnabled: false,
                        compassEnabled: false,
                        mapToolbarEnabled: false,
                      ),
                    ),

                    // Right Floating Controls
                    Positioned(
                      right: 12.w,
                      top: 12.h,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildMapMiniButton(
                            icon: Icons.my_location_rounded,
                            onTap: () {
                              if (homeLoc?.latitude != null &&
                                  homeLoc?.longitude != null) {
                                final myGps = LatLng(
                                  homeLoc!.latitude!,
                                  homeLoc.longitude!,
                                );
                                _onMapTapped(myGps);
                              }
                            },
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
                    onTap: _isSaving ? null : _onSave,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isSaving)
                          SizedBox(
                            width: 22.r,
                            height: 22.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        else ...[
                          Icon(
                            widget.placeToEdit != null
                                ? Icons.edit_outlined
                                : Icons.check_rounded,
                            color: Colors.white,
                            size: 22.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            widget.placeToEdit != null
                                ? 'Edit Safe place'
                                : 'Save Safe place',
                            style: GoogleFonts.inter(
                              fontSize: 15.5.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
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
