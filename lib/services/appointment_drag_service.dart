import 'package:flutter/widgets.dart';
import 'package:scheduler/scheduler.dart';

enum DragMode {
  drag,
  size
}

class AppointmentDragService{
  final ValueNotifier<AppointmentDragDetails?> appointmentDragEnd = ValueNotifier<AppointmentDragDetails?>(null);
  final ValueNotifier<AppointmentDragUpdateDetails?> appointmentDragUpdate = ValueNotifier<AppointmentDragUpdateDetails?>(null);
  final ValueNotifier<bool> appointmentDragCancel = ValueNotifier<bool>(false);
  final ValueNotifier<DragMode> dragModeNotifier = ValueNotifier<DragMode>(DragMode.drag);
  static final AppointmentDragService _appointmentDragService = AppointmentDragService._internal();
  static final instance = _appointmentDragService;
  factory AppointmentDragService() {
    return _appointmentDragService;
  }
  AppointmentDragService._internal();

  ScrollController? activeScrollController;

  bool _isDragging = false;
  bool get isDragging => _isDragging;
  DragMode get dragMode => dragModeNotifier.value;
  SizingDirection _dragSizeDirection = SizingDirection.none;
  SizingDirection get dragSizeDirection => _dragSizeDirection;

  prepareDragSize(SizingDirection dragSizeDirection) {
     _dragSizeDirection = dragSizeDirection;
     if (_dragSizeDirection == SizingDirection.none){
       dragModeNotifier.value = DragMode.drag;
     } else {
       dragModeNotifier.value = DragMode.size;
     }
  }


  endDrag(Appointment appointment, DraggableDetails dragDetails) {
     _isDragging = false;
     appointmentDragCancel.value = false;
     appointmentDragEnd.value = AppointmentDragDetails(appointment, dragDetails);
     dragModeNotifier.value = DragMode.drag;
  }

  beginDrag(Appointment appointment) {
    appointmentDragCancel.value = false;
    dragScrollPixelsStart = activeScrollController!.position.pixels;
    _isDragging = true;
  }

  updateDrag(Appointment appointment, DragUpdateDetails dragUpdateDetails, Offset change) {
    appointmentDragUpdate.value = AppointmentDragUpdateDetails(appointment, dragUpdateDetails, change);
  }

  DateTime? dragTargetDate;

  double dragScrollPixelsStart = 0;
  double get dragScrollPixelsEnd => activeScrollController!.position.pixels;
  double get dragScrollPixels  => dragScrollPixelsEnd - dragScrollPixelsStart;

  Offset adjustForDragScroll(Offset dragDelta, FlowOrientation timeOrientation) {
    if (timeOrientation == FlowOrientation.vertical) {
      return Offset(dragDelta.dx, dragDelta.dy + dragScrollPixels);
    }
    return Offset(dragDelta.dx + dragScrollPixels, dragDelta.dy);
  }

  void cancelDrag() {
    if (isDragging) {
      _isDragging = false;
      appointmentDragCancel.value = true;
      dragModeNotifier.value = DragMode.drag;
    }
  }



}

class AppointmentDragDetails {
  Appointment? appointment;
  DraggableDetails? dragDetails;
  AppointmentDragDetails(this.appointment, this.dragDetails);
}

class AppointmentDragUpdateDetails {
  Appointment? appointment;
  DragUpdateDetails? dragUpdateDetails;
  Offset change;
  AppointmentDragUpdateDetails(this.appointment, this.dragUpdateDetails, this.change);
}