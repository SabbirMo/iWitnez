import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarkerHelper {
  static final Map<String, BitmapDescriptor> _cache = {};

  /// Creates a clean, standard-sized glowing blue dot marker for the user
  static Future<BitmapDescriptor> createUserDotIcon() async {
    const cacheKey = 'user_dot_icon_compact_v3';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = 48.0;
    const center = Offset(size / 2, size / 2);

    // 1. Subtle outer soft glow
    final outerHaloPaint = Paint()
      ..color = const Color(0xFF007AFF).withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 22.0, outerHaloPaint);

    // 2. Translucent ring
    final midRingPaint = Paint()
      ..color = const Color(0xFF93C5FD).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 15.0, midRingPaint);

    // 3. Drop shadow for crisp elevation
    final shadowPaint = Paint()
      ..color = const Color(0x30000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    canvas.drawCircle(const Offset(size / 2, size / 2 + 1.0), 10.0, shadowPaint);

    // 4. White border ring
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 9.5, borderPaint);

    // 5. Vibrant blue core
    final corePaint = Paint()
      ..color = const Color(0xFF007AFF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 7.0, corePaint);

    // 6. Center specular gloss
    final glossPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(size / 2 - 2, size / 2 - 2), 2.0, glossPaint);

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      final icon = BitmapDescriptor.bytes(byteData.buffer.asUint8List());
      _cache[cacheKey] = icon;
      return icon;
    }
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
  }

  /// Creates a circular profile avatar marker with green online live dot for contacts
  static Future<BitmapDescriptor> createAvatarMarker({
    required String name,
    String? avatarUrl,
    Color fallbackColor = const Color(0xFF8B2CF5),
    bool isLive = true,
  }) async {
    final cacheKey = 'avatar_${name}_${avatarUrl ?? ''}_$isLive';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    const size = 70.0;
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
      final icon = BitmapDescriptor.bytes(byteData.buffer.asUint8List());
      _cache[cacheKey] = icon;
      return icon;
    }
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose);
  }
}
