import 'package:flutter/widgets.dart';
import 'package:scheduler/scheduler.dart';

class AppointmentDragService{
  final ValueNotifier<AppointmentDragDetails?> appointmentDragEnd = ValueNotifier<AppointmentDragDetails?>(null);
  final ValueNotifier<AppointmentDragUpdateDetails?> appointmentDragUpdate = ValueNotifier<AppointmentDragUpdateDetails?>(null);
  final ValueNotifier<bool> appointmentDragCancel = ValueNotifier<bool>(false);
  static final AppointmentDragService _appointmentDragService = AppointmentDragService._internal();
  factory AppointmentDragService() {
    return _appointmentDragService;
  }
  AppointmentDragService._internal();

  ScrollController? activeScrollController;

  bool _isDragging = false;
  bool get isDragging => _isDragging;

  endDrag(Appointment appointment, DraggableDetails dragDetails) {
     _isDragging = false;
     appointmentDragCancel.value = false;
     appointmentDragEnd.value = AppointmentDragDetails(appointment, dragDetails);
  }

  beginDrag(Appointment appointment) {
    appointmentDragCancel.value = false;
    dragScrollPixelsStart = activeScrollController!.position.pixels;
    _isDragging = true;
  }

  updateDrag(Appointment appointment, DragUpdateDetails dragUpdateDetails) {
    appointmentDragUpdate.value = AppointmentDragUpdateDetails(appointment, dragUpdateDetails);
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
  AppointmentDragUpdateDetails(this.appointment, this.dragUpdateDetails);
}