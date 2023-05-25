
import 'package:dart_date/dart_date.dart';
import 'package:flutter/material.dart';
import 'package:scheduler/scheduler.dart';
import 'package:scheduler/services/scheduler_service.dart';
import 'grid_row.dart';
import 'timebar/timebar_cell.dart';

class SchedulerGrid extends StatelessWidget {
  final IntervalType intervalType;
  final List<DateTime> gridDates;
  final Axis direction;
  final int colCount;
  final int rowCount;
  final Size cellSize;
  final HeaderPosition headerPosition;
  final Size rulerCellSize;
  final int slotsPerTimeBlock;
  final Rect clientRect;
  final ScrollController scrollController;
  const SchedulerGrid({
    super.key,
    required this.rulerCellSize,
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
  });

  @override
  Widget build(BuildContext context) {
    //super.build(context);
    final schedulerSettings = SchedulerService().schedulerSettings;
    final lineColor = schedulerSettings.getIntervalLineColor(context);
    final lineWidth = schedulerSettings.dividerLineWidth;
    final width = cellSize.width * colCount + rulerCellSize.width;

    List<TimebarCell> rulerCells (int index, DateTime date) {
      return [TimebarCell(rowIndex: index, colIndex: 0, direction: direction,
          size: rulerCellSize, date: date, intervalBlockSize: slotsPerTimeBlock)];
    }

    return ListView.builder(
        primary: false,
        controller: scrollController,
        itemCount: rowCount,
        itemBuilder: (context, index) {
          final intervalDate = gridDates[0].addMinutes((60 ~/ slotsPerTimeBlock) * index);

          return Stack(children: [
            Visibility(
              visible: false,
              child: CustomPaint(
                size: Size(width, cellSize.height),
                painter: GridLinesPainter(
                    slotsPerTimeBlock: slotsPerTimeBlock,
                    strokeWidth: lineWidth,
                    lineColor: lineColor,
                    headerSize: rulerCellSize,
                    rowCount: 1, //slotsPerTimeBlock,
                    intervalDate: intervalDate,
                    rowIndex: index,
                    colCount: colCount,
                    cellSize: cellSize,),
              ),
            ),
            GridRow(rulerCells: rulerCells(index, intervalDate), intervalBlockSize: slotsPerTimeBlock,
                cellCount: gridDates.length, cellSize: cellSize, rowIndex: index),
          ]);
        },);
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

    if (rowIndex % slotsPerTimeBlock == 0) {
      canvas.drawLine(Offset(left, 0), Offset(right, top), paint);
    } else {
      drawDashLine(canvas, lineSize, top, left);
    }
    for (int i = 0; i < colCount; i++) {
      canvas.drawLine(Offset(left, top), Offset(left, bottom), paint);
      left += cellSize.width;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
