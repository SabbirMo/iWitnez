import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Vector Painter for the Full Screen Map with Manhattan Grid
class LiveLocationMapPainter extends CustomPainter {
  final double zoom;

  const LiveLocationMapPainter({required this.zoom});

  @override
  void paint(Canvas canvas, Size size) {
    // Base land ground
    final basePaint = Paint()..color = const Color(0xFFF1F3F5);
    canvas.drawRect(Offset.zero & size, basePaint);

    // East River (water on right)
    final waterPaint = Paint()..color = const Color(0xFF9FD3FB);
    final waterPath = Path()
      ..moveTo(size.width * 0.74, size.height)
      ..lineTo(size.width, size.height * 0.15)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(waterPath, waterPaint);

    // Shoreline yellow highway line (FDR Dr)
    final fdrYellowPaint = Paint()
      ..color = const Color(0xFFFCD34D)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.74, size.height),
      Offset(size.width, size.height * 0.15),
      fdrYellowPaint,
    );

    // FDR Road border (white line)
    final fdrRoadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.72, size.height),
      Offset(size.width, size.height * 0.13),
      fdrRoadPaint,
    );

    // Green park patches
    final parkPaint = Paint()..color = const Color(0xFFDCFCE7);

    // Park 1 (top-left / Central Park edge)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-10, -10, size.width * 0.22, size.height * 0.45),
        const Radius.circular(8),
      ),
      parkPaint,
    );

    // Park 2 (mid right)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.65, size.height * 0.30, 26, 20),
        const Radius.circular(4),
      ),
      parkPaint,
    );

    // Park 3 (bottom left)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.12, size.height * 0.68, 30, 22),
        const Radius.circular(5),
      ),
      parkPaint,
    );

    // Angled street grid lines in white
    final avenuePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.square;

    final crossStreetPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.square;

    // Avenues (bottom-left to top-right)
    canvas.drawLine(
      Offset(-20, size.height * 0.60),
      Offset(size.width * 0.55, -20),
      avenuePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.10, size.height + 20),
      Offset(size.width * 0.85, -20),
      avenuePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.38, size.height + 20),
      Offset(size.width * 1.15, -20),
      avenuePaint,
    );

    // Cross streets (top-left to bottom-right)
    canvas.drawLine(
      Offset(-20, size.height * 0.10),
      Offset(size.width * 0.90, size.height + 20),
      crossStreetPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.05, -20),
      Offset(size.width * 1.05, size.height * 0.85),
      crossStreetPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.35, -20),
      Offset(size.width * 1.20, size.height * 0.65),
      crossStreetPaint,
    );
    canvas.drawLine(
      Offset(-20, size.height * 0.40),
      Offset(size.width * 0.60, size.height + 20),
      crossStreetPaint,
    );

    // Street Labels rotated along roads
    _drawAngledText(
      canvas,
      'Park Ave',
      Offset(size.width * 0.02, size.height * 0.28),
      -0.72,
    );
    _drawAngledText(
      canvas,
      'Madison Ave',
      Offset(size.width * 0.18, size.height * 0.28),
      -0.72,
    );
    _drawAngledText(
      canvas,
      'E 86th St',
      Offset(size.width * 0.52, size.height * 0.22),
      0.70,
    );
    _drawAngledText(
      canvas,
      '1st Ave',
      Offset(size.width * 0.68, size.height * 0.32),
      -0.72,
    );
    _drawAngledText(
      canvas,
      'E 72nd St',
      Offset(size.width * 0.12, size.height * 0.58),
      0.70,
    );
    _drawAngledText(
      canvas,
      'FDR Dr',
      Offset(size.width * 0.82, size.height * 0.55),
      -0.72,
    );
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
        fontSize: 7.5,
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
  bool shouldRepaint(covariant LiveLocationMapPainter oldDelegate) =>
      oldDelegate.zoom != zoom;
}
