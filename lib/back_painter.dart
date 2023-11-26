import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class BackPainter extends CustomPainter {
  BackPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.black);
    double step = 10;
    var offsetX = (size.width.round() % step.round()) / 2;
    offsetX = 0;
    for (double y = -1; y < size.height + step * 2; y += step) {
      for (double x = offsetX; x < size.width + step * 2; x += step) {
        canvas.drawCircle(
            Offset(x, y),
            5,
            Paint()
              ..style = PaintingStyle.fill
              ..color = Colors.white10);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
