import 'package:flutter/material.dart';

class LoginBackgroundPainter extends CustomPainter {
  final Color primaryColor;
  final Color accentColor;

  LoginBackgroundPainter({required this.primaryColor, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [primaryColor, accentColor],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final circlePaint = Paint()..color = Colors.white.withAlpha((255 * 0.1).round());

    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.2), 50, circlePaint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.3), 80, circlePaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.8), 120, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}