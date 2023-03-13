import 'package:scheduler/scheduler.dart';
import 'package:scheduler/services/appointment_render_service.dart';

class AppointmentItem {
  final Appointment appointment;
  final DateTime startDate;
  final DateTime endDate;
  final AppointmentGeometry geometry = AppointmentGeometry();
  AppointmentItem(this.appointment, this.startDate, this.endDate);
  Duration get duration {
    return endDate.difference(startDate);
  }
}

