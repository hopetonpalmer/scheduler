import 'package:flutter/material.dart';
import 'package:scheduler/services/appointment_drag_service.dart';

class DraggableCursor extends MaterialStateMouseCursor {
  @override
  String get debugDescription => 'DraggableCursor()';

  @override
  MouseCursor resolve(Set<MaterialState> states) {
    if (AppointmentDragService().isDragging){
      return SystemMouseCursors.move;
    }
    return SystemMouseCursors.basic;
  }

}