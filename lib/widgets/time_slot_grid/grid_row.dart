import 'package:flutter/material.dart';

import 'grid_cell.dart';

class GridRow extends StatelessWidget {
  final int cellCount;
  final Size cellSize;
  final Size headerSize;
  const GridRow({
    super.key,
    required this.cellCount,
    required this.cellSize,
    required this.headerSize,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: headerSize.width),
      child: Row(
        children: [for (int i = 0; i < cellCount; i++) GridCell(size: cellSize)],
      ),
    );
  }
}
