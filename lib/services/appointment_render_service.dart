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

class AppointmentRenderService {
  final bool fixedSize;
  final double margin;
  final AnchorPosition fixedPosition;
  final double pixelsPerMinute;
  final double gutterSize;
  final TimeSlot timeSlotSample;
  final Rect calendarRect;
  final double dayWidth;
  final DateTime startDate;
  final double fixedHeight;

  const AppointmentRenderService(
    this.pixelsPerMinute,
    this.fixedPosition,
    this.timeSlotSample,
    this.calendarRect,
    this.dayWidth,
    this.startDate,
    {
    this.fixedSize = false,
    this.fixedHeight = 50,
    this.margin = 1,
    this.gutterSize = 10,
  });

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
      int dayDiff = targetDate.differenceInDays(appointmentItem.startDate.startOfDay);
      durationChange = Duration(days: dayDiff, minutes: minutes);
    } else {
      int minutesDiff = change ~/ pixelsPerMinute;
      durationChange = Duration(minutes: minutesDiff);
    }
    DateTime newStartDate = appointmentItem.appointment.startDate.add(durationChange);
    if (SchedulerService().schedulerSettings.snapToTimeSlot) {
      int timeSlotMins = timeSlotSample.duration.inMinutes.remainder(60);
      newStartDate = newStartDate.closestMinute(timeSlotMins, before: true);
    }
    DateTime newEndDate = newStartDate.add(appointmentItem.appointment.duration);
    return [newStartDate, newEndDate];
  }


  measureAppointments(DateRange dateRange, Rect workArea, List<AppointmentItem> visibleItems) {
    List<AppointmentItem> appointmentItemsOfDay = visibleItems.where((a) => dateRange.inRange(a.startDate) || dateRange.inRange(a.endDate)).toList();
    if (appointmentItemsOfDay.isEmpty) {
      return;
    }
    appointmentItemsOfDay.sort((a, b) => a.startDate.compareTo(b.startDate));

    //--give all appointment rectangles the full size
    for (AppointmentItem apptItem in appointmentItemsOfDay) {
      updateAppointmentGeometry(apptItem, workArea, Size.zero);
    }

    //-- identify all overlapping appointments and set the number of overlaps by adjusting the spread
/*    var spreadManager = SpreadManager();
    for (AppointmentItem item in appointmentItemsOfDay) {
       spreadAppointment(item, appointmentItemsOfDay, spreadManager);
    }*/


    spreadAppointments(appointmentItemsOfDay, workArea);
    //ensureMinWidth(appointmentItemsOfDay, workArea);


    //-- Reset the top or left of the geometry to fix the overlaps.
    //-- All overlaps are usually resolved in 1 pass, but multiple passes are
    //-- sometimes required depending on the complexity of the overlaps.
    int maxPass = 10;
    int passes = 0;
    while (passes < maxPass && findOverlaps(appointmentItemsOfDay).isNotEmpty){
      for (AppointmentItem item in appointmentItemsOfDay) {
        if (fixedSize) {
          repositionFixedOverlaps(item, appointmentItemsOfDay);
        } else {
          repositionFixedOverlaps(item, appointmentItemsOfDay);
        }
      }
      passes++;
    }


    //--final pass to fill gaps and resize to fit if necessary
    if (!fixedSize){
      double maxRight = workArea.right - gutterSize;
      //fixMarginOverflows(appointmentItemsOfDay, maxRight, workArea);
      fixGaps(appointmentItemsOfDay, maxRight, workArea);
    }
  }


  void fixGaps(List<AppointmentItem> appointmentItems, double maxRight, Rect dayRect) {
    for (AppointmentItem apptItem in appointmentItems) {
      Rect rect = apptItem.geometry.rect;

      //-- fill gaps on left if any
      /*  Rect rectToLeft = Rect.fromLTWH(dayRect.left, rect.top, rect.left, rect.height);
      List<AppointmentItem> apptsToLeft = overlapped(apptItem, appointmentItems, rect: rectToLeft);
      apptsToLeft.sort((a, b) => a.geometry.left.compareTo(b.geometry.left));
      if (apptsToLeft.isNotEmpty) {
        double left = apptsToLeft.last.geometry.rect.right + margin;
        apptItem.geometry.left = left;
      }*/

      //-- fill gaps on right if any
      Rect rectToRight = Rect.fromLTWH(rect.left, rect.top, maxRight-rect.left, rect.height);
      List<AppointmentItem> apptsToRight = overlapped(apptItem, appointmentItems, rect: rectToRight);
      apptsToRight.sort((a, b) => a.geometry.left.compareTo(b.geometry.left));
      bool hasRightAppts = apptsToRight.isNotEmpty;
      double rightPos = hasRightAppts ? apptsToRight.first.geometry.left - margin : maxRight;

      double width = rightPos-apptItem.geometry.left;
      if (width < rect.width) {
        //repositionOverlaps(appt, appointments);
        if (hasRightAppts) {
          apptsToRight.first.geometry.left = apptItem.geometry.rect.right + margin;
        }
      } else {
        apptItem.geometry.size = Size(width, rect.height);
      }
      if (apptItem.geometry.rect.right > maxRight) {
        width = apptItem.geometry.size.width - (apptItem.geometry.rect.right - maxRight);
        apptItem.geometry.size = Size(width, rect.height);
      }
    }
  }

  void fixMarginOverflows(List<AppointmentItem> appointmentItems, double maxRight, Rect dayRect) {
    for (AppointmentItem item in appointmentItems) {
      if (item.geometry.rect.right > maxRight ) {
        //var minWidth = getMaxWidth(dayRect) / item.geometry.spreadCount;
        double diff = item.geometry.rect.right - maxRight;
        Rect fullRect = Rect.fromLTWH(dayRect.left, item.geometry.rect.top, getMaxWidth(dayRect), item.geometry.rect.height);
        List<AppointmentItem> spreadApptItems = overlapped(item, appointmentItems, rect: fullRect);
        double spreadSize = diff / spreadApptItems.length;
        for (AppointmentItem spreadAppt in spreadApptItems) {
          Rect rect = spreadAppt.geometry.rect;
          spreadAppt.geometry.size = Size(rect.width - spreadSize, rect.height);
          if (rect.left > dayRect.left) {
            spreadAppt.geometry.left -= spreadSize;
          }
        }
        item.geometry.left -= spreadSize;
      }
    }
  }

  void ensureMinWidth(List<AppointmentItem> appointmentItems, Rect dayRect) {
    if (fixedSize) {
      return;
    }
    for (AppointmentItem item in appointmentItems) {
      var minWidth = getMaxWidth(dayRect) / item.geometry.spreadCount;
      if (item.geometry.rect.width < minWidth ) {
        double diff = minWidth - item.geometry.rect.width;
        Rect fullRect = Rect.fromLTWH(dayRect.left, item.geometry.rect.top, getMaxWidth(dayRect), item.geometry.rect.height);
        List<AppointmentItem> spreadApptItems = overlapped(item, appointmentItems, rect: fullRect);
        double diffSplit = diff / spreadApptItems.length;
        for (AppointmentItem spreadAppt in spreadApptItems) {
          Rect rect = spreadAppt.geometry.rect;
          spreadAppt.geometry.size = Size(rect.width - diffSplit, rect.height);
        }
        Rect rect = item.geometry.rect;
        item.geometry.size = Size(rect.width + diff, rect.height);
      }
    }
  }

  resizeAppointment(AppointmentItem item, SpreadManager spreadManager) {
    int spreadCount = max(1, spreadManager.getSpreadCount(item.appointment));
    if (!fixedSize) {
      item.geometry.spreadCount = spreadCount;
      var size = item.geometry.size;
      if (fixedPosition == AnchorPosition.top) {
        var width = (size.width / spreadCount) - margin;
        item.geometry.size = Size(width, size.height);
      } else {
        var height = (size.height / spreadCount) - margin;
        item.geometry.size = Size(size.height, height);
      }
    }
  }

  repositionFixedOverlaps(AppointmentItem appointmentItem, List<AppointmentItem> appointmentItems) {
    var index = appointmentItems.indexOf(appointmentItem);
    for (int i = 0; i < index; i++) {
      var appt = appointmentItems[i];
      if (appt.geometry.rect.overlaps(appointmentItem.geometry.rect)) {
        if (fixedPosition == AnchorPosition.top) {
          appointmentItem.geometry.left = appt.geometry.rect.right + margin;
        } else {
          appointmentItem.geometry.top = appt.geometry.rect.bottom + margin;
        }
        repositionFixedOverlaps(appointmentItem, appointmentItems);
        return;
      }
    }
  }


  repositionOverlaps(AppointmentItem appointmentItem, List<AppointmentItem> appointmentItems) {
    for (AppointmentItem appt in appointmentItems) {
      if (appt != appointmentItem && appt.geometry.rect.overlaps(appointmentItem.geometry.rect)) {
        if (fixedPosition == AnchorPosition.top) {
          appt.geometry.left = appointmentItem.geometry.left + appointmentItem.geometry.rect.width + margin;
        } else {
          appt.geometry.top = appointmentItem.geometry.top + appointmentItem.geometry.rect.height + margin;
        }
      }
    }
  }

  List<AppointmentItem> findOverlaps(List<AppointmentItem> appointmentItems) {
    List<AppointmentItem> result = [];
    for (AppointmentItem item in appointmentItems) {
      result = overlapped(item, appointmentItems);
      if (result.isNotEmpty) {
        break;
      }
    }
    return result;
  }

  List<AppointmentItem> overlapped(AppointmentItem appointmentItem, List<AppointmentItem> appointmentItems,{bool inclusive = false, Rect? rect}) {
    rect ??= appointmentItem.geometry.rect;
    var result = appointmentItems.where((item) => item != appointmentItem && item.geometry.rect.overlaps(rect!)).toList();
    if (result.isNotEmpty && inclusive) {
      result.insert(0, appointmentItem);
    }
    return result;
  }

  spreadAppointments(List<AppointmentItem> items, Rect dayRect) {
    if (fixedSize) {
      return;
    }
    var spreadManager = SpreadManager();

    doSpread(AppointmentItem item, Rect? rect) {
      List<Appointment> overlappedItems = overlapped(item, items, inclusive: true, rect: rect).map((a) => a.appointment).toList();
      spreadManager.spreads.add(Spread()..appointment = item.appointment ..spreadAppts = overlappedItems);
    }

    for (var item in items) {
      if (fixedSize) {
         doSpread(item, null);
      } else {
        var itemRect = item.geometry.rect;
        var timeSlotHeight = timeSlotSample.size;
        Rect rect = Rect.fromLTWH(dayRect.left, itemRect.top, dayRect.width, timeSlotHeight);
        while (rect.top < itemRect.bottom) {
            doSpread(item, rect);
            rect = Rect.fromLTWH(rect.left, rect.top + timeSlotHeight, rect.width, rect.height);
        }
      }
    }
    for (var item in items) {
       resizeAppointment(item, spreadManager);
    }
  }

  spreadAppointment(AppointmentItem appointmentItem, List<AppointmentItem> appointmentItems, SpreadManager spreadManager) {
    int spreadCount = appointmentItems.fold(1, (value, item) {
      if (item != appointmentItem && item.geometry.rect.overlaps(appointmentItem.geometry.rect)) {
        return value + 1;
      }
      return value;
    });
    appointmentItem.geometry.spreadCount = spreadCount;
    if (!fixedSize) {
      var size = appointmentItem.geometry.size;
      if (fixedPosition == AnchorPosition.top) {
        var width = (size.width / spreadCount) - margin;
        appointmentItem.geometry.size = Size(width, size.height);
      } else {
        var height = (size.height / spreadCount) - margin;
        appointmentItem.geometry.size = Size(size.height, height);
      }
    }
  }


  List<Widget> renderAppointments(List<AppointmentItem> visibleItems) {
    List<Widget> result = [];
    for (AppointmentItem appointmentItem in visibleItems) {
      //var key = GlobalKey();
      result.add(AppointmentWidget(appointmentItem, this, timeOrientation));
    }
    return result;
  }

  /*List<SizingGroup> getSizingGroups(List<Appointment> appointments, DateTime date) {
    bool newGroup = true;
    List<TimeSlot> timeSlots = this.timeSlots.where((ts) => ts.startDate.isSameDay(date)).toList();
    List<SizingGroup> groups = [];
    for (TimeSlot timeSlot in timeSlots) {
      List<Appointment> apptsInRange = appointments.where((a) => timeSlot.startDate.isBetween(a.startDate, a.endDate) ||
          timeSlot.endDate.isBetween(a.startDate, a.endDate) ).toList();

      if (apptsInRange.isEmpty) {
        newGroup = true;
        continue;
      }
      if (groups.isNotEmpty) {
        newGroup = !groups.last.appointments.containsAll(apptsInRange);
            //groups.last.appointments.where((g) => apptsInRange.contains(g)).length != apptsInRange.length;
      }
      if (newGroup) {
        newGroup = false;
        groups.add(SizingGroup(apptsInRange.length, apptsInRange));
      } else {
        var group = groups.last;
        group.maxSpread = max(apptsInRange.length, group.maxSpread);
        group.appointments.addAll(apptsInRange.where((a) => !group.appointments.contains(a)));
      }
    }
    return groups;
  }*/

}

class SpreadManager {
  Spread? findSpread(Appointment appt){
    return spreads.firstWhereOrNull((s) => s.appointment == appt);
  }
  addSpread(Appointment appt1, Appointment appt2){
    if (spreadExists(appt1, appt2)) {
      // var spread = Spread();
       //spread.spreadAppts.
    }
  }
  bool spreadExists(Appointment appt1, Appointment appt2) {
     return spreads.firstWhereOrNull((s) => s.spreadAppts.contains(appt1) && s.spreadAppts.contains(appt2)) != null;
  }

  bool inAnySpread(Appointment appt){
    return spreads.firstWhereOrNull((s) => s.spreadAppts.contains(appt)) != null;
  }

  int getSpreadCount(Appointment appt){
     var apptSpreads = spreads.where((s) => s.spreadAppts.contains(appt));
     return apptSpreads.fold(0,(count, spread) {
       //return spread.count + count;
       return max(spread.count, count);
     });
  }
  List<Spread> spreads = [];
}

class Spread {
  Appointment? appointment;
  int get count => spreadAppts.length;
  List<Appointment> spreadAppts = [];
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

  Offset offset = Offset.zero;
  int spreadCount = 1;
}
