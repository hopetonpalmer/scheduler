import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scheduler/date_range.dart';
import 'package:scheduler/extensions/date_extensions.dart';
import 'package:scheduler/scheduler.dart';
import 'package:scheduler/services/appointment_render_service.dart';
import 'package:scheduler/services/scheduler_service.dart';
import 'package:scheduler/time_slot.dart';
import 'package:dart_date/dart_date.dart';
import 'package:scheduler/widgets/current_time_indicator.dart';
import 'package:scheduler/widgets/scroll_aware_stack.dart';


import '../../widgets/scheduler_grid/scheduler_grid.dart';

class EventGrid extends StatefulWidget {
  final DateTime date;
  final int days;
  final BoxConstraints constraints;
  final double intervalWidth;
  final double intervalHeight;
  final bool showCurrentTimeIndicator;
  final Axis orientation;
  final IntervalType intervalType;
  final double headerThickness;
  final CalendarViewType calendarViewType;
  const EventGrid({
    Key? key,
    required this.date,
    required this.days,
    required this.constraints,
    required this.intervalHeight,
    required this.intervalWidth,
    required this.showCurrentTimeIndicator,
    required this.orientation,
    required this.intervalType,
    required this.headerThickness,
    required this.calendarViewType,
  }) : super(key: key);

  double get height => constraints.maxHeight;
  double get width => constraints.maxWidth;
  int get interval => schedulerService.dayViewSettings.intervalMinute.value;
  int get slotCount => intervalCount * days;
  int get slotsPerTimeBlock => 60 ~/ interval;
  int get intervalCount => slotsPerTimeBlock * 24;
  double get pixelsPerMinute => intervalHeight / interval;

  @override
  _EventGridState createState() => _EventGridState();
}

class _EventGridState extends State<EventGrid> {
  List<TimeSlot> timeSlots = [];
  AppointmentRenderService? appointmentRenderService;
  late final ScrollController scrollController;

  @override
  void initState() {
    scrollController = ScrollController(initialScrollOffset: Scheduler.currentScrollPos);
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    timeSlots.clear();
    List<DateTime> dates =
    widget.date.incDates(widget.days, (date, delta) => date.incDays(delta));
    bool todayInDates = dates.any((x) => x.isToday);
    Scheduler scheduler = Scheduler.of(context);
    SchedulerDataSource dataSource = scheduler.dataSource!;
    double timebarThickness = widget.headerThickness;
    double dayWidth = (widget.width - timebarThickness) / widget.days;
    double height = widget.intervalCount * widget.intervalHeight;
    Rect calendarRect = Rect.fromLTWH(
      timebarThickness,
      0,
      widget.width - timebarThickness,
      widget.height,
    );
    double pixelsPerMinute = height / scheduler.schedulerSettings.dayDuration.inMinutes;
    double activeDayLeft = min(calendarRect.width + timebarThickness,
      timebarThickness + (dayWidth * DateTime.now().startOfDay.diffInDays(widget.date.startOfDay)),
    );

    var timeSlotTemplate = TimeSlot(
      widget.date,
      widget.date.incMinutes(widget.interval),
      widget.calendarViewType,
      widget.intervalType,
      widget.intervalHeight,
    );

    appointmentRenderService = AppointmentRenderService(
      widget.pixelsPerMinute,
      widget.orientation == Axis.vertical ? AnchorPosition.top : AnchorPosition.left,
      timeSlotTemplate,
      calendarRect,
      dayWidth,
      widget.date,
    );

    List<Widget>? renderAppointments() {
      dataSource.visibleDateRange.setRange(widget.date, widget.date.incDays(widget.days, true));
      var visibleItems = dataSource.visibleAppointmentItemsByDay;
      for (int i = 0; i < widget.days; i++) {
        DateTime date = widget.date.incDays(i);
        Rect dayRect = Rect.fromLTWH(timebarThickness + (dayWidth * i), 0, dayWidth, height);
        appointmentRenderService?.measureAppointments(
          DateRange(date, date),
          dayRect,
          visibleItems,
        );
      }

      return appointmentRenderService?.renderAppointments(visibleItems);
    }

    return Stack(
      children: [
        NotificationListener<ScrollUpdateNotification>(
          onNotification: (notification) {
            var position = notification.metrics.pixels;
            Scheduler.of(context).setSchedulerScrollPos(position);

            return false;
          },
          child: SchedulerGrid(
            clientRect: calendarRect,
            headerPosition: widget.orientation == Axis.vertical ? HeaderPosition.columnStart : HeaderPosition.rowStart,
            rulerCellSize: widget.orientation == Axis.vertical ? Size(
              widget.headerThickness,
              widget.intervalHeight,
            ) : Size(
              widget.intervalWidth,
              widget.headerThickness,
            ),
            orientation: widget.orientation,
            gridDates: dates,
            slotsPerTimeBlock: widget.slotsPerTimeBlock,
            cellSize: Size(dayWidth, widget.intervalHeight),
            intervalType: widget.intervalType,
            colCount: dates.length,
            rowCount: widget.intervalCount,
            scrollController: scrollController,
          ),
        ),
        ValueListenableBuilder(
          valueListenable: dataSource,
          builder: (BuildContext context, value, Widget? child) =>
              ScrollAwareStack(
                clientConstraints: widget.constraints,
                scrollController: scrollController,
                children: [...?renderAppointments()],
              ),
        ),
        if (widget.showCurrentTimeIndicator && todayInDates)
          CurrentTimeIndicator(
            startPos: timebarThickness,
            activePos: activeDayLeft,
            activeLength: dayWidth,
            clientHeight: height,
            clientWidth: widget.width,
          ),
      ],
    );
  }

}
