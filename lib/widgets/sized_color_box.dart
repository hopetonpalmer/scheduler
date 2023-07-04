import 'package:flutter/material.dart';

class SizedColorBox extends StatelessWidget {
  final double? height;
  final double? width;
  final Color color;
  final Widget? child;
  const SizedColorBox({
    super.key,
    this.height,
    this.width,
    this.child,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ColoredBox(
        color: color,
        child: child,
      ),
    );
  }
}
