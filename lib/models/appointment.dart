part of scheduler;

typedef AppointmentItemGenerator = List<AppointmentItem> Function(
    Appointment appointment, DateTime startDate, DateTime endDate,);

class Appointment {
  late DateTime _startDate;
  DateTime get startDate => _startDate;

  late DateTime _endDate;
  DateTime get endDate => _endDate;

  final appointmentService = AppointmentService.instance;

  String subject;
  Color color;
  bool isAllDay;
  final List<AppointmentItem> appointmentItems = [];
  final List<AppointmentItem> appointmentItemsByDay = [];
  final List<AppointmentItem> appointmentItemsByWeek = [];
  final List<AppointmentItem> appointmentItemsByMonth = [];

  Appointment(
    DateTime startDate,
    DateTime endDate,
    this.subject,
    {
      this.color = Colors.grey,
      this.isAllDay = false,
    }
  ){
    setDates(startDate, endDate);
  }

  Duration get duration {
    return endDate.difference(startDate);
  }

  setDates(DateTime start, DateTime end) {
    if (start.isBefore(end)) {
      _startDate = start;
      _endDate = end;
      _generateAppointmentItems();
    }
  }

  _generateAppointmentItems() {
    appointmentItems.clear();
    appointmentItemsByWeek.clear();
    appointmentItemsByMonth.clear();
    appointmentItemsByDay.clear();
    appointmentItems.addAll(appointmentService.getSingleAppointmentItems(this));
    appointmentItemsByDay.addAll(appointmentService.getAppointmentItemsByDay(this));
    appointmentItemsByWeek.addAll(appointmentService.getAppointmentItemsByWeek(this));
    appointmentItemsByMonth.addAll(appointmentService.getAppointmentItemsByMonth(this));
  }

}
