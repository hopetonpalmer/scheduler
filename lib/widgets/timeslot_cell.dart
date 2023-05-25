// ignore_for_file: unused_import

import 'dart:math';
import 'dart:ui';

import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/material.dart';
import 'package:scheduler/draggable_cursor.dart';
import 'package:scheduler/scheduler.dart';
import 'package:scheduler/services/appointment_drag_service.dart';
import 'package:scheduler/slot_selector.dart';
import 'package:scheduler/time_slot.dart';

import '../common/scheduler_view_helper.dart';

typedef HeaderBuilder = Widget Function(
  BuildContext context,
  bool isSelected,
);

class TimeslotCell extends StatefulWidget {
  final Widget? header;
  final HeaderBuilder? builder;
  final TimeSlot timeSlot;
  final bool isGroupEnd;
  final double? height;
  final double? width;
  final FlowOrientation flowOrientation;
  final bool showBottomBorder;
  final bool showDivider;
  final bool showBorders;
  final bool disabled;
  final Color? backgroundColor;
  const TimeslotCell({
    Key? key,
    this.header,
    this.builder,
    this.showDivider = true,
    this.showBottomBorder = false,
    required this.timeSlot,
    this.showBorders = true,
    this.flowOrientation = FlowOrientation.vertical,
    this.isGroupEnd = false,
    this.disabled = false,
    this.backgroundColor = Colors.transparent,
    this.width,
    this.height,
  }) : super(key: key);

  get startDate => timeSlot.startDate;
  get endDate => timeSlot.endDate;

  @override
  State<TimeslotCell> createState() => _TimeslotCellState();
}

class _TimeslotCellState extends State<TimeslotCell> {
  late SlotSelector slotSelector;
  bool _isHovered = false;
  bool isSelected = false;
  bool first = true;

  bool get canSelect {
    return !widget.disabled;
  }

  bool get isHovered => _isHovered && !AppointmentDragService().isDragging;
  set isHovered(bool value) {
    if (value != _isHovered) {
      _isHovered = value;
      setState(() => {});
    }
  }

  void selectSlotInRange() {
    if (!canSelect) {
      return;
    }
    var inRange = slotSelector.selectedSlotDates.inRange(widget.startDate);
    if (inRange != isSelected && mounted) {
      setState(() {
        isSelected = inRange;
      });
    }
  }

  @override
  void dispose() {
    slotSelector.removeListener(selectSlotInRange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SchedulerSettings schedulerSettings =
        Scheduler.of(context).schedulerSettings;
    slotSelector = Scheduler.of(context).slotSelector;
    slotSelector.addListener(selectSlotInRange);

    return Listener(
      onPointerDown: (event) {
        if (canSelect && event.buttons == 1) {
          slotSelector.startSelection(widget.timeSlot);
        }
      },
      onPointerUp: (_) {
        if (canSelect) {
          slotSelector.endSelection();
        }
      },
      child: MouseRegion(
        cursor: DraggableCursor(),
        onExit: (event) {
          isHovered = false;
        },
        onEnter: (event) {
          if (event.kind == PointerDeviceKind.mouse) {
            isHovered = true;
          }
          if (slotSelector.isSelecting) {
            slotSelector.select(widget.timeSlot);
          }
        },
        child: DragTarget(
          onWillAccept: (data) => data is Appointment,
          onAccept: (_) =>
              AppointmentDragService().dragTargetDate = widget.startDate,
          builder: (
            BuildContext context,
            List<Object?> candidateData,
            List rejectedData,
          ) =>
              buildTimeslots(context, schedulerSettings),
        ),
      ),
    );
  }

  Widget buildTimeslots(
    BuildContext context,
    SchedulerSettings schedulerSettings,
  ) {
    var borderSide = BorderSide(
      color: schedulerSettings.getIntervalLineColor(context),
      width: schedulerSettings.dividerLineWidth,
    );
    var isVertical = widget.flowOrientation == FlowOrientation.vertical;

    List<Widget> timeSlotWidgets = getTimeSlotWrapper(
      buildTimeslot(schedulerSettings, isVertical, borderSide),
    );

    return isVertical
        ? Row(children: timeSlotWidgets)
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: timeSlotWidgets,
          );
  }

  Widget buildTimeslot(
    SchedulerSettings schedulerSettings,
    bool isVertical,
    BorderSide borderSide,
  ) {
    var borderSideBottom = BorderSide(
      color: widget.showBottomBorder
          ? schedulerSettings.getIntervalLineColor(context)
          : Colors.transparent,
      width: schedulerSettings.dividerLineWidth,
    );

    return Stack(
      children: [
        Container(
          color: isSelected && !SchedulerViewHelper.isMobileLayout(context)
              ? schedulerSettings.selectionBackgroundColor
              : widget.backgroundColor,
          child: Container(
            height: widget.height,
            width: widget.width,
            decoration: widget.isGroupEnd
                ? BoxDecoration(
                    border: !widget.showBorders
                        ? null
                        : isVertical
                            ? Border(top: borderSide)
                            : Border(
                                left: borderSide,
                                bottom: borderSideBottom,
                              ),
                  )
                : DottedDecoration(
                    dash: const [1, 2],
                    color: schedulerSettings.getIntervalLineColor(context),
                    strokeWidth: schedulerSettings.dividerLineWidth,
                    shape: Shape.line,
                    linePosition:
                        isVertical ? LinePosition.top : LinePosition.left,
                  ),
            child: widget.builder != null
                ? widget.builder!(context, isSelected)
                : !widget.showDivider
                    ? Container()
                    : Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          color: schedulerSettings.getDividerLineColor(context),
                          width: schedulerSettings.dividerLineWidth,
                        ),
                      ),
          ),
        ),

        //--hover border
        if (isHovered)
          Container(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
              border: Border.all(
                color: schedulerSettings.getCellHoverBorderColor(context),
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> getTimeSlotWrapper(Widget timeSlotsWidget) {
    if (widget.header != null) {
      return [widget.header!, Expanded(child: timeSlotsWidget)];
    } else if (widget.builder != null) {
      return [
        widget.builder!(context, isSelected),
        Expanded(child: timeSlotsWidget),
      ];
    }

    return [Expanded(child: RepaintBoundary(child: timeSlotsWidget))];
    // return [Expanded(child: Stack(children: [timeSlotsWidget, Align(child: Text(widget.startDate.toString()))]))];
  }
}
