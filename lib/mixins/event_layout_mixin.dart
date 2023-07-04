import 'dart:ui';

import 'package:scheduler/extensions/date_extensions.dart';

import '../models/appointment_item.dart';

mixin EventLayoutMixin {
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

  List<AppointmentItem> overlappedRight(AppointmentItem appointmentItem, List<AppointmentItem> appointmentItems,{bool inclusive = false, Rect? rect}) {
    List<AppointmentItem> result = overlapped(appointmentItem, appointmentItems, inclusive: inclusive, rect: rect);
    result.sort((a, b) => a.left.compareTo(b.left));

    return result;
  }


  List<AppointmentItem> collidingEvents(AppointmentItem event, List<AppointmentItem> appointmentItems) {
    var result = appointmentItems.where((item) => item != event &&
        (item.startDate.isBetween(event.startDate, event.endDate) ||
         item.endDate.isBetween(event.startDate, event.endDate))).toList();

    return result;
  }

}