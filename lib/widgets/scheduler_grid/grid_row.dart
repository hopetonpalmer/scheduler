import 'package:flutter/material.dart';

class GridRow extends StatefulWidget {
  final int rows;
  final int cols;
  const GridRow({Key? key, required this.rows, required this.cols}) : super(key: key);

  @override
  _GridRowState createState() => _GridRowState();
}

class _GridRowState extends State<GridRow> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
