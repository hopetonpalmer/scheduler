import 'package:flutter/material.dart';
import 'package:scheduler/widgets/scheduler_grid/grid_row.dart';

class SchedulerGrid extends StatelessWidget {
  final int rows;
  final int cols;
  const SchedulerGrid({Key? key, required this.rows, required this.cols}) : super(key: key);

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


