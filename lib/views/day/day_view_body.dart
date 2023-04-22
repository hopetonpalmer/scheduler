import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scheduler/date_range.dart';
import 'package:scheduler/extensions/date_extensions.dart';
import 'package:scheduler/scheduler.dart';
import 'package:scheduler/services/appointment_render_service.dart';
import 'package:scheduler/services/scheduler_service.dart';
import 'package:scheduler/time_slot.dart';
import 'package:scheduler/views/day/day_view_interval.dart';
import 'package:dart_date/dart_date.dart';
import 'package:scheduler/widgets/current_time_indicator.dart';
import 'package:scheduler/widgets/scroll_aware_stack.dart';
import 'package:scheduler/widgets/timeslot_cell.dart';

import '../../widgets/scheduler_grid/scheduler_grid.dart';

class DayViewBody extends StatefulWidget {
  final DateTime date;
  final int days;
  final BoxConstraints constraints;
  const DayViewBody({
    Key? key,
    required this.date,
    required this.days,
    required this.constraints,
  }) : super(key: key);

  double get height => constraints.maxHeight;
  double get width => constraints.maxWidth;
  int get interval => schedulerService.dayViewSettings.intervalMinute.value;
  int get slotCount => intervalCount * days;
  int get slotsPerHour => 60 ~/ interval;
  int get intervalCount => slotsPerHour * 24;
  double get intervalHeight => max(schedulerService.dayViewSettings.intervalMinHeight, height / intervalCount).ceilToDouble();
  double get pixelsPerMinute => intervalHeight / interval;

  @override
  _DayViewBodyState createState() => _DayViewBodyState();
}

class _DayViewBodyState extends State<DayViewBody> {
  List<TimeSlot> timeSlots = [];
  AppointmentRenderService? appointmentRenderService;
  late final ScrollController scrollController;

  @override
  void initState() {
    //schedulerService.scheduler.initializeSchedulerScrollPos(widget.pixelsPerMinute * DateTime.now().totalMinutes);
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
    List<DateTime> dates = widget.date.incDates(widget.days, (date, delta) => date.incDays(delta));
    bool todayInDates = dates.any((x) => x.isToday);
    Scheduler scheduler = Scheduler.of(context);
    SchedulerDataSource dataSource = scheduler.dataSource!;
    double timebarWidth = scheduler.dayViewSettings.timebarFullWidth;
    double dayWidth = (widget.width - timebarWidth) / widget.days;
    double height = widget.intervalCount * widget.intervalHeight;
    Rect calendarRect = Rect.fromLTWH(timebarWidth, 0, widget.width - timebarWidth, widget.height);
    double pixelsPerMinute = height / scheduler.schedulerSettings.dayDuration.inMinutes;
    double activeDayLeft = min(calendarRect.width + timebarWidth, timebarWidth + (dayWidth *
                DateTime.now().startOfDay.diffInDays(widget.date.startOfDay)));

    var timeSlotSample = TimeSlot(
        widget.date,
        widget.date.incMinutes(widget.interval),
        CalendarViewType.day,
        IntervalType.minute,
        widget.intervalHeight);

    appointmentRenderService = AppointmentRenderService(
        pixelsPerMinute,
        AnchorPosition.top,
        timeSlotSample,
        calendarRect,
        dayWidth,
        widget.date);

    List<Widget>? renderAppointments() {
      dataSource.visibleDateRange.setRange(widget.date, widget.date.incDays(widget.days, true));
      var visibleItems = dataSource.visibleAppointmentItemsByDay;
      for (int i = 0; i < widget.days; i++) {
        DateTime date = widget.date.incDays(i);
        Rect dayRect = Rect.fromLTWH(timebarWidth + (dayWidth * i), 0, dayWidth, height);
        appointmentRenderService?.measureAppointments(DateRange(date, date), dayRect, visibleItems);
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
            headerPosition: HeaderPosition.columnStart,
            rulerCellSize: Size(schedulerService.dayViewSettings.timebarFullWidth,
                widget.intervalHeight),
            direction: Axis.vertical,
            gridDates: dates,
            slotsPerTimeBlock: widget.slotsPerHour,
            cellSize: Size(dayWidth, widget.intervalHeight),
            intervalType: IntervalType.minute,
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
                  children: [...?renderAppointments()]),
        ),
        if (todayInDates)
          CurrentTimeIndicator(
              startPos: timebarWidth,
              activePos: activeDayLeft,
              activeLength: dayWidth,
              clientHeight: height,
              clientWidth: widget.width),
      ],
    );
  }

  List<Widget> buildIntervalTimeSlots(int intervalIndex) {
    List<Widget> result = [];
    for (int i = 0; i < widget.days; i++) {
      GlobalKey key = GlobalKey();
      DateTime date = widget.date
          .incDays(i)
          .startOfDay
          .incMinutes(widget.interval * intervalIndex);
      DateTime endDate = date.incMinutes(widget.interval);
      TimeSlot timeSlot = TimeSlot(date, endDate, CalendarViewType.day,
          IntervalType.minute, widget.intervalHeight);
      timeSlots.add(timeSlot);
      //-- time bar interval header (combined to create the timebar timebar)
      if (i == 0) {
        result.add(DayViewInterval(date: date, height: widget.intervalHeight));
      }
      result.add(Expanded(
        child: TimeslotCell(
          timeSlot: timeSlot,
          isGroupEnd: intervalIndex % widget.slotsPerHour == 0,
          height: widget.intervalHeight,
          key: key,
        ),
      ));
    }
    return result;
  }
}
