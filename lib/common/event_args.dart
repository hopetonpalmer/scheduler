import '../scheduler.dart';

abstract class EventArgs {
  final Object sender;
  EventArgs(this.sender);
}

class AppointmentSelectedEventArgs extends EventArgs {
  Appointment selected;
  AppointmentSelectedEventArgs(Object sender, this.selected) : super(sender);
}