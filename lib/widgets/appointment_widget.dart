part of scheduler;

class AppointmentWidget extends StatefulWidget {
  final AppointmentItem appointmentItem;
  final TextStyle? textStyle;
  final Decoration? decoration;
  final AppointmentRenderService appointmentRenderService;
  final FlowOrientation timeOrientation;
  const AppointmentWidget(
      this.appointmentItem,
      this.appointmentRenderService,
      this.timeOrientation,
      {Key? key, this.textStyle, this.decoration,}
   ) : super(key: key);

  @override
  State<AppointmentWidget> createState() => _AppointmentWidgetState();
}

class _AppointmentWidgetState extends State<AppointmentWidget> {
  SlotSelector? slotSelector;

  onEntered(bool entered){
  }

  Appointment get appointment {
    return widget.appointmentItem.appointment;
  }

  BorderRadius borderRadius(Radius? cornerRadius) {
    Radius borderRadius = cornerRadius ?? const Radius.circular(4);
    if (appointment.appointmentItems.length == 1) {
      return BorderRadius.all(borderRadius);
    }
    Radius topLeft = borderRadius;
    Radius topRight = borderRadius;
    Radius bottomLeft = borderRadius;
    Radius bottomRight = borderRadius;

    if (widget.timeOrientation == FlowOrientation.vertical) {
      if (widget.appointmentItem != appointment.appointmentItems.last) {
        bottomLeft = const Radius.circular(0);
        bottomRight = const Radius.circular(0);
      }
      if (widget.appointmentItem != appointment.appointmentItems.first) {
        topLeft = const Radius.circular(0);
        topRight = const Radius.circular(0);
      }
    } else {
      if (widget.appointmentItem != appointment.appointmentItems.last) {
        topRight = const Radius.circular(0);
        bottomRight = const Radius.circular(0);
      }
      if (widget.appointmentItem != appointment.appointmentItems.first) {
        topLeft = const Radius.circular(0);
        bottomLeft = const Radius.circular(0);
      }
    }
    return BorderRadius.only(topLeft: topLeft, topRight: topRight,
        bottomLeft: bottomLeft, bottomRight: bottomRight);
  }

  @override
  Widget build(BuildContext context) {
    Scheduler scheduler = Scheduler.of(context);
    slotSelector = scheduler.slotSelector;
    AppointmentSettings settings = scheduler.appointmentSettings;
    Color color = widget.appointmentItem.appointment.color ?? settings.defaultColor;
    double height = widget.appointmentItem.geometry.rect.height;
    double width = widget.appointmentItem.geometry.rect.width;
    Offset dragDelta = const Offset(0,0);
    Color textColor = settings.calcFontColor ? color.lighten(0.3) : settings.fontColor;
    Widget appointmentView({double opacity = 1, bool dragging = false}) {
      return Listener(
        onPointerDown: (_) {
          slotSelector?.clearSelection();
          AppointmentService().selectAppointment(appointment);
        },
        child: MouseRegion(
          cursor: DraggableCursor(),
          onEnter: onEntered(true),
          onExit: onEntered(false),
          child: Container(
              padding: const EdgeInsets.only(left:4, top: 2),
              decoration: widget.decoration ?? BoxDecoration(
                  color: color.withOpacity(opacity),
                  border: Border.all(width: dragging ? 2 : 1, color: dragging ? settings.selectionColor : Colors.black26),
                  borderRadius: borderRadius(settings.cornerRadius),
              ),
              height: max(0,height),
              width: width == double.infinity ? 0 : max(0,width),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRect(
                    child: Text(
                        widget.appointmentItem.appointment.subject,
                        style: widget.textStyle ?? TextStyle(color: textColor, fontSize: 12.0, overflow: TextOverflow.ellipsis)
                    ),
                  ),
                  ClipRect(
                    child: Text(
                        DateFormat('h:mm a').format(widget.appointmentItem.appointment.startDate)+' - ' +DateFormat('h:mm a').format(widget.appointmentItem.appointment.endDate),
                        style: widget.textStyle ?? TextStyle(color: textColor, fontSize: 12.0, overflow: TextOverflow.ellipsis)
                    ),
                  ),
                ],
              )),
        ),
      );
    }

    return ValueListenableBuilder(
      valueListenable: scheduler.schedulerScrollPosNotify,
      builder: (BuildContext context, double scrollBy, Widget? child) {
        widget.appointmentRenderService.scrollAppointment(widget.appointmentItem, scrollBy);
        return Positioned(
            top: widget.appointmentItem.geometry.rect.top,
            left: widget.appointmentItem.geometry.rect.left,
            child: LongPressDraggable<Appointment>(
              delay: Duration(milliseconds: settings.dragDelayMilliseconds),
              onDragStarted: () {
                AppointmentDragService().beginDrag(widget.appointmentItem.appointment);
              },
              onDragUpdate: (DragUpdateDetails updateDetails) {
                AppointmentDragService().updateDrag(widget.appointmentItem.appointment, updateDetails);
                dragDelta = Offset(dragDelta.dx + updateDetails.delta.dx, dragDelta.dy + updateDetails.delta.dy);
              },
              onDragEnd: (DraggableDetails dragDetails) {
                //if (dragDetails.wasAccepted){
                if (AppointmentDragService().isDragging) {
                  dragDelta = AppointmentDragService().adjustForDragScroll(dragDelta, widget.timeOrientation);
                  AppointmentDragService().endDrag(widget.appointmentItem.appointment, dragDetails);
                  List newDates = widget.appointmentRenderService.datesOfPosChange(widget.appointmentItem, dragDelta);
                  Scheduler.of(context).dataSource!.rescheduleAppointment(widget.appointmentItem.appointment, newDates[0], newDates[1]);
                } else {
                  dragDelta = Offset.zero;
                }
              },
              data: widget.appointmentItem.appointment,
              childWhenDragging: MouseRegion(cursor: SystemMouseCursors.grab, child: appointmentView(dragging: true)),
              feedback: ValueListenableBuilder(
                  valueListenable: AppointmentDragService().appointmentDragCancel,
                  builder: (BuildContext context, bool canceled, Widget? child) =>
                  canceled ? Container() : Material(color: Colors.transparent, child: appointmentView(opacity: 0.75))),
              child: appointmentView(),
              ),
            );
      }
    );
  }
}
