import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/material.dart';

import '../scheduler.dart';

class DottedLine extends StatelessWidget {
  final bool isVerticalFlow;
  final double dotSize;
  final double width;
  final double height;
  final Color? color;
  const DottedLine(
      {Key? key,
      required this.isVerticalFlow,
      this.dotSize = 0.75,
      this.color,
      this.width = 0.75,
      this.height = 0.75,
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    SchedulerSettings schedulerSettings =
        Scheduler.of(context).schedulerSettings;
    return Container(
        width: width,
        height: height,
        decoration: DottedDecoration(
            dash: const [1, 2],
            color: color ?? schedulerSettings.getIntervalLineColor(context),
            strokeWidth: dotSize,
            shape: Shape.line,
            linePosition: isVerticalFlow ? LinePosition.top : LinePosition.left));
  }
}
