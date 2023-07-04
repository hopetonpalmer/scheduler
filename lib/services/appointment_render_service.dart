import 'dart:core';
import 'dart:math';

import 'package:dart_date/dart_date.dart';
import 'package:flutter/widgets.dart';
import 'package:scheduler/date_range.dart';
import 'package:scheduler/extensions/date_extensions.dart';
import 'package:scheduler/models/appointment_item.dart';
import 'package:scheduler/scheduler.dart';
import 'package:scheduler/services/scheduler_service.dart';
import 'package:scheduler/time_slot.dart';
import 'package:list_ext/list_ext.dart';

import '../mixins/event_layout_mixin.dart';
import 'event_position_service.dart';

class AppointmentRenderService with EventLayoutMixin {
  final bool fixedSize;
  final AnchorPosition fixedPosition;
  final double pixelsPerMinute;
  final double gutterSize;
  final TimeSlot timeSlotTemplate;
  final Rect calendarRect;
  final double dayWidth;
  final DateTime startDate;
  final double fixedHeight;

  const AppointmentRenderService(
    this.pixelsPerMinute,
    this.fixedPosition,
    this.timeSlotTemplate,
    this.calendarRect,
    this.dayWidth,
    this.startDate,
    {
    this.fixedSize = false,
    this.fixedHeight = 50,
    this.gutterSize = 10,
  });

  EventPositionService get appointmentLayoutService => EventPositionService.instance;

  FlowOrientation get timeOrientation {
    return fixedPosition == AnchorPosition.top ? FlowOrientation.vertical : FlowOrientation.horizontal;
  }

  getMaxWidth(Rect dayRect) => dayRect.width - gutterSize;
  getMaxHeight(Rect dayRect) => dayRect.height -gutterSize;
  double getPositionMinutes(AppointmentItem item)  {
    if (fixedPosition == AnchorPosition.top) {
      return item.startDate.totalMinutes;
    }

    return item.startDate.differenceInMinutes(startDate).toDouble();
  }

  positionAppointment(AppointmentItem appointmentItem, Rect dayRect, Size offset) {
    double totalMinutes = getPositionMinutes(appointmentItem);  // appointmentItem.startDate.totalMinutes;
    //appointmentItem.geometry.offset = Offset(dayRect.left, dayRect.top);
    if (fixedPosition == AnchorPosition.top) {
      appointmentItem.geometry.left = dayRect.left - offset.width;
      appointmentItem.geometry.top = (totalMinutes * pixelsPerMinute) - offset.height;
    } else {
      appointmentItem.geometry.left = (totalMinutes * pixelsPerMinute) - offset.width;
      appointmentItem.geometry.top = dayRect.top; // + offset.height;
    }
  }

  sizeAppointment(AppointmentItem appointmentItem, Rect dayRect) {
    // Ensures that rects can fit side by side as close as possible without
    // overlapping when they share the same end and start times.
    const double sharedTimeSpace = 0.001;

    double length = (pixelsPerMinute * appointmentItem.duration.inMinutes) - sharedTimeSpace;
    if (fixedPosition == AnchorPosition.top) {
      appointmentItem.geometry.size = Size(getMaxWidth(dayRect), length);
    } else {
      appointmentItem.geometry.size = Size(length, fixedSize ? fixedHeight : getMaxHeight(dayRect));
    }
  }

  updateAppointmentGeometry(AppointmentItem appointmentItem, Rect dayRect, Size offset) {
    sizeAppointment(appointmentItem, dayRect);
    positionAppointment(appointmentItem, dayRect, offset);
  }

  scrollAppointment(AppointmentItem appointmentItem, double offset) {
    double totalMinutes = getPositionMinutes(appointmentItem);
    AppointmentGeometry geometry = appointmentItem.geometry;
    if (fixedPosition == AnchorPosition.top) {
      geometry.top = (totalMinutes * pixelsPerMinute) - offset;
    } else {
      geometry.left = (totalMinutes * pixelsPerMinute) - offset;
    }
  }


  List<DateTime> datesOfPosChange(AppointmentItem appointmentItem, Offset delta) {
    int borderOffset = 1;
    delta = Offset(delta.dx+borderOffset, delta.dy-borderOffset);
    Duration durationChange;
    double change = fixedPosition == AnchorPosition.top ? delta.dy : delta.dx;

    if (fixedPosition == AnchorPosition.top) {
      int dayIndex = (appointmentItem.geometry.left + delta.dx - calendarRect.left) ~/ dayWidth;
      DateTime targetDate = startDate.incDays(dayIndex);
      int minutes = change ~/pixelsPerMinute;
      int dayDiff = targetDate.diffInDays(appointmentItem.startDate.startOfDay);
      durationChange = Duration(days: dayDiff, minutes: minutes);
    } else {
      int minutesDiff = change ~/ pixelsPerMinute;
      durationChange = Duration(minutes: minutesDiff);
    }
    DateTime newStartDate = appointmentItem.appointment.startDate.add(durationChange);
    if (SchedulerService().schedulerSettings.snapToTimeSlot) {
      int timeSlotMins = timeSlotTemplate.duration.inMinutes.remainder(60);
      newStartDate = newStartDate.closestMinute(timeSlotMins, before: true);
    }
    DateTime newEndDate = newStartDate.add(appointmentItem.appointment.duration);

    return [newStartDate, newEndDate];
  }

  List<DateTime> datesOfSizeChange(AppointmentItem appointmentItem, Offset delta, SizingDirection changeDirection) {
     DateTime newStartDate = appointmentItem.appointment.startDate;
     DateTime newEndDate = appointmentItem.appointment.endDate;
     int startChange = 0;
     int endChange = 0;

     switch (changeDirection) {
       case SizingDirection.left:
         startChange = delta.dx ~/ pixelsPerMinute;
         break;
       case SizingDirection.right:
         endChange = delta.dx ~/ pixelsPerMinute;
         break;
       case SizingDirection.up:
         startChange = delta.dy ~/ pixelsPerMinute;
         break;
       case SizingDirection.down:
         endChange = delta.dy ~/ pixelsPerMinute;
         break;
       case SizingDirection.none:
         // TODO: Handle this case.
         break;
     }

     newStartDate = newStartDate.addMinutes(startChange);
     newEndDate = newEndDate.addMinutes(endChange);

     if (SchedulerService().schedulerSettings.snapToTimeSlot) {
       int timeSlotMins = timeSlotTemplate.duration.inMinutes.remainder(60);
       newStartDate = newStartDate.closestMinute(timeSlotMins, before: true);
       newEndDate = newEndDate.closestMinute(timeSlotMins, before: false);
     }

     return [newStartDate, newEndDate];
  }


  measureAppointments(DateRange dateRange, Rect workArea, List<AppointmentItem> visibleItems) {
    double margin = schedulerService.appointmentSettings.spaceBetween;
    double maxRight = workArea.right - gutterSize;
    Rect clientRect = Rect.fromLTWH(workArea.left+1, workArea.top, maxRight - workArea.left - 1, workArea.height);
    List<AppointmentItem> appointmentItemsOfDay = visibleItems.where((a) => dateRange.inRange(a.startDate) || dateRange.inRange(a.endDate)).toList();
    if (appointmentItemsOfDay.isEmpty) {
      return;
    }
    appointmentItemsOfDay.sort((a, b) => a.startDate.compareTo(b.startDate));

    //--give all appointment rectangles the full size
    for (AppointmentItem apptItem in appointmentItemsOfDay) {
      updateAppointmentGeometry(apptItem, workArea, Size.zero);
    }

    if (!fixedSize) {
      appointmentLayoutService.positionVerticalEvents(appointmentItemsOfDay, clientRect, margin);
    } else {
     appointmentLayoutService.positionHorizontalEvents(appointmentItemsOfDay, margin);
    }
  }

  List<Widget> renderAppointments(List<AppointmentItem> visibleItems) {
    List<Widget> result = [];
    int index = 0;
    for (AppointmentItem appointmentItem in visibleItems) {
      //var key = GlobalKey(); //-- adding a key causes the appointments to re-animate
      result.add(AppointmentWidget(index, appointmentItem, this, timeOrientation));
      index++;
    }
    //result.add(const SizingFeedbackContainer());

    return result;
  }

}

class AppointmentGeometry {
  Size size = Size.zero;

  double _left = 0;
  double get left => _left + offset.dx;
  set left(double value) {
    _left = value;
  }

  double _top = 0;
  double get top => _top + offset.dy;
  set top(double value) {
    _top = value;
  }

  Rect get rect {
    return Rect.fromLTWH(left, top, size.width, size.height);
  }

  set rect(Rect value) {
    _top = value.top;
    _left = value.left;
    size = Size(value.width, value.height);
  }

  Offset offset = Offset.zero;
  int spreadCount = 1;
}
