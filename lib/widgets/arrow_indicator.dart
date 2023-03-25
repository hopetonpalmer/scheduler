import 'package:flutter/material.dart';

class ArrowIndicator extends StatelessWidget {
  final Color color;
  final double height;
  final double width;
  final EdgeInsetsGeometry? margin;
  const ArrowIndicator(
      {Key? key,
      required this.color,
      required this.height,
      required this.width,
      this.margin})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        painter: RightArrowPainter(
          color,
        ),
        child: Container(margin: margin, height:height, width: width),
      ),
    );
  }
}

class RightArrowPainter extends CustomPainter {
  final Color arrowColor;
  RightArrowPainter(this.arrowColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = arrowColor
      ..style = PaintingStyle.fill;

    final path = Path();
  /*  path.moveTo(0, 0); // top-left point of the arrow
    path.lineTo(size.width * 0.75, size.height / 2); // right point of the triangle
    path.lineTo(0, size.height); // bottom-left point of the arrow
    path.lineTo(size.width * 0.25, size.height / 2); // middle-left point of the arrow
    path.close(); // connects the last point to the first point*/

    path.moveTo(0, 0); // top-left point of the arrow
    path.lineTo(size.width * 0.75, size.height / 2); // right point of the triangle
    path.lineTo(0, size.height); // bottom-left point of the arrow
    path.lineTo(0, size.height * 0.75); // middle-left bottom point of the arrow
    path.lineTo(0, size.height * 0.25); // middle-left top point of the arrow
    path.close(); // connects the last point to the first point

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
