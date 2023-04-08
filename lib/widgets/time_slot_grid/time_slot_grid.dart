import 'dart:ui';

import 'package:dart_date/dart_date.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:list_ext/list_ext.dart';
import 'package:scheduler/scheduler.dart';
import 'package:scheduler/services/scheduler_service.dart';
import '../../draggable_cursor.dart';
import '../../services/appointment_drag_service.dart';
import 'grid_cell_data.dart';
import 'grid_row.dart';

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
  final Rect clientRect;
  final ScrollController scrollController;
  TimeSlotGrid({
    Key? key,
    required this.headerSize,
    required this.headerPosition,
    required this.cellSize,
    required this.gridDates,
    required this.intervalType,
    required this.direction,
    required this.colCount,
    required this.rowCount,
    required this.slotsPerTimeBlock,
    required this.clientRect,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final schedulerSettings = SchedulerService().schedulerSettings;
    final lineColor = schedulerSettings.getIntervalLineColor(context);
    final lineWidth = schedulerSettings.dividerLineWidth;
    final width = cellSize.width * colCount + headerSize.width;

    return ListView.builder(
        primary: false,
        controller: scrollController,
        itemCount: rowCount,
        itemBuilder: (context, index) {
          return Stack(children: [
            CustomPaint(
              size: Size(width, cellSize.height),
              painter: GridLinesPainter(
                  slotsPerTimeBlock: slotsPerTimeBlock,
                  strokeWidth: lineWidth,
                  lineColor: lineColor,
                  headerSize: headerSize,
                  rowCount: 1, //slotsPerTimeBlock,
                  intervalDate: gridDates[0]
                      .addMinutes((60 ~/ slotsPerTimeBlock) * index),
                  rowIndex: index,
                  colCount: colCount,
                  cellSize: cellSize),
            ),
            GridRow(headerSize: headerSize, cellCount: gridDates.length, cellSize: cellSize),
          ]);
        });
  }
}

class CellHighlightPainter extends CustomPainter {
  final Rect rect;
  CellHighlightPainter(this.rect);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = .75;

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class GridLinesPainter extends CustomPainter {
  final Size headerSize;
  final int colCount;
  final int rowCount;
  final Size cellSize;
  final Color lineColor;
  final double strokeWidth;
  final int rowIndex;
  final int colIndex;
  final int slotsPerTimeBlock;
  final DateTime intervalDate;
  GridLinesPainter({
    required this.colCount,
    required this.rowCount,
    required this.cellSize,
    required this.headerSize,
    required this.lineColor,
    required this.strokeWidth,
    required this.slotsPerTimeBlock,
    required this.intervalDate,
    this.colIndex = 0,
    this.rowIndex = 0,
  });

  void drawDashLine(Canvas canvas, Size size, double top, double left) {
    double dashWidth = 3, dashSpace = 1, startX = left;
    final paint = Paint()
      ..color = lineColor.withOpacity(0.1)
      ..strokeWidth = strokeWidth;
    while (startX < size.width) {
      canvas.drawLine(
          Offset(startX, top), Offset(startX + dashWidth, top), paint);
      startX += dashWidth + dashSpace;
    }
  }

  void drawText(String text, Canvas canvas, Size size) {
    final textSpan = TextSpan(text: text, style: TextStyle(fontSize: 10));
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(60 - textPainter.width, 0));
  }

  @override
  void paint(Canvas canvas, Size size) {
    verticalPaint(canvas, size);
  }

  verticalPaint(Canvas canvas, Size size) {
    double left = headerSize.width + 0.4;
    double top = 0; //rowIndex * cellSize.height;
    double right = size.width;
    double bottom = top + cellSize.height;
    Size lineSize = Size(right, strokeWidth);

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth;

    //for (int i = 0; i < rowCount; i++) {
    if (rowIndex % slotsPerTimeBlock == 0) {
      canvas.drawLine(Offset(left, 0), Offset(right, top), paint);
      drawText(
          intl.DateFormat(intl.DateFormat.HOUR_MINUTE).format(intervalDate),
          canvas,
          size);
    } else {
      drawDashLine(canvas, lineSize, top, left);
      drawText(intl.DateFormat(intl.DateFormat.MINUTE).format(intervalDate),
          canvas, size);
    }
    //top += cellSize.height;
    // }
    for (int i = 0; i < colCount; i++) {
      canvas.drawLine(Offset(left, top), Offset(left, bottom), paint);
      left += cellSize.width;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
