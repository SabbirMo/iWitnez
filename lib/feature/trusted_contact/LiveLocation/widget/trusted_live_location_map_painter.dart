import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TrustedLiveLocationMapPainter extends CustomPainter {
  final double zoom;

  const TrustedLiveLocationMapPainter({this.zoom = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Base land ground
    final basePaint = Paint()..color = const Color(0xFFF1F3F5);
    canvas.drawRect(Offset.zero & size, basePaint);

    // 2. East River (water on bottom right)
    final waterPaint = Paint()..color = const Color(0xFF9FD3FB);
    final waterPath = Path()
      ..moveTo(size.width * 0.72, size.height)
      ..lineTo(size.width, size.height * 0.45)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(waterPath, waterPaint);

    // Shoreline yellow highway line (FDR Dr)
    final fdrYellowPaint = Paint()
      ..color = const Color(0xFFFCD34D)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.72, size.height),
      Offset(size.width, size.height * 0.45),
      fdrYellowPaint,
    );

    // FDR Road border (white line)
    final fdrRoadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.70, size.height),
      Offset(size.width, size.height * 0.43),
      fdrRoadPaint,
    );

    // 3. Green park patches
    final parkPaint = Paint()..color = const Color(0xFFDCFCE7);

    // Top-left Central Park edge
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-10, -10, size.width * 0.28, size.height * 0.18),
        const Radius.circular(8),
      ),
      parkPaint,
    );

    // Mid-left park (between Park & Madison)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.08, size.height * 0.24, 34, 26),
        const Radius.circular(5),
      ),
      parkPaint,
    );

    // Mid-right park (near 1st Ave)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.62, size.height * 0.44, 28, 20),
        const Radius.circular(4),
      ),
      parkPaint,
    );

    // Lower right park
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.74, size.height * 0.50, 24, 18),
        const Radius.circular(4),
      ),
      parkPaint,
    );

    // 4. Angled street grid lines in white
    final avenuePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.square;

    final crossStreetPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.8
      ..strokeCap = StrokeCap.square;

    // Avenues (bottom-left to top-right)
    // Park Ave
    canvas.drawLine(
      Offset(-20, size.height * 0.46),
      Offset(size.width * 0.35, -20),
      avenuePaint,
    );
    // Madison Ave
    canvas.drawLine(
      Offset(size.width * 0.04, size.height * 0.70),
      Offset(size.width * 0.62, -20),
      avenuePaint,
    );
    // 3rd Ave
    canvas.drawLine(
      Offset(size.width * 0.28, size.height + 20),
      Offset(size.width * 0.88, -20),
      avenuePaint,
    );
    // 1st Ave
    canvas.drawLine(
      Offset(size.width * 0.50, size.height + 20),
      Offset(size.width * 1.10, -20),
      avenuePaint,
    );

    // Cross streets (top-left to bottom-right)
    // E 86th St
    canvas.drawLine(
      Offset(size.width * 0.20, -20),
      Offset(size.width * 1.05, size.height * 0.45),
      crossStreetPaint,
    );
    // E 79th St
    canvas.drawLine(
      Offset(-20, size.height * 0.16),
      Offset(size.width * 0.90, size.height * 0.68),
      crossStreetPaint,
    );
    // E 75th St (where the target is near)
    canvas.drawLine(
      Offset(-20, size.height * 0.35),
      Offset(size.width * 0.78, size.height * 0.88),
      crossStreetPaint,
    );
    // E 72nd St
    canvas.drawLine(
      Offset(-20, size.height * 0.52),
      Offset(size.width * 0.60, size.height + 20),
      crossStreetPaint,
    );

    // 5. Street Labels rotated along roads
    _drawAngledText(
      canvas,
      'Park Ave',
      Offset(size.width * 0.05, size.height * 0.36),
      -0.72,
    );
    _drawAngledText(
      canvas,
      'Madison Ave',
      Offset(size.width * 0.20, size.height * 0.38),
      -0.72,
    );
    _drawAngledText(
      canvas,
      'E 86th St',
      Offset(size.width * 0.58, size.height * 0.32),
      0.68,
    );
    _drawAngledText(
      canvas,
      '1st Ave',
      Offset(size.width * 0.72, size.height * 0.44),
      -0.72,
    );
    _drawAngledText(
      canvas,
      'E 72nd St',
      Offset(size.width * 0.16, size.height * 0.54),
      0.68,
    );
    _drawAngledText(
      canvas,
      'FDR Dr',
      Offset(size.width * 0.92, size.height * 0.52),
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
        fontSize: 8.5,
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
