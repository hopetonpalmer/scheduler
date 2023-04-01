import 'package:flutter/material.dart';
import 'package:scheduler/widgets/scheduler_grid/grid_row.dart';

class SchedulerGrid extends StatelessWidget {
  final List<Sizer>? columSizers;
  final List<Sizer>? rowSizers;
  final int rows;
  final int cols;
  const SchedulerGrid({
    super.key,
    this.columSizers,
    this.rowSizers,
    required this.rows,
    required this.cols,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        //controller: _scrollController,
        physics: const ClampingScrollPhysics(),
        itemCount: rows,
        itemBuilder: (context, index) {
          var key = GlobalKey();
          return GridRow(key: key, rows: 4, cols: cols);
        });
  }
}

class Sizer {
  int index;
  double value;
  Sizer(this.index, this.value);
}
