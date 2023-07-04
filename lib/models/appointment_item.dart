import 'dart:ui';

import 'package:scheduler/extensions/date_extensions.dart';
import 'package:scheduler/scheduler.dart';
import '../services/appointment_render_service.dart';

class AppointmentItem {
  final Appointment appointment;
  final DateTime startDate;
  final DateTime endDate;
  final AppointmentGeometry geometry = AppointmentGeometry();
  AppointmentItem(this.appointment, this.startDate, this.endDate);
  Duration get duration {
    return endDate.diffInDuration(startDate);
  }

  Rect get rect => geometry.rect;
  set rect(Rect value) {
    geometry.rect = value;
  }

  double get left => rect.left;
  set left(double value) {
    rect = Rect.fromLTWH(value, top, width, height);
  }

  double get top => rect.top;
  set top(double value) {
    rect = Rect.fromLTWH(left, value, width, height);
  }

  double get width => rect.width;
  set width(double value) {
    rect = Rect.fromLTWH(left, top, value, height);
  }

  double get height => rect.height;
  set height(double value) {
    rect = Rect.fromLTWH(left, top, width, value);
  }

  double get right => rect.right;
  set right(double value) {
    rect = Rect.fromLTWH(left, top, value-left, height);
  }
}

