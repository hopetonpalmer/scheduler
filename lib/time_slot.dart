import 'package:scheduler/extensions/date_extensions.dart';
import 'package:scheduler/scheduler.dart';

class TimeSlot {
  final DateTime startDate;
  final DateTime endDate;
  final CalendarViewType viewType;
  final List<TimeSlot>? timeSlots;
  final IntervalType intervalType;
  final double size;
  const TimeSlot(
      this.startDate, this.endDate, this.viewType, this.intervalType, this.size,
      {this.timeSlots});

  Duration get duration => startDate.duration(endDate);
}
