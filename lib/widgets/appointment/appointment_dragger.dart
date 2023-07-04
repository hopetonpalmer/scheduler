import 'package:flutter/material.dart';

import '../../models/appointment_item.dart';
import '../../scheduler.dart';
import '../../services/appointment_drag_service.dart';
import '../../services/appointment_render_service.dart';
import '../../services/scheduler_service.dart';
import '../long_press_draggable_ex.dart';

class AppointmentDragger extends StatefulWidget {
  final AppointmentItem appointmentItem;
  final AppointmentRenderService appointmentRenderService;
  final FlowOrientation orientation;
  final Widget child;
  final AppointmentViewBuilder viewBuilder;
  const AppointmentDragger({
    Key? key,
    required this.child,
    required this.viewBuilder,
    required this.orientation,
    required this.appointmentItem,
    required this.appointmentRenderService,
  }) : super(key: key);

  @override
  _AppointmentDraggerState createState() => _AppointmentDraggerState();
}

class _AppointmentDraggerState extends State<AppointmentDragger> {
  Scheduler scheduler = SchedulerService.instance.scheduler;
  Offset startingPosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    Offset dragDelta = const Offset(0, 0);
    
    return Listener(
      onPointerDown: (event){
        startingPosition = event.position;
      },
      child: LongPressDraggableEx<Appointment>(
        allowDragGesture: () => false,
        delay: const Duration(), // scheduler.appointmentSettings.dragDelay,
        onDragStarted: () {
          AppointmentDragService().beginDrag(widget.appointmentItem.appointment);
        },
        onDragUpdate: (DragUpdateDetails updateDetails) {
          dragDelta = Offset(updateDetails.globalPosition.dx - startingPosition.dx , updateDetails.globalPosition.dy - startingPosition.dy);
          AppointmentDragService().updateDrag(widget.appointmentItem.appointment, updateDetails, dragDelta);
        },
        onDragEnd: (DraggableDetails dragDetails) {
          if (AppointmentDragService().isDragging) {
            var dragMode = AppointmentDragService.instance.dragMode;
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            dragDelta = renderBox.globalToLocal(dragDetails.offset);
            // AppointmentDragService().adjustForDragScroll(localOffset, widget.orientation);
            AppointmentDragService().endDrag(widget.appointmentItem.appointment, dragDetails);
            if (dragDelta.dx.abs() >= 1 || dragDelta.dy.abs() >= 1) {
              if (dragMode == DragMode.drag){
                List newDates = widget.appointmentRenderService.datesOfPosChange(widget.appointmentItem, dragDelta);
                scheduler.dataSource!.rescheduleAppointment(widget.appointmentItem.appointment, newDates[0], newDates[1]);
              } else {
                var dragSizeDirection = AppointmentDragService().dragSizeDirection;
                List newDates = widget.appointmentRenderService.datesOfSizeChange(widget.appointmentItem, dragDelta, dragSizeDirection);
                scheduler.dataSource!.rescheduleAppointment(widget.appointmentItem.appointment, newDates[0], newDates[1]);
              }
            }
          } else {
            dragDelta = Offset.zero;
          }
        },
        data: widget.appointmentItem.appointment,
        //childWhenDragging: widget.viewBuilder(dragging: true),
        feedback: ValueListenableBuilder(
          valueListenable: AppointmentDragService().dragModeNotifier,
          builder: (BuildContext context, DragMode mode, Widget? child) => mode == DragMode.size
              ? Container()
              : ValueListenableBuilder(
                  valueListenable: AppointmentDragService().appointmentDragCancel,
                  builder: (BuildContext context, bool canceled, Widget? child) => canceled
                          ? Container()
                          : Material(
                              color: Colors.transparent,
                              child: widget.viewBuilder(
                                  opacity: 0.75, dragging: true,),),),
        ),
        child: widget.child,
      ),
    );
  }
}

