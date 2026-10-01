import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/feature/main_user/LiveLocation/model/live_sharing_model.dart';
import 'package:iwitnez/feature/main_user/LiveLocation/provider/live_location_screen_provider.dart';
import 'package:iwitnez/feature/main_user/LiveLocation/widget/live_location_map_painter.dart';

class LiveLocationMapView extends ConsumerWidget {
  final Animation<double> pulseAnimation;
  final void Function(SharingPersonModel person)? onPersonPinTap;

  const LiveLocationMapView({
    super.key,
    required this.pulseAnimation,
    this.onPersonPinTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(liveLocationScreenProvider);

    return Stack(
      children: [
        // Vector Map Canvas
        Positioned.fill(
          child: CustomPaint(
            painter: LiveLocationMapPainter(zoom: state.zoomLevel),
          ),
        ),

        // User Location (pulsing halo + vibrant blue circle)
        Positioned(
          left: 65.w,
          bottom: 50.h,
          child: AnimatedBuilder(
            animation: pulseAnimation,
            builder: (context, child) {
              final wave = pulseAnimation.value;
              return Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Outer expanding halo
                  Container(
                    width: (50 + wave * 24).r,
                    height: (50 + wave * 24).r,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(
                        alpha: (1.0 - wave) * 0.35,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                  // Static translucent ring
                  Container(
                    width: 44.r,
                    height: 44.r,
                    decoration: BoxDecoration(
                      color: const Color(0xFF93C5FD).withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                  ),
                  // Center solid blue pin
                  Container(
                    width: 24.r,
                    height: 24.r,
                    decoration: BoxDecoration(
                      color: const Color(0xFF007AFF),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3.w),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF007AFF,
                          ).withValues(alpha: 0.4),
                          blurRadius: 6,
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

        // Contact Pin 1: Sarah Khan (top left)
        Positioned(
          left: 42.w,
          top: 80.h,
          child: _buildMapPinAvatar(
            imageUrl:
                'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
            fallbackName: 'Sarah',
            fallbackColor: const Color(0xFFFDA4AF),
            onTap: () {
              final person = state.contacts.firstWhere(
                (p) => p.name.contains('Sarah'),
                orElse: () => state.contacts.first,
              );
              onPersonPinTap?.call(person);
            },
          ),
        ),

        // Contact Pin 2: Amit Sharma (top right)
        Positioned(
          right: 100.w,
          top: 90.h,
          child: _buildMapPinAvatar(
            imageUrl:
                'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
            fallbackName: 'Amit',
            fallbackColor: const Color(0xFF60A5FA),
            onTap: () {
              final person = state.contacts.firstWhere(
                (p) => p.name.contains('Amit'),
                orElse: () => state.contacts.first,
              );
              onPersonPinTap?.call(person);
            },
          ),
        ),

        // Contact Pin 3: Priya Patel (bottom right)
        Positioned(
          right: 90.w,
          bottom: 40.h,
          child: _buildMapPinAvatar(
            imageUrl:
                'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150',
            fallbackName: 'Priya',
            fallbackColor: const Color(0xFFFB923C),
            onTap: () {
              final person = state.contacts.firstWhere(
                (p) => p.name.contains('Priya'),
                orElse: () => state.contacts.first,
              );
              onPersonPinTap?.call(person);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMapPinAvatar({
    required String imageUrl,
    required String fallbackName,
    required Color fallbackColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.8.w),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
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
                        fallbackName[0],
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16.sp,
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
              width: 12.r,
              height: 12.r,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.w),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
