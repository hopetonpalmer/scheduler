import 'dart:ui';

class GridCellData {
  Rect rect;
  Color? color;
  DateTime date;

  GridCellData({
    required this.rect,
    required this.date,
    this.color,
  });
}