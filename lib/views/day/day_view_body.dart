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
import 'package:scheduler/widgets/time_cell_block.dart';
import 'package:scheduler/widgets/timeslot_cell.dart';

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
  int get interval => SchedulerService().dayViewSettings.intervalMinute.value;
  int get slotCount => intervalCount * days;
  int get slotsPerHour => 60 ~/ interval;
  int get intervalCount => slotsPerHour * 24;
  double get intervalHeight => max(
          SchedulerService().dayViewSettings.intervalMinHeight,
          height / intervalCount)
      .ceilToDouble();

  @override
  _DayViewBodyState createState() => _DayViewBodyState();
}

class _DayViewBodyState extends State<DayViewBody> {
  double scrollPos = 0;
  final _scrollController = ScrollController();
  List<TimeSlot> timeSlots = [];
  AppointmentRenderService? appointmentRenderService;

  @override
  void initState() {
    super.initState();
 /*   SchedulerService().scheduler.dataSource!.visibleDateRange
        .setRange(widget.date, widget.date.incDays(widget.days, true));
    SchedulerService().scheduler.controller.addListener(() {
      SchedulerService().scheduler.dataSource!.visibleDateRange
          .setRange(SchedulerService().scheduler.controller.startDate, widget.date.incDays(widget.days, true));
    });*/
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    timeSlots.clear();
    List<DateTime> dates =
        widget.date.incDates(widget.days, (date, delta) => date.incDays(delta));
    Scheduler scheduler = Scheduler.of(context);
    SchedulerDataSource dataSource = scheduler.dataSource!;
    double timebarWidth = scheduler.dayViewSettings.timebarWidth;
    double dayWidth = (widget.width - timebarWidth) / widget.days;
    double activeDayLeft = timebarWidth +
        (dayWidth *
            DateTime.now().startOfDay.differenceInDays(widget.date.startOfDay));
    double height = widget.intervalCount * widget.intervalHeight;
    Rect calendarRect = Rect.fromLTWH(
        timebarWidth, 0, widget.width - timebarWidth, widget.height);
    double pixelsPerMinute =
        height / scheduler.schedulerSettings.dayDuration.inMinutes;
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
      dataSource.visibleDateRange
          .setRange(widget.date, widget.date.incDays(widget.days, true));
      var visibleItems = dataSource.visibleAppointmentItemsByDay;
      for (int i = 0; i < widget.days; i++) {
        DateTime date = widget.date.incDays(i);
        Rect dayRect =
            Rect.fromLTWH(timebarWidth + (dayWidth * i), 0, dayWidth, height);

        appointmentRenderService?.measureAppointments(
            DateRange(date, date), dayRect, visibleItems);
      }
      return appointmentRenderService?.renderAppointments(visibleItems);
    }

    return Stack(
      //scrollController: _scrollController,
      children: [
        NotificationListener<ScrollUpdateNotification>(
          onNotification: (notification) {
            Scheduler.of(context)
                .notifySchedulerScrollPos(notification.metrics.pixels);
            return false;
          },
          child: ListView.builder(
              controller: _scrollController,
              physics: const ClampingScrollPhysics(),
              itemCount: widget.intervalCount, // 24
              itemBuilder: (context, index) {
                var key = GlobalKey();
                return Row(key: key, children: buildIntervalTimeSlots(index));
                return TimeCellBlock(
                  cellHeaderPosition: HeaderPosition.columnStart,
                  cellHeaderSize:
                      Size(SchedulerService().dayViewSettings.timebarWidth, 0),
                  direction: Axis.vertical,
                  cellCount: widget.slotsPerHour,
                  blockDates: dates,
                  cellSize: Size(dayWidth, widget.intervalHeight),
                  intervalType: IntervalType.minute,
                );
              }),
        ),
        ValueListenableBuilder(
          valueListenable: dataSource,
          builder: (BuildContext context, value, Widget? child) =>
              ScrollAwareStack(
                  scrollController: _scrollController,
                  children: [...?renderAppointments()]),
        ),
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
      //-- time bar interval header (combined to create the ruler)
      if (i == 0) {
        result.add(DayViewInterval(date: date, height: widget.intervalHeight));
      }
      result.add(Expanded(
        child:
        TimeslotCell(
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
