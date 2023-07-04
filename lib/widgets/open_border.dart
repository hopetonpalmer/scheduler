import 'dart:math';

import 'package:flutter/material.dart';

import '../services/ui_service.dart';
import 'sized_color_box.dart';

class OpenBorder extends StatelessWidget {
  final bool isActive;
  final BorderSide border;
  final Color color;
  final Widget child;
  final Size size;
  final Axis orientation;
  final bool isFirst;
  final bool isLast;
  const OpenBorder({
    super.key,
    required this.isFirst,
    required this.isLast,
    required this.orientation,
    required this.isActive,
    required this.size,
    required this.border,
    required this.color,
    required this.child,
  });

  final double thickness = 3.0;


  Alignment getMainAlignment() {
    return orientation == Axis.vertical ? isFirst ? Alignment.bottomCenter : Alignment.topCenter : isFirst ? Alignment.centerRight : Alignment.centerLeft;
  }

  Alignment getSideAlignment1() {
    return orientation == Axis.vertical ? isFirst ? Alignment.bottomLeft : Alignment.topLeft : isFirst ? Alignment.topRight : Alignment.topLeft;
  }

  Alignment getSideAlignment2() {
    return orientation == Axis.vertical ? isFirst ? Alignment.bottomRight : Alignment.topRight : isFirst ? Alignment.bottomRight : Alignment.bottomLeft;
  }


  @override
  Widget build(BuildContext context) {
    if (!isActive || (!isLast && !isFirst)) return child;

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          child,
          Align(
            alignment: getMainAlignment(),
            child: SizedColorBox(
              color: color,
              width: orientation == Axis.vertical ? size.width : thickness,
              height: orientation == Axis.vertical ? thickness : size.height,
            ),
          ),
          Align(
             alignment: getSideAlignment1(),
             child: SizedColorBox(
               color: border.color,
               width: orientation == Axis.vertical ? border.width : thickness,
               height: orientation == Axis.vertical ? thickness : border.width,
            ),
          ),
          Align(
            alignment: getSideAlignment2(),
            child: SizedColorBox(
              color: border.color,
              width: orientation == Axis.vertical ? border.width : thickness,
              height: orientation == Axis.vertical ? thickness : border.width,
            ),
          ),
        ],
      ),
    );

    return Stack(
      children: [
        child,
        Positioned(
          left: border.width,
          bottom: 0,
          child: Container(
            color: color,
            width: size.width,
            height: 3,
          ),
        ),
        Positioned(
          left: 0,
          bottom: 0,
          child: Container(
            color: border.color,
            width: border.width,
            height: 3,
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            color: border.color,
            width: border.width,
            height: 3,
          ),
        ),
      ],
    );
  }
}

