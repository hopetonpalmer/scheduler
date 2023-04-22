import 'package:flutter/material.dart';

import 'grid_cell.dart';
import 'timebar/timebar_cell.dart';

class GridRow extends StatelessWidget {
  final int rowIndex;
  final int cellCount;
  final Size cellSize;
  final int intervalBlockSize;
  final List<TimebarCell> rulerCells;
  const GridRow({
    super.key,
    required this.rowIndex,
    required this.cellCount,
    required this.cellSize,
    required this.rulerCells,
    required this.intervalBlockSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [for (int i = 0; i < rulerCells.length; i++) rulerCells[i],
        ...[for (int i = 0; i < cellCount; i++) GridCell(size: cellSize,
            rowIndex: rowIndex, colIndex: i, intervalBlockSize: intervalBlockSize,)]],
    );
  }
}
