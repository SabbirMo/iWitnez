import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iwitnez/feature/main_user/LiveLocation/model/live_sharing_model.dart';
import 'package:iwitnez/feature/main_user/LiveLocation/provider/live_location_screen_provider.dart';
import 'package:iwitnez/feature/main_user/LiveLocation/widget/map_marker_helper.dart';

class LiveLocationMapView extends ConsumerStatefulWidget {
  final MapType mapType;
  final void Function(GoogleMapController controller)? onMapCreated;
  final void Function(SharingPersonModel person)? onPersonPinTap;

  const LiveLocationMapView({
    super.key,
    this.mapType = MapType.normal,
    this.onMapCreated,
    this.onPersonPinTap,
  });

  @override
  ConsumerState<LiveLocationMapView> createState() =>
      _LiveLocationMapViewState();
}

class _LiveLocationMapViewState extends ConsumerState<LiveLocationMapView> {
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};

  @override
  void initState() {
    super.initState();
    _buildMapElements();
  }

  Future<void> _buildMapElements() async {
    final state = ref.read(liveLocationScreenProvider);
    final markers = <Marker>{};
    final circles = <Circle>{};

    // 1. User's own live location marker (only shown when sharing is active)
    if (state.isSharing &&
        state.userLatitude != null &&
        state.userLongitude != null) {
      final userLatLng = LatLng(state.userLatitude!, state.userLongitude!);
      final userIcon = await MapMarkerHelper.createUserDotIcon();

      markers.add(
        Marker(
          markerId: const MarkerId('user_live_location'),
          position: userLatLng,
          icon: userIcon,
          anchor: const Offset(0.5, 0.5),
          zIndexInt: 999,
          infoWindow: InfoWindow(
            title: '${state.userName ?? "You"} (Live)',
            snippet: state.userAddress ?? 'Sharing location',
          ),
        ),
      );
    }

    // 2. Contacts markers (placed at their real GPS coordinates while sharing is active)
    if (state.isSharing) {
      final contacts = state.contacts.where((c) => c.id != 'self').toList();
      for (final contact in contacts) {
        if (contact.latitude != null && contact.longitude != null) {
          final avatarIcon = await MapMarkerHelper.createAvatarMarker(
            name: contact.name,
            avatarUrl: contact.imageUrl,
            fallbackColor: contact.fallbackColor,
            isLive: contact.isLive,
          );

          markers.add(
            Marker(
              markerId: MarkerId(contact.id),
              position: LatLng(contact.latitude!, contact.longitude!),
              icon: avatarIcon,
              anchor: const Offset(0.5, 0.5),
              zIndexInt: 10,
              infoWindow: InfoWindow(
                title: contact.name,
                snippet: contact.subtitle,
              ),
              onTap: () => widget.onPersonPinTap?.call(contact),
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
        _circles
          ..clear()
          ..addAll(circles);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Re-build markers whenever location coordinates or contacts update
    ref.listen<LiveLocationScreenState>(liveLocationScreenProvider, (
      previous,
      next,
    ) {
      if (previous?.userLatitude != next.userLatitude ||
          previous?.userLongitude != next.userLongitude ||
          previous?.contacts != next.contacts ||
          previous?.isSharing != next.isSharing) {
        _buildMapElements();
      }
    });

    final state = ref.watch(liveLocationScreenProvider);
    final hasCoords = state.userLatitude != null && state.userLongitude != null;

    if (!hasCoords) {
      return Container(
        color: const Color(0xFFF8FAFC),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state.isLoading)
                const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B2CF5)),
                )
              else
                Icon(
                  Icons.location_off_rounded,
                  size: 32.sp,
                  color: const Color(0xFF94A3B8),
                ),
              SizedBox(height: 12.h),
              Text(
                state.isLoading
                    ? 'Loading live location...'
                    : 'Location coordinates not available',
                style: GoogleFonts.inter(
                  color: const Color(0xFF64748B),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final userLatLng = LatLng(state.userLatitude!, state.userLongitude!);

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: userLatLng, zoom: 15.0),
      mapType: widget.mapType,
      padding: EdgeInsets.only(bottom: 110.h),
      markers: _markers,
      circles: _circles,
      onMapCreated: (controller) {
        widget.onMapCreated?.call(controller);
      },
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
      rotateGesturesEnabled: true,
      tiltGesturesEnabled: true,
      scrollGesturesEnabled: true,
      zoomGesturesEnabled: true,
    );
  }
}
