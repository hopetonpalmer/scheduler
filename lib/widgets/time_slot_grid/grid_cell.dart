import 'dart:ui';

import 'package:flutter/material.dart';

import '../../draggable_cursor.dart';
import '../../scheduler.dart';
import '../../services/appointment_drag_service.dart';
import '../../services/scheduler_service.dart';

class GridCell extends StatelessWidget {
  final Size size;
  const GridCell({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    CellPainter cellPainter = CellPainter(cell: this, context: context);
    return MouseRegion(
      cursor: DraggableCursor(),
      onEnter: (event) {
        if (event.kind == PointerDeviceKind.mouse) {
          if (!AppointmentDragService().isDragging) {
            cellPainter.isHovered = true;
          }
        }
      },
      onExit: (event) {
        cellPainter.isHovered = false;
      },
      child: CustomPaint(
        size: size,
        painter: cellPainter,
      ),
    );
  }
}

class CellPainter extends CustomPainter with ChangeNotifier {
  final GridCell cell;
  final BuildContext context;
  CellPainter({
    required this.cell,
    required this.context,
  });

  bool _isHovered = false;
  bool get isHovered => _isHovered;

  set isHovered(bool value){
    if (value != isHovered) {
      _isHovered = value;
      notifyListeners();
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    SchedulerSettings settings = SchedulerService().schedulerSettings;
    Rect rect =
        Rect.fromPoints(Offset.zero, Offset(cell.size.width, cell.size.height));
    Color color =
        isHovered ? settings.getCellHoverBorderColor(context) : Colors.transparent;
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = settings.dividerLineWidth
      ..style = PaintingStyle.stroke;
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CellPainter oldDelegate) {
    return oldDelegate.isHovered != isHovered;
  }


}
