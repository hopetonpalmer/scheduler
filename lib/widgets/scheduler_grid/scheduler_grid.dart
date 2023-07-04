
import 'package:dart_date/dart_date.dart';
import 'package:flutter/material.dart';
import 'package:scheduler/scheduler.dart';
import 'package:scheduler/services/scheduler_service.dart';
import 'grid_row.dart';
import 'timebar/timebar_cell.dart';

class SchedulerGrid extends StatelessWidget {
  final IntervalType intervalType;
  final List<DateTime> gridDates;
  final Axis orientation;
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
    required this.orientation,
    required this.colCount,
    required this.rowCount,
    required this.slotsPerTimeBlock,
    required this.clientRect,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    List<TimebarCell> rulerCells (int index, DateTime date) {
      return [TimebarCell(rowIndex: index, colIndex: 0, direction: orientation,
          size: rulerCellSize, date: date, intervalBlockSize: slotsPerTimeBlock,)];
    }

    return ListView.builder(
        primary: false,
        controller: scrollController,
        itemCount: rowCount,
        itemBuilder: (context, index) {
          final intervalDate = gridDates[0].addMinutes((60 ~/ slotsPerTimeBlock) * index);

          return Stack(children: [
            GridRow(rulerCells: rulerCells(index, intervalDate), intervalBlockSize: slotsPerTimeBlock,
                cellCount: gridDates.length, cellSize: cellSize, rowIndex: index,),
          ]);
        },);
  }
}

