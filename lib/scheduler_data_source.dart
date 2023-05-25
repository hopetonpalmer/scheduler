part of scheduler;

class SchedulerDataSource extends ChangeNotifier implements ValueListenable<List<Appointment>> {

  late final List<Appointment> appointments;
  SchedulerDataSource({List<Appointment>? appointments}){
    this.appointments = appointments ?? <Appointment>[];
  }


  final DateRange _visibleDateRange = DateRange();
  DateRange get visibleDateRange {
     return _visibleDateRange;
  }

  setDateRange(DateTime start, DateTime end) {
    visibleDateRange.setRange(start, end);
    notifyListeners();
  }

  List<Appointment> get visibleAppointments {
    if (visibleDateRange.isEmpty) {
      return appointments;
    }

    return appointments.where((a) => visibleDateRange.inRange(a.startDate) ||
        visibleDateRange.inRange(a.endDate)).toList();
  }

  List<AppointmentItem> get visibleAppointmentItems {
    if (visibleDateRange.isEmpty){
      return visibleAppointments.fold<List<AppointmentItem>>([], (appointmentItems, appointment) {
        appointmentItems.addAll(appointment.appointmentItems);

        return appointmentItems;
      });
    }

    return visibleAppointments.fold<List<AppointmentItem>>([], (appointmentItems, appointment) {
      appointmentItems.addAll(appointment.appointmentItems.where((a) => visibleDateRange.inRange(a.startDate) ||
          visibleDateRange.inRange(a.endDate)));

      return appointmentItems;
    });
  }

  List<AppointmentItem> get visibleAppointmentItemsByDay {
    return getVisibleAppointmentItemsFrom((appointment) => appointment.appointmentItemsByDay);
  }

  List<AppointmentItem> get visibleAppointmentItemsByWeek {
    return getVisibleAppointmentItemsFrom((appointment) => appointment.appointmentItemsByWeek);
  }

  List<AppointmentItem> get visibleAppointmentItemsByMonth {
    return getVisibleAppointmentItemsFrom((appointment) => appointment.appointmentItemsByMonth);
  }

  List<AppointmentItem> getVisibleAppointmentItemsFrom(AppointmentItemListFunction getItems) {
    if (visibleDateRange.isEmpty){
      return visibleAppointments.fold<List<AppointmentItem>>([], (appointmentItems, appointment) {
        appointmentItems.addAll(getItems(appointment));

        return appointmentItems;
      });
    }

    return visibleAppointments.fold<List<AppointmentItem>>([], (appointmentItems, appointment) {
      appointmentItems.addAll(getItems(appointment).where((a) => visibleDateRange.inRange(a.startDate) ||
          visibleDateRange.inRange(a.endDate)));

      return appointmentItems;
    });
  }


  addAppointment(DateTime startDate, Duration duration, String subject, {Color color = const Color(0xff757575)}){
    Appointment appointment = Appointment(startDate.toLocalTime, startDate.toLocalTime.add(duration), subject, color: color);
    appointments.add(appointment);
    notifyListeners();
  }

  deleteAppointment(Appointment appointment) {
    appointments.remove(appointment);
    notifyListeners();
  }

  rescheduleAppointment(Appointment appointment, DateTime startDate, DateTime endDate) {
    appointment.setDates(startDate, endDate);
    notifyListeners();
  }

  updateListeners() {
    notifyListeners();
  }

  @override
  List<Appointment> get value => visibleAppointments;

}


