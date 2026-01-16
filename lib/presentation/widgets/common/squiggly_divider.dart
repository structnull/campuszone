import 'package:campuszone/core/core.dart';
import 'package:flutter/material.dart';

class SquigglyDivider extends StatelessWidget {
  final double height;
  final double width;
  final Color color;

  const SquigglyDivider({
    super.key,
    this.height = 20.0,
    this.width = double.infinity,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _SquigglyLinePainter(color: color)),
    );
  }
}

class _SquigglyLinePainter extends CustomPainter {
  final Color color;
  _SquigglyLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;

    final Path path = Path();
    final double amplitude = 10;

    path.moveTo(0, size.height / 2);

    for (double x = 0; x <= size.width; x += 20) {
      double controlX = x + 10;
      double controlY =
          size.height / 2 + (x % 40 == 0 ? amplitude : -amplitude);
      double endX = x + 20;
      double endY = size.height / 2;
      path.quadraticBezierTo(controlX, controlY, endX, endY);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
