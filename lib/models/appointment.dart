part of scheduler;

typedef AppointmentItemGenerator = List<AppointmentItem> Function(
    Appointment appointment, DateTime startDate, DateTime endDate);

class Appointment {
  late DateTime _startDate;
  DateTime get startDate => _startDate;

  late DateTime _endDate;
  DateTime get endDate => _endDate;

  String subject;
  Color? color;
  final List<AppointmentItem> appointmentItems = [];
  final List<AppointmentItem> appointmentItemsByDay = [];
  final List<AppointmentItem> appointmentItemsByWeek = [];
  final List<AppointmentItem> appointmentItemsByMonth = [];
  AppointmentGeometry geometry = AppointmentGeometry();
  Appointment(
    DateTime startDate,
    DateTime endDate,
    this.subject,
    {this.color = Colors.grey }
  ){
    color ?? Colors.grey;
    setDates(startDate, endDate);
  }

  Duration get duration {
    return endDate.difference(startDate);
  }

  setDates(DateTime start, DateTime end) {
    _startDate = start;
    _endDate = end;
    _generateItems();
  }

  _generateItems() {
    appointmentItems.clear();
    appointmentItemsByWeek.clear();
    appointmentItemsByMonth.clear();
    appointmentItemsByDay.clear();
    appointmentItems.addAll(AppointmentService().getSingleAppointmentItems(this));
    appointmentItemsByDay.addAll(AppointmentService().getAppointmentItemsByDay(this));
    appointmentItemsByWeek.addAll(AppointmentService().getAppointmentItemsByWeek(this));
    appointmentItemsByMonth.addAll(AppointmentService().getAppointmentItemsByMonth(this));
  }

}
