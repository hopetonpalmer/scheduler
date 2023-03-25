import 'package:dart_date/dart_date.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scheduler/extensions/date_extensions.dart';
import 'package:scheduler/models/appointment_item.dart';
import 'package:scheduler/scheduler.dart';
import 'package:scheduler/services/scheduler_service.dart';

import '../common/event_args.dart';

class AppointmentService with ChangeNotifier {
  static final AppointmentService instance = AppointmentService._internal();
  AppointmentService._internal();
  Appointment? _selectedAppointment;
  get selectedAppointment => _selectedAppointment;
  get dataSource => SchedulerService().scheduler.dataSource;

  final _appointmentSelectedSubject = BehaviorSubject<Appointment>();
  ValueStream<Appointment> get $appointmentSelected =>
      _appointmentSelectedSubject.stream;

  List<AppointmentItem> getAppointmentItemsByDay(Appointment appointment) {
    List<AppointmentItem> result = [];
    var start = appointment.startDate;
    var end = appointment.endDate;
    int dayCount = start.getDifferenceInCalendarDays(end);
    for (int i = 0; i <= dayCount; i++) {
      end = start.isSameDay(end) ? end : start.getEndOfDay();
      result.add(AppointmentItem(appointment, start, end));
      start = start.incDays(1).startOfDay;
      end = appointment.endDate;
    }
    return result;
  }

  List<AppointmentItem> getAppointmentItemsByWeek(Appointment appointment) {
    List<AppointmentItem> result = [];
    var start = appointment.startDate;
    var end = appointment.endDate;
    int weekCount = start.getDifferenceInCalendarWeeks(end);
    for (int i = 0; i <= weekCount; i++) {
      end = start.isSameWeek(end) ? end : start.endOfDay;
      result.add(AppointmentItem(appointment, start, end));
      start = start.incWeeks(1).startOfDay;
      end = appointment.endDate;
    }
    return result;
  }

  List<AppointmentItem> getAppointmentItemsByMonth(Appointment appointment) {
    List<AppointmentItem> result = [];
    var start = appointment.startDate;
    var end = appointment.endDate;
    int monthCount = start.getDifferenceInCalendarMonths(end);
    for (int i = 0; i <= monthCount; i++) {
      end = start.isSameMonth(end) ? end : start.endOfDay;
      result.add(AppointmentItem(appointment, start, end));
      start = start.incMonths(1).startOfDay;
      end = appointment.endDate;
    }
    return result;
  }

  List<AppointmentItem> getSingleAppointmentItems(Appointment appointment) {
    return [
      AppointmentItem(appointment, appointment.startDate, appointment.endDate)
    ];
  }

  selectAppointment(Appointment appointment) {
    if (_selectedAppointment != appointment) {
      _selectedAppointment = appointment;
      _appointmentSelectedSubject.add(appointment);
      //notifyListeners();
    }
  }

  void deleteSelectedAppointment() {
    if (selectedAppointment != null) {
      dataSource.deleteAppointment(selectedAppointment);
      notifyListeners();
    }
  }
}
