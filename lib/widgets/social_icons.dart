import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Brand icons for the social sign-in buttons, drawn in code
/// (no image assets): the four-colour Google "G" and the
/// Facebook "f" badge.
class GoogleIcon extends StatelessWidget {
  const GoogleIcon({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _GoogleGPainter());
  }
}

class _GoogleGPainter extends CustomPainter {
  static const _blue = Color(0xFF4285F4);
  static const _red = Color(0xFFEA4335);
  static const _yellow = Color(0xFFFBBC05);
  static const _green = Color(0xFF34A853);

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.30;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    void arc(Color color, double startDeg, double sweepDeg) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        rect,
        startDeg * math.pi / 180,
        sweepDeg * math.pi / 180,
        false,
        paint,
      );
    }

    // Four colour segments of the G (0 deg = right, clockwise).
    arc(_red, 185, 115); // left -> top -> upper right
    arc(_blue, 300, 120); // the right side, where the bar sits
    arc(_green, 60, 55); // bottom right -> bottom
    arc(_yellow, 115, 70); // bottom -> lower left

    // The horizontal bar of the G.
    final barHeight = strokeWidth * 0.98;
    final barPaint = Paint()..color = _blue;
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx - strokeWidth * 0.2,
        center.dy - barHeight / 2,
        size.width / 2 + strokeWidth * 0.2,
        barHeight,
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// The Facebook badge: white "f" on the brand-blue circle.
class FacebookIcon extends StatelessWidget {
  const FacebookIcon({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFF1877F2),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        'f',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.78,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}
