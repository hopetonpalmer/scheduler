import 'package:flutter/material.dart';
import 'package:scheduler/scheduler.dart';
import 'package:scheduler/services/scheduler_service.dart';
import 'package:scheduler/widgets/date_header.dart';
import 'package:scheduler/widgets/time_cell/time_cell.dart';

class TimeSlotGrid extends StatelessWidget {
  final IntervalType intervalType;
  final List<DateTime> gridDates;
  final Axis direction;
  final int colCount;
  final int rowCount;
  final Size cellSize;
  final HeaderPosition headerPosition;
  final Size headerSize;
  final int slotsPerTimeBlock;
  const TimeSlotGrid({
    Key? key,
    required this.headerSize,
    required this.headerPosition,
    required this.cellSize,
    required this.gridDates,
    required this.intervalType,
    required this.direction,
    required this.colCount,
    required this.rowCount,
    required this.slotsPerTimeBlock
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final schedulerSettings = SchedulerService().schedulerSettings;
    final lineColor = schedulerSettings.getIntervalLineColor(context);
    final lineWidth = schedulerSettings.dividerLineWidth;

    return SizedBox(
      width: cellSize.width * colCount + headerSize.width,
      height: cellSize.height * rowCount,
      child: CustomPaint(
        painter: SlotGridPainter(
            slotsPerTimeBlock: slotsPerTimeBlock,
            strokeWidth: lineWidth,
            lineColor: lineColor,
            headerSize: headerSize,
            rowCount: rowCount,
            colCount: colCount,
            cellSize: cellSize),
      ),
    );
  }

}

class SlotGridPainter extends CustomPainter {
  final Size headerSize;
  final int colCount;
  final int rowCount;
  final Size cellSize;
  final Color lineColor;
  final double strokeWidth;
  final int slotsPerTimeBlock;
  SlotGridPainter({
    required this.colCount,
    required this.rowCount,
    required this.cellSize,
    required this.headerSize,
    required this.lineColor,
    required this.strokeWidth,
    required this.slotsPerTimeBlock
  });

  void drawDashLine(Canvas canvas, Size size, double top, double left) {
    double dashWidth = 3, dashSpace = 1, startX = left;
    final paint = Paint()
      ..color = lineColor.withOpacity(0.1)
      ..strokeWidth = strokeWidth;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, top), Offset(startX + dashWidth, top), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
     verticalPaint(canvas, size);
  }

  verticalPaint(Canvas canvas, Size size){
    double left = headerSize.width + 0.5;
    double top = 0;
    double right = size.width;
    double bottom = size.height;
    Size lineSize = Size(right, strokeWidth);

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth;

    for (int i = 0; i < rowCount; i++) {
      if (i % slotsPerTimeBlock == 0) {
        canvas.drawLine(Offset(left, top), Offset(right, top), paint);
      } else {
        drawDashLine(canvas, lineSize, top, left);
      }
      top += cellSize.height;
    }
    for (int i = 0; i < colCount; i++) {
      canvas.drawLine(Offset(left, 0), Offset(left, bottom), paint);
      left += cellSize.width;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
