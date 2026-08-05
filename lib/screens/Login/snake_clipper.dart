import 'package:flutter/material.dart';

class SnakeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.85);
    final amplitude = 30.0;
    final wavelength = size.width / 4;
    for (double x = 0; x <= size.width; x += wavelength) {
      path.quadraticBezierTo(
        x + wavelength / 4,
        size.height * 0.85 +
            (x ~/ wavelength % 2 == 0 ? amplitude : -amplitude),
        x + wavelength / 2,
        size.height * 0.85,
      );
    }
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class MultipleSnakePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final baseColor = Color.fromARGB(255, 81, 111, 81);
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 20
          ..strokeCap = StrokeCap.round;

    double amplitude = 50;
    double wavelength = size.width / 5;
    int numberOfSnakes = 6;
    double startY = size.height * 0.55 + 20;
    double verticalSpacing = (size.height - startY) / numberOfSnakes;

    for (int i = 0; i < numberOfSnakes; i++) {
      double opacity = 0.15 + (i * 0.12);
      Color currentColor = baseColor.withOpacity(opacity.clamp(0, 0.5));
      paint.color = currentColor;
      final path = Path();
      double yCenter = startY + i * verticalSpacing;
      path.moveTo(0, yCenter);
      for (double x = 0; x <= size.width; x += wavelength) {
        path.quadraticBezierTo(
          x + wavelength / 4,
          yCenter + amplitude,
          x + wavelength / 2,
          yCenter,
        );
        path.quadraticBezierTo(
          x + 3 * wavelength / 4,
          yCenter - amplitude,
          x + wavelength,
          yCenter,
        );
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
