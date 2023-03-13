import 'package:flutter/material.dart';
import 'package:scheduler/scheduler.dart';
import 'package:scheduler/services/scheduler_service.dart';
import 'package:scheduler/widgets/date_header.dart';
import 'package:scheduler/widgets/time_cell.dart';

class TimeCellBlock extends StatelessWidget {
  final IntervalType intervalType;
  final List<DateTime> blockDates;
  final Axis direction;
  final int cellCount;
  final Size cellSize;
  final HeaderPosition cellHeaderPosition;
  final Size cellHeaderSize;
  const TimeCellBlock({
    Key? key,
    required this.cellHeaderSize,
    required this.cellHeaderPosition,
    required this.cellSize,
    required this.cellCount,
    required this.blockDates,
    required this.intervalType,
    required this.direction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final schedulerSettings = SchedulerService().schedulerSettings;
    return Container(
      //width: (cellSize.width * blockDates.length) + cellHeaderSize.width,
      height: cellSize.height * cellCount,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: schedulerSettings.getIntervalLineColor(context), width: 0.75
            // width: 0, //schedulerSettings.dividerLineWidth,
          ),
        ),
      ),
      child: CustomPaint(
        painter: CellBlockPainter(
          headerSize: cellHeaderSize,
          rows: cellCount,
          cols: blockDates.length,
          cellSize: cellSize
        ),
      ),
    );
  }

  Widget buildCellBlock() {
    List<Widget> blockCells = [];
    for (int i = 0; i < blockDates.length; i++) {
      List<Widget> dateCells = [];
      for (int j = 0; j < cellCount; j++) {
        dateCells.add(TimeCell(
          //header: i == 0 ? DateHeader(width: 62.5, headerType: DateHeaderType.minute, date: blockDates[0]) : null,
          headerVisible: i == 0,
          cellDate: blockDates[0],
          direction: direction,
          headerPosition: cellHeaderPosition,
          headerSize: cellHeaderSize,
          size: cellSize,
          lineVisible: j > 0,
        ));
      }
      blockCells.add(Container(
        height: cellSize.height * cellCount,
        decoration: const BoxDecoration(border: Border(left: BorderSide(color: Colors.orange, width: 0.5))), //todo: set to settings dividerWidth
        child: Flex(
          direction: direction,
          children: dateCells,
        ),
      ));
    }
    return Row(
      children: blockCells,
    );
  }
}

class CellBlockPainter extends CustomPainter {
  final Size headerSize;
  final int cols;
  final int rows;
  final Size cellSize;
  CellBlockPainter({required this.cols, required this.rows, required this.cellSize, required this.headerSize});

  void drawDashLine(Canvas canvas, Size size, double top, double left) {
    double dashWidth = 3, dashSpace = 1, startX = left;
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = .5;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, top), Offset(startX + dashWidth, top), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
      final paint = Paint()..color = Colors.red..strokeWidth=.5;

      double top = 0;
      for(int i = 0; i < rows; i++) {
        top += cellSize.height;

        if (i < rows - 1) {
          drawDashLine(canvas, size, top, 0);
        }
      }
      double left = headerSize.width;
      for (int i = 0; i < cols; i++) {
        canvas.drawLine(Offset(left, 1), Offset(left, size.height), paint);
        left += ((size.width - headerSize.width) / cols);
      }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}



