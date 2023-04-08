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
    this.timeOrientation, {
    Key? key,
    this.textStyle,
    this.decoration,
  }) : super(key: key);

  @override
  State<AppointmentWidget> createState() => _AppointmentWidgetState();
}

class _AppointmentWidgetState extends State<AppointmentWidget> with TickerProviderStateMixin {
  Timer? longPressTimer;
  SlotSelector? slotSelector;
  final AppointmentSettings settings = SchedulerService().scheduler.appointmentSettings;
  final Scheduler scheduler = SchedulerService().scheduler;
  final ValueNotifier<bool> hoverNotifier = ValueNotifier<bool>(false);
  final AppointmentService appointmentService = AppointmentService.instance;
  late final StreamSubscription? _appointmentSelectedSubscription;

  late final AnimationController _animationController = AnimationController(
    duration: settings.animationDuration,
    vsync: this,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeIn,
  );


  bool _isHovered = false;
  Appointment get appointment {
    return widget.appointmentItem.appointment;
  }

  bool get isHovered => _isHovered && !AppointmentDragService().isDragging;
  set isHovered(bool value) {
    if (value != _isHovered) {
      _isHovered = value;
      hoverNotifier.value = value;
    }
  }

  get isSelected =>
      appointmentService.selectedAppointment ==
      widget.appointmentItem.appointment;

  @override
  initState() {
    super.initState();
    _animationController.forward();
    _appointmentSelectedSubscription =
        appointmentService.$appointmentSelected.listen((appointment) {
      //if (appointment != widget.appointmentItem.appointment) {
        setState(() {});
      //}
    });
  }

  @override
  dispose() {
    _animationController.dispose();
    _appointmentSelectedSubscription?.cancel();
    cancelLongPressTimer();
    super.dispose();
  }

  cancelLongPressTimer() {
    longPressTimer?.cancel();
    longPressTimer = null;
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
    return BorderRadius.only(
      topLeft: topLeft,
      topRight: topRight,
      bottomLeft: bottomLeft,
      bottomRight: bottomRight,
    );
  }

  Border border(bool isDragging){
    double width = 1;
    Color color = appointment.color.darken(.25);
    if(isDragging){
      //color = Colors.greenAccent;
    } else if (isSelected) {
      width = 1.5;
      color = settings.getSelectionBorderColor(context);
    } else if (isHovered) {
      color = settings.getHoverBorderColor(context);
    }

    return Border.all(width: width, color: color);
  }

  selectAppointment() {
     slotSelector?.clearSelection();
     AppointmentService.instance.selectAppointment(appointment);
  }

  @override
  Widget build(BuildContext context) {
    const minResponsiveHeight = 50;
    slotSelector = scheduler.slotSelector;
    Color color = widget.appointmentItem.appointment.color;
    double height = widget.appointmentItem.geometry.rect.height;
    double width = widget.appointmentItem.geometry.rect.width;
    Offset dragDelta = const Offset(0, 0);
    Color textColor = settings.fontColorShadeOfBack ? color.darken(0.45) : settings.fontColor;

    Widget appointmentViewBody(double opacity, bool dragging) {
      return Container(
          padding: const EdgeInsets.only(left: 4, top: 2, bottom: 2, right: 4),
          decoration: widget.decoration ??
              BoxDecoration(
                color: color.withOpacity(opacity),
                border: border(dragging),
                borderRadius: borderRadius(settings.cornerRadius),
              ),
          height: max(0, height),
          width: width == double.infinity ? 0 : max(0, width),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                child: Text(widget.appointmentItem.appointment.subject,
                    style: widget.textStyle ??
                        TextStyle(
                            color: textColor,
                            fontSize: height >= minResponsiveHeight ? 12.0 : min(12,height * .40),
                            overflow: TextOverflow.ellipsis)),
              ),
              Visibility(
                visible: height > minResponsiveHeight,
                child: ClipRect(
                  child: FittedBox(
                    child: Text(
                        DateFormat('h:mm a').format(widget.appointmentItem.appointment.startDate) +' - ' +DateFormat('h:mm a')
                                .format(widget.appointmentItem.appointment.endDate),
                        style: widget.textStyle ??
                            TextStyle(
                                color: textColor,
                                fontSize: 12.0,
                                overflow: TextOverflow.ellipsis)),
                  ),
                ),
              ),
            ],
          ));
    }

    Widget appointmentView({double opacity = 1, bool dragging = false}) {
      return Padding(
        padding: const EdgeInsets.only(left: 0.5),
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (event) {
            isHovered = false;
            if (SchedulerViewHelper.isMobileLayout(context)) {
              longPressTimer = Timer(settings.selectionDelay, () {
                cancelLongPressTimer();
                if (settings.hapticFeedbackOnLongPressSelection) {
                    HapticFeedback.selectionClick();
                }
                selectAppointment();
              });
            }
          },
          onPointerUp: (event) {
            cancelLongPressTimer();
            if (!SchedulerViewHelper.isMobileLayout(context)) {
              selectAppointment();
            }
          },
          onPointerMove: (event) {
            if (event.down && event.delta.distanceSquared > 2) {
              cancelLongPressTimer();
            }
          },
          child: MouseRegion(
            cursor: DraggableCursor(),
            opaque: !SchedulerViewHelper.isMobileLayout(context),
            onEnter: (event) {
              if (event.kind == PointerDeviceKind.mouse) {
                isHovered = true;
              }
            },
            onExit: (event) {
              isHovered = false;
            },
            child: ValueListenableBuilder(
                valueListenable: hoverNotifier,
                builder: (BuildContext context, bool hovered, Widget? child) =>
                    appointmentViewBody(opacity, dragging)),
          ),
        ),
      );
    }

    return ValueListenableBuilder(
        valueListenable: scheduler.schedulerScrollPosNotify,
        builder: (BuildContext context, double scrollBy, Widget? child) {
          widget.appointmentRenderService
              .scrollAppointment(widget.appointmentItem, Scheduler.currentScrollPos);
          return Positioned(
            top: widget.appointmentItem.geometry.rect.top,
            left: widget.appointmentItem.geometry.rect.left,
            child: SchedulerViewHelper.isMobileLayout(context)
                ? appointmentView()
                : LongPressDraggableEx<Appointment>(
                      allowDragGesture: () => false,
                      delay: const Duration(), // settings.dragDelay,
                      onDragStarted: () {
                        AppointmentDragService().beginDrag(widget.appointmentItem.appointment);
                      },
                      onDragUpdate: (DragUpdateDetails updateDetails) {
                        AppointmentDragService().updateDrag(
                            widget.appointmentItem.appointment, updateDetails);
                        dragDelta = Offset(dragDelta.dx + updateDetails.delta.dx,
                            dragDelta.dy + updateDetails.delta.dy);
                      },
                      onDragEnd: (DraggableDetails dragDetails) {
                        //if (dragDetails.wasAccepted){
                        if (AppointmentDragService().isDragging) {
                          dragDelta = AppointmentDragService().adjustForDragScroll(dragDelta, widget.timeOrientation);
                          AppointmentDragService().endDrag(widget.appointmentItem.appointment, dragDetails);
                          if (dragDelta.dx.abs() >= 1 || dragDelta.dy.abs() >= 1) {
                            List newDates = widget.appointmentRenderService.datesOfPosChange(widget.appointmentItem, dragDelta);
                            scheduler.dataSource!.rescheduleAppointment(widget.appointmentItem.appointment,newDates[0],newDates[1]);
                          }
                        } else {
                          dragDelta = Offset.zero;
                        }
                      },
                      data: widget.appointmentItem.appointment,
/*                    childWhenDragging: MouseRegion(
                          cursor: SystemMouseCursors.grab,
                          child: appointmentView(dragging: true)),*/
                      feedback: ValueListenableBuilder(
                          valueListenable:AppointmentDragService().appointmentDragCancel,
                          builder: (BuildContext context, bool canceled,Widget? child) => canceled
                                  ? Container()
                                  : Material(
                                      color: Colors.transparent,
                                      child: appointmentView(opacity: 0.75, dragging: true))),
                      child: FadeTransition(
                         opacity: _animation,
                         child: appointmentView()
                      ),
                    ),
          );
        });
  }
}
